import '../../../../core/database/repositories.dart';
import '../../../../core/database/vault_database.dart';
import '../../../../core/concurrency/vault_operation_gate.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/files/file_operation_journal.dart';
import '../../../../core/files/file_reference.dart';
import '../../../reminders/application/reminder_scheduler.dart';
import '../search/secure_search_index.dart';
import '../viewer/protected_thumbnail_service.dart';

/// Narrow abstraction keeps lifecycle deletion testable without a platform
/// notification plugin. It deliberately cancels only opaque notification IDs.
abstract interface class ReminderCanceller {
  Future<void> cancel(String reminderId);
}

class ReminderSchedulerCanceller implements ReminderCanceller {
  const ReminderSchedulerCanceller(this._scheduler);
  final ReminderScheduler _scheduler;

  @override
  Future<void> cancel(String reminderId) => _scheduler.cancel(reminderId);
}

/// Coordinates document lifecycle transitions. Permanent deletion follows the
/// file-operation journal: database metadata is committed first, followed by
/// encrypted bytes; startup recovery completes the latter if interrupted.
class DocumentLifecycleService {
  factory DocumentLifecycleService(
    DocumentRepository documents,
    ReminderRepository reminders,
    ReminderCanceller reminderCanceller,
    FileOperationJournal journal,
    SecureFileStore files, {
    ProtectedThumbnailService? thumbnails,
    SecureSearchIndex? search,
    VaultOperationGate? operationGate,
    DateTime Function()? clock,
  }) => DocumentLifecycleService._(
    documents,
    reminders,
    reminderCanceller,
    journal,
    files,
    thumbnails,
    search,
    operationGate: operationGate,
    clock: clock,
  );

  DocumentLifecycleService._(
    this._documents,
    this._reminders,
    this._reminderCanceller,
    this._journal,
    this._files,
    this._thumbnails,
    this._search, {
    this._operationGate,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final DocumentRepository _documents;
  final ReminderRepository _reminders;
  final ReminderCanceller _reminderCanceller;
  final FileOperationJournal _journal;
  final SecureFileStore _files;
  final ProtectedThumbnailService? _thumbnails;
  final SecureSearchIndex? _search;
  final VaultOperationGate? _operationGate;
  final DateTime Function() _clock;

  Future<void> setFavorite(String documentId, bool favorite) => _write(
    () => _documents.setFavorite(
      documentId,
      favorite: favorite,
      updatedAt: _clock().toUtc(),
    ),
  );

  Future<void> archive(String documentId) => _write(() => _archive(documentId));

  Future<void> _archive(String documentId) async {
    final document = await _requireDocument(documentId);
    if (document.deletedAt != null) {
      throw const ValidationFailure(
        'Restore this document before archiving it.',
      );
    }
    await _documents.archive(
      documentId,
      archived: true,
      updatedAt: _clock().toUtc(),
    );
  }

  Future<void> restoreArchive(String documentId) => _write(
    () => _documents.archive(
      documentId,
      archived: false,
      updatedAt: _clock().toUtc(),
    ),
  );

  Future<void> moveToTrash(String documentId) =>
      _write(() => _moveToTrash(documentId));

  Future<void> _moveToTrash(String documentId) async {
    await _requireDocument(documentId);
    await _documents.moveToTrash(documentId, deletedAt: _clock().toUtc());
  }

  Future<void> restoreFromTrash(String documentId) =>
      _write(() => _restoreFromTrash(documentId));

  Future<void> _restoreFromTrash(String documentId) async {
    final document = await _requireDocument(documentId);
    if (document.deletedAt == null) {
      throw const ValidationFailure('This document is not in Trash.');
    }
    await _documents.restore(documentId, updatedAt: _clock().toUtc());
  }

  Future<void> deletePermanently(String documentId) =>
      _write(() => _deletePermanently(documentId));

  Future<void> _deletePermanently(String documentId) async {
    final document = await _requireDocument(documentId);
    if (document.deletedAt == null) {
      throw const ValidationFailure(
        'Move the document to Trash before deleting it permanently.',
      );
    }
    final files = await _documents.filesForDocument(documentId);
    final operationId = await _journal.start(
      operationType: 'document_delete',
      entityId: documentId,
    );
    await _journal.markFilesWritten(
      operationId,
      FileOperationPayload(
        encryptedPaths: files
            .map((file) => file.encryptedRelativePath)
            .toList(),
        fileIds: files.map((file) => file.id).toList(),
      ),
    );

    var databaseCommitted = false;
    try {
      // Cancel while rows still exist, so scheduler can resolve the opaque OS
      // notification identifier. The document delete then cascades reminders.
      for (final reminder in await _reminders.listForDocument(documentId)) {
        await _reminderCanceller.cancel(reminder.id);
      }
      final deletedFiles = await _documents.deletePermanently(documentId);
      databaseCommitted = true;
      await _journal.markDatabaseCommitted(operationId);
      for (final file in deletedFiles) {
        await _files.delete(_reference(file));
        _thumbnails?.invalidate(file.id);
      }
      _search?.remove(documentId);
      await _journal.complete(operationId);
    } on Object catch (error) {
      // Once metadata is gone, preserve the journal so startup reconciliation
      // can remove any encrypted bytes left by an interruption/failure.
      if (!databaseCommitted) await _journal.fail(operationId);
      if (error is AppFailure) rethrow;
      throw StorageFailure(
        'Could not permanently delete this document.',
        cause: error,
      );
    }
  }

  Future<Document> _requireDocument(String id) async {
    final document = await _documents.getById(id);
    if (document == null) {
      throw const ValidationFailure('Document was not found.');
    }
    return document;
  }

  SecureFileReference _reference(DocumentFile file) => SecureFileReference(
    id: file.id,
    encryptedRelativePath: file.encryptedRelativePath,
    mimeType: file.mimeType,
    integrityHash: file.integrityHash,
    sizeBytes: file.sizeBytes,
    encryptionVersion: file.encryptionVersion,
  );

  Future<T> _write<T>(Future<T> Function() action) =>
      _operationGate?.runWrite(action) ?? action();
}
