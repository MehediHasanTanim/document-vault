import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/cloud_backup_provider.dart';
import '../application/cloud_backup_service.dart';

/// Release configuration injects reviewed providers and the existing encrypted
/// backup/restore actions here. The default is intentionally disabled: an
/// unregistered provider must never be exposed as an active cloud destination.
final cloudBackupFeatureProvider = Provider<CloudBackupFeature>(
  (ref) => const CloudBackupFeature.disabled(),
);

class CloudBackupFeature {
  const CloudBackupFeature({
    required this.providers,
    this.createEncryptedBackup,
    this.restoreVersion,
  });

  const CloudBackupFeature.disabled()
    : providers = const [],
      createEncryptedBackup = null,
      restoreVersion = null;

  final List<BackupProvider> providers;
  final Future<void> Function(CloudBackupManager manager)?
  createEncryptedBackup;
  final Future<void> Function(
    CloudBackupManager manager,
    CloudBackupVersion version,
  )?
  restoreVersion;
}
