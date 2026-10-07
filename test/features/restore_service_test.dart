import 'dart:io';

import 'package:documentvault/core/database/vault_database.dart';
import 'package:documentvault/core/errors/app_failure.dart';
import 'package:documentvault/features/backup/application/backup_models.dart';
import 'package:documentvault/features/backup/application/backup_package_codec.dart';
import 'package:documentvault/features/backup/application/restore_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  const passwordText = 'A durable backup passphrase 2026!';
  final password = BackupPassword.forRestore(passwordText);

  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('document-vault-restore-');
  });
  tearDown(() => root.delete(recursive: true));

  test('authenticates, stages, validates, activates, and finalizes restore', () async {
    final source = await _createSourceVault(root);
    final backup = await _createBackup(root, source, password: password);
    final storage = FileSystemRestoreStorage(
      root: Directory('${root.path}/restore'),
    );
    final processor = _RecordingPostProcessor();
    final service = EncryptedRestoreService(
      BackupPackageCodec(),
      storage,
      postProcessor: processor,
    );

    final prepared = await service.prepare(
      backupFile: backup,
      password: password,
    );

    expect(prepared.summary.documentCount, 1);
    expect(prepared.summary.familyMemberCount, 0);
    expect(await storage.activeDirectory.exists(), isFalse);
    final result = await service.activate(prepared);

    expect(result.replacedExisting, isFalse);
    expect(await storage.databaseIn(storage.activeDirectory).exists(), isTrue);
    expect(
      await File(
        '${storage.documentsIn(storage.activeDirectory).path}/document-1/file-1.dvf',
      ).exists(),
      isTrue,
    );
    expect(processor.steps, [
      'key',
      'pin',
      'biometrics',
      'search',
      'notifications',
    ]);
    expect(await storage.markerFile.exists(), isFalse);
    expect(await storage.rollbackDirectory.exists(), isFalse);
  });

  test(
    'keeps active vault untouched for wrong password and low storage',
    () async {
      final source = await _createSourceVault(root);
      final backup = await _createBackup(root, source, password: password);
      final storage = FileSystemRestoreStorage(
        root: Directory('${root.path}/restore'),
      );
      await storage.activeDirectory.create(recursive: true);
      final old = File('${storage.activeDirectory.path}/old.txt');
      await old.writeAsString('keep');

      final service = EncryptedRestoreService(BackupPackageCodec(), storage);
      await expectLater(
        service.prepare(
          backupFile: backup,
          password: BackupPassword.forRestore('Wrong password 2026!'),
        ),
        throwsA(isA<BackupFailure>()),
      );
      expect(await old.readAsString(), 'keep');

      final constrained = EncryptedRestoreService(
        BackupPackageCodec(),
        storage,
        capacity: const _FixedCapacity(1),
      );
      await expectLater(
        constrained.prepare(backupFile: backup, password: password),
        throwsA(isA<InsufficientStorageFailure>()),
      );
      expect(await old.readAsString(), 'keep');
    },
  );

  test(
    'rejects backup with a database reference to a missing encrypted file',
    () async {
      final source = await _createSourceVault(root);
      final backup = await _createBackup(
        root,
        source,
        password: password,
        includeDocumentFile: false,
      );
      final storage = FileSystemRestoreStorage(
        root: Directory('${root.path}/restore'),
      );
      final service = EncryptedRestoreService(BackupPackageCodec(), storage);

      await expectLater(
        service.prepare(backupFile: backup, password: password),
        throwsA(isA<BackupFailure>()),
      );
      expect(await storage.stagingRoot.exists(), isTrue);
      expect(await storage.stagingRoot.list().isEmpty, isTrue);
    },
  );

  test(
    'rejects corrupted databases and backup schemas newer than this app',
    () async {
      final source = await _createSourceVault(root);
      final raw = sqlite.sqlite3.open(source.databaseFile.path);
      raw.execute(
        'PRAGMA user_version = ${VaultDatabase.currentSchemaVersion + 1}',
      );
      raw.close();
      final newer = await _createBackup(
        root,
        source,
        password: password,
        name: 'newer.dvbak',
      );
      final storage = FileSystemRestoreStorage(
        root: Directory('${root.path}/restore'),
      );
      final service = EncryptedRestoreService(BackupPackageCodec(), storage);
      await expectLater(
        service.prepare(backupFile: newer, password: password),
        throwsA(isA<BackupFailure>()),
      );

      final damagedDatabase = File('${root.path}/not-a-database.sqlite');
      await damagedDatabase.writeAsBytes(const [1, 2, 3, 4]);
      final corrupted = File('${root.path}/corrupted.dvbak');
      await BackupPackageCodec().create(
        snapshot: BackupSnapshot(
          database: _input('database.sqlite', damagedDatabase),
          files: const [],
        ),
        password: password,
        destination: corrupted,
        createdAt: DateTime.utc(2026, 10, 7),
      );
      await expectLater(
        service.prepare(backupFile: corrupted, password: password),
        throwsA(isA<BackupFailure>()),
      );
    },
  );

  test(
    'rolls back after a post-activation failure and recovers interruption',
    () async {
      final source = await _createSourceVault(root);
      final backup = await _createBackup(root, source, password: password);
      final storage = FileSystemRestoreStorage(
        root: Directory('${root.path}/restore'),
      );
      await storage.activeDirectory.create(recursive: true);
      final old = File('${storage.activeDirectory.path}/old.txt');
      await old.writeAsString('previous vault');
      final service = EncryptedRestoreService(
        BackupPackageCodec(),
        storage,
        postProcessor: const _FailingPostProcessor(),
      );
      final prepared = await service.prepare(
        backupFile: backup,
        password: password,
      );

      await expectLater(
        service.activate(prepared),
        throwsA(isA<BackupFailure>()),
      );
      expect(await old.readAsString(), 'previous vault');

      await storage.rollbackDirectory.create(recursive: true);
      await File('${storage.rollbackDirectory.path}/old.txt')
          .writeAsString('interrupted previous vault');
      await storage.activeDirectory.delete(recursive: true);
      await storage.writeMarker('activated', 'interrupted');
      await service.reconcileAtStartup();

      expect(await old.readAsString(), 'interrupted previous vault');
      expect(await storage.markerFile.exists(), isFalse);
    },
  );
}

Future<_SourceVault> _createSourceVault(Directory root) async {
  final source = Directory('${root.path}/source');
  await source.create(recursive: true);
  final databaseFile = File('${source.path}/vault.sqlite');
  final database = VaultDatabase(NativeDatabase(databaseFile));
  final now = DateTime.utc(2026, 10, 7);
  await database
      .into(database.documentCategories)
      .insert(
        DocumentCategoriesCompanion.insert(
          id: 'identity',
          code: 'identity',
          createdAt: now,
          updatedAt: now,
        ),
      );
  await database
      .into(database.documents)
      .insert(
        DocumentsCompanion.insert(
          id: 'document-1',
          titleEncrypted: 'encrypted title',
          categoryId: 'identity',
          createdAt: now,
          updatedAt: now,
        ),
      );
  await database
      .into(database.documentFiles)
      .insert(
        DocumentFilesCompanion.insert(
          id: 'file-1',
          documentId: 'document-1',
          mimeType: 'application/pdf',
          encryptedRelativePath: 'document-1/file-1.dvf',
          sizeBytes: 5,
          integrityHash: 'integrity',
          encryptionVersion: 1,
          createdAt: now,
        ),
      );
  await database.close();
  final encryptedFile = File('${source.path}/documents/document-1/file-1.dvf');
  await encryptedFile.parent.create(recursive: true);
  await encryptedFile.writeAsBytes(const [0x44, 0x56, 0x46, 0x31, 0x01]);
  return _SourceVault(databaseFile, encryptedFile);
}

Future<File> _createBackup(
  Directory root,
  _SourceVault source, {
  required BackupPassword password,
  bool includeDocumentFile = true,
  String name = 'backup.dvbak',
}) async {
  final output = File('${root.path}/$name');
  await BackupPackageCodec().create(
    snapshot: BackupSnapshot(
      database: _input('database.sqlite', source.databaseFile),
      files: includeDocumentFile
          ? [_input('files/document-1/file-1.dvf', source.encryptedFile)]
          : const [],
    ),
    password: password,
    destination: output,
    createdAt: DateTime.utc(2026, 10, 7),
  );
  return output;
}

BackupInput _input(String id, File file) => BackupInput(
  id: id,
  byteLength: file.lengthSync(),
  open: () async => file.openRead(),
);

class _SourceVault {
  const _SourceVault(this.databaseFile, this.encryptedFile);
  final File databaseFile;
  final File encryptedFile;
}

class _FixedCapacity implements RestoreCapacityProvider {
  const _FixedCapacity(this.value);
  final int value;
  @override
  Future<int?> availableBytes() async => value;
}

class _RecordingPostProcessor implements RestorePostProcessor {
  final steps = <String>[];
  @override
  Future<void> disableAndOfferBiometrics() async => steps.add('biometrics');
  @override
  Future<void> recreateDeviceKeyProtection() async => steps.add('key');
  @override
  Future<void> rebuildSearch() async => steps.add('search');
  @override
  Future<void> reconcileNotifications() async => steps.add('notifications');
  @override
  Future<void> requireNewPin() async => steps.add('pin');
}

class _FailingPostProcessor implements RestorePostProcessor {
  const _FailingPostProcessor();
  @override
  Future<void> disableAndOfferBiometrics() async {}
  @override
  Future<void> recreateDeviceKeyProtection() =>
      Future<void>.error(StateError('simulated post-restore failure'));
  @override
  Future<void> rebuildSearch() async {}
  @override
  Future<void> reconcileNotifications() async {}
  @override
  Future<void> requireNewPin() async {}
}
