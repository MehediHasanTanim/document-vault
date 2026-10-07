import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pull request template requires all ten security answers', () async {
    final template = await File('.github/PULL_REQUEST_TEMPLATE.md')
        .readAsString();
    const requiredPrompts = [
      'Plaintext sensitive storage',
      'Decrypted-data lifetime',
      'Sensitive logs',
      'Temporary files',
      'Notification exposure',
      'Screenshot exposure',
      'Backup compatibility',
      'Key or encryption migration',
      'Restore',
      'App death midway',
    ];

    for (final prompt in requiredPrompts) {
      expect(template, contains(prompt));
    }
    expect(template, contains('security reviewer'));
    expect(template, contains('flutter analyze'));
  });

  test('security workstream documents enforceable recovery policy', () async {
    final policy = await File(
      'docs/testing/Cross_Sprint_Security_Workstream.md',
    ).readAsString();

    for (final requirement in [
      'private encrypted storage',
      'operation journal',
      'atomic activation',
      'verified rollback',
      'Android `FLAG_SECURE`',
      'iOS app-switcher privacy cover',
      'SecureLogger',
    ]) {
      expect(policy, contains(requirement));
    }
  });

  test('critical privacy and recovery controls remain wired', () async {
    final android = await File(
      'android/app/src/main/kotlin/com/nextgenai/documentvault/MainActivity.kt',
    ).readAsString();
    final ios = await File('ios/Runner/AppDelegate.swift').readAsString();
    final notifications = await File(
      'lib/features/reminders/infrastructure/flutter_local_notification_gateway.dart',
    ).readAsString();
    final backupCodec = await File(
      'lib/features/backup/application/backup_package_codec.dart',
    ).readAsString();
    final restore = await File(
      'lib/features/backup/application/restore_service.dart',
    ).readAsString();
    final maintenance = await File(
      'lib/core/reliability/vault_startup_maintenance.dart',
    ).readAsString();

    expect(android, contains('FLAG_SECURE'));
    expect(ios, contains('willResignActiveNotification'));
    expect(ios, contains('showPrivacyCover'));
    expect(notifications, contains('NotificationVisibility.private'));
    expect(notifications, contains("payload: 'vault-reminder'"));
    expect(backupCodec, contains('Future<BackupVerificationResult> verify'));
    expect(backupCodec, contains('associated authenticated data'));
    expect(restore, contains('staging_restore'));
    expect(restore, contains('createVerifiedRollback'));
    expect(restore, contains('Future<void> rollback'));
    expect(maintenance, contains('reconcileAtStartup'));
    expect(maintenance, contains('cleanTemporaryWorkspace'));
  });
}
