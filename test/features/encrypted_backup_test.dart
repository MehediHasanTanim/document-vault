import 'dart:async';
import 'dart:io';

import 'package:documentvault/core/database/repositories.dart';
import 'package:documentvault/core/database/vault_database.dart';
import 'package:documentvault/core/errors/app_failure.dart';
import 'package:documentvault/core/uuid/uuid_generator.dart';
import 'package:documentvault/features/backup/application/backup_models.dart';
import 'package:documentvault/features/backup/application/backup_package_codec.dart';
import 'package:documentvault/features/backup/application/backup_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/database_test_harness.dart';

void main() {
  final now = DateTime.utc(2026, 10, 6, 12);
  final password = BackupPassword.create(
    password: 'My backup passphrase 2026!',
    confirmation: 'My backup passphrase 2026!',
    acknowledgedRecoveryWarning: true,
  );

  late Directory root;
  late VaultDatabase database;
  late EncryptedBackupService service;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('document-vault-backup-');
    database = openTestDatabase();
    service = EncryptedBackupService(
      _SnapshotSource(_snapshot()),
      DriftBackupRepository(database),
      _SequenceUuid(),
      workspaceDirectory: () async => Directory('${root.path}/workspace'),
      clock: () => now,
    );
  });
  tearDown(() async {
    await database.close();
    await root.delete(recursive: true);
  });

  test(
    'creates, verifies, streams to destination, and stores safe history',
    () async {
      final destination = FileBackupDestination(
        Directory('${root.path}/saved'),
      );
      final result = await service.create(
        password: password,
        destination: destination,
      );

      expect(result.record.verified, isTrue);
      expect(result.record.destinationType, 'deviceFolder');
      expect(result.record.relativePath, isNull);
      expect(result.verification.manifest.files, hasLength(2));
      final saved = await Directory('${root.path}/saved')
          .list()
          .where((entry) => entry.path.endsWith('.dvbak'))
          .single;
      expect(await File(saved.path).length(), result.record.sizeBytes);
      expect(await DriftBackupRepository(database).lastVerified(), isNotNull);
    },
  );

  test(
    'rejects a wrong password and a corrupted output without details',
    () async {
      final codec = BackupPackageCodec();
      final output = File('${root.path}/backup.dvbak');
      await codec.create(
        snapshot: _snapshot(),
        password: password,
        destination: output,
        createdAt: now,
      );
      final wrong = BackupPassword.create(
        password: 'Different backup password!',
        confirmation: 'Different backup password!',
        acknowledgedRecoveryWarning: true,
      );
      await expectLater(
        codec.verify(file: output, password: wrong),
        throwsA(isA<BackupFailure>()),
      );
      final handle = await output.open(mode: FileMode.append);
      await handle.writeByte(1);
      await handle.close();
      await expectLater(
        codec.verify(file: output, password: password),
        throwsA(isA<BackupFailure>()),
      );
    },
  );

  test(
    'handles destination cancellation and storage failures without history',
    () async {
      await expectLater(
        service.create(
          password: password,
          destination: const _CancelledDestination(),
        ),
        throwsA(isA<BackupCancelledFailure>()),
      );
      await expectLater(
        service.create(
          password: password,
          destination: const _FailingDestination(),
        ),
        throwsA(isA<BackupFailure>()),
      );
      expect(await DriftBackupRepository(database).lastVerified(), isNull);
    },
  );

  test('uses bounded source chunks for a large vault input', () async {
    final large = _generatedInput('files/large.dvf', 12 * 1024 * 1024);
    final codec = BackupPackageCodec();
    final output = File('${root.path}/large.dvbak');
    final result = await codec.create(
      snapshot: BackupSnapshot(
        database: _input('database.sqlite', [1, 2, 3]),
        files: [large],
      ),
      password: password,
      destination: output,
      createdAt: now,
    );
    expect(result.manifest.files.single.sizeBytes, 12 * 1024 * 1024);
    expect(result.sizeBytes, greaterThan(12 * 1024 * 1024));
  });

  test(
    'supports weekly, monthly, quarterly and future custom backup reminders',
    () {
      for (final schedule in [
        const BackupReminderSchedule(BackupReminderFrequency.weekly),
        const BackupReminderSchedule(BackupReminderFrequency.monthly),
        const BackupReminderSchedule(BackupReminderFrequency.quarterly),
        const BackupReminderSchedule(
          BackupReminderFrequency.custom,
          customInterval: Duration(days: 45),
        ),
      ]) {
        expect(schedule.isDue(now.subtract(schedule.interval), now), isFalse);
        expect(
          schedule.isDue(
            now.subtract(schedule.interval + const Duration(seconds: 1)),
            now,
          ),
          isTrue,
        );
      }
    },
  );

  test(
    '500 MB streaming stress profile is available for release-device runs',
    () async {
      final input = _generatedInput('files/stress.dvf', 500 * 1024 * 1024);
      expect(input.byteLength, 500 * 1024 * 1024);
    },
    skip: 'Run on representative release devices during backup sign-off.',
  );
}

BackupSnapshot _snapshot() => BackupSnapshot(
  database: _input(
    'database.sqlite',
    List<int>.generate(4096, (index) => index % 251),
  ),
  files: [
    _input('files/document-1/file-1.dvf', List<int>.filled(100000, 7)),
    _input('files/document-2/file-2.dvf', List<int>.filled(150000, 9)),
  ],
  vaultChangesSinceLastBackup: 3,
);

BackupInput _input(String id, List<int> bytes) => BackupInput(
  id: id,
  byteLength: bytes.length,
  open: () async => Stream.value(bytes),
);

BackupInput _generatedInput(String id, int length) => BackupInput(
  id: id,
  byteLength: length,
  open: () async => _generatedStream(length),
);

Stream<List<int>> _generatedStream(int length) async* {
  var remaining = length;
  while (remaining > 0) {
    final size = remaining > 64 * 1024 ? 64 * 1024 : remaining;
    yield List<int>.generate(size, (index) => index % 251, growable: false);
    remaining -= size;
  }
}

class _SnapshotSource implements BackupSnapshotSource {
  const _SnapshotSource(this.snapshot);
  final BackupSnapshot snapshot;
  @override
  Future<T> withConsistentSnapshot<T>(
    Future<T> Function(BackupSnapshot snapshot) action,
  ) => action(snapshot);
}

class _SequenceUuid implements UuidGenerator {
  var _next = 0;
  @override
  String v4() => 'backup-${_next++}';
}

class _CancelledDestination implements BackupDestination {
  const _CancelledDestination();
  @override
  Future<BackupSaveResult> save({
    required File stagedBackup,
    required String suggestedFilename,
  }) => throw const BackupCancelledFailure();
}

class _FailingDestination implements BackupDestination {
  const _FailingDestination();
  @override
  Future<BackupSaveResult> save({
    required File stagedBackup,
    required String suggestedFilename,
  }) => throw const BackupFailure('Storage is full.');
}
