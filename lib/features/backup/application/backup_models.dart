import 'dart:convert';

import '../../../../core/errors/app_failure.dart';

const backupFormatVersion = 1;
const backupEncryptionVersion = 1;
const backupKdfParameterVersion = 1;

class BackupPassword {
  const BackupPassword._(this._value);
  final String _value;

  /// The raw value is intentionally available only to the immediate backup
  /// operation. Never retain this object in state, logs, settings, or history.
  String get value => _value;

  static BackupPassword create({
    required String password,
    required String confirmation,
    required bool acknowledgedRecoveryWarning,
  }) {
    if (password != confirmation) {
      throw const ValidationFailure('Backup passwords do not match.');
    }
    if (!acknowledgedRecoveryWarning) {
      throw const ValidationFailure(
        'Confirm that a forgotten backup password cannot be recovered.',
      );
    }
    if (passwordStrength(password) == BackupPasswordStrength.weak) {
      throw const ValidationFailure(
        'Use at least 12 characters with a mix of words, numbers, or symbols.',
      );
    }
    return BackupPassword._(password);
  }

  /// Wraps a password supplied to open an existing backup. Restore must not
  /// impose current password-creation rules on older user backups.
  static BackupPassword forRestore(String password) {
    if (password.isEmpty) {
      throw const ValidationFailure('Enter the backup password.');
    }
    return BackupPassword._(password);
  }

  static BackupPasswordStrength passwordStrength(String value) {
    if (value.length < 12) return BackupPasswordStrength.weak;
    final groups = [
      RegExp(r'[a-z]').hasMatch(value),
      RegExp(r'[A-Z]').hasMatch(value),
      RegExp(r'[0-9]').hasMatch(value),
      RegExp(r'[^A-Za-z0-9]').hasMatch(value),
    ].where((matched) => matched).length;
    return value.length >= 16 && groups >= 3
        ? BackupPasswordStrength.strong
        : BackupPasswordStrength.good;
  }
}

enum BackupPasswordStrength { weak, good, strong }

class BackupKdfParameters {
  const BackupKdfParameters({
    this.version = backupKdfParameterVersion,
    this.algorithm = 'pbkdf2-hmac-sha256',
    this.iterations = 310000,
    this.bits = 256,
  });
  final int version;
  final String algorithm;
  final int iterations;
  final int bits;

  Map<String, Object> toJson() => {
    'version': version,
    'algorithm': algorithm,
    'iterations': iterations,
    'bits': bits,
  };

  factory BackupKdfParameters.fromJson(Map<String, dynamic> json) {
    final value = BackupKdfParameters(
      version: json['version'] as int,
      algorithm: json['algorithm'] as String,
      iterations: json['iterations'] as int,
      bits: json['bits'] as int,
    );
    if (value.version != backupKdfParameterVersion ||
        value.algorithm != 'pbkdf2-hmac-sha256' ||
        value.bits != 256 ||
        value.iterations < 100000 ||
        value.iterations > 1000000) {
      throw const BackupFailure('Backup is unsupported or damaged.');
    }
    return value;
  }
}

class BackupPackageHeader {
  const BackupPackageHeader({
    required this.salt,
    required this.kdf,
    this.formatVersion = backupFormatVersion,
    this.encryptionVersion = backupEncryptionVersion,
    this.chunkSize = 64 * 1024,
  });
  final List<int> salt;
  final BackupKdfParameters kdf;
  final int formatVersion;
  final int encryptionVersion;
  final int chunkSize;

  Map<String, Object> toJson() => {
    'formatVersion': formatVersion,
    'encryptionVersion': encryptionVersion,
    'kdf': kdf.toJson(),
    'salt': base64Encode(salt),
    'chunkSize': chunkSize,
  };

  factory BackupPackageHeader.fromJson(Map<String, dynamic> json) {
    final header = BackupPackageHeader(
      formatVersion: json['formatVersion'] as int,
      encryptionVersion: json['encryptionVersion'] as int,
      kdf: BackupKdfParameters.fromJson(json['kdf'] as Map<String, dynamic>),
      salt: base64Decode(json['salt'] as String),
      chunkSize: json['chunkSize'] as int,
    );
    if (header.formatVersion != backupFormatVersion ||
        header.encryptionVersion != backupEncryptionVersion ||
        header.salt.length != 16 ||
        header.chunkSize < 4096 ||
        header.chunkSize > 1024 * 1024) {
      throw const BackupFailure('Backup is unsupported or damaged.');
    }
    return header;
  }
}

class BackupInput {
  const BackupInput({
    required this.id,
    required this.byteLength,
    required this.open,
  });
  final String id;
  final int byteLength;
  final Future<Stream<List<int>>> Function() open;
}

class BackupSnapshot {
  const BackupSnapshot({
    required this.database,
    required this.files,
    this.vaultChangesSinceLastBackup = 0,
  });
  final BackupInput database;
  final List<BackupInput> files;
  final int vaultChangesSinceLastBackup;
}

class BackupManifestEntry {
  const BackupManifestEntry({
    required this.id,
    required this.sizeBytes,
    required this.sha256,
  });
  final String id;
  final int sizeBytes;
  final String sha256;

  Map<String, Object> toJson() => {
    'id': id,
    'sizeBytes': sizeBytes,
    'sha256': sha256,
  };

  factory BackupManifestEntry.fromJson(Map<String, dynamic> json) =>
      BackupManifestEntry(
        id: json['id'] as String,
        sizeBytes: json['sizeBytes'] as int,
        sha256: json['sha256'] as String,
      );
}

class BackupManifest {
  const BackupManifest({
    required this.createdAt,
    required this.database,
    required this.files,
  });
  final DateTime createdAt;
  final BackupManifestEntry database;
  final List<BackupManifestEntry> files;

  Map<String, Object> toJson() => {
    'createdAt': createdAt.toUtc().toIso8601String(),
    'database': database.toJson(),
    'files': files.map((value) => value.toJson()).toList(),
  };

  factory BackupManifest.fromJson(Map<String, dynamic> json) => BackupManifest(
    createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    database: BackupManifestEntry.fromJson(
      json['database'] as Map<String, dynamic>,
    ),
    files: (json['files'] as List<dynamic>)
        .map(
          (entry) =>
              BackupManifestEntry.fromJson(entry as Map<String, dynamic>),
        )
        .toList(growable: false),
  );
}

class BackupVerificationResult {
  const BackupVerificationResult({
    required this.header,
    required this.manifest,
    required this.sizeBytes,
  });
  final BackupPackageHeader header;
  final BackupManifest manifest;
  final int sizeBytes;
}

class RestoreSummary {
  const RestoreSummary({
    required this.backupDate,
    required this.documentCount,
    required this.familyMemberCount,
    required this.approximateSizeBytes,
    required this.schemaVersion,
  });
  final DateTime backupDate;
  final int documentCount;
  final int familyMemberCount;
  final int approximateSizeBytes;
  final int schemaVersion;
}

enum RestoreProgressStage {
  selecting,
  authenticating,
  extracting,
  validating,
  creatingRollback,
  activating,
  finalizing,
}

class RestoreProgress {
  const RestoreProgress(this.stage);
  final RestoreProgressStage stage;
}

enum BackupDestinationType { deviceFolder, systemProvider, cloudProvider }

class BackupSaveResult {
  const BackupSaveResult({required this.destinationType});
  final BackupDestinationType destinationType;
}

enum BackupReminderFrequency { weekly, monthly, quarterly, custom }

class BackupReminderSchedule {
  const BackupReminderSchedule(this.frequency, {this.customInterval});
  final BackupReminderFrequency frequency;
  final Duration? customInterval;

  Duration get interval => switch (frequency) {
    BackupReminderFrequency.weekly => const Duration(days: 7),
    BackupReminderFrequency.monthly => const Duration(days: 30),
    BackupReminderFrequency.quarterly => const Duration(days: 90),
    BackupReminderFrequency.custom =>
      customInterval ?? const Duration(days: 30),
  };

  bool isDue(DateTime? lastBackup, DateTime now) =>
      lastBackup == null || now.isAfter(lastBackup.add(interval));
}
