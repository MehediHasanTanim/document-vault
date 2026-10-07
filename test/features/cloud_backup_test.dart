import 'dart:io';

import 'package:documentvault/core/errors/app_failure.dart';
import 'package:documentvault/features/backup/application/cloud_backup_provider.dart';
import 'package:documentvault/features/backup/application/cloud_backup_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;
  late File package;
  late _Tokens tokens;
  late _Authenticator authenticator;
  late _Transport transport;
  late _Network network;
  late GoogleDriveBackupProvider provider;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('documentvault-cloud-test-');
    package = File('${root.path}/encrypted.dvbak');
    await package.writeAsBytes([0x44, 0x56, 0x42, 0x4b, 1, 2, 3, 4]);
    tokens = _Tokens();
    authenticator = _Authenticator();
    transport = _Transport();
    network = _Network();
    provider = GoogleDriveBackupProvider(
      registration: BackupProviderRegistration(
        clientId: 'configured-client-id',
        redirectUri: Uri(scheme: 'documentvault', host: 'oauth'),
      ),
      authenticator: authenticator,
      transport: transport,
      tokens: tokens,
      network: network,
      retry: const CloudBackupRetryPolicy(maxAttempts: 2),
    );
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test(
    'authenticates through the broker and uploads only encrypted packages',
    () async {
      expect(
        provider.descriptor.authorizationParameters['access_type'],
        'offline',
      );
      await provider.authenticate();
      expect(await provider.isConnected(), isTrue);
      expect(authenticator.authorizeCalls, 1);

      final version = await provider.uploadEncryptedBackup(package);
      expect(version.id, 'remote-1');
      expect(transport.uploads, 1);
      expect(transport.uploadedBytes, [0x44, 0x56, 0x42, 0x4b, 1, 2, 3, 4]);

      final invalid = File('${root.path}/not-encrypted.dvbak');
      await invalid.writeAsBytes([1, 2, 3, 4]);
      await expectLater(
        provider.uploadEncryptedBackup(invalid),
        throwsA(isA<CloudBackupFailure>()),
      );
      expect(transport.uploads, 1);
    },
  );

  test('uses bounded retry for transient upload failure', () async {
    await provider.authenticate();
    transport.transientUploadFailures = 1;

    await provider.uploadEncryptedBackup(package);

    expect(transport.uploads, 2);
  });

  test('rejects cloud operations when explicitly offline', () async {
    await provider.authenticate();
    network.value = CloudNetworkState.offline;

    await expectLater(
      provider.listBackups(),
      throwsA(isA<CloudBackupFailure>()),
    );
    expect(transport.listCalls, 0);
  });

  test('refreshes an expired token and disconnect removes only local authorization', () async {
    tokens.value = CloudAccessToken(
      accessToken: 'expired',
      refreshToken: 'refresh',
      expiresAt: DateTime.utc(2020),
    );

    await provider.listBackups();
    expect(authenticator.refreshCalls, 1);
    expect(transport.listCalls, 1);

    await provider.disconnect();
    expect(tokens.value, isNull);
    expect(
      transport.deletes,
      0,
      reason: 'Disconnect does not delete cloud backups',
    );
  });

  test('retention keeps last N versions after a verified upload', () async {
    await provider.authenticate();
    final now = DateTime.utc(2026, 10, 7);
    transport.versions.addAll([
      CloudBackupVersion(
        id: 'oldest',
        createdAt: now.subtract(const Duration(days: 3)),
        sizeBytes: 1,
      ),
      CloudBackupVersion(
        id: 'middle',
        createdAt: now.subtract(const Duration(days: 2)),
        sizeBytes: 1,
      ),
      CloudBackupVersion(
        id: 'recent',
        createdAt: now.subtract(const Duration(days: 1)),
        sizeBytes: 1,
      ),
    ]);
    final manager = CloudBackupManager(
      provider,
      retention: const CloudBackupRetentionPolicy(maxVersions: 2),
    );

    final result = await manager.uploadVerified(package);

    expect(result.retentionDeleted, 2);
    expect(result.retentionCleanupSucceeded, isTrue);
    expect(transport.deletedIds, containsAll(['oldest', 'middle']));
    expect(
      transport.versions.map((value) => value.id),
      contains(result.version.id),
    );
  });

  test('downloads to a private workspace and removes it on disposal', () async {
    await provider.authenticate();
    final manager = CloudBackupManager(provider);
    final download = await manager.download(
      CloudBackupVersion(
        id: 'remote-existing',
        createdAt: DateTime.utc(2026, 10, 7),
        sizeBytes: 8,
      ),
      workspaceDirectory: () async => root,
    );

    expect(await download.file.readAsBytes(), [
      0x44,
      0x56,
      0x42,
      0x4b,
      1,
      2,
      3,
      4,
    ]);
    final workspace = download.file.parent;
    await download.dispose();
    expect(await workspace.exists(), isFalse);
  });
}

class _Tokens implements BackupProviderTokenStore {
  CloudAccessToken? value;
  @override
  Future<void> delete(BackupProviderId provider) async => value = null;
  @override
  Future<CloudAccessToken?> read(BackupProviderId provider) async => value;
  @override
  Future<void> write(BackupProviderId provider, CloudAccessToken token) async =>
      value = token;
}

class _Authenticator implements BackupProviderAuthenticator {
  var authorizeCalls = 0;
  var refreshCalls = 0;

  @override
  Future<CloudAccessToken> authenticate({
    required BackupProviderDescriptor provider,
    required BackupProviderRegistration registration,
  }) async {
    authorizeCalls++;
    return CloudAccessToken(
      accessToken: 'access',
      refreshToken: 'refresh',
      expiresAt: DateTime.utc(2099),
    );
  }

  @override
  Future<CloudAccessToken> refresh({
    required BackupProviderDescriptor provider,
    required BackupProviderRegistration registration,
    required String refreshToken,
  }) async {
    refreshCalls++;
    return CloudAccessToken(
      accessToken: 'new-access',
      refreshToken: refreshToken,
      expiresAt: DateTime.utc(2099),
    );
  }
}

class _Network implements CloudNetworkMonitor {
  var value = CloudNetworkState.online;
  @override
  Future<CloudNetworkState> current() async => value;
}

class _Transport implements CloudBackupTransport {
  final versions = <CloudBackupVersion>[];
  final deletedIds = <String>[];
  var uploads = 0;
  var listCalls = 0;
  var deletes = 0;
  var transientUploadFailures = 0;
  List<int>? uploadedBytes;

  @override
  Future<void> delete({
    required CloudAccessToken token,
    required String versionId,
  }) async {
    deletes++;
    deletedIds.add(versionId);
    versions.removeWhere((version) => version.id == versionId);
  }

  @override
  Future<void> download({
    required CloudAccessToken token,
    required String versionId,
    required File destination,
  }) => destination.writeAsBytes([0x44, 0x56, 0x42, 0x4b, 1, 2, 3, 4]);

  @override
  Future<List<CloudBackupVersion>> list({
    required CloudAccessToken token,
  }) async {
    listCalls++;
    return List.of(versions);
  }

  @override
  Future<CloudBackupVersion> upload({
    required CloudAccessToken token,
    required File encryptedBackup,
  }) async {
    uploads++;
    if (transientUploadFailures > 0) {
      transientUploadFailures--;
      throw const CloudBackupFailure(
        'Temporary provider issue.',
        retryable: true,
      );
    }
    uploadedBytes = await encryptedBackup.readAsBytes();
    final version = CloudBackupVersion(
      id: 'remote-$uploads',
      createdAt: DateTime.utc(2026, 10, 7, 12, uploads),
      sizeBytes: uploadedBytes!.length,
    );
    versions.add(version);
    return version;
  }
}
