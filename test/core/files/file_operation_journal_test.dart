import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:documentvault/core/files/encrypted_file_store.dart';
import 'package:documentvault/core/files/file_operation_journal.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/database_test_harness.dart';

void main() {
  test('startup reconciliation removes files from an interrupted pre-commit operation', () async {
    final root = await Directory.systemTemp.createTemp(
      'document-vault-journal-',
    );
    final key = SecretKey(List<int>.filled(32, 7));
    final store = EncryptedFileStore(key, supportDirectory: () async => root);
    final database = openTestDatabase();
    addTearDown(() async {
      await database.close();
      await root.delete(recursive: true);
    });
    final journal = FileOperationJournal(
      database,
      store,
      AesGcmOperationPayloadCodec(key),
    );
    final reference = await store.writeEncrypted(
      documentId: 'document-1',
      mimeType: 'image/jpeg',
      bytes: Stream.value([1, 2, 3]),
    );
    final operation = await journal.start(
      operationType: 'import',
      entityId: 'document-1',
    );
    await journal.markFilesWritten(
      operation,
      FileOperationPayload(
        encryptedPaths: [reference.encryptedRelativePath],
        fileIds: ['uncommitted-file'],
      ),
    );

    final report = await journal.reconcileAtStartup();
    expect(report.cleanedUp, 1);
    expect(
      await File(
        '${(await store.documentsDirectory).path}/${reference.encryptedRelativePath}',
      ).exists(),
      isFalse,
    );
  });
}
