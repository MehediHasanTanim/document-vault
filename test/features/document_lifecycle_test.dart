import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:documentvault/core/database/repositories.dart';
import 'package:documentvault/core/database/vault_database.dart';
import 'package:documentvault/core/files/encrypted_file_store.dart';
import 'package:documentvault/core/files/file_operation_journal.dart';
import 'package:documentvault/core/files/file_reference.dart';
import 'package:documentvault/features/documents/application/lifecycle/document_lifecycle_service.dart';
import 'package:documentvault/features/documents/application/lifecycle/document_version_service.dart';
import 'package:documentvault/features/documents/application/lifecycle/trash_cleanup_service.dart';
import 'package:documentvault/core/uuid/uuid_generator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/database_test_harness.dart';

void main() {
  late VaultDatabase database;
  late DriftCategoryRepository categories;
  late DriftDocumentRepository documents;
  late DriftReminderRepository reminders;
  late EncryptedFileStore files;
  late FileOperationJournal journal;
  late Directory root;
  final now = DateTime.utc(2026, 10, 6, 10);

  setUp(() async {
    database = openTestDatabase();
    categories = DriftCategoryRepository(database);
    documents = DriftDocumentRepository(database);
    reminders = DriftReminderRepository(database);
    root = await Directory.systemTemp.createTemp('document-vault-lifecycle-');
    final key = SecretKey(List<int>.filled(32, 5));
    files = EncryptedFileStore(key, supportDirectory: () async => root);
    journal = FileOperationJournal(
      database,
      files,
      AesGcmOperationPayloadCodec(key),
      clock: () => now,
    );
    await categories.save(
      DocumentCategoriesCompanion.insert(
        id: 'category',
        code: 'identity',
        createdAt: now,
        updatedAt: now,
      ),
    );
  });
  tearDown(() async {
    await database.close();
    await root.delete(recursive: true);
  });

  Future<void> createDocument({
    required String id,
    SecureFileReference? file,
    bool reminder = false,
  }) => documents.create(
    DocumentWrite(
      document: DocumentsCompanion.insert(
        id: id,
        titleEncrypted: 'encrypted-title',
        categoryId: 'category',
        createdAt: now,
        updatedAt: now,
      ),
      files: file == null
          ? const []
          : [
              DocumentFilesCompanion.insert(
                id: file.id,
                documentId: id,
                mimeType: file.mimeType,
                encryptedRelativePath: file.encryptedRelativePath,
                integrityHash: file.integrityHash,
                sizeBytes: file.sizeBytes,
                encryptionVersion: file.encryptionVersion,
                createdAt: now,
              ),
            ],
      reminders: !reminder
          ? const []
          : [
              RemindersCompanion.insert(
                id: 'reminder-$id',
                documentId: id,
                targetDate: now.add(const Duration(days: 30)),
                scheduledAt: now.add(const Duration(days: 20)),
                createdAt: now,
                updatedAt: now,
              ),
            ],
    ),
  );

  DocumentLifecycleService lifecycle(_RecordingCanceller canceller) =>
      DocumentLifecycleService(
        documents,
        reminders,
        canceller,
        journal,
        files,
        clock: () => now,
      );

  test(
    'trash restore, favorite and archive transitions preserve metadata',
    () async {
      await createDocument(id: 'document');
      final service = lifecycle(_RecordingCanceller());
      await service.setFavorite('document', true);
      await service.archive('document');
      await service.moveToTrash('document');
      expect((await documents.getById('document'))!.deletedAt, isNotNull);

      await service.restoreFromTrash('document');
      var restored = (await documents.getById('document'))!;
      expect(restored.deletedAt, isNull);
      expect(restored.isArchived, isTrue);
      expect(restored.isFavorite, isTrue);

      await service.restoreArchive('document');
      restored = (await documents.getById('document'))!;
      expect(restored.isArchived, isFalse);
    },
  );

  test('permanent delete removes encrypted files, cascades rows, and cancels reminders', () async {
    final file = await files.writeEncrypted(
      documentId: 'document',
      mimeType: 'image/jpeg',
      bytes: Stream.value([1, 2, 3]),
    );
    await createDocument(id: 'document', file: file, reminder: true);
    await documents.moveToTrash('document', deletedAt: now);
    final canceller = _RecordingCanceller();

    await lifecycle(canceller).deletePermanently('document');

    expect(await documents.getById('document'), isNull);
    expect(await reminders.listForDocument('document'), isEmpty);
    expect(canceller.ids, ['reminder-document']);
    expect(
      await File(
        '${(await files.documentsDirectory).path}/${file.encryptedRelativePath}',
      ).exists(),
      isFalse,
    );
  });

  test('startup recovery completes an interrupted permanent deletion', () async {
    final file = await files.writeEncrypted(
      documentId: 'document',
      mimeType: 'image/jpeg',
      bytes: Stream.value([4, 5, 6]),
    );
    await createDocument(id: 'document', file: file);
    final operation = await journal.start(
      operationType: 'document_delete',
      entityId: 'document',
    );
    await journal.markFilesWritten(
      operation,
      FileOperationPayload(
        encryptedPaths: [file.encryptedRelativePath],
        fileIds: [file.id],
      ),
    );
    await documents.deletePermanently('document');

    final report = await journal.reconcileAtStartup();

    expect(report.completed, 1);
    expect(
      await File(
        '${(await files.documentsDirectory).path}/${file.encryptedRelativePath}',
      ).exists(),
      isFalse,
    );
  });

  test(
    'automatic cleanup obeys the 30-day default and can be disabled',
    () async {
      await createDocument(id: 'old');
      await createDocument(id: 'recent');
      await documents.moveToTrash(
        'old',
        deletedAt: now.subtract(const Duration(days: 31)),
      );
      await documents.moveToTrash(
        'recent',
        deletedAt: now.subtract(const Duration(days: 29)),
      );
      final cleanup = TrashCleanupService(
        documents,
        lifecycle(_RecordingCanceller()),
        clock: () => now,
      );

      expect(await cleanup.run(const TrashRetentionPolicy()), 1);
      expect(await documents.getById('old'), isNull);
      expect(await documents.getById('recent'), isNotNull);
      expect(await cleanup.run(const TrashRetentionPolicy(enabled: false)), 0);
    },
  );

  test(
    'replacement records supersede the old document and preserve lineage',
    () async {
      await createDocument(id: 'old');
      await createDocument(id: 'new');
      final versions = DriftDocumentVersionRepository(database);
      final service = DocumentVersionService(
        documents,
        versions,
        _SequenceUuid(['old-version', 'new-version']),
        clock: () => now,
      );

      await service.markReplacement(
        supersededDocumentId: 'old',
        replacementDocumentId: 'new',
      );

      expect((await documents.getById('old'))!.status, 'superseded');
      expect((await documents.getById('new'))!.currentVersionId, 'new-version');
      final current = await versions.listForDocument('new');
      expect(current.single.previousVersionId, 'old-version');
    },
  );
}

class _RecordingCanceller implements ReminderCanceller {
  final ids = <String>[];
  @override
  Future<void> cancel(String reminderId) async => ids.add(reminderId);
}

class _SequenceUuid implements UuidGenerator {
  _SequenceUuid(this._values);
  final List<String> _values;
  @override
  String v4() => _values.removeAt(0);
}
