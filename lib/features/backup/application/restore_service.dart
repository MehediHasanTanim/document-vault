import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:uuid/uuid.dart';

import '../../../../core/database/vault_database.dart';
import '../../../../core/errors/app_failure.dart';
import 'backup_models.dart';
import 'backup_package_codec.dart';

abstract interface class RestoreCapacityProvider {
  Future<int?> availableBytes();
}

class UnknownRestoreCapacityProvider implements RestoreCapacityProvider {
  const UnknownRestoreCapacityProvider();
  @override
  Future<int?> availableBytes() async => null;
}

abstract interface class RestorePostProcessor {
  Future<void> recreateDeviceKeyProtection();
  Future<void> requireNewPin();
  Future<void> disableAndOfferBiometrics();
  Future<void> rebuildSearch();
  Future<void> reconcileNotifications();
}

class NoopRestorePostProcessor implements RestorePostProcessor {
  const NoopRestorePostProcessor();
  @override
  Future<void> disableAndOfferBiometrics() async {}
  @override
  Future<void> recreateDeviceKeyProtection() async {}
  @override
  Future<void> rebuildSearch() async {}
  @override
  Future<void> reconcileNotifications() async {}
  @override
  Future<void> requireNewPin() async {}
}

class PreparedRestore {
  const PreparedRestore({
    required this.id,
    required this.stagingDirectory,
    required this.summary,
    required this.verification,
  });
  final String id;
  final Directory stagingDirectory;
  final RestoreSummary summary;
  final BackupVerificationResult verification;
}

class RestoreResult {
  const RestoreResult({required this.summary, required this.replacedExisting});
  final RestoreSummary summary;
  final bool replacedExisting;
}

/// Validates a private staged vault before it can replace any active data.
class DriftStagedVaultValidator {
  Future<RestoreSummary> migrateAndValidate({
    required File databaseFile,
    required Directory documentsDirectory,
    required BackupVerificationResult verification,
  }) async {
    if (!await databaseFile.exists()) {
      throw const BackupFailure('Backup is unsupported or damaged.');
    }
    sqlite.Database? raw;
    try {
      raw = sqlite.sqlite3.open(databaseFile.path);
      final tables = raw.select(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'documents'",
      );
      final schemaVersion =
          raw.select('PRAGMA user_version').single['user_version'] as int;
      if (tables.isEmpty ||
          schemaVersion > VaultDatabase.currentSchemaVersion) {
        throw const BackupFailure(
          'Backup is newer than this app or is damaged.',
        );
      }
    } on BackupFailure {
      rethrow;
    } on Object catch (error) {
      throw BackupFailure('Backup is unsupported or damaged.', cause: error);
    } finally {
      raw?.close();
    }

    final database = VaultDatabase(NativeDatabase(databaseFile));
    try {
      final integrity = await database
          .customSelect('PRAGMA integrity_check')
          .get();
      if (integrity.length != 1 || integrity.single.data.values.first != 'ok') {
        throw const BackupFailure('Backup is unsupported or damaged.');
      }
      final foreignKeys = await database
          .customSelect('PRAGMA foreign_key_check')
          .get();
      if (foreignKeys.isNotEmpty) {
        throw const BackupFailure('Backup is unsupported or damaged.');
      }
      final documentFiles = await database.select(database.documentFiles).get();
      for (final file in documentFiles) {
        if (!_safeRelativePath(file.encryptedRelativePath)) {
          throw const BackupFailure('Backup is unsupported or damaged.');
        }
        final restored = File(
          '${documentsDirectory.path}/${file.encryptedRelativePath}',
        );
        if (!await restored.exists() || await restored.length() <= 4) {
          throw const BackupFailure('Backup is unsupported or damaged.');
        }
        final signature = await restored
            .openRead(0, 4)
            .fold<List<int>>(<int>[], (value, bytes) => [...value, ...bytes]);
        if (signature.length != 4 ||
            signature[0] != 0x44 ||
            signature[1] != 0x56 ||
            signature[2] != 0x46 ||
            signature[3] != 0x31) {
          throw const BackupFailure('Backup is unsupported or damaged.');
        }
      }
      return RestoreSummary(
        backupDate: verification.manifest.createdAt,
        documentCount: (await database.select(database.documents).get()).length,
        familyMemberCount:
            (await database.select(database.familyMembers).get()).length,
        approximateSizeBytes: verification.sizeBytes,
        schemaVersion: database.schemaVersion,
      );
    } on BackupFailure {
      rethrow;
    } on Object catch (error) {
      throw BackupFailure('Backup is unsupported or damaged.', cause: error);
    } finally {
      await database.close();
    }
  }

  bool _safeRelativePath(String value) {
    final parts = value.split('/');
    return parts.length == 2 &&
        RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(parts[0]) &&
        RegExp(r'^[A-Za-z0-9_-]+\.dvf$').hasMatch(parts[1]);
  }
}

/// Private directory layout for a recoverable two-rename activation. Active,
/// staging, and rollback directories are siblings, so rename is atomic per
/// filesystem operation and the journal makes the pair recoverable on restart.
class FileSystemRestoreStorage {
  FileSystemRestoreStorage({
    required this.root,
    this.activeName = 'active_vault',
    this.databaseFilename = 'vault.sqlite',
  });
  final Directory root;
  final String activeName;
  final String databaseFilename;

  Directory get activeDirectory => Directory('${root.path}/$activeName');
  Directory get rollbackDirectory => Directory('${root.path}/rollback_restore');
  Directory get stagingRoot => Directory('${root.path}/staging_restore');
  File get markerFile => File('${root.path}/restore_recovery.json');

  Future<Directory> createStaging(String id) async {
    await root.create(recursive: true);
    final staging = Directory('${stagingRoot.path}/$id');
    if (await staging.exists()) {
      await staging.delete(recursive: true);
    }
    await staging.create(recursive: true);
    return staging;
  }

  File databaseIn(Directory vault) => File('${vault.path}/$databaseFilename');
  Directory documentsIn(Directory vault) =>
      Directory('${vault.path}/documents');

  Future<bool> createVerifiedRollback() async {
    if (!await activeDirectory.exists()) {
      return false;
    }
    if (await rollbackDirectory.exists()) {
      await rollbackDirectory.delete(recursive: true);
    }
    final pending = Directory('${rollbackDirectory.path}.partial');
    if (await pending.exists()) {
      await pending.delete(recursive: true);
    }
    await _copyDirectory(activeDirectory, pending);
    if (!await _sameTree(activeDirectory, pending)) {
      if (await pending.exists()) {
        await pending.delete(recursive: true);
      }
      throw const BackupFailure('Could not create a safe rollback snapshot.');
    }
    await pending.rename(rollbackDirectory.path);
    return true;
  }

  Future<void> activate(Directory staging) async {
    if (!await staging.exists()) {
      throw const BackupFailure('Restore staging is unavailable.');
    }
    final displaced = Directory('${root.path}/previous_active_restore');
    if (await displaced.exists()) {
      await displaced.delete(recursive: true);
    }
    if (await activeDirectory.exists()) {
      await activeDirectory.rename(displaced.path);
    }
    try {
      await staging.rename(activeDirectory.path);
      if (await displaced.exists()) {
        await displaced.delete(recursive: true);
      }
    } on Object catch (error) {
      if (!await activeDirectory.exists() && await displaced.exists()) {
        await displaced.rename(activeDirectory.path);
      }
      throw BackupFailure('Could not activate restored vault.', cause: error);
    }
  }

  Future<void> rollback() async {
    if (!await rollbackDirectory.exists()) {
      return;
    }
    final failed = Directory('${root.path}/failed_restore');
    if (await failed.exists()) {
      await failed.delete(recursive: true);
    }
    if (await activeDirectory.exists()) {
      await activeDirectory.rename(failed.path);
    }
    await rollbackDirectory.rename(activeDirectory.path);
    if (await failed.exists()) await failed.delete(recursive: true);
  }

  Future<void> writeMarker(String state, String id) async {
    await root.create(recursive: true);
    await markerFile.writeAsString(jsonEncode({'state': state, 'id': id}));
  }

  Future<Map<String, dynamic>?> readMarker() async {
    if (!await markerFile.exists()) return null;
    try {
      return jsonDecode(await markerFile.readAsString())
          as Map<String, dynamic>;
    } on Object {
      return null;
    }
  }

  Future<void> clearMarker() async {
    if (await markerFile.exists()) {
      await markerFile.delete();
    }
  }

  Future<void> cleanStaging() async {
    if (await stagingRoot.exists()) {
      await stagingRoot.delete(recursive: true);
    }
  }

  Future<void> cleanRollback() async {
    if (await rollbackDirectory.exists()) {
      await rollbackDirectory.delete(recursive: true);
    }
  }

  Future<void> reconcileInterruptedRestore() async {
    final marker = await readMarker();
    if (marker == null) return;
    final state = marker['state'];
    if (state == 'rollback_ready' || state == 'activated') {
      if (!await activeDirectory.exists()) {
        await rollback();
      } else {
        await cleanRollback();
      }
    }
    await cleanStaging();
    await clearMarker();
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await destination.create(recursive: true);
    await for (final entity in source.list(
      recursive: true,
      followLinks: false,
    )) {
      final relative = entity.path.substring(source.path.length + 1);
      final target = '${destination.path}/$relative';
      if (entity is Directory) {
        await Directory(target).create(recursive: true);
      } else if (entity is File) {
        await File(target).parent.create(recursive: true);
        await entity.openRead().pipe(File(target).openWrite());
      }
    }
  }

  Future<bool> _sameTree(Directory left, Directory right) async {
    final leftFiles = <String, File>{};
    final rightFiles = <String, File>{};
    await for (final entity in left.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        leftFiles[entity.path.substring(left.path.length + 1)] = entity;
      }
    }
    await for (final entity in right.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is File) {
        rightFiles[entity.path.substring(right.path.length + 1)] = entity;
      }
    }
    if (leftFiles.length != rightFiles.length) return false;
    for (final entry in leftFiles.entries) {
      final counterpart = rightFiles[entry.key];
      if (counterpart == null ||
          await entry.value.length() != await counterpart.length() ||
          await _sha256(entry.value) != await _sha256(counterpart)) {
        return false;
      }
    }
    return true;
  }

  Future<String> _sha256(File file) async {
    final sink = Sha256().toSync().newHashSink();
    await for (final bytes in file.openRead()) {
      sink.add(bytes);
    }
    sink.close();
    return base64Encode((await sink.hash()).bytes);
  }
}

class EncryptedRestoreService {
  EncryptedRestoreService(
    this._codec,
    this._storage, {
    DriftStagedVaultValidator? validator,
    RestoreCapacityProvider? capacity,
    RestorePostProcessor? postProcessor,
    Uuid? uuid,
  }) : _validator = validator ?? DriftStagedVaultValidator(),
       _capacity = capacity ?? const UnknownRestoreCapacityProvider(),
       _postProcessor = postProcessor ?? const NoopRestorePostProcessor(),
       _uuid = uuid ?? const Uuid();

  final BackupPackageCodec _codec;
  final FileSystemRestoreStorage _storage;
  final DriftStagedVaultValidator _validator;
  final RestoreCapacityProvider _capacity;
  final RestorePostProcessor _postProcessor;
  final Uuid _uuid;

  Future<BackupPackageHeader> inspect(File file) => _codec.inspectHeader(file);

  Future<PreparedRestore> prepare({
    required File backupFile,
    required BackupPassword password,
    void Function(RestoreProgress progress)? onProgress,
  }) async {
    onProgress?.call(const RestoreProgress(RestoreProgressStage.selecting));
    await _ensureCapacity(await backupFile.length());
    final id = _uuid.v4();
    final staging = await _storage.createStaging(id);
    try {
      onProgress?.call(
        const RestoreProgress(RestoreProgressStage.authenticating),
      );
      final header = await _codec.inspectHeader(backupFile);
      if (header.formatVersion != backupFormatVersion ||
          header.encryptionVersion != backupEncryptionVersion) {
        throw const BackupFailure('Backup is unsupported or damaged.');
      }
      onProgress?.call(const RestoreProgress(RestoreProgressStage.extracting));
      final verification = await _codec.extract(
        file: backupFile,
        password: password,
        databaseDestination: _storage.databaseIn(staging),
        documentsDestination: _storage.documentsIn(staging),
      );
      onProgress?.call(const RestoreProgress(RestoreProgressStage.validating));
      final summary = await _validator.migrateAndValidate(
        databaseFile: _storage.databaseIn(staging),
        documentsDirectory: _storage.documentsIn(staging),
        verification: verification,
      );
      return PreparedRestore(
        id: id,
        stagingDirectory: staging,
        summary: summary,
        verification: verification,
      );
    } on Object {
      if (await staging.exists()) {
        await staging.delete(recursive: true);
      }
      rethrow;
    }
  }

  Future<RestoreResult> activate(
    PreparedRestore prepared, {
    void Function(RestoreProgress progress)? onProgress,
  }) async {
    if (!await prepared.stagingDirectory.exists()) {
      throw const BackupFailure('Restore staging is unavailable.');
    }
    onProgress?.call(
      const RestoreProgress(RestoreProgressStage.creatingRollback),
    );
    final hasRollback = await _storage.createVerifiedRollback();
    await _storage.writeMarker('rollback_ready', prepared.id);
    try {
      onProgress?.call(const RestoreProgress(RestoreProgressStage.activating));
      await _storage.activate(prepared.stagingDirectory);
      await _storage.writeMarker('activated', prepared.id);
      onProgress?.call(const RestoreProgress(RestoreProgressStage.finalizing));
      await _postProcessor.recreateDeviceKeyProtection();
      await _postProcessor.requireNewPin();
      await _postProcessor.disableAndOfferBiometrics();
      await _postProcessor.rebuildSearch();
      await _postProcessor.reconcileNotifications();
      await _storage.cleanStaging();
      await _storage.cleanRollback();
      await _storage.clearMarker();
      return RestoreResult(
        summary: prepared.summary,
        replacedExisting: hasRollback,
      );
    } on Object catch (error) {
      if (hasRollback) await _storage.rollback();
      throw BackupFailure(
        'Could not restore this backup. Your previous vault was kept.',
        cause: error,
      );
    }
  }

  Future<void> reconcileAtStartup() => _storage.reconcileInterruptedRestore();

  Future<void> _ensureCapacity(int packageBytes) async {
    final available = await _capacity.availableBytes();
    // Staging, rollback, and filesystem overhead must fit before touching data.
    if (available != null && available < packageBytes * 3) {
      throw const InsufficientStorageFailure(
        'There is not enough private device storage to restore this backup.',
      );
    }
  }
}
