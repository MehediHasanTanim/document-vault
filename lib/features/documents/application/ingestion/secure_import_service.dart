import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/repositories.dart';
import '../../../../core/database/vault_database.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/files/encrypted_file_store.dart';
import '../../../../core/files/file_reference.dart';
import '../../../../core/files/file_operation_journal.dart';
import 'import_file_validator.dart';
import 'import_models.dart';
import 'private_import_workspace.dart';

abstract interface class StorageCapacityProvider {
  /// Null means that the platform cannot safely report available space.
  Future<int?> availableBytes();
}

class UnknownStorageCapacityProvider implements StorageCapacityProvider {
  const UnknownStorageCapacityProvider();
  @override
  Future<int?> availableBytes() async => null;
}

class SecureImportResult {
  const SecureImportResult({
    required this.fileIds,
    required this.bytesImported,
  });
  final List<String> fileIds;
  final int bytesImported;
}

/// Encrypts staged input, records every filesystem boundary in the operation
/// journal, then writes all file/page metadata in one SQLite transaction.
class SecureImportService {
  SecureImportService(
    this._documents,
    this._files,
    this._journal,
    this._workspace,
    this._capacity, {
    Uuid? uuid,
    DateTime Function()? clock,
  }) : _uuid = uuid ?? const Uuid(),
       _clock = clock ?? DateTime.now;

  static const _workspaceReserveBytes = 5 * 1024 * 1024;
  final DocumentRepository _documents;
  final EncryptedFileStore _files;
  final FileOperationJournal _journal;
  final PrivateImportWorkspace _workspace;
  final StorageCapacityProvider _capacity;
  final Uuid _uuid;
  final DateTime Function() _clock;

  Future<PrivateImportSession> openWorkspace() => _workspace.open();

  Future<SecureImportResult> importPages({
    required String documentId,
    required List<StagedImportFile> pages,
  }) async {
    if (pages.isEmpty) {
      throw const ValidationFailure('Add at least one page before importing.');
    }
    await _ensureCapacity(pages);
    final operationId = await _journal.start(
      operationType: 'document_import',
      entityId: documentId,
    );
    final references = <SecureFileReference>[];
    try {
      for (final page in pages) {
        final reference = await _files.writeEncrypted(
          documentId: documentId,
          bytes: page.file.openRead(),
          mimeType: page.mimeType,
        );
        references.add(reference);
        // Persist each completed path so restart recovery can remove partial
        // imports if the app dies before the metadata transaction.
        await _journal.markFilesWritten(
          operationId,
          FileOperationPayload(
            encryptedPaths: references
                .map((ref) => ref.encryptedRelativePath)
                .toList(),
            fileIds: references.map((ref) => ref.id).toList(),
          ),
        );
      }
      final now = _clock().toUtc();
      final files = <DocumentFilesCompanion>[];
      final documentPages = <DocumentPagesCompanion>[];
      for (var index = 0; index < references.length; index++) {
        final ref = references[index];
        final page = pages[index];
        files.add(
          DocumentFilesCompanion.insert(
            id: ref.id,
            documentId: documentId,
            fileType: Value(
              page.source == ImportSource.camera ? 'capture' : 'import',
            ),
            mimeType: ref.mimeType,
            encryptedRelativePath: ref.encryptedRelativePath,
            sizeBytes: ref.sizeBytes,
            integrityHash: ref.integrityHash,
            encryptionVersion: ref.encryptionVersion,
            createdAt: now,
          ),
        );
        // A PDF stays one original file. Each imported/captured image maps to
        // one ordered page and can later be rendered or composed into a PDF.
        if (page.mimeType.startsWith('image/')) {
          documentPages.add(
            DocumentPagesCompanion.insert(
              id: _uuid.v4(),
              documentId: documentId,
              documentFileId: ref.id,
              pageNumber: index + 1,
              encryptedPath: Value(ref.encryptedRelativePath),
              rotation: Value(page.rotation),
              createdAt: now,
            ),
          );
        }
      }
      await _documents.attachImportedFiles(
        documentId,
        files: files,
        pages: documentPages,
      );
      await _journal.markDatabaseCommitted(operationId);
      await _journal.complete(operationId);
      return SecureImportResult(
        fileIds: references
            .map((reference) => reference.id)
            .toList(growable: false),
        bytesImported: references.fold(
          0,
          (total, reference) => total + reference.sizeBytes,
        ),
      );
    } on Object catch (error) {
      // A hard process death skips this block: the persisted journal is then
      // reconciled after unlock. Ordinary failures clean up immediately.
      for (final reference in references) {
        await _files.delete(reference);
      }
      await _journal.fail(operationId);
      if (error is AppFailure) rethrow;
      throw StorageFailure(
        'The document could not be imported securely.',
        cause: error,
      );
    }
  }

  Future<List<StagedImportFile>> stage(
    List<SelectedImportFile> selected,
    PrivateImportSession session,
    ImportFileValidator validator,
  ) async {
    final staged = <StagedImportFile>[];
    for (final file in selected) {
      staged.add(await session.copyAndValidate(file, validator));
    }
    await _ensureCapacity(staged);
    return staged;
  }

  Future<void> _ensureCapacity(List<StagedImportFile> files) async {
    final available = await _capacity.availableBytes();
    if (available == null) return;
    final sourceBytes = files.fold<int>(
      0,
      (total, file) => total + file.sizeBytes,
    );
    // Encrypted output, temporary staging, and a safety reserve must fit.
    final required = sourceBytes * 2 + _workspaceReserveBytes;
    if (available < required) {
      throw const InsufficientStorageFailure(
        'There is not enough private device storage to import this document.',
      );
    }
  }
}

/// Runs after vault unlock. It finishes journal recovery and removes encrypted
/// files which cannot be referenced by the database (the tiny crash window
/// between a filesystem rename and journal update).
class ImportRecoveryService {
  ImportRecoveryService(this._database, this._journal, this._cleanup);
  final VaultDatabase _database;
  final FileOperationJournal _journal;
  final EncryptedStorageCleanupManager _cleanup;

  Future<FileOperationReconciliationReport> reconcile() async {
    final report = await _journal.reconcileAtStartup();
    final referenced = await _database.select(_database.documentFiles).get();
    await _cleanup.cleanTemporaryWorkspace();
    await _cleanup.removePartialEncryptedWrites();
    await _cleanup.removeOrphanedEncryptedFiles(
      referenced.map((file) => file.encryptedRelativePath),
    );
    return report;
  }
}
