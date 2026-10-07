import 'dart:io';

import 'package:uuid/uuid.dart';

import '../../../../core/errors/app_failure.dart';
import 'backup_models.dart';
import 'backup_service.dart';
import 'cloud_backup_provider.dart';
import 'restore_service.dart';

class CloudBackupRetentionPolicy {
  const CloudBackupRetentionPolicy({this.maxVersions = 5})
    : assert(maxVersions >= 1 && maxVersions <= 20);
  final int maxVersions;
}

class CloudUploadResult {
  const CloudUploadResult({
    required this.version,
    required this.retentionDeleted,
    required this.retentionCleanupSucceeded,
  });
  final CloudBackupVersion version;
  final int retentionDeleted;

  /// An upload remains successful when deleting an older version fails. The
  /// user can retry cleanup later; never discard the newly verified backup.
  final bool retentionCleanupSucceeded;
}

class CloudBackupManager {
  CloudBackupManager(
    this.provider, {
    this.retention = const CloudBackupRetentionPolicy(),
  });

  final BackupProvider provider;
  final CloudBackupRetentionPolicy retention;

  Future<CloudUploadResult> uploadVerified(File encryptedBackup) async {
    final uploaded = await provider.uploadEncryptedBackup(encryptedBackup);
    var removed = 0;
    var cleanupSucceeded = true;
    try {
      final versions = await provider.listBackups()
        ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
      for (final version in versions.skip(retention.maxVersions)) {
        // Keep the object returned by this operation even if providers report
        // identical timestamps in a non-deterministic order.
        if (version.id == uploaded.id) continue;
        await provider.deleteBackup(version.id);
        removed++;
      }
    } on Object {
      cleanupSucceeded = false;
    }
    return CloudUploadResult(
      version: uploaded,
      retentionDeleted: removed,
      retentionCleanupSucceeded: cleanupSucceeded,
    );
  }

  Future<List<CloudBackupVersion>> listVersions() async {
    final values = await provider.listBackups();
    values.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return List.unmodifiable(values);
  }

  Future<CloudDownloadedBackup> download(
    CloudBackupVersion version, {
    required Future<Directory> Function() workspaceDirectory,
    Uuid? uuid,
  }) async {
    final root = await workspaceDirectory();
    await root.create(recursive: true);
    final workspace = await root.createTemp('cloud-download-');
    final file = File('${workspace.path}/${(uuid ?? const Uuid()).v4()}.dvbak');
    try {
      await provider.downloadBackup(versionId: version.id, destination: file);
      return CloudDownloadedBackup._(file, workspace);
    } on Object {
      if (await workspace.exists()) await workspace.delete(recursive: true);
      rethrow;
    }
  }
}

/// Adapter lets the established backup creation pipeline upload a package only
/// after it has been encrypted and re-open verified locally.
class CloudBackupDestination implements BackupDestination {
  const CloudBackupDestination(this._manager);
  final CloudBackupManager _manager;

  @override
  Future<BackupSaveResult> save({
    required File stagedBackup,
    required String suggestedFilename,
  }) async {
    await _manager.uploadVerified(stagedBackup);
    return const BackupSaveResult(
      destinationType: BackupDestinationType.cloudProvider,
    );
  }
}

class CloudDownloadedBackup {
  CloudDownloadedBackup._(this.file, this._workspace);
  final File file;
  final Directory _workspace;
  Future<void>? _disposeFuture;

  Future<void> dispose() => _disposeFuture ??= _dispose();
  Future<void> _dispose() async {
    if (await _workspace.exists()) await _workspace.delete(recursive: true);
  }
}

/// Downloads an encrypted backup to a private workspace, then feeds it into
/// the existing staged, authenticated restore path. Cloud content cannot
/// replace the active vault directly.
class CloudRestoreService {
  CloudRestoreService(this._manager, this._restore);
  final CloudBackupManager _manager;
  final EncryptedRestoreService _restore;

  Future<PreparedRestore> prepare(
    CloudBackupVersion version, {
    required BackupPassword password,
    required Future<Directory> Function() workspaceDirectory,
  }) async {
    final download = await _manager.download(
      version,
      workspaceDirectory: workspaceDirectory,
    );
    try {
      return await _restore.prepare(
        backupFile: download.file,
        password: password,
      );
    } on AppFailure {
      rethrow;
    } on Object catch (error) {
      throw CloudBackupFailure(
        'Cloud backup could not be prepared for restore.',
        cause: error,
      );
    } finally {
      await download.dispose();
    }
  }
}
