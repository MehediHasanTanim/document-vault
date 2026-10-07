import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/helpers.dart' show randomBytes;
import 'package:uuid/uuid.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../backup/application/backup_models.dart';
import '../export/secure_export_models.dart';
import '../export/secure_export_service.dart';

enum EmergencyExportEncryption { none, passwordProtected }

/// A caller must choose the protection mode explicitly. Passwords use the
/// existing portable-backup validation rules and are never retained here.
class EmergencyExportProtection {
  const EmergencyExportProtection.unencrypted({
    required this.acknowledgedUnencryptedRisk,
  }) : password = null;
  const EmergencyExportProtection.password(this.password)
    : acknowledgedUnencryptedRisk = false;

  final BackupPassword? password;
  final bool acknowledgedUnencryptedRisk;
  EmergencyExportEncryption get mode => password == null
      ? EmergencyExportEncryption.none
      : EmergencyExportEncryption.passwordProtected;
}

class EmergencyExportDocument {
  EmergencyExportDocument({required this.documentId, required this.export})
    : assert(documentId == export.documentId);

  final String documentId;
  final SecureExportRequest export;
}

class EmergencyExportRequest {
  const EmergencyExportRequest({
    required this.documents,
    required this.protection,
  });

  final List<EmergencyExportDocument> documents;
  final EmergencyExportProtection protection;
}

/// Prepares selected pages through the existing flattening/redaction pipeline,
/// then either hands off those short-lived images or puts them in a
/// password-protected package. No source document is ever exported directly.
class EmergencyExportService {
  EmergencyExportService(
    this._exports,
    this._destination, {
    required this.workspaceDirectory,
    EmergencyPackageCodec? packages,
    Uuid? uuid,
  }) : _packages = packages ?? EmergencyPackageCodec(),
       _uuid = uuid ?? const Uuid();

  final SecureExportService _exports;
  final SecureShareDestination _destination;
  final Future<Directory> Function() workspaceDirectory;
  final EmergencyPackageCodec _packages;
  final Uuid _uuid;

  Future<bool> export(EmergencyExportRequest request) async {
    _validate(request);
    final prepared = <PreparedSecureExport>[];
    Directory? packageWorkspace;
    try {
      for (final document in request.documents) {
        prepared.add(await _exports.prepare(document.export));
      }
      final files = prepared.expand((value) => value.files).toList();
      if (request.protection.mode == EmergencyExportEncryption.none) {
        return await _destination.share(files: files, mimeType: 'image/jpeg');
      }

      packageWorkspace = await workspaceDirectory();
      await packageWorkspace.create(recursive: true);
      final workspace = await packageWorkspace.createTemp('emergency-pack-');
      packageWorkspace = workspace;
      final destination = File('${workspace.path}/${_uuid.v4()}.dvep');
      await _packages.create(
        files: files,
        password: request.protection.password!,
        destination: destination,
      );
      await _packages.verify(
        file: destination,
        password: request.protection.password!,
      );
      return await _destination.share(
        files: [destination],
        mimeType: 'application/octet-stream',
      );
    } finally {
      for (final export in prepared) {
        await export.dispose();
      }
      if (packageWorkspace != null && await packageWorkspace.exists()) {
        await packageWorkspace.delete(recursive: true);
      }
    }
  }

  void _validate(EmergencyExportRequest request) {
    if (request.documents.isEmpty) {
      throw const ValidationFailure(
        'Choose at least one emergency document. / অন্তত একটি জরুরি নথি বেছে নিন।',
      );
    }
    final ids = request.documents.map((value) => value.documentId).toSet();
    if (ids.length != request.documents.length || ids.any((id) => id.isEmpty)) {
      throw const ValidationFailure(
        'Choose each emergency document only once. / প্রতিটি জরুরি নথি একবারই বেছে নিন।',
      );
    }
    if (request.protection.mode == EmergencyExportEncryption.none &&
        !request.protection.acknowledgedUnencryptedRisk) {
      throw const ValidationFailure(
        'Confirm that an unencrypted emergency export can be read outside the vault. / নিশ্চিত করুন যে এনক্রিপশনবিহীন জরুরি রপ্তানি ভল্টের বাইরে পড়া যাবে।',
      );
    }
  }
}

class EmergencyPackageVerification {
  const EmergencyPackageVerification({required this.sizeBytes});
  final int sizeBytes;
}

/// A small, distinct streaming envelope for emergency packages. Its magic is
/// deliberately not a vault-backup magic: an emergency package cannot be used
/// to restore or replace a vault. Entries have opaque names and contain only
/// flattened export images.
class EmergencyPackageCodec {
  EmergencyPackageCodec({
    Cipher? cipher,
    this.kdf = const BackupKdfParameters(),
  }) : _cipher = cipher ?? AesGcm.with256bits();

  static const _magic = <int>[0x44, 0x56, 0x45, 0x50]; // DVEP
  static const _chunkSize = 64 * 1024;
  final Cipher _cipher;
  final BackupKdfParameters kdf;

  Future<void> create({
    required List<File> files,
    required BackupPassword password,
    required File destination,
  }) async {
    IOSink? sink;
    try {
      if (files.isEmpty || files.any((file) => !file.existsSync())) {
        throw const ValidationFailure(
          'Emergency export files are unavailable.',
        );
      }
      final header = _EmergencyHeader(salt: randomBytes(16), kdf: kdf);
      final headerBytes = utf8.encode(jsonEncode(header.toJson()));
      final key = await _deriveKey(password, header);
      await destination.parent.create(recursive: true);
      sink = destination.openWrite(mode: FileMode.writeOnly);
      sink.add(_magic);
      sink.add(_u32(headerBytes.length));
      sink.add(headerBytes);
      final writer = _EmergencyChunkWriter(sink, _cipher, key, headerBytes);
      for (var index = 0; index < files.length; index++) {
        final file = files[index];
        final name = 'items/${index.toString().padLeft(4, '0')}.jpg';
        await writer.add(_u16(utf8.encode(name).length));
        await writer.add(utf8.encode(name));
        await writer.add(_u64(await file.length()));
        await for (final bytes in file.openRead()) {
          await writer.add(bytes);
        }
      }
      await writer.close();
      sink.add(_u32(0));
      await sink.flush();
    } on AppFailure {
      rethrow;
    } on Object catch (error) {
      throw StorageFailure(
        'Could not create the encrypted emergency pack.',
        cause: error,
      );
    } finally {
      await sink?.close();
    }
  }

  Future<EmergencyPackageVerification> verify({
    required File file,
    required BackupPassword password,
  }) async {
    RandomAccessFile? input;
    try {
      input = await file.open(mode: FileMode.read);
      final header = await _readHeader(input);
      final key = await _deriveKey(password, header.header);
      await for (final _ in _decryptChunks(input, key, header.bytes)) {}
      return EmergencyPackageVerification(sizeBytes: await file.length());
    } on AppFailure {
      rethrow;
    } on Object catch (error) {
      throw StorageFailure(
        'Emergency export password is incorrect or package is damaged.',
        cause: error,
      );
    } finally {
      await input?.close();
    }
  }

  Future<_EmergencyEnvelopeHeader> _readHeader(RandomAccessFile input) async {
    final magic = await _readExactly(input, _magic.length);
    if (!_same(magic, _magic)) throw const FormatException('Invalid package.');
    final length = _readU32(await _readExactly(input, 4));
    if (length <= 0 || length > 16 * 1024) {
      throw const FormatException('Invalid package header.');
    }
    final bytes = await _readExactly(input, length);
    return _EmergencyEnvelopeHeader(
      _EmergencyHeader.fromJson(jsonDecode(utf8.decode(bytes)) as Map),
      bytes,
    );
  }

  Stream<List<int>> _decryptChunks(
    RandomAccessFile input,
    SecretKey key,
    List<int> header,
  ) async* {
    var index = 0;
    while (true) {
      final length = _readU32(await _readExactly(input, 4));
      if (length == 0) {
        if (await input.readByte() != -1) {
          throw const FormatException('Trailing data.');
        }
        return;
      }
      if (length > _chunkSize) throw const FormatException('Invalid chunk.');
      final nonce = await _readExactly(input, 12);
      final ciphertext = await _readExactly(input, length);
      final mac = await _readExactly(input, 16);
      yield await _cipher.decrypt(
        SecretBox(ciphertext, nonce: nonce, mac: Mac(mac)),
        secretKey: key,
        aad: [...header, ..._u64(index++)],
      );
    }
  }

  Future<SecretKey> _deriveKey(
    BackupPassword password,
    _EmergencyHeader header,
  ) => Pbkdf2.hmacSha256(
    iterations: header.kdf.iterations,
    bits: header.kdf.bits,
  ).deriveKeyFromPassword(password: password.value, nonce: header.salt);

  static Future<List<int>> _readExactly(
    RandomAccessFile input,
    int length,
  ) async {
    final value = await input.read(length);
    if (value.length != length) throw const FormatException('Unexpected end.');
    return value;
  }

  static List<int> _u16(int value) =>
      (ByteData(2)..setUint16(0, value, Endian.big)).buffer.asUint8List();
  static List<int> _u32(int value) =>
      (ByteData(4)..setUint32(0, value, Endian.big)).buffer.asUint8List();
  static List<int> _u64(int value) =>
      (ByteData(8)..setUint64(0, value, Endian.big)).buffer.asUint8List();
  static int _readU32(List<int> value) =>
      ByteData.sublistView(Uint8List.fromList(value)).getUint32(0, Endian.big);
  static bool _same(List<int> left, List<int> right) =>
      left.length == right.length &&
      List.generate(
        left.length,
        (index) => left[index] == right[index],
      ).every((same) => same);
}

/// Removes only abandoned password-encrypted emergency-pack workspaces after
/// process death. The secure-export cleanup owns its own flattened-image
/// workspaces; this class never deletes originals or viewer data.
class EmergencyExportWorkspaceCleanup {
  const EmergencyExportWorkspaceCleanup(this._root);
  final Future<Directory> Function() _root;

  Future<int> cleanAbandoned() async {
    final root = await _root();
    if (!await root.exists()) return 0;
    var removed = 0;
    await for (final entity in root.list()) {
      final name = entity.uri.pathSegments
          .where((segment) => segment.isNotEmpty)
          .last;
      if (entity is Directory && name.startsWith('emergency-pack-')) {
        await entity.delete(recursive: true);
        removed++;
      }
    }
    return removed;
  }
}

class _EmergencyHeader {
  const _EmergencyHeader({required this.salt, required this.kdf});
  final List<int> salt;
  final BackupKdfParameters kdf;

  Map<String, Object> toJson() => {
    'formatVersion': 1,
    'encryptionVersion': 1,
    'salt': base64Encode(salt),
    'kdf': kdf.toJson(),
    'chunkSize': EmergencyPackageCodec._chunkSize,
  };

  factory _EmergencyHeader.fromJson(Map value) {
    if (value['formatVersion'] != 1 ||
        value['encryptionVersion'] != 1 ||
        value['chunkSize'] != EmergencyPackageCodec._chunkSize) {
      throw const FormatException('Unsupported package.');
    }
    final salt = base64Decode(value['salt'] as String);
    if (salt.length != 16) throw const FormatException('Invalid salt.');
    return _EmergencyHeader(
      salt: salt,
      kdf: BackupKdfParameters.fromJson(
        Map<String, dynamic>.from(value['kdf'] as Map),
      ),
    );
  }
}

class _EmergencyEnvelopeHeader {
  const _EmergencyEnvelopeHeader(this.header, this.bytes);
  final _EmergencyHeader header;
  final List<int> bytes;
}

class _EmergencyChunkWriter {
  _EmergencyChunkWriter(this._sink, this._cipher, this._key, this._header);
  final IOSink _sink;
  final Cipher _cipher;
  final SecretKey _key;
  final List<int> _header;
  final _pending = BytesBuilder(copy: false);
  var _index = 0;

  Future<void> add(List<int> bytes) async {
    _pending.add(bytes);
    while (_pending.length >= EmergencyPackageCodec._chunkSize) {
      final all = _pending.takeBytes();
      await _write(all.sublist(0, EmergencyPackageCodec._chunkSize));
      _pending.add(all.sublist(EmergencyPackageCodec._chunkSize));
    }
  }

  Future<void> close() async {
    if (_pending.isNotEmpty) await _write(_pending.takeBytes());
  }

  Future<void> _write(List<int> plaintext) async {
    final box = await _cipher.encrypt(
      plaintext,
      secretKey: _key,
      nonce: randomBytes(12),
      aad: [..._header, ...EmergencyPackageCodec._u64(_index++)],
    );
    _sink.add(EmergencyPackageCodec._u32(plaintext.length));
    _sink.add(box.nonce);
    _sink.add(box.cipherText);
    _sink.add(box.mac.bytes);
  }
}
