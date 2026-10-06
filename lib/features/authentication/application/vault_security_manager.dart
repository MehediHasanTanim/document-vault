import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/validation/validators.dart';

abstract interface class VaultMetadataStore {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> delete();
}

class SecureVaultMetadataStore implements VaultMetadataStore {
  const SecureVaultMetadataStore([
    this._storage = const FlutterSecureStorage(),
  ]);
  static const _key = 'document_vault.security.v1';
  final FlutterSecureStorage _storage;
  @override
  Future<String?> read() => _storage.read(key: _key);
  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);
  @override
  Future<void> delete() => _storage.delete(key: _key);
}

class VaultSecurityManager {
  VaultSecurityManager(this._store, {DateTime Function()? now, Uuid? uuid})
    : _now = now ?? DateTime.now,
      _uuid = uuid ?? const Uuid();
  static const _iterations = 210000;
  final VaultMetadataStore _store;
  final DateTime Function() _now;
  final Uuid _uuid;
  final _cipher = AesGcm.with256bits();
  final _kdf = Pbkdf2.hmacSha256(iterations: _iterations, bits: 256);
  SecretKeyData? _masterKey;

  bool get isUnlocked => _masterKey != null;
  Future<bool> get hasVault async => await _store.read() != null;

  Future<String> createVault(String pin) async {
    final error = Validators.sixDigitPin(pin);
    if (error != null) {
      throw ValidationFailure(error);
    }
    if (await hasVault) {
      throw const SecurityFailure('A vault already exists on this device.');
    }
    final master = SecretKeyData.random(length: 32);
    final record = await _wrap(master, pin, vaultId: _uuid.v4());
    await _store.write(jsonEncode(record));
    _masterKey = master;
    return record['vaultId']! as String;
  }

  Future<bool> unlockWithPin(String pin) async {
    final raw = await _store.read();
    if (raw == null) {
      return false;
    }
    final record = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final retryAfter = DateTime.tryParse(record['retryAfter'] as String? ?? '');
    if (retryAfter != null && _now().isBefore(retryAfter)) {
      throw const SecurityFailure('Too many attempts. Try again shortly.');
    }
    try {
      final master = await _unwrap(record, pin);
      record
        ..['failedAttempts'] = 0
        ..remove('retryAfter');
      await _store.write(jsonEncode(record));
      _masterKey = master;
      return true;
    } on SecretBoxAuthenticationError {
      final attempts = (record['failedAttempts'] as int? ?? 0) + 1;
      record['failedAttempts'] = attempts;
      if (attempts >= 3) {
        record['retryAfter'] = _now()
            .add(Duration(seconds: min(60, 1 << min(attempts - 3, 5))))
            .toIso8601String();
      }
      await _store.write(jsonEncode(record));
      return false;
    }
  }

  Future<void> changePin(String currentPin, String newPin) async {
    if (!isUnlocked && !await unlockWithPin(currentPin)) {
      throw const SecurityFailure('Current PIN is incorrect.');
    }
    final error = Validators.sixDigitPin(newPin);
    if (error != null) {
      throw ValidationFailure(error);
    }
    final raw = await _store.read();
    if (raw == null || _masterKey == null) {
      throw const SecurityFailure('Vault key is unavailable.');
    }
    final old = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final replacement = await _wrap(
      _masterKey!,
      newPin,
      vaultId: old['vaultId'] as String,
    );
    await _store.write(jsonEncode(replacement));
  }

  Future<void> lock() async {
    _masterKey?.destroy();
    _masterKey = null;
  }

  Future<Map<String, dynamic>> _wrap(
    SecretKeyData master,
    String pin, {
    required String vaultId,
  }) async {
    final salt = _randomBytes(16);
    final nonce = _randomBytes(12);
    final pinKey = await _kdf.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );
    final box = await _cipher.encrypt(
      await master.extractBytes(),
      secretKey: pinKey,
      nonce: nonce,
      aad: utf8.encode(vaultId),
    );
    return {
      'version': 1,
      'vaultId': vaultId,
      'kdf': 'PBKDF2-HMAC-SHA256',
      'iterations': _iterations,
      'salt': base64Encode(salt),
      'nonce': base64Encode(box.nonce),
      'ciphertext': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
      'failedAttempts': 0,
    };
  }

  Future<SecretKeyData> _unwrap(Map<String, dynamic> record, String pin) async {
    final salt = base64Decode(record['salt'] as String);
    final pinKey = await _kdf.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );
    final box = SecretBox(
      base64Decode(record['ciphertext'] as String),
      nonce: base64Decode(record['nonce'] as String),
      mac: Mac(base64Decode(record['mac'] as String)),
    );
    final bytes = await _cipher.decrypt(
      box,
      secretKey: pinKey,
      aad: utf8.encode(record['vaultId'] as String),
    );
    return SecretKeyData(bytes);
  }

  List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }
}

class MemoryVaultMetadataStore implements VaultMetadataStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String value) async => this.value = value;
  @override
  Future<void> delete() async => value = null;
}
