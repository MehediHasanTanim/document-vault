import 'package:flutter/services.dart';

import '../application/vault_settings_service.dart';

/// Applies screen capture/recent-app protection where Android or iOS supports
/// it. Unsupported platforms intentionally retain the user's preference for a
/// later supported device rather than failing a settings save.
class PlatformPrivacyDisplayController implements PrivacyDisplayController {
  const PlatformPrivacyDisplayController();
  static const _channel = MethodChannel('documentvault/privacy_display');

  @override
  Future<void> apply({
    required bool hideInAppSwitcher,
    required bool screenshotProtection,
  }) async {
    try {
      await _channel.invokeMethod<void>('apply', {
        'hideInAppSwitcher': hideInAppSwitcher,
        'screenshotProtection': screenshotProtection,
      });
    } on MissingPluginException {
      // Desktop/web and older app shells have no equivalent platform control.
    } on PlatformException {
      // Retain the preference and allow settings to remain usable if the OS
      // does not permit the requested protection at runtime.
    }
  }
}
