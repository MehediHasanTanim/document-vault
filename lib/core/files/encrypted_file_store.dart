import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../errors/app_failure.dart';
import 'file_reference.dart';

/// Private, authenticated file storage. Callers provide the unlocked vault key;
/// plaintext is never written outside the process-private temporary buffer.
class EncryptedFileStore implements SecureFileStore {
  EncryptedFileStore(this._vaultKey, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();
  final SecretKey _vaultKey;
  final Uuid _uuid;
  final _cipher = AesGcm.with256bits();
  Future<Directory> _root() async {
    final d = await getApplicationSupportDirectory();
    return Directory('${d.path}/vault/documents');
  }

  @override
  Future<SecureFileReference> writeEncrypted({
    required String documentId,
    required Stream<List<int>> bytes,
    required String mimeType,
  }) async {
    final plain = await bytes.expand((e) => e).toList();
    final box = await _cipher.encrypt(plain, secretKey: _vaultKey);
    final id = _uuid.v4();
    final dir = Directory('${(await _root()).path}/$documentId');
    await dir.create(recursive: true);
    final file = File('${dir.path}/$id.enc');
    await file.writeAsBytes(
      utf8.encode(
        jsonEncode({
          'v': 1,
          'n': base64Encode(box.nonce),
          'c': base64Encode(box.cipherText),
          'm': base64Encode(box.mac.bytes),
        }),
      ),
      flush: true,
    );
    return SecureFileReference(
      id: id,
      encryptedRelativePath: '$documentId/$id.enc',
      mimeType: mimeType,
    );
  }

  @override
  Future<Stream<List<int>>> readDecrypted(SecureFileReference ref) async {
    try {
      final map = jsonDecode(
        await File('${(await _root()).path}/${ref.encryptedRelativePath}')
            .readAsString(),
      ) as Map;
      final box = SecretBox(
        base64Decode(map['c'] as String),
        nonce: base64Decode(map['n'] as String),
        mac: Mac(base64Decode(map['m'] as String)),
      );
      return Stream.value(await _cipher.decrypt(box, secretKey: _vaultKey));
    } on Object catch (e) {
      throw StorageFailure(
        'Encrypted document integrity check failed.',
        cause: e,
      );
    }
  }

  @override
  Future<void> delete(SecureFileReference ref) async {
    final file = File('${(await _root()).path}/${ref.encryptedRelativePath}');
    if (await file.exists()) await file.delete();
  }
}
