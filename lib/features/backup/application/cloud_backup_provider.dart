import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/errors/app_failure.dart';

enum BackupProviderId { googleDrive, oneDrive, dropbox }

class BackupProviderDescriptor {
  const BackupProviderDescriptor({
    required this.id,
    required this.label,
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    required this.scopes,
    this.authorizationParameters = const {},
  });

  final BackupProviderId id;
  final String label;
  final Uri authorizationEndpoint;
  final Uri tokenEndpoint;
  final Set<String> scopes;

  /// Provider-specific, non-secret OAuth parameters. These are used only for
  /// standards-compliant refresh-token requests (for example, offline access).
  final Map<String, String> authorizationParameters;
}

/// OAuth registration is supplied by the release environment. Client IDs and
/// redirect URIs are deliberately not hardcoded into the application.
class BackupProviderRegistration {
  const BackupProviderRegistration({
    required this.clientId,
    required this.redirectUri,
  });
  final String clientId;
  final Uri redirectUri;
}

class CloudAccessToken {
  const CloudAccessToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;

  bool get isExpired =>
      expiresAt != null && !expiresAt!.isAfter(DateTime.now().toUtc());

  Map<String, Object?> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresAt': expiresAt?.toUtc().toIso8601String(),
  };

  factory CloudAccessToken.fromJson(Map<String, dynamic> value) =>
      CloudAccessToken(
        accessToken: value['accessToken'] as String,
        refreshToken: value['refreshToken'] as String?,
        expiresAt: value['expiresAt'] == null
            ? null
            : DateTime.parse(value['expiresAt'] as String).toUtc(),
      );
}

abstract interface class BackupProviderTokenStore {
  Future<CloudAccessToken?> read(BackupProviderId provider);
  Future<void> write(BackupProviderId provider, CloudAccessToken token);
  Future<void> delete(BackupProviderId provider);
}

/// OAuth tokens are held by Keychain/Keystore-backed secure storage, never by
/// Drift, shared preferences, backup packages, logs, or app settings.
class SecureBackupProviderTokenStore implements BackupProviderTokenStore {
  const SecureBackupProviderTokenStore([
    this._storage = const FlutterSecureStorage(),
  ]);

  final FlutterSecureStorage _storage;
  static const _prefix = 'document_vault.cloud_backup.oauth.v1.';

  String _key(BackupProviderId provider) => '$_prefix${provider.name}';

  @override
  Future<CloudAccessToken?> read(BackupProviderId provider) async {
    final raw = await _storage.read(key: _key(provider));
    if (raw == null) return null;
    try {
      return CloudAccessToken.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } on Object catch (error) {
      await delete(provider);
      throw CloudBackupFailure(
        'Cloud connection needs to be reconnected.',
        cause: error,
      );
    }
  }

  @override
  Future<void> write(BackupProviderId provider, CloudAccessToken token) =>
      _storage.write(key: _key(provider), value: jsonEncode(token.toJson()));

  @override
  Future<void> delete(BackupProviderId provider) =>
      _storage.delete(key: _key(provider));
}

enum CloudNetworkState { online, offline, unknown }

abstract interface class CloudNetworkMonitor {
  Future<CloudNetworkState> current();
}

class AssumedOnlineNetworkMonitor implements CloudNetworkMonitor {
  const AssumedOnlineNetworkMonitor();
  @override
  Future<CloudNetworkState> current() async => CloudNetworkState.unknown;
}

class CloudBackupVersion {
  const CloudBackupVersion({
    required this.id,
    required this.createdAt,
    required this.sizeBytes,
  });

  /// Opaque provider object ID. It is not a document title or backup filename.
  final String id;
  final DateTime createdAt;
  final int sizeBytes;
}

/// Runs the provider's OAuth authorization-code PKCE flow. Platform/browser
/// handling is injected to keep provider UI out of the persistence layer.
abstract interface class BackupProviderAuthenticator {
  Future<CloudAccessToken> authenticate({
    required BackupProviderDescriptor provider,
    required BackupProviderRegistration registration,
  });

  Future<CloudAccessToken> refresh({
    required BackupProviderDescriptor provider,
    required BackupProviderRegistration registration,
    required String refreshToken,
  });
}

/// Provider-specific REST implementations stream encrypted `.dvbak` files.
/// They must not inspect, decrypt, index, or log their contents.
abstract interface class CloudBackupTransport {
  Future<CloudBackupVersion> upload({
    required CloudAccessToken token,
    required File encryptedBackup,
  });
  Future<List<CloudBackupVersion>> list({required CloudAccessToken token});
  Future<void> download({
    required CloudAccessToken token,
    required String versionId,
    required File destination,
  });
  Future<void> delete({
    required CloudAccessToken token,
    required String versionId,
  });
}

/// Contract for Google Drive, OneDrive and Dropbox adapters. Only encrypted
/// portable packages cross this boundary; no document CRUD exists here.
abstract interface class BackupProvider {
  BackupProviderId get id;
  BackupProviderDescriptor get descriptor;
  Future<bool> isConnected();
  Future<void> authenticate();
  Future<CloudBackupVersion> uploadEncryptedBackup(File verifiedPackage);
  Future<List<CloudBackupVersion>> listBackups();
  Future<void> downloadBackup({
    required String versionId,
    required File destination,
  });
  Future<void> deleteBackup(String versionId);
  Future<void> disconnect();
}

abstract class OAuthBackupProvider implements BackupProvider {
  OAuthBackupProvider({
    required this.id,
    required this.descriptor,
    required this._registration,
    required this._authenticator,
    required this._transport,
    required this._tokens,
    this._network = const AssumedOnlineNetworkMonitor(),
    this._retry = const CloudBackupRetryPolicy(),
  });

  @override
  final BackupProviderId id;
  @override
  final BackupProviderDescriptor descriptor;
  final BackupProviderRegistration _registration;
  final BackupProviderAuthenticator _authenticator;
  final CloudBackupTransport _transport;
  final BackupProviderTokenStore _tokens;
  final CloudNetworkMonitor _network;
  final CloudBackupRetryPolicy _retry;

  @override
  Future<bool> isConnected() async => await _tokens.read(id) != null;

  @override
  Future<void> authenticate() async {
    await _requireNetwork();
    try {
      final token = await _authenticator.authenticate(
        provider: descriptor,
        registration: _registration,
      );
      await _tokens.write(id, token);
    } on CloudBackupFailure {
      rethrow;
    } on Object catch (error) {
      throw CloudBackupFailure(
        'Could not connect this cloud provider.',
        cause: error,
      );
    }
  }

  @override
  Future<CloudBackupVersion> uploadEncryptedBackup(File verifiedPackage) async {
    await _requireEncryptedPackage(verifiedPackage);
    return _withToken(
      (token) => _retry.run(
        () => _transport.upload(token: token, encryptedBackup: verifiedPackage),
      ),
    );
  }

  @override
  Future<List<CloudBackupVersion>> listBackups() =>
      _withToken((token) => _retry.run(() => _transport.list(token: token)));

  @override
  Future<void> downloadBackup({
    required String versionId,
    required File destination,
  }) async {
    if (versionId.isEmpty) {
      throw const ValidationFailure('Choose a cloud backup version.');
    }
    await _withToken((token) async {
      await destination.parent.create(recursive: true);
      final pending = File('${destination.path}.partial');
      try {
        await _retry.run(
          () => _transport.download(
            token: token,
            versionId: versionId,
            destination: pending,
          ),
        );
        await _requireEncryptedPackage(pending);
        await pending.rename(destination.path);
      } on Object {
        if (await pending.exists()) await pending.delete();
        rethrow;
      }
    });
  }

  @override
  Future<void> deleteBackup(String versionId) => _withToken(
    (token) =>
        _retry.run(() => _transport.delete(token: token, versionId: versionId)),
  );

  @override
  Future<void> disconnect() async {
    // Disconnect never deletes remotely stored encrypted backups. The user can
    // still restore them by reconnecting or using a downloaded copy.
    await _tokens.delete(id);
  }

  Future<T> _withToken<T>(
    Future<T> Function(CloudAccessToken token) action,
  ) async {
    await _requireNetwork();
    var token = await _tokens.read(id);
    if (token == null) {
      throw const CloudBackupFailure(
        'Connect a cloud provider before continuing.',
      );
    }
    if (token.isExpired) {
      final refresh = token.refreshToken;
      if (refresh == null || refresh.isEmpty) {
        await _tokens.delete(id);
        throw const CloudBackupFailure(
          'Cloud connection needs to be reconnected.',
        );
      }
      try {
        token = await _authenticator.refresh(
          provider: descriptor,
          registration: _registration,
          refreshToken: refresh,
        );
        await _tokens.write(id, token);
      } on Object catch (error) {
        await _tokens.delete(id);
        throw CloudBackupFailure(
          'Cloud connection needs to be reconnected.',
          cause: error,
        );
      }
    }
    try {
      return await action(token);
    } on CloudBackupFailure {
      rethrow;
    } on Object catch (error) {
      throw CloudBackupFailure(
        'Cloud backup could not be completed. Try again when connected.',
        cause: error,
        retryable: true,
      );
    }
  }

  Future<void> _requireNetwork() async {
    if (await _network.current() == CloudNetworkState.offline) {
      throw const CloudBackupFailure(
        'You are offline. Connect to the internet and try again.',
        retryable: true,
      );
    }
  }

  Future<void> _requireEncryptedPackage(File file) async {
    if (!await file.exists() || await file.length() < 8) {
      throw const CloudBackupFailure(
        'Encrypted backup package is unavailable.',
      );
    }
    final magic = await file
        .openRead(0, 4)
        .fold<List<int>>(<int>[], (previous, bytes) => [...previous, ...bytes]);
    if (magic.length != 4 ||
        magic[0] != 0x44 ||
        magic[1] != 0x56 ||
        magic[2] != 0x42 ||
        magic[3] != 0x4b) {
      throw const CloudBackupFailure(
        'Only verified encrypted backups can be uploaded.',
      );
    }
  }
}

class GoogleDriveBackupProvider extends OAuthBackupProvider {
  GoogleDriveBackupProvider({
    required super.registration,
    required super.authenticator,
    required super.transport,
    required super.tokens,
    super.network,
    super.retry,
  }) : super(
         id: BackupProviderId.googleDrive,
         descriptor: BackupProviderDescriptor(
           id: BackupProviderId.googleDrive,
           label: 'Google Drive',
           authorizationEndpoint: Uri(
             scheme: 'https',
             host: 'accounts.google.com',
             path: '/o/oauth2/v2/auth',
           ),
           tokenEndpoint: Uri(
             scheme: 'https',
             host: 'oauth2.googleapis.com',
             path: '/token',
           ),
           scopes: {'https://www.googleapis.com/auth/drive.appdata'},
           authorizationParameters: {'access_type': 'offline'},
         ),
       );
}

class OneDriveBackupProvider extends OAuthBackupProvider {
  OneDriveBackupProvider({
    required super.registration,
    required super.authenticator,
    required super.transport,
    required super.tokens,
    super.network,
    super.retry,
  }) : super(
         id: BackupProviderId.oneDrive,
         descriptor: BackupProviderDescriptor(
           id: BackupProviderId.oneDrive,
           label: 'OneDrive',
           authorizationEndpoint: Uri(
             scheme: 'https',
             host: 'login.microsoftonline.com',
             path: '/consumers/oauth2/v2.0/authorize',
           ),
           tokenEndpoint: Uri(
             scheme: 'https',
             host: 'login.microsoftonline.com',
             path: '/consumers/oauth2/v2.0/token',
           ),
           scopes: {'Files.ReadWrite.AppFolder', 'offline_access'},
         ),
       );
}

class DropboxBackupProvider extends OAuthBackupProvider {
  DropboxBackupProvider({
    required super.registration,
    required super.authenticator,
    required super.transport,
    required super.tokens,
    super.network,
    super.retry,
  }) : super(
         id: BackupProviderId.dropbox,
         descriptor: BackupProviderDescriptor(
           id: BackupProviderId.dropbox,
           label: 'Dropbox',
           authorizationEndpoint: Uri(
             scheme: 'https',
             host: 'www.dropbox.com',
             path: '/oauth2/authorize',
           ),
           tokenEndpoint: Uri(
             scheme: 'https',
             host: 'api.dropboxapi.com',
             path: '/oauth2/token',
           ),
           scopes: {'files.content.write', 'files.content.read'},
           authorizationParameters: {'token_access_type': 'offline'},
         ),
       );
}

/// Bounded retry applies only to the current already-verified staging file.
/// It never persistently queues a token, password, or plaintext package.
class CloudBackupRetryPolicy {
  const CloudBackupRetryPolicy({
    this.maxAttempts = 3,
    this.delay = Duration.zero,
  }) : assert(maxAttempts >= 1 && maxAttempts <= 5);
  final int maxAttempts;
  final Duration delay;

  Future<T> run<T>(Future<T> Function() action) async {
    CloudBackupFailure? lastFailure;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        return await action();
      } on CloudBackupFailure catch (error) {
        lastFailure = error;
        if (!error.retryable || attempt == maxAttempts - 1) rethrow;
        if (delay > Duration.zero) await Future<void>.delayed(delay);
      }
    }
    throw lastFailure ??
        const CloudBackupFailure('Cloud backup could not be completed.');
  }
}
