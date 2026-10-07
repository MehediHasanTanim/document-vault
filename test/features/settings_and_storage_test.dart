import 'dart:async';
import 'dart:io';

import 'package:documentvault/core/crypto/vault_data_protector.dart';
import 'package:documentvault/core/database/repositories.dart';
import 'package:documentvault/core/database/vault_database.dart';
import 'package:documentvault/core/errors/app_failure.dart';
import 'package:documentvault/core/files/file_reference.dart';
import 'package:documentvault/features/authentication/application/biometric_authenticator.dart';
import 'package:documentvault/features/reminders/application/local_notification_gateway.dart';
import 'package:documentvault/features/reminders/application/reminder_models.dart';
import 'package:documentvault/features/settings/application/privacy_permissions_service.dart';
import 'package:documentvault/features/settings/application/settings_models.dart';
import 'package:documentvault/features/settings/application/storage_management_service.dart';
import 'package:documentvault/features/settings/application/vault_settings_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 10, 7);

  test(
    'persists encrypted general, security, and notification preferences',
    () async {
      final repository = _MemorySettings();
    final service = VaultSettingsService(
      repository,
      const _PrefixProtector(),
      privacyDisplay: const NoopPrivacyDisplayController(),
      clock: () => now,
    );
      await service.saveGeneral(
        const GeneralSettings(languageCode: 'bn', theme: 'dark'),
      );
      await service.saveSecurity(
        const SecuritySettings(
          biometricsEnabled: true,
          autoLock: AutoLockPreference.minutes5,
        ),
      );
      await service.saveNotifications(
        const NotificationSettings(defaultOffsets: [60, 7, 7, 0]),
      );

      expect(
        repository.values.values.every((value) => value.startsWith('enc:')),
        isTrue,
      );
      expect((await service.general()).languageCode, 'bn');
      expect((await service.general()).theme, 'dark');
      expect((await service.security()).autoLock, AutoLockPreference.minutes5);
      expect((await service.notifications()).defaultOffsets, [60, 7, 0]);
    },
  );

  test(
    'reports storage, clears only disposable artifacts, and checks files',
    () async {
      final root = await Directory.systemTemp.createTemp('vault-settings-');
      addTearDown(() => root.delete(recursive: true));
      final databaseFile = File('${root.path}/vault.sqlite');
      final database = VaultDatabase(NativeDatabase(databaseFile));
      addTearDown(database.close);
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
              titleEncrypted: 'title',
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
              sizeBytes: 4096,
              integrityHash: 'a' * 64,
              encryptionVersion: 1,
              createdAt: now,
            ),
          );
      await database
          .into(database.documentPages)
          .insert(
            DocumentPagesCompanion.insert(
              id: 'page-1',
              documentId: 'document-1',
              documentFileId: 'file-1',
              pageNumber: 1,
              createdAt: now,
            ),
          );
      final attachments = Directory('${root.path}/documents')..createSync();
      final temp = Directory('${root.path}/temp')..createSync();
      final thumbnails = Directory('${root.path}/thumbnails')..createSync();
      final cache = Directory('${root.path}/cache')..createSync();
      await File('${attachments.path}/stored.dvf')
          .writeAsBytes(List.filled(20, 1));
      await File('${temp.path}/safe.tmp').writeAsBytes([1]);
      await File('${cache.path}/thumb.tmp').writeAsBytes([1]);
      await File('${thumbnails.path}/thumb').writeAsBytes(List.filled(10, 1));
      final service = StorageManagementService(
        database,
        VaultStoragePaths(
          database: databaseFile,
          attachments: attachments,
          temporary: temp,
          thumbnails: thumbnails,
          cache: cache,
        ),
        files: const _CheckingFileStore(),
      );

      final report = await service.report();
      expect(report.documentCount, 1);
      expect(report.pageCount, 1);
      expect(report.fileCount, 1);
      expect(report.attachmentBytes, 20);
      expect(report.thumbnailBytes, 10);
      expect(report.estimatedBackupBytes, greaterThanOrEqualTo(20));
      expect((await service.findLargeFiles()).single.fileId, 'file-1');
      await service.clearSafeTemporaryFiles();
      expect(await temp.list().isEmpty, isTrue);
      expect(await cache.list().isEmpty, isTrue);
      expect(await File('${attachments.path}/stored.dvf').exists(), isTrue);
      expect((await service.runIntegrityCheck()).isHealthy, isTrue);
      await expectLater(
        service.emptyTrash(confirmed: false),
        throwsA(isA<ValidationFailure>()),
      );
    },
  );

  test(
    'reports privacy statuses without initiating a permission request',
    () async {
      final permissions = _Permissions();
      final service = PrivacyPermissionsService(
        permissions,
        const _Notifications(),
        const _Biometrics(),
      );
      final snapshot = await service.status();
      expect(snapshot.camera, DeviceAccessStatus.denied);
      expect(snapshot.photosAndFiles, DeviceAccessStatus.granted);
      expect(snapshot.notifications, DeviceAccessStatus.permanentlyDenied);
      expect(snapshot.biometrics, DeviceAccessStatus.granted);
      expect(permissions.requested, isFalse);
    },
  );
}

class _MemorySettings implements SettingsRepository {
  final values = <String, String>{};
  @override
  Future<void> delete(String key) async => values.remove(key);
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Stream<String?> watch(String key) => Stream.value(values[key]);
  @override
  Future<void> write(
    String key,
    String encryptedValue,
    DateTime updatedAt,
  ) async => values[key] = encryptedValue;
}

class _PrefixProtector implements VaultDataProtector {
  const _PrefixProtector();
  @override
  Future<String> decrypt(String ciphertext, {required String context}) async =>
      ciphertext.substring(4);
  @override
  Future<String> encrypt(String plaintext, {required String context}) async =>
      'enc:$plaintext';
  @override
  Future<String> normalizedNameHash(String value, {required String context}) =>
      Future.value(value);
}

class _CheckingFileStore implements SecureFileStore {
  const _CheckingFileStore();
  @override
  Future<void> delete(SecureFileReference reference) async {}
  @override
  Future<Stream<List<int>>> readDecrypted(
    SecureFileReference reference,
  ) async => Stream.value(const [1]);
  @override
  Future<SecureFileReference> writeEncrypted({
    required String documentId,
    required Stream<List<int>> bytes,
    required String mimeType,
  }) => throw UnimplementedError();
}

class _Permissions implements DevicePrivacyPermissions {
  var requested = false;
  @override
  Future<DeviceAccessStatus> camera() async => DeviceAccessStatus.denied;
  @override
  Future<void> openSettings() async {}
  @override
  Future<DeviceAccessStatus> photosAndFiles() async =>
      DeviceAccessStatus.granted;
  @override
  Future<DeviceAccessStatus> requestCamera() async {
    requested = true;
    return DeviceAccessStatus.granted;
  }

  @override
  Future<DeviceAccessStatus> requestPhotosAndFiles() async {
    requested = true;
    return DeviceAccessStatus.granted;
  }
}

class _Notifications implements LocalNotificationGateway {
  const _Notifications();
  @override
  Future<void> cancel(int notificationId) async {}
  @override
  Future<void> openSettings() async {}
  @override
  Future<int> pendingCount() async => 0;
  @override
  Future<LocalNotificationPermission> permission() async =>
      LocalNotificationPermission.permanentlyDenied;
  @override
  Future<LocalNotificationPermission> requestPermission() async =>
      LocalNotificationPermission.permanentlyDenied;
  @override
  Future<void> schedule({
    required int notificationId,
    required DateTime at,
    required PrivateNotificationContent content,
  }) async {}
}

class _Biometrics implements BiometricAuthenticator {
  const _Biometrics();
  @override
  Future<bool> authenticate() async => false;
  @override
  Future<BiometricAvailability> availability() async =>
      BiometricAvailability.available;
}
