import '../database/vault_database.dart';
import '../files/encrypted_file_store.dart';
import '../files/file_operation_journal.dart';

/// Safe post-unlock reconciliation. Each step is independent so a failed
/// optional cleanup never prevents journal recovery or a restore rollback.
/// No paths, filenames, document metadata, or exceptions are retained.
class VaultStartupMaintenance {
  VaultStartupMaintenance({
    required this.database,
    required this.journal,
    required this.encryptedCleanup,
    this.cleanBackupWorkspace,
    this.reconcileRestore,
  });

  final VaultDatabase database;
  final FileOperationJournal journal;
  final EncryptedStorageCleanupManager encryptedCleanup;
  final Future<int> Function()? cleanBackupWorkspace;
  final Future<void> Function()? reconcileRestore;

  Future<VaultStartupMaintenanceReport> reconcileAfterUnlock() async {
    FileOperationReconciliationReport? journal;
    var temporaryItemsRemoved = 0;
    var partialFilesRemoved = 0;
    var orphanFilesRemoved = 0;
    var backupWorkspaceItemsRemoved = 0;
    var restoreReconciled = false;
    final issues = <VaultMaintenanceIssue>[];

    try {
      journal = await this.journal.reconcileAtStartup();
    } on Object {
      issues.add(VaultMaintenanceIssue.journal);
    }
    try {
      final temporary = await encryptedCleanup.temporaryDirectory;
      temporaryItemsRemoved = await temporary.list().length;
      await encryptedCleanup.cleanTemporaryWorkspace();
    } on Object {
      issues.add(VaultMaintenanceIssue.temporaryWorkspace);
    }
    try {
      partialFilesRemoved = await encryptedCleanup
          .removePartialEncryptedWrites();
    } on Object {
      issues.add(VaultMaintenanceIssue.partialWrites);
    }
    try {
      final references = await database.select(database.documentFiles).get();
      orphanFilesRemoved = await encryptedCleanup.removeOrphanedEncryptedFiles(
        references.map((file) => file.encryptedRelativePath),
      );
    } on Object {
      issues.add(VaultMaintenanceIssue.orphanFiles);
    }
    try {
      backupWorkspaceItemsRemoved = await cleanBackupWorkspace?.call() ?? 0;
    } on Object {
      issues.add(VaultMaintenanceIssue.backupWorkspace);
    }
    try {
      await reconcileRestore?.call();
      restoreReconciled = reconcileRestore != null;
    } on Object {
      issues.add(VaultMaintenanceIssue.restore);
    }
    return VaultStartupMaintenanceReport(
      journal: journal,
      temporaryItemsRemoved: temporaryItemsRemoved,
      partialFilesRemoved: partialFilesRemoved,
      orphanFilesRemoved: orphanFilesRemoved,
      backupWorkspaceItemsRemoved: backupWorkspaceItemsRemoved,
      restoreReconciled: restoreReconciled,
      issues: List.unmodifiable(issues),
    );
  }
}

enum VaultMaintenanceIssue {
  journal,
  temporaryWorkspace,
  partialWrites,
  orphanFiles,
  backupWorkspace,
  restore,
}

class VaultStartupMaintenanceReport {
  const VaultStartupMaintenanceReport({
    required this.journal,
    required this.temporaryItemsRemoved,
    required this.partialFilesRemoved,
    required this.orphanFilesRemoved,
    required this.backupWorkspaceItemsRemoved,
    required this.restoreReconciled,
    required this.issues,
  });

  final FileOperationReconciliationReport? journal;
  final int temporaryItemsRemoved;
  final int partialFilesRemoved;
  final int orphanFilesRemoved;
  final int backupWorkspaceItemsRemoved;
  final bool restoreReconciled;
  final List<VaultMaintenanceIssue> issues;
  bool get isHealthy => issues.isEmpty;
}
