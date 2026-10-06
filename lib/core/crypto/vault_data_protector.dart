import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import '../errors/app_failure.dart';

/// Encrypts sensitive metadata before it reaches Drift. The unlock flow owns
/// the [SecretKey]; feature code receives this narrow capability instead.
abstract interface class VaultDataProtector {
  Future<String> encrypt(String plaintext, {required String context});
  Future<String> decrypt(String ciphertext, {required String context});
  Future<String> normalizedNameHash(String value, {required String context});
}

class AesGcmVaultDataProtector implements VaultDataProtector {
  AesGcmVaultDataProtector(this._key);
  final SecretKey _key;
  final Cipher _cipher = AesGcm.with256bits();
  final MacAlgorithm _hmac = Hmac.sha256();

  @override
  Future<String> encrypt(String plaintext, {required String context}) async {
    final box = await _cipher.encrypt(
      utf8.encode(plaintext),
      secretKey: _key,
      aad: utf8.encode(context),
    );
    return jsonEncode({
      'v': 1,
      'n': base64Encode(box.nonce),
      'c': base64Encode(box.cipherText),
      'm': base64Encode(box.mac.bytes),
    });
  }

  @override
  Future<String> decrypt(String ciphertext, {required String context}) async {
    try {
      final envelope = jsonDecode(ciphertext) as Map<String, dynamic>;
      if (envelope['v'] != 1) {
        throw const FormatException('Unsupported encrypted metadata version.');
      }
      final plaintext = await _cipher.decrypt(
        SecretBox(
          base64Decode(envelope['c'] as String),
          nonce: base64Decode(envelope['n'] as String),
          mac: Mac(base64Decode(envelope['m'] as String)),
        ),
        secretKey: _key,
        aad: utf8.encode(context),
      );
      return utf8.decode(plaintext);
    } on Object catch (error) {
      throw StorageFailure(
        'Encrypted vault metadata could not be verified.',
        cause: error,
      );
    }
  }

  @override
  Future<String> normalizedNameHash(
    String value, {
    required String context,
  }) async {
    final normalized = value.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    final mac = await _hmac.calculateMac(
      utf8.encode('$context:$normalized'),
      secretKey: _key,
    );
    return mac.bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}
