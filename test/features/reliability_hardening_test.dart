import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:documentvault/core/files/encrypted_file_store.dart';
import 'package:documentvault/core/files/file_operation_journal.dart';
import 'package:documentvault/core/performance/vault_performance.dart';
import 'package:documentvault/core/reliability/vault_startup_maintenance.dart';
import 'package:documentvault/features/documents/application/search/secure_search_index.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/database_test_harness.dart';
import '../support/performance_vault_fixture.dart';

void main() {
  test(
    'generates repeatable 100, 1000, and 10000-record performance vaults',
    () {
      for (final count in [100, 1000, 10000]) {
        final records = PerformanceVaultFixture.searchableRecords(count);
        final index = SecureSearchIndex()..build(records);
        expect(index.count, count);
        expect(
          index
              .search('synthetic household document ${count - 1}')
              .single
              .documentId,
          'fixture-document-${count - 1}',
        );
      }
    },
  );

  test('records bounded, in-memory performance samples without swallowing failures', () async {
    final monitor = VaultPerformanceMonitor(maxSamples: 2);
    expect(
      await monitor.measure(VaultPerformanceOperation.search, () async => 42),
      42,
    );
    await expectLater(
      monitor.measure<int>(
        VaultPerformanceOperation.pdfOpen,
        () async => throw StateError('renderer unavailable'),
      ),
      throwsStateError,
    );
    await monitor.measure(VaultPerformanceOperation.unlock, () async {});
    expect(monitor.samples, hasLength(2));
    expect(monitor.samples.first.operation, VaultPerformanceOperation.pdfOpen);
    expect(monitor.samples.first.succeeded, isFalse);
    expect(monitor.isWithinBudget(monitor.samples.last), isTrue);
    monitor.clear();
    expect(monitor.samples, isEmpty);
  });

  test('startup maintenance removes only recoverable debris and runs independent recovery steps', () async {
    final root = await Directory.systemTemp.createTemp(
      'document-vault-hardening-',
    );
    final database = openTestDatabase();
    addTearDown(() async {
      await database.close();
      if (await root.exists()) await root.delete(recursive: true);
    });
    final key = SecretKey(List<int>.filled(32, 5));
    final store = EncryptedFileStore(key, supportDirectory: () async => root);
    final cleanup = EncryptedStorageCleanupManager(store);
    final journal = FileOperationJournal(
      database,
      store,
      AesGcmOperationPayloadCodec(key),
    );
    final orphan = await store.writeEncrypted(
      documentId: 'orphan-document',
      mimeType: 'image/jpeg',
      bytes: Stream.value([1, 2, 3]),
    );
    final pending = File(
      '${(await store.documentsDirectory).path}/pending/.write.pending',
    );
    await pending.parent.create(recursive: true);
    await pending.writeAsBytes([1]);
    final temporary = File(
      '${(await store.temporaryDirectory).path}/viewer/plaintext',
    );
    await temporary.parent.create(recursive: true);
    await temporary.writeAsString('never retained');
    var backupsCleaned = false;
    var restoreReconciled = false;

    final report = await VaultStartupMaintenance(
      database: database,
      journal: journal,
      encryptedCleanup: cleanup,
      cleanBackupWorkspace: () async {
        backupsCleaned = true;
        return 1;
      },
      reconcileRestore: () async => restoreReconciled = true,
    ).reconcileAfterUnlock();

    expect(report.isHealthy, isTrue);
    expect(report.orphanFilesRemoved, 1);
    expect(report.partialFilesRemoved, 1);
    expect(report.temporaryItemsRemoved, 1);
    expect(report.backupWorkspaceItemsRemoved, 1);
    expect(backupsCleaned, isTrue);
    expect(restoreReconciled, isTrue);
    expect(report.restoreReconciled, isTrue);
    expect(
      await File(
        '${(await store.documentsDirectory).path}/${orphan.encryptedRelativePath}',
      ).exists(),
      isFalse,
    );
    expect(await pending.exists(), isFalse);
    expect(await temporary.exists(), isFalse);
  });

  test('startup maintenance reports an optional cleanup failure without stopping restore recovery', () async {
    final root = await Directory.systemTemp.createTemp(
      'document-vault-maintenance-failure-',
    );
    final database = openTestDatabase();
    addTearDown(() async {
      await database.close();
      if (await root.exists()) await root.delete(recursive: true);
    });
    final key = SecretKey(List<int>.filled(32, 6));
    var restored = false;
    final report = await VaultStartupMaintenance(
      database: database,
      journal: FileOperationJournal(
        database,
        EncryptedFileStore(key, supportDirectory: () async => root),
        AesGcmOperationPayloadCodec(key),
      ),
      encryptedCleanup: EncryptedStorageCleanupManager(
        EncryptedFileStore(key, supportDirectory: () async => root),
      ),
      cleanBackupWorkspace: () async => throw StateError('unavailable'),
      reconcileRestore: () async => restored = true,
    ).reconcileAfterUnlock();
    expect(report.issues, contains(VaultMaintenanceIssue.backupWorkspace));
    expect(restored, isTrue);
  });
}
