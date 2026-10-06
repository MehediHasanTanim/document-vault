import 'package:flutter/foundation.dart';

abstract interface class SecureLogger {
  void info(String event, {Map<String, Object?> fields = const {}});
  void warning(String event, {Map<String, Object?> fields = const {}});
  void error(
    String event, {
    Object? error,
    Map<String, Object?> fields = const {},
  });
}

class SanitizedDebugLogger implements SecureLogger {
  const SanitizedDebugLogger();
  static const _blocked = {
    'pin',
    'password',
    'key',
    'secret',
    'documentnumber',
    'filename',
    'documentcontent',
    'ocrtext',
    'title',
    'path',
  };
  @override
  void info(String event, {Map<String, Object?> fields = const {}}) =>
      _write('info', event, fields);
  @override
  void warning(String event, {Map<String, Object?> fields = const {}}) =>
      _write('warning', event, fields);
  @override
  void error(
    String event, {
    Object? error,
    Map<String, Object?> fields = const {},
  }) => _write('error', event, fields, error: error);
  void _write(
    String level,
    String event,
    Map<String, Object?> fields, {
    Object? error,
  }) {
    final safe = <String, Object?>{};
    for (final entry in fields.entries) {
      final key = entry.key.toLowerCase().replaceAll(RegExp(r'[_\-\s]'), '');
      safe[entry.key] = _blocked.contains(key) ? '[REDACTED]' : entry.value;
    }
    if (kDebugMode) {
      debugPrint(
        '[$level] $event $safe${error == null ? '' : ' error=${error.runtimeType}'}',
      );
    }
  }
}
