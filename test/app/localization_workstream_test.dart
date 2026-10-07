import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> readArb(String path) =>
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

  test('English and Bengali ARB keys remain in parity', () {
    final english = readArb('lib/l10n/app_en.arb');
    final bangla = readArb('lib/l10n/app_bn.arb');
    final englishKeys = english.keys
        .where((key) => !key.startsWith('@'))
        .toSet();
    final banglaKeys = bangla.keys.where((key) => !key.startsWith('@')).toSet();

    expect(banglaKeys, englishKeys);
    expect(english.values.whereType<String>(), everyElement(isNotEmpty));
    expect(bangla.values.whereType<String>(), everyElement(isNotEmpty));
  });

  test('canonical terminology uses the approved natural Bengali copy', () {
    final bangla = readArb('lib/l10n/app_bn.arb');
    expect(bangla['documents'], 'ডকুমেন্ট');
    expect(bangla['family'], 'পরিবার');
    expect(bangla['backupAndRestore'], contains('ব্যাকআপ'));
    expect(bangla['backupAndRestore'], contains('পুনরুদ্ধার'));
    expect(bangla['expiringSoon'], 'শিগগির মেয়াদ শেষ হবে');
  });

  test(
    'shared app shell uses generated localization instead of UI literals',
    () async {
      const shellFiles = [
        'lib/app/app.dart',
        'lib/app/router/app_router.dart',
        'lib/features/onboarding/presentation/onboarding_screens.dart',
        'lib/features/authentication/presentation/unlock_screen.dart',
      ];
      final literalText = RegExp(r'''(?:const\s+)?Text\(\s*['"]''');

      for (final path in shellFiles) {
        final source = await File(path).readAsString();
        expect(
          source,
          contains('context.l10n'),
          reason: '$path must resolve UI copy',
        );
        expect(
          literalText.hasMatch(source),
          isFalse,
          reason: '$path has hardcoded UI text',
        );
        expect(
          source.contains(' / '),
          isFalse,
          reason: '$path has a paired locale literal',
        );
      }
    },
  );

  test('PR template requires localization evidence', () async {
    final template = await File('.github/PULL_REQUEST_TEMPLATE.md')
        .readAsString();
    expect(template, contains('Localization workstream review'));
    expect(template, contains('generated localization key'));
    expect(template, contains('English and বাংলা'));
  });
}
