import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/services.dart';

import '../../../core/errors/app_failure.dart';
import '../application/cloud_backup_provider.dart';

/// Native code opens the system browser and returns only the redirect URI. The
/// authorization code is exchanged here with PKCE; no client secret is baked
/// into the mobile app and no token crosses a method-channel boundary.
class PlatformOAuthBackupProviderAuthenticator
    implements BackupProviderAuthenticator {
  PlatformOAuthBackupProviderAuthenticator({HttpClient Function()? client})
    : _client = client ?? HttpClient.new;

  static const _channel = MethodChannel('documentvault/cloud_oauth');
  final HttpClient Function() _client;

  @override
  Future<CloudAccessToken> authenticate({
    required BackupProviderDescriptor provider,
    required BackupProviderRegistration registration,
  }) async {
    _validateRegistration(registration);
    final state = _randomUrlSafe(24);
    final verifier = _randomUrlSafe(48);
    final digest = await Sha256().hash(utf8.encode(verifier));
    final challenge = base64UrlEncode(digest.bytes).replaceAll('=', '');
    final authorization = provider.authorizationEndpoint.replace(
      queryParameters: {
        ...provider.authorizationEndpoint.queryParameters,
        'response_type': 'code',
        'client_id': registration.clientId,
        'redirect_uri': registration.redirectUri.toString(),
        'scope': provider.scopes.join(' '),
        'state': state,
        'code_challenge': challenge,
        'code_challenge_method': 'S256',
        ...provider.authorizationParameters,
      },
    );
    final redirected = await _openAuthorization(
      authorization,
      registration.redirectUri.scheme,
    );
    if (redirected.queryParameters['state'] != state) {
      throw const CloudBackupFailure('Cloud sign-in could not be verified.');
    }
    final code = redirected.queryParameters['code'];
    if (code == null || code.isEmpty) {
      throw const CloudBackupFailure('Cloud sign-in was cancelled or failed.');
    }
    return _exchange(provider.tokenEndpoint, {
      'grant_type': 'authorization_code',
      'client_id': registration.clientId,
      'code': code,
      'redirect_uri': registration.redirectUri.toString(),
      'code_verifier': verifier,
    });
  }

  @override
  Future<CloudAccessToken> refresh({
    required BackupProviderDescriptor provider,
    required BackupProviderRegistration registration,
    required String refreshToken,
  }) async {
    _validateRegistration(registration);
    final refreshed = await _exchange(provider.tokenEndpoint, {
      'grant_type': 'refresh_token',
      'client_id': registration.clientId,
      'refresh_token': refreshToken,
    });
    return CloudAccessToken(
      accessToken: refreshed.accessToken,
      refreshToken: refreshed.refreshToken ?? refreshToken,
      expiresAt: refreshed.expiresAt,
    );
  }

  Future<Uri> _openAuthorization(Uri authorization, String scheme) async {
    try {
      final raw = await _channel.invokeMethod<String>('authorize', {
        'authorizationUrl': authorization.toString(),
        'redirectScheme': scheme,
      });
      final value = raw == null ? null : Uri.tryParse(raw);
      if (value == null || value.scheme != scheme) {
        throw const CloudBackupFailure(
          'Cloud sign-in was cancelled or failed.',
        );
      }
      return value;
    } on CloudBackupFailure {
      rethrow;
    } on PlatformException catch (error) {
      throw CloudBackupFailure(
        'Cloud sign-in is unavailable on this device.',
        cause: error,
      );
    } on MissingPluginException catch (error) {
      throw CloudBackupFailure(
        'Cloud sign-in is unavailable on this device.',
        cause: error,
      );
    }
  }

  Future<CloudAccessToken> _exchange(
    Uri endpoint,
    Map<String, String> form,
  ) async {
    final client = _client();
    try {
      final request = await client.postUrl(endpoint);
      request.headers.contentType = ContentType(
        'application',
        'x-www-form-urlencoded',
      );
      request.write(Uri(queryParameters: form).query);
      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const CloudBackupFailure(
          'Cloud sign-in could not be completed. Try again later.',
          retryable: true,
        );
      }
      final json = Map<String, dynamic>.from(jsonDecode(body) as Map);
      final accessToken = json['access_token'] as String?;
      if (accessToken == null || accessToken.isEmpty) {
        throw const CloudBackupFailure('Cloud sign-in could not be completed.');
      }
      final expires = json['expires_in'];
      return CloudAccessToken(
        accessToken: accessToken,
        refreshToken: json['refresh_token'] as String?,
        expiresAt: expires is num
            ? DateTime.now().toUtc().add(Duration(seconds: expires.toInt()))
            : null,
      );
    } on CloudBackupFailure {
      rethrow;
    } on Object catch (error) {
      throw CloudBackupFailure(
        'Cloud sign-in could not be completed. Try again later.',
        cause: error,
        retryable: true,
      );
    } finally {
      client.close(force: true);
    }
  }

  void _validateRegistration(BackupProviderRegistration registration) {
    if (registration.clientId.trim().isEmpty ||
        registration.redirectUri.scheme != 'documentvault' ||
        registration.redirectUri.host != 'oauth') {
      throw const CloudBackupFailure('Cloud provider setup is unavailable.');
    }
  }

  String _randomUrlSafe(int bytes) {
    final random = Random.secure();
    final value = List<int>.generate(bytes, (_) => random.nextInt(256));
    return base64UrlEncode(value).replaceAll('=', '');
  }
}
