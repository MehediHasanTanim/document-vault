import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:documentvault/core/errors/app_failure.dart';
import 'package:documentvault/core/files/encrypted_file_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;
  late EncryptedFileStore store;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('document-vault-test-');
    store = EncryptedFileStore(
      SecretKey(List<int>.generate(32, (index) => index)),
      supportDirectory: () async => root,
    );
  });
  tearDown(() => root.delete(recursive: true));

  test('encrypts and streams the original bytes from private generated storage', () async {
    final reference = await store.writeEncrypted(
      documentId: 'document-1',
      mimeType: 'application/pdf',
      bytes: Stream.fromIterable([List<int>.generate(130000, (i) => i % 251)]),
    );
    final encrypted = File(
      '${(await store.documentsDirectory).path}/${reference.encryptedRelativePath}',
    );
    expect(encrypted.path, isNot(contains('application')));
    expect(
      (await encrypted.readAsBytes()).take(4),
      orderedEquals([68, 86, 70, 49]),
    );

    final restored = <int>[];
    await for (final chunk in await store.readDecrypted(reference)) {
      restored.addAll(chunk);
    }
    expect(restored, List<int>.generate(130000, (i) => i % 251));
  });

  test('rejects a tampered encrypted document', () async {
    final reference = await store.writeEncrypted(
      documentId: 'document-1',
      mimeType: 'image/jpeg',
      bytes: Stream.value([1, 2, 3, 4]),
    );
    final encrypted = File(
      '${(await store.documentsDirectory).path}/${reference.encryptedRelativePath}',
    );
    final bytes = await encrypted.readAsBytes();
    bytes[20] ^= 0x01;
    await encrypted.writeAsBytes(bytes, flush: true);

    expect(() async {
      await for (final _ in await store.readDecrypted(reference)) {}
    }, throwsA(isA<StorageFailure>()));
  });

  test('cleanup removes only unreferenced encrypted files and all viewer workspace files', () async {
    final retained = await store.writeEncrypted(
      documentId: 'document-1',
      mimeType: 'image/jpeg',
      bytes: Stream.value([1]),
    );
    await store.writeEncrypted(
      documentId: 'document-2',
      mimeType: 'image/jpeg',
      bytes: Stream.value([2]),
    );
    final tempFile = File(
      '${(await store.temporaryDirectory).path}/abandoned/plaintext',
    );
    await tempFile.parent.create(recursive: true);
    await tempFile.writeAsString('temporary');

    final cleanup = EncryptedStorageCleanupManager(store);
    expect(
      await cleanup.removeOrphanedEncryptedFiles([
        retained.encryptedRelativePath,
      ]),
      1,
    );
    await cleanup.cleanTemporaryWorkspace();
    expect(await (await store.temporaryDirectory).list().isEmpty, isTrue);
  });
}
