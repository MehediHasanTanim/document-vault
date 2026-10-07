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
    'passphrase',
    'key',
    'secret',
    'token',
    'accesstoken',
    'refreshtoken',
    'authorization',
    'cookie',
    'documentnumber',
    'documenttitle',
    'documentdescription',
    'documentnotes',
    'documentpath',
    'originalfilename',
    'filename',
    'documentcontent',
    'ocrtext',
    'title',
    'path',
    'uri',
    'url',
    'notes',
    'description',
    'address',
    'email',
    'phone',
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
    final safe = sanitizeFields(fields);
    if (kDebugMode) {
      debugPrint(
        '[$level] ${sanitizeEvent(event)} $safe${error == null ? '' : ' error=${error.runtimeType}'}',
      );
    }
  }

  /// Public for deterministic QA tests. Nested maps are sanitized recursively;
  /// unstructured collections and objects are never converted with `toString`,
  /// because that can expose paths, titles, or document content.
  static Map<String, Object?> sanitizeFields(Map<String, Object?> fields) => {
    for (final entry in fields.entries)
      entry.key: _isBlocked(entry.key) ? '[REDACTED]' : _sanitize(entry.value),
  };

  static String sanitizeEvent(String value) =>
      RegExp(r'^[a-z0-9._-]{1,80}$').hasMatch(value) ? value : 'invalid_event';

  static bool _isBlocked(String key) =>
      _blocked.contains(key.toLowerCase().replaceAll(RegExp(r'[_\-\s]'), ''));

  static Object? _sanitize(Object? value) {
    if (value == null || value is num || value is bool || value is String) {
      return value;
    }
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): _isBlocked(entry.key.toString())
              ? '[REDACTED]'
              : _sanitize(entry.value),
      };
    }
    return '[REDACTED]';
  }
}
