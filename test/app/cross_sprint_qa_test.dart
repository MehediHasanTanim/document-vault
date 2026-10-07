import 'dart:io';

import 'package:documentvault/app/app.dart';
import 'package:documentvault/app/localization/locale_controller.dart';
import 'package:documentvault/app/theme/theme_controller.dart';
import 'package:documentvault/core/logging/secure_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app smoke renders Bengali in dark mode', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localeStorageProvider.overrideWithValue(
            const InMemoryLocaleStorage('bn'),
          ),
          themeStorageProvider.overrideWithValue(
            const InMemoryThemeStorage('dark'),
          ),
        ],
        child: const DocumentVaultApp(),
      ),
    );
    await tester.pump();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.locale, const Locale('bn'));
    expect(app.themeMode, ThemeMode.dark);
    expect(find.text('ডকুমেন্ট ভল্ট বিডি'), findsOneWidget);
  });

  testWidgets('app smoke renders English in light mode', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localeStorageProvider.overrideWithValue(
            const InMemoryLocaleStorage('en'),
          ),
          themeStorageProvider.overrideWithValue(
            const InMemoryThemeStorage('light'),
          ),
        ],
        child: const DocumentVaultApp(),
      ),
    );
    await tester.pump();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.locale, const Locale('en'));
    expect(app.themeMode, ThemeMode.light);
  });

  test('secure logger redacts sensitive and nested fields', () {
    final safe = SanitizedDebugLogger.sanitizeFields({
      'access_token': 'never-log',
      'metadata': {'documentTitle': 'Passport', 'attempt': 2},
      'opaqueObject': Object(),
      'success': true,
    });

    expect(safe['access_token'], '[REDACTED]');
    expect(safe['metadata'], {'documentTitle': '[REDACTED]', 'attempt': 2});
    expect(safe['opaqueObject'], '[REDACTED]');
    expect(safe['success'], true);
    expect(
      SanitizedDebugLogger.sanitizeEvent('backup.created'),
      'backup.created',
    );
    expect(SanitizedDebugLogger.sanitizeEvent('Passport 123'), 'invalid_event');
  });

  test('production source has no direct print or debugPrint calls', () async {
    final root = Directory('lib');
    final violations = <String>[];
    await for (final entity in root.list(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.endsWith('/core/logging/secure_logger.dart')) continue;
      final lines = await entity.readAsLines();
      for (var index = 0; index < lines.length; index++) {
        if (RegExp(r'\b(?:print|debugPrint)\s*\(').hasMatch(lines[index])) {
          violations.add('${entity.path}:${index + 1}');
        }
      }
    }
    expect(
      violations,
      isEmpty,
      reason: 'Use SecureLogger with safe event IDs.',
    );
  });
}
