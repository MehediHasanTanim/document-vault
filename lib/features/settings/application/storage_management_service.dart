import 'dart:io';

import 'package:drift/drift.dart';

import '../../../core/database/vault_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/files/encrypted_file_store.dart';
import '../../../core/files/file_reference.dart';
import '../../documents/application/lifecycle/trash_cleanup_service.dart';

class VaultStoragePaths {
  const VaultStoragePaths({
    required this.database,
    required this.attachments,
    required this.temporary,
    required this.thumbnails,
    required this.cache,
  });
  final File database;
  final Directory attachments;
  final Directory temporary;
  final Directory thumbnails;
  final Directory cache;
}

class VaultStorageReport {
  const VaultStorageReport({
    required this.documentCount,
    required this.trashedDocumentCount,
    required this.pageCount,
    required this.fileCount,
    required this.databaseBytes,
    required this.attachmentBytes,
    required this.thumbnailBytes,
    required this.cacheBytes,
    required this.trashBytes,
  });
  final int documentCount;
  final int trashedDocumentCount;
  final int pageCount;
  final int fileCount;
  final int databaseBytes;
  final int attachmentBytes;
  final int thumbnailBytes;
  final int cacheBytes;
  final int trashBytes;
  int get estimatedBackupBytes => databaseBytes + attachmentBytes;
  int get totalVaultBytes =>
      databaseBytes + attachmentBytes + thumbnailBytes + cacheBytes;
}

class LargeStoredFile {
  const LargeStoredFile({
    required this.fileId,
    required this.documentId,
    required this.mimeType,
    required this.sizeBytes,
  });
  final String fileId;
  final String documentId;
  final String mimeType;
  final int sizeBytes;
}

class IntegrityCheckReport {
  const IntegrityCheckReport({
    required this.databaseHealthy,
    required this.checkedFiles,
    required this.invalidFileIds,
  });
  final bool databaseHealthy;
  final int checkedFiles;
  final List<String> invalidFileIds;
  bool get isHealthy => databaseHealthy && invalidFileIds.isEmpty;
}

/// Reports private storage without revealing document titles or original names.
/// Maintenance only clears known disposable directories; encrypted originals are
/// never selected for automatic deletion.
class StorageManagementService {
  StorageManagementService(
    this._database,
    this._paths, {
    this.encryptedCleanup,
    this.trashCleanup,
    required this.files,
  });

  final VaultDatabase _database;
  final VaultStoragePaths _paths;
  final EncryptedStorageCleanupManager? encryptedCleanup;
  final TrashCleanupService? trashCleanup;
  final SecureFileStore files;

  Future<VaultStorageReport> report() async {
    final documents = await _database.select(_database.documents).get();
    final files = await _database.select(_database.documentFiles).get();
    final pages = await _database.select(_database.documentPages).get();
    final trashedIds = documents
        .where((document) => document.deletedAt != null)
        .map((document) => document.id)
        .toSet();
    final trashBytes = files
        .where((file) => trashedIds.contains(file.documentId))
        .fold<int>(0, (total, file) => total + file.sizeBytes);
    return VaultStorageReport(
      documentCount: documents
          .where((document) => document.deletedAt == null)
          .length,
      trashedDocumentCount: trashedIds.length,
      pageCount: pages.length,
      fileCount: files.length,
      databaseBytes: await _fileBytes(_paths.database),
      attachmentBytes: await _directoryBytes(_paths.attachments),
      thumbnailBytes: await _directoryBytes(_paths.thumbnails),
      cacheBytes: await _directoryBytes(_paths.cache),
      trashBytes: trashBytes,
    );
  }

  Future<List<LargeStoredFile>> findLargeFiles({int limit = 20}) async {
    if (limit <= 0) return const [];
    final rows =
        await (_database.select(_database.documentFiles)
              ..orderBy([(file) => OrderingTerm.desc(file.sizeBytes)])
              ..limit(limit))
            .get();
    return rows
        .map(
          (file) => LargeStoredFile(
            fileId: file.id,
            documentId: file.documentId,
            mimeType: file.mimeType,
            sizeBytes: file.sizeBytes,
          ),
        )
        .toList(growable: false);
  }

  Future<void> clearSafeTemporaryFiles() async {
    await _clearDirectory(_paths.temporary);
    await _clearDirectory(_paths.cache);
    await encryptedCleanup?.cleanTemporaryWorkspace();
    await encryptedCleanup?.removePartialEncryptedWrites();
  }

  /// Permanent removal is only possible after a caller's explicit destructive
  /// confirmation. [TrashCleanupService] deletes rows/files through the
  /// operation journal and does not touch active documents.
  Future<int> emptyTrash({required bool confirmed}) async {
    if (!confirmed) {
      throw const ValidationFailure(
        'Confirm before permanently emptying Trash.',
      );
    }
    final cleanup = trashCleanup;
    if (cleanup == null) {
      throw const StorageFailure('Trash cleanup is unavailable.');
    }
    return cleanup.emptyNow();
  }

  Future<IntegrityCheckReport> runIntegrityCheck() async {
    var databaseHealthy = false;
    try {
      final integrity = await _database
          .customSelect('PRAGMA integrity_check')
          .get();
      final foreignKeys = await _database
          .customSelect('PRAGMA foreign_key_check')
          .get();
      databaseHealthy =
          integrity.length == 1 &&
          integrity.single.data.values.first == 'ok' &&
          foreignKeys.isEmpty;
    } on Object {
      databaseHealthy = false;
    }
    final invalid = <String>[];
    var checked = 0;
    for (final file in await _database.select(_database.documentFiles).get()) {
      checked++;
      try {
        await for (final _ in await files.readDecrypted(_reference(file))) {}
      } on Object {
        invalid.add(file.id);
      }
    }
    return IntegrityCheckReport(
      databaseHealthy: databaseHealthy,
      checkedFiles: checked,
      invalidFileIds: List.unmodifiable(invalid),
    );
  }

  SecureFileReference _reference(DocumentFile file) => SecureFileReference(
    id: file.id,
    encryptedRelativePath: file.encryptedRelativePath,
    mimeType: file.mimeType,
    integrityHash: file.integrityHash,
    sizeBytes: file.sizeBytes,
    encryptionVersion: file.encryptionVersion,
  );

  Future<int> _fileBytes(File file) async =>
      await file.exists() ? file.length() : 0;

  Future<int> _directoryBytes(Directory directory) async {
    if (!await directory.exists()) return 0;
    var total = 0;
    await for (final entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is File) total += await entity.length();
    }
    return total;
  }

  Future<void> _clearDirectory(Directory directory) async {
    if (!await directory.exists()) return;
    await for (final entity in directory.list(followLinks: false)) {
      await entity.delete(recursive: true);
    }
  }
}
