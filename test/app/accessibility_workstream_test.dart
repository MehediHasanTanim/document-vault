import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shared theme preserves accessible touch targets', () async {
    final theme = await File('lib/app/theme/app_theme.dart').readAsString();
    expect(theme, contains('minimumTouchTarget = Size(48, 48)'));
    expect(theme, contains('MaterialTapTargetSize.padded'));
    expect(theme, contains('textButtonTheme'));
    expect(theme, contains('iconButtonTheme'));
  });

  test('shell and feedback states expose focus and error semantics', () async {
    final router = await File('lib/app/router/app_router.dart').readAsString();
    final feedback = await File(
      'lib/core/presentation/vault_feedback_states.dart',
    ).readAsString();
    expect(router, contains('FocusTraversalGroup'));
    expect(router, contains('label: l10n.scanNewDocument'));
    expect(feedback, contains('liveRegion: announce'));
    expect(feedback, contains('announce: true'));
  });

  test('accessibility checklist is required in pull requests', () async {
    final template = await File('.github/PULL_REQUEST_TEMPLATE.md')
        .readAsString();
    final guide = await File(
      'docs/testing/Cross_Sprint_Accessibility_Workstream.md',
    ).readAsString();
    expect(template, contains('Accessibility workstream review'));
    expect(template, contains('TalkBack/VoiceOver'));
    expect(guide, contains('Text scaling'));
    expect(guide, contains('by colour'));
  });
}
