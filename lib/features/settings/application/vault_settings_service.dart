import '../../../core/crypto/vault_data_protector.dart';
import '../../../core/database/repositories.dart';
import '../../../core/errors/app_failure.dart';
import '../../authentication/application/vault_security_manager.dart';
import '../infrastructure/platform_privacy_display_controller.dart';
import 'settings_models.dart';

/// Platform privacy controls are deliberately narrow: iOS/Android adapters can
/// apply what their OS supports without changing the user's stored choice.
abstract interface class PrivacyDisplayController {
  Future<void> apply({
    required bool hideInAppSwitcher,
    required bool screenshotProtection,
  });
}

class NoopPrivacyDisplayController implements PrivacyDisplayController {
  const NoopPrivacyDisplayController();
  @override
  Future<void> apply({
    required bool hideInAppSwitcher,
    required bool screenshotProtection,
  }) async {}
}

/// Lets notification code cancel/reconcile schedules when global preferences
/// change. The concrete scheduler remains independent of settings storage.
abstract interface class NotificationPreferencesApplier {
  Future<void> apply(NotificationSettings settings);
}

class NoopNotificationPreferencesApplier
    implements NotificationPreferencesApplier {
  const NoopNotificationPreferencesApplier();
  @override
  Future<void> apply(NotificationSettings settings) async {}
}

/// Encrypted configuration for settings that live inside the unlocked vault.
/// App start language/theme remain mirrored in shared preferences so they can
/// be honored before the vault is unlocked.
class VaultSettingsService {
  VaultSettingsService(
    this._repository,
    this._protector, {
    this.pinSecurity,
    PrivacyDisplayController? privacyDisplay,
    NotificationPreferencesApplier? notificationApplier,
    DateTime Function()? clock,
  }) : _privacyDisplay =
           privacyDisplay ?? const PlatformPrivacyDisplayController(),
       _notificationApplier =
           notificationApplier ?? const NoopNotificationPreferencesApplier(),
       _clock = clock ?? DateTime.now;

  static const _generalKey = 'settings.general.v1';
  static const _securityKey = 'settings.security.v1';
  static const _notificationsKey = 'settings.notifications.v1';

  final SettingsRepository _repository;
  final VaultDataProtector _protector;
  final VaultSecurityManager? pinSecurity;
  final PrivacyDisplayController _privacyDisplay;
  final NotificationPreferencesApplier _notificationApplier;
  final DateTime Function() _clock;

  Future<GeneralSettings> general() =>
      _read(_generalKey, GeneralSettings.new, GeneralSettings.fromJson);
  Future<SecuritySettings> security() =>
      _read(_securityKey, SecuritySettings.new, SecuritySettings.fromJson);
  Future<NotificationSettings> notifications() => _read(
    _notificationsKey,
    NotificationSettings.new,
    NotificationSettings.fromJson,
  );

  Future<void> saveGeneral(GeneralSettings value) =>
      _write(_generalKey, value.toJson());

  Future<void> saveSecurity(SecuritySettings value) async {
    await _privacyDisplay.apply(
      hideInAppSwitcher: value.hideInAppSwitcher,
      screenshotProtection: value.screenshotProtection,
    );
    await _write(_securityKey, value.toJson());
  }

  Future<void> saveNotifications(NotificationSettings value) async {
    await _notificationApplier.apply(value);
    await _write(_notificationsKey, value.toJson());
  }

  Future<void> changePin({
    required String currentPin,
    required String newPin,
    required String confirmation,
  }) async {
    if (newPin != confirmation) {
      throw const ValidationFailure('New PINs do not match.');
    }
    final security = pinSecurity;
    if (security == null) {
      throw const SecurityFailure('PIN changes are unavailable until setup.');
    }
    await security.changePin(currentPin, newPin);
  }

  Future<T> _read<T>(
    String key,
    T Function() fallback,
    T Function(Map<String, dynamic>) parse,
  ) async {
    final encrypted = await _repository.read(key);
    if (encrypted == null) return fallback();
    try {
      return parse(
        decodeSettings(await _protector.decrypt(encrypted, context: key)),
      );
    } on Object catch (error) {
      throw StorageFailure('Settings could not be read safely.', cause: error);
    }
  }

  Future<void> _write(String key, Map<String, Object?> value) async {
    final encrypted = await _protector.encrypt(
      encodeSettings(value),
      context: key,
    );
    await _repository.write(key, encrypted, _clock().toUtc());
  }
}
