import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../errors/app_failure.dart';
import 'file_reference.dart';

/// Version-one encrypted envelope. Bounded chunks receive independent AES-GCM
/// authentication tags; the footer detects truncation and wrong-file swaps.
class EncryptedFileStore implements SecureFileStore {
  EncryptedFileStore(
    this._vaultKey, {
    Uuid? uuid,
    Future<Directory> Function()? supportDirectory,
  }) : _uuid = uuid ?? const Uuid(),
       _supportDirectory = supportDirectory ?? getApplicationSupportDirectory;

  static const _magic = <int>[0x44, 0x56, 0x46, 0x31]; // DVF1
  static const _version = 1;
  static const _chunkSize = 64 * 1024;
  final SecretKey _vaultKey;
  final Uuid _uuid;
  final Future<Directory> Function() _supportDirectory;
  final Cipher _cipher = AesGcm.with256bits();

  Future<Directory> get vaultDirectory async {
    final support = await _supportDirectory();
    final root = Directory('${support.path}/vault');
    await root.create(recursive: true);
    return root;
  }

  Future<Directory> get documentsDirectory async {
    final documents = Directory('${(await vaultDirectory).path}/documents');
    await documents.create(recursive: true);
    return documents;
  }

  Future<Directory> get temporaryDirectory async {
    final temporary = Directory('${(await vaultDirectory).path}/temp');
    await temporary.create(recursive: true);
    return temporary;
  }

  @override
  Future<SecureFileReference> writeEncrypted({
    required String documentId,
    required Stream<List<int>> bytes,
    required String mimeType,
  }) async {
    if (!_isSafeSegment(documentId)) {
      throw const StorageFailure('Invalid document storage identifier.');
    }
    final id = _uuid.v4();
    final directory = Directory(
      '${(await documentsDirectory).path}/$documentId',
    );
    await directory.create(recursive: true);
    final finalFile = File('${directory.path}/$id.dvf');
    final pendingFile = File('${directory.path}/.$id.pending');
    var bytesWritten = 0;
    final hashSink = Sha256().toSync().newHashSink();
    RandomAccessFile? output;
    try {
      output = await pendingFile.open(mode: FileMode.write);
      await output.writeFrom(<int>[..._magic, _version, ..._u32(_chunkSize)]);
      await for (final input in bytes) {
        for (final chunk in _split(input, _chunkSize)) {
          final box = await _cipher.encrypt(chunk, secretKey: _vaultKey);
          await output.writeByte(1);
          await output.writeFrom(box.nonce);
          await output.writeFrom(_u32(box.cipherText.length));
          await output.writeFrom(box.cipherText);
          await output.writeFrom(box.mac.bytes);
          hashSink.add(chunk);
          bytesWritten += chunk.length;
        }
      }
      hashSink.close();
      final hash = await hashSink.hash();
      await output.writeByte(0);
      await output.writeFrom(_u64(bytesWritten));
      await output.writeFrom(hash.bytes);
      await output.flush();
      await output.close();
      output = null;
      await pendingFile.rename(finalFile.path);
      return SecureFileReference(
        id: id,
        encryptedRelativePath: '$documentId/$id.dvf',
        mimeType: mimeType,
        integrityHash: _hex(hash.bytes),
        sizeBytes: bytesWritten,
      );
    } on Object catch (error) {
      await output?.close();
      if (await pendingFile.exists()) await pendingFile.delete();
      throw StorageFailure(
        'Could not encrypt document in private storage.',
        cause: error,
      );
    }
  }

  @override
  Future<Stream<List<int>>> readDecrypted(SecureFileReference ref) async {
    _validateReference(ref);
    final file = File(
      '${(await documentsDirectory).path}/${ref.encryptedRelativePath}',
    );
    if (!await file.exists()) {
      throw const StorageFailure('Encrypted document file is unavailable.');
    }
    return _decrypt(file, ref);
  }

  Stream<List<int>> _decrypt(File file, SecureFileReference ref) async* {
    RandomAccessFile? input;
    try {
      input = await file.open();
      final header = await _readExactly(input, 9);
      if (!_sameBytes(header.sublist(0, 4), _magic) || header[4] != _version) {
        throw const FormatException('Unsupported encrypted file format.');
      }
      final declaredChunkSize = _readU32(header, 5);
      if (declaredChunkSize <= 0 || declaredChunkSize > 1024 * 1024) {
        throw const FormatException('Invalid encrypted file chunk size.');
      }
      var plainLength = 0;
      final hashSink = Sha256().toSync().newHashSink();
      while (true) {
        final marker = await _readExactly(input, 1);
        if (marker[0] == 0) break;
        if (marker[0] != 1) {
          throw const FormatException('Invalid encrypted record.');
        }
        final nonce = await _readExactly(input, 12);
        final cipherLength = _readU32(await _readExactly(input, 4), 0);
        if (cipherLength > declaredChunkSize) {
          throw const FormatException('Invalid encrypted chunk length.');
        }
        final ciphertext = await _readExactly(input, cipherLength);
        final mac = await _readExactly(input, 16);
        final plaintext = await _cipher.decrypt(
          SecretBox(ciphertext, nonce: nonce, mac: Mac(mac)),
          secretKey: _vaultKey,
        );
        plainLength += plaintext.length;
        hashSink.add(plaintext);
        yield plaintext;
      }
      final footerLength = _readU64(await _readExactly(input, 8), 0);
      final footerHash = await _readExactly(input, 32);
      if (await input.readByte() != -1) {
        throw const FormatException('Unexpected trailing data.');
      }
      hashSink.close();
      final computedHash = await hashSink.hash();
      if (plainLength != footerLength ||
          plainLength != ref.sizeBytes ||
          !_sameBytes(computedHash.bytes, footerHash) ||
          _hex(computedHash.bytes) != ref.integrityHash) {
        throw const FormatException('Encrypted file integrity mismatch.');
      }
    } on Object catch (error) {
      throw StorageFailure(
        'Encrypted document integrity check failed.',
        cause: error,
      );
    } finally {
      await input?.close();
    }
  }

  /// Materializes plaintext only in a private, short-lived workspace. Prefer
  /// [readDecrypted] unless a platform API specifically requires a file path.
  Future<T> withDecryptedTemporaryFile<T>(
    SecureFileReference ref,
    Future<T> Function(File file) action,
  ) async {
    final workspace = await Directory((await temporaryDirectory).path)
        .createTemp('view-');
    final temporaryFile = File('${workspace.path}/${_uuid.v4()}.bin');
    try {
      final sink = temporaryFile.openWrite(mode: FileMode.writeOnly);
      await for (final chunk in await readDecrypted(ref)) {
        sink.add(chunk);
      }
      await sink.close();
      return await action(temporaryFile);
    } finally {
      if (await workspace.exists()) await workspace.delete(recursive: true);
    }
  }

  @override
  Future<void> delete(SecureFileReference ref) async {
    _validateReference(ref);
    await deleteRelativePath(ref.encryptedRelativePath);
  }

  Future<void> deleteRelativePath(String relativePath) async {
    _validateRelativePath(relativePath);
    final file = File('${(await documentsDirectory).path}/$relativePath');
    if (await file.exists()) await file.delete();
  }

  static Iterable<List<int>> _split(List<int> bytes, int length) sync* {
    for (var offset = 0; offset < bytes.length; offset += length) {
      final end = offset + length > bytes.length
          ? bytes.length
          : offset + length;
      yield bytes.sublist(offset, end);
    }
  }

  static Future<Uint8List> _readExactly(
    RandomAccessFile input,
    int length,
  ) async {
    final value = await input.read(length);
    if (value.length != length) {
      throw const FormatException('Unexpected end of encrypted file.');
    }
    return Uint8List.fromList(value);
  }

  static List<int> _u32(int value) =>
      (ByteData(4)..setUint32(0, value, Endian.big)).buffer.asUint8List();
  static List<int> _u64(int value) =>
      (ByteData(8)..setUint64(0, value, Endian.big)).buffer.asUint8List();
  static int _readU32(List<int> bytes, int offset) =>
      ByteData.sublistView(Uint8List.fromList(bytes))
          .getUint32(offset, Endian.big);
  static int _readU64(List<int> bytes, int offset) =>
      ByteData.sublistView(Uint8List.fromList(bytes))
          .getUint64(offset, Endian.big);
  static bool _sameBytes(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var difference = 0;
    for (var i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }
    return difference == 0;
  }

  static String _hex(List<int> bytes) =>
      bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  static bool _isSafeSegment(String value) =>
      RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value);
  static void _validateRelativePath(String path) {
    final parts = path.split('/');
    if (parts.length != 2 ||
        !_isSafeSegment(parts[0]) ||
        !RegExp(r'^[a-zA-Z0-9_-]+\.dvf$').hasMatch(parts[1])) {
      throw const StorageFailure('Invalid encrypted storage path.');
    }
  }

  static void _validateReference(SecureFileReference ref) {
    _validateRelativePath(ref.encryptedRelativePath);
    if (ref.encryptionVersion != _version ||
        ref.sizeBytes < 0 ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(ref.integrityHash)) {
      throw const StorageFailure('Invalid encrypted file reference.');
    }
  }
}

/// Removes abandoned temporary workspaces and unreferenced encrypted files.
class EncryptedStorageCleanupManager {
  EncryptedStorageCleanupManager(this._store);
  final EncryptedFileStore _store;

  Future<void> cleanTemporaryWorkspace() async {
    final temp = await _store.temporaryDirectory;
    await for (final entity in temp.list()) {
      await entity.delete(recursive: true);
    }
  }

  Future<int> removeOrphanedEncryptedFiles(
    Iterable<String> referencedPaths,
  ) async {
    final referenced = referencedPaths.toSet();
    final root = await _store.documentsDirectory;
    var removed = 0;
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.dvf')) continue;
      final relative = entity.path.substring(root.path.length + 1);
      if (!referenced.contains(relative)) {
        await entity.delete();
        removed++;
      }
    }
    return removed;
  }
}
