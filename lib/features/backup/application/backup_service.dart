import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../../core/concurrency/vault_operation_gate.dart';
import '../../../../core/database/repositories.dart';
import '../../../../core/database/vault_database.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/uuid/uuid_generator.dart';
import 'backup_models.dart';
import 'backup_package_codec.dart';

enum BackupProgressStage { preparing, packaging, verifying, saving }

class BackupProgress {
  const BackupProgress(this.stage);
  final BackupProgressStage stage;
}

abstract interface class BackupSnapshotSource {
  /// Runs [action] after active cooperative vault writes finish, while new
  /// cooperative writes are held. [BackupSnapshot] inputs must be repeatable.
  Future<T> withConsistentSnapshot<T>(
    Future<T> Function(BackupSnapshot snapshot) action,
  );
}

abstract interface class BackupDestination {
  /// Persist [stagedBackup] without exposing its contents to Dart memory.
  /// Throws [BackupCancelledFailure] if the user dismisses the destination UI.
  Future<BackupSaveResult> save({
    required File stagedBackup,
    required String suggestedFilename,
  });
}

class BackupCreationResult {
  const BackupCreationResult({
    required this.record,
    required this.verification,
  });
  final BackupRecord record;
  final BackupVerificationResult verification;
}

/// Makes a database copy through a caller-supplied, SQLite-consistent export
/// and captures generated encrypted-file paths. The files remain raw encrypted
/// `.dvf` bytes; plaintext is never materialised for a backup.
class FileSystemBackupSnapshotSource implements BackupSnapshotSource {
  FileSystemBackupSnapshotSource({
    required this.gate,
    required this.encryptedDocumentsDirectory,
    required this.workspace,
    required this.exportDatabaseSnapshot,
    this.vaultChangesSinceLastBackup = 0,
  });

  final VaultOperationGate gate;
  final Directory encryptedDocumentsDirectory;
  final Directory workspace;
  final Future<void> Function(File target) exportDatabaseSnapshot;
  final int vaultChangesSinceLastBackup;

  @override
  Future<T> withConsistentSnapshot<T>(
    Future<T> Function(BackupSnapshot snapshot) action,
  ) => gate.runSnapshot(() async {
    final snapshotDirectory = await workspace.createTemp('snapshot-');
    try {
      final database = File('${snapshotDirectory.path}/vault.sqlite');
      await exportDatabaseSnapshot(database);
      final files = <BackupInput>[];
      if (await encryptedDocumentsDirectory.exists()) {
        await for (final entity in encryptedDocumentsDirectory.list(
          recursive: true,
          followLinks: false,
        )) {
          if (entity is! File || !entity.path.endsWith('.dvf')) continue;
          final relative = entity.path.substring(
            encryptedDocumentsDirectory.path.length + 1,
          );
          files.add(_fileInput(entity, 'files/$relative'));
        }
      }
      files.sort((left, right) => left.id.compareTo(right.id));
      return await action(
        BackupSnapshot(
          database: _fileInput(database, 'database.sqlite'),
          files: files,
          vaultChangesSinceLastBackup: vaultChangesSinceLastBackup,
        ),
      );
    } finally {
      if (await snapshotDirectory.exists()) {
        await snapshotDirectory.delete(recursive: true);
      }
    }
  });

  BackupInput _fileInput(File file, String id) => BackupInput(
    id: id,
    byteLength: file.lengthSync(),
    open: () async => file.openRead(),
  );
}

/// Streams a staged package into a selected app-accessible folder. This is
/// useful for device storage and for tests; a document-provider implementation
/// can use the same interface without changing encryption or verification.
class FileBackupDestination implements BackupDestination {
  FileBackupDestination(
    this.directory, {
    this.type = BackupDestinationType.deviceFolder,
  });
  final Directory directory;
  final BackupDestinationType type;

  @override
  Future<BackupSaveResult> save({
    required File stagedBackup,
    required String suggestedFilename,
  }) async {
    final target = File('${directory.path}/$suggestedFilename');
    final pending = File('${target.path}.partial');
    try {
      await directory.create(recursive: true);
      await stagedBackup.openRead().pipe(pending.openWrite());
      await pending.rename(target.path);
      return BackupSaveResult(destinationType: type);
    } on Object catch (error) {
      if (await pending.exists()) await pending.delete();
      throw BackupFailure(
        'Could not save the backup to that location.',
        cause: error,
      );
    }
  }
}

/// Removes abandoned private staging files after process termination. A staged
/// package is never counted as a successful backup until it was verified and
/// saved through a destination.
class BackupWorkspaceCleanup {
  BackupWorkspaceCleanup(this._workspace);
  final Directory _workspace;

  Future<int> clean() async {
    if (!await _workspace.exists()) return 0;
    var removed = 0;
    await for (final entity in _workspace.list()) {
      if (entity is File &&
          (entity.path.endsWith('.partial') ||
              entity.path.endsWith('.dvbak'))) {
        await entity.delete();
        removed++;
      }
      if (entity is Directory && entity.path.contains('/snapshot-')) {
        await entity.delete(recursive: true);
        removed++;
      }
    }
    return removed;
  }
}

class EncryptedBackupService {
  EncryptedBackupService(
    this._snapshotSource,
    this._history,
    this._uuid, {
    BackupPackageCodec? codec,
    Future<Directory> Function()? workspaceDirectory,
    DateTime Function()? clock,
  }) : _codec = codec ?? BackupPackageCodec(),
       _workspaceDirectory = workspaceDirectory ?? _defaultWorkspace,
       _clock = clock ?? DateTime.now;

  final BackupSnapshotSource _snapshotSource;
  final BackupRepository _history;
  final UuidGenerator _uuid;
  final BackupPackageCodec _codec;
  final Future<Directory> Function() _workspaceDirectory;
  final DateTime Function() _clock;

  Future<BackupCreationResult> create({
    required BackupPassword password,
    required BackupDestination destination,
    void Function(BackupProgress progress)? onProgress,
  }) async {
    final workspace = await _workspaceDirectory();
    await workspace.create(recursive: true);
    final pending = File('${workspace.path}/${_uuid.v4()}.partial');
    File? verified;
    try {
      onProgress?.call(const BackupProgress(BackupProgressStage.preparing));
      late BackupSnapshot snapshot;
      late BackupVerificationResult verification;
      await _snapshotSource.withConsistentSnapshot((value) async {
        snapshot = value;
        onProgress?.call(const BackupProgress(BackupProgressStage.packaging));
        verification = await _codec.create(
          snapshot: value,
          password: password,
          destination: pending,
          createdAt: _clock().toUtc(),
        );
      });
      onProgress?.call(const BackupProgress(BackupProgressStage.verifying));
      // [create] performs a re-open verification; this second call protects
      // callers that replace or transport the staged file between steps.
      verification = await _codec.verify(file: pending, password: password);
      final suggestedFilename = _suggestedFilename(_clock());
      verified = File('${workspace.path}/$suggestedFilename');
      await pending.rename(verified.path);

      onProgress?.call(const BackupProgress(BackupProgressStage.saving));
      final saved = await destination.save(
        stagedBackup: verified,
        suggestedFilename: suggestedFilename,
      );
      final record = BackupRecord(
        id: _uuid.v4(),
        relativePath: null,
        createdAt: _clock().toUtc(),
        sizeBytes: verification.sizeBytes,
        verified: true,
        destinationType: saved.destinationType.name,
        vaultChangesSinceBackup: snapshot.vaultChangesSinceLastBackup,
      );
      await _history.save(record.toCompanion(false));
      return BackupCreationResult(record: record, verification: verification);
    } on BackupCancelledFailure {
      rethrow;
    } on BackupFailure {
      rethrow;
    } on Object catch (error) {
      throw BackupFailure('Could not create encrypted backup.', cause: error);
    } finally {
      if (await pending.exists()) await pending.delete();
      if (verified != null && await verified.exists()) await verified.delete();
    }
  }

  static Future<Directory> _defaultWorkspace() async => Directory(
    '${(await getApplicationSupportDirectory()).path}/vault/backup-workspace',
  );

  static String _suggestedFilename(DateTime value) =>
      'document-vault-backup-${value.toUtc().toIso8601String().replaceAll(':', '').replaceAll('.', '')}.dvbak';
}
