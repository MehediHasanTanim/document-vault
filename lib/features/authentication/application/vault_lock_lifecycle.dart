import 'dart:async';

import 'package:flutter/widgets.dart';

import 'vault_security_manager.dart';

/// Coordinates app lifecycle locking. Presentation supplies its configured
/// timeout; sensitive services are cleared before the vault state changes.
class VaultLockLifecycle with WidgetsBindingObserver {
  VaultLockLifecycle(
    this._security, {
    this.timeout = const Duration(minutes: 1),
    this.onLocked,
  });
  final VaultSecurityManager _security;
  final Duration timeout;
  final VoidCallback? onLocked;
  Timer? _timer;

  void start() => WidgetsBinding.instance.addObserver(this);
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<void> lockNow() async {
    _timer?.cancel();
    await _security.lock();
    onLocked?.call();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timer?.cancel();
      return;
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (timeout == Duration.zero) {
        lockNow();
      } else {
        _timer?.cancel();
        _timer = Timer(timeout, lockNow);
      }
    }
  }
}
