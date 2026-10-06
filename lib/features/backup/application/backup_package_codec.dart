import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/helpers.dart' show randomBytes;

import '../../../../core/errors/app_failure.dart';
import 'backup_models.dart';

/// Streaming v1 portable envelope:
/// `[DVBK][header length][public versioned header][AEAD chunks][end marker]`.
/// The public header deliberately contains only KDF and format data. It is
/// included as associated authenticated data for every encrypted chunk.
class BackupPackageCodec {
  BackupPackageCodec({this.kdf = const BackupKdfParameters(), Cipher? cipher})
    : _cipher = cipher ?? AesGcm.with256bits();

  static const _magic = <int>[0x44, 0x56, 0x42, 0x4b]; // DVBK
  final BackupKdfParameters kdf;
  final Cipher _cipher;

  Future<BackupVerificationResult> create({
    required BackupSnapshot snapshot,
    required BackupPassword password,
    required File destination,
    required DateTime createdAt,
  }) async {
    try {
      _validateSnapshot(snapshot);
      final manifest = await _buildManifest(snapshot, createdAt);
      final header = BackupPackageHeader(salt: randomBytes(16), kdf: kdf);
      final headerBytes = utf8.encode(jsonEncode(header.toJson()));
      final key = await _deriveKey(password, header);
      final parent = destination.parent;
      await parent.create(recursive: true);
      final sink = destination.openWrite(mode: FileMode.writeOnly);
      try {
        sink.add(_magic);
        sink.add(_u32(headerBytes.length));
        sink.add(headerBytes);
        final writer = _EncryptedChunkWriter(
          sink,
          _cipher,
          key,
          headerBytes,
          header.chunkSize,
        );
        await _writeEntry(
          writer,
          BackupInput(
            id: 'manifest.json',
            byteLength: utf8.encode(jsonEncode(manifest.toJson())).length,
            open: () async =>
                Stream.value(utf8.encode(jsonEncode(manifest.toJson()))),
          ),
          expected: null,
        );
        await _writeEntry(
          writer,
          snapshot.database,
          expected: manifest.database,
        );
        for (var index = 0; index < snapshot.files.length; index++) {
          await _writeEntry(
            writer,
            snapshot.files[index],
            expected: manifest.files[index],
          );
        }
        await writer.close();
        sink.add(_u32(0));
        await sink.flush();
      } finally {
        await sink.close();
      }
      return await verify(file: destination, password: password);
    } on BackupFailure {
      rethrow;
    } on Object catch (error) {
      throw BackupFailure('Could not create encrypted backup.', cause: error);
    }
  }

  Future<BackupVerificationResult> verify({
    required File file,
    required BackupPassword password,
  }) async {
    RandomAccessFile? input;
    try {
      input = await file.open(mode: FileMode.read);
      final magic = await _readExactly(input, _magic.length);
      if (!_same(magic, _magic)) {
        throw const BackupFailure('Backup is unsupported or damaged.');
      }
      final headerLength = _readU32(await _readExactly(input, 4));
      if (headerLength <= 0 || headerLength > 16 * 1024) {
        throw const BackupFailure('Backup is unsupported or damaged.');
      }
      final headerBytes = await _readExactly(input, headerLength);
      final header = BackupPackageHeader.fromJson(
        jsonDecode(utf8.decode(headerBytes)) as Map<String, dynamic>,
      );
      final key = await _deriveKey(password, header);
      final reader = _StreamByteReader(_decryptChunks(input, key, headerBytes));
      final manifestHeader = await _readEntryHeader(reader);
      if (manifestHeader.id != 'manifest.json' ||
          manifestHeader.sizeBytes > 1024 * 1024) {
        throw const BackupFailure('Backup is unsupported or damaged.');
      }
      final manifestBytes = await reader.readExactly(manifestHeader.sizeBytes);
      final manifest = BackupManifest.fromJson(
        jsonDecode(utf8.decode(manifestBytes)) as Map<String, dynamic>,
      );
      await _verifyEntry(reader, manifest.database);
      for (final entry in manifest.files) {
        await _verifyEntry(reader, entry);
      }
      if (!await reader.isAtEnd()) {
        throw const BackupFailure('Backup is unsupported or damaged.');
      }
      return BackupVerificationResult(
        manifest: manifest,
        sizeBytes: await file.length(),
      );
    } on BackupFailure {
      rethrow;
    } on Object catch (error) {
      // Wrong passwords, corruption, and invalid framing intentionally share a
      // privacy-safe public error message.
      throw BackupFailure(
        'Backup password is incorrect or backup is damaged.',
        cause: error,
      );
    } finally {
      await input?.close();
    }
  }

  Future<BackupManifest> _buildManifest(
    BackupSnapshot snapshot,
    DateTime createdAt,
  ) async => BackupManifest(
    createdAt: createdAt.toUtc(),
    database: await _fingerprint(snapshot.database),
    files: await Future.wait(snapshot.files.map(_fingerprint)),
  );

  Future<BackupManifestEntry> _fingerprint(BackupInput input) async {
    final sink = Sha256().toSync().newHashSink();
    var length = 0;
    await for (final bytes in await input.open()) {
      sink.add(bytes);
      length += bytes.length;
    }
    sink.close();
    if (length != input.byteLength) {
      throw const BackupFailure(
        'Vault changed while preparing backup. Try again.',
      );
    }
    return BackupManifestEntry(
      id: input.id,
      sizeBytes: length,
      sha256: _hex((await sink.hash()).bytes),
    );
  }

  Future<void> _writeEntry(
    _EncryptedChunkWriter writer,
    BackupInput input, {
    required BackupManifestEntry? expected,
  }) async {
    final idBytes = utf8.encode(input.id);
    if (idBytes.length > 1024) {
      throw const BackupFailure('Backup input is invalid.');
    }
    await writer.add(_u16(idBytes.length));
    await writer.add(idBytes);
    await writer.add(_u64(input.byteLength));
    final hashSink = Sha256().toSync().newHashSink();
    var copied = 0;
    await for (final bytes in await input.open()) {
      hashSink.add(bytes);
      copied += bytes.length;
      await writer.add(bytes);
    }
    hashSink.close();
    if (copied != input.byteLength ||
        (expected != null &&
            (expected.id != input.id ||
                expected.sizeBytes != copied ||
                expected.sha256 != _hex((await hashSink.hash()).bytes)))) {
      throw const BackupFailure(
        'Vault changed while creating backup. Try again.',
      );
    }
  }

  Future<void> _verifyEntry(
    _StreamByteReader reader,
    BackupManifestEntry expected,
  ) async {
    final header = await _readEntryHeader(reader);
    if (header.id != expected.id || header.sizeBytes != expected.sizeBytes) {
      throw const BackupFailure('Backup is unsupported or damaged.');
    }
    final hashSink = Sha256().toSync().newHashSink();
    var remaining = header.sizeBytes;
    while (remaining > 0) {
      final bytes = await reader.readUpTo(
        remaining > 64 * 1024 ? 64 * 1024 : remaining,
      );
      hashSink.add(bytes);
      remaining -= bytes.length;
    }
    hashSink.close();
    if (_hex((await hashSink.hash()).bytes) != expected.sha256) {
      throw const BackupFailure('Backup is unsupported or damaged.');
    }
  }

  Stream<List<int>> _decryptChunks(
    RandomAccessFile input,
    SecretKey key,
    List<int> headerBytes,
  ) async* {
    var index = 0;
    while (true) {
      final plainLength = _readU32(await _readExactly(input, 4));
      if (plainLength == 0) {
        if (await input.readByte() != -1) {
          throw const BackupFailure('Backup is unsupported or damaged.');
        }
        return;
      }
      if (plainLength > 1024 * 1024) {
        throw const BackupFailure('Backup is unsupported or damaged.');
      }
      final nonce = await _readExactly(input, 12);
      final ciphertext = await _readExactly(input, plainLength);
      final mac = await _readExactly(input, 16);
      final plaintext = await _cipher.decrypt(
        SecretBox(ciphertext, nonce: nonce, mac: Mac(mac)),
        secretKey: key,
        aad: [...headerBytes, ..._u64(index)],
      );
      yield plaintext;
      index++;
    }
  }

  Future<SecretKey> _deriveKey(
    BackupPassword password,
    BackupPackageHeader header,
  ) => Pbkdf2.hmacSha256(
    iterations: header.kdf.iterations,
    bits: header.kdf.bits,
  ).deriveKeyFromPassword(password: password.value, nonce: header.salt);

  void _validateSnapshot(BackupSnapshot snapshot) {
    _validateInput(snapshot.database);
    final ids = <String>{snapshot.database.id};
    for (final file in snapshot.files) {
      _validateInput(file);
      if (!ids.add(file.id)) {
        throw const BackupFailure('Backup input contains duplicate files.');
      }
    }
  }

  void _validateInput(BackupInput input) {
    if (input.byteLength < 0 ||
        input.id.isEmpty ||
        input.id.length > 1024 ||
        input.id.contains('..') ||
        !RegExp(r'^[A-Za-z0-9_.\-/]+$').hasMatch(input.id)) {
      throw const BackupFailure('Backup input is invalid.');
    }
  }

  static Future<_EntryHeader> _readEntryHeader(_StreamByteReader reader) async {
    final idLength = _readU16(await reader.readExactly(2));
    if (idLength <= 0 || idLength > 1024) {
      throw const BackupFailure('Backup is unsupported or damaged.');
    }
    final id = utf8.decode(await reader.readExactly(idLength));
    final size = _readU64(await reader.readExactly(8));
    if (id.contains('..') || !RegExp(r'^[A-Za-z0-9_.\-/]+$').hasMatch(id)) {
      throw const BackupFailure('Backup is unsupported or damaged.');
    }
    return _EntryHeader(id, size);
  }

  static Future<List<int>> _readExactly(
    RandomAccessFile input,
    int length,
  ) async {
    final bytes = await input.read(length);
    if (bytes.length != length) {
      throw const BackupFailure('Backup is unsupported or damaged.');
    }
    return bytes;
  }

  static List<int> _u16(int value) =>
      (ByteData(2)..setUint16(0, value, Endian.big)).buffer.asUint8List();
  static List<int> _u32(int value) =>
      (ByteData(4)..setUint32(0, value, Endian.big)).buffer.asUint8List();
  static List<int> _u64(int value) =>
      (ByteData(8)..setUint64(0, value, Endian.big)).buffer.asUint8List();
  static int _readU16(List<int> bytes) =>
      ByteData.sublistView(Uint8List.fromList(bytes)).getUint16(0, Endian.big);
  static int _readU32(List<int> bytes) =>
      ByteData.sublistView(Uint8List.fromList(bytes)).getUint32(0, Endian.big);
  static int _readU64(List<int> bytes) =>
      ByteData.sublistView(Uint8List.fromList(bytes)).getUint64(0, Endian.big);
  static bool _same(List<int> left, List<int> right) {
    if (left.length != right.length) return false;
    var different = 0;
    for (var index = 0; index < left.length; index++) {
      different |= left[index] ^ right[index];
    }
    return different == 0;
  }

  static String _hex(List<int> bytes) =>
      bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
}

class _EncryptedChunkWriter {
  _EncryptedChunkWriter(
    this._sink,
    this._cipher,
    this._key,
    this._header,
    this._chunkSize,
  );
  final IOSink _sink;
  final Cipher _cipher;
  final SecretKey _key;
  final List<int> _header;
  final int _chunkSize;
  final BytesBuilder _buffer = BytesBuilder(copy: false);
  var _index = 0;

  Future<void> add(List<int> bytes) async {
    _buffer.add(bytes);
    while (_buffer.length >= _chunkSize) {
      final all = _buffer.takeBytes();
      await _write(all.sublist(0, _chunkSize));
      if (all.length > _chunkSize) {
        _buffer.add(all.sublist(_chunkSize));
      }
    }
  }

  Future<void> close() async {
    if (_buffer.length > 0) await _write(_buffer.takeBytes());
  }

  Future<void> _write(List<int> plaintext) async {
    final box = await _cipher.encrypt(
      plaintext,
      secretKey: _key,
      aad: [..._header, ...BackupPackageCodec._u64(_index)],
    );
    _sink.add(BackupPackageCodec._u32(plaintext.length));
    _sink.add(box.nonce);
    _sink.add(box.cipherText);
    _sink.add(box.mac.bytes);
    _index++;
  }
}

class _StreamByteReader {
  _StreamByteReader(Stream<List<int>> stream)
    : _iterator = StreamIterator(stream);
  final StreamIterator<List<int>> _iterator;
  List<int> _current = const [];
  var _offset = 0;
  var _ended = false;

  Future<List<int>> readExactly(int length) async {
    final bytes = BytesBuilder(copy: false);
    while (bytes.length < length) {
      bytes.add(await readUpTo(length - bytes.length));
    }
    return bytes.takeBytes();
  }

  Future<List<int>> readUpTo(int maximum) async {
    if (maximum <= 0) return const [];
    if (_offset == _current.length && !await _advance()) {
      throw const BackupFailure('Backup is unsupported or damaged.');
    }
    final count = maximum < _current.length - _offset
        ? maximum
        : _current.length - _offset;
    final value = _current.sublist(_offset, _offset + count);
    _offset += count;
    return value;
  }

  Future<bool> isAtEnd() async {
    if (_offset < _current.length) return false;
    return !await _advance();
  }

  Future<bool> _advance() async {
    if (_ended) return false;
    while (await _iterator.moveNext()) {
      final next = _iterator.current;
      if (next.isNotEmpty) {
        _current = next;
        _offset = 0;
        return true;
      }
    }
    _ended = true;
    return false;
  }
}

class _EntryHeader {
  const _EntryHeader(this.id, this.sizeBytes);
  final String id;
  final int sizeBytes;
}
