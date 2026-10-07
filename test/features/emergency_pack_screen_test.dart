import 'package:documentvault/features/documents/application/emergency/emergency_export_service.dart';
import 'package:documentvault/features/documents/presentation/emergency_pack_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const documents = [
    EmergencyDocumentOption(
      id: 'passport',
      title: 'Passport',
      category: 'Identity',
    ),
    EmergencyDocumentOption(
      id: 'insurance',
      title: 'Insurance',
      category: 'Medical',
    ),
  ];

  testWidgets('saves only explicitly checked emergency documents', (
    tester,
  ) async {
    _largeViewport(tester);
    List<String>? saved;
    await tester.pumpWidget(
      MaterialApp(
        home: EmergencyPackScreen(
          documents: documents,
          initialSelection: const {'passport'},
          onSaveSelection: (ids) async => saved = ids,
        ),
      ),
    );

    await tester.tap(find.text('Insurance'));
    await tester.tap(find.text('Save selection / নির্বাচন সংরক্ষণ করুন'));
    await tester.pumpAndSettle();

    expect(saved, ['passport', 'insurance']);
  });

  testWidgets('requires explicit confirmation for unencrypted export', (
    tester,
  ) async {
    _largeViewport(tester);
    EmergencyExportProtection? captured;
    await tester.pumpWidget(
      MaterialApp(
        home: EmergencyPackScreen(
          documents: documents,
          initialSelection: const {'passport'},
          onExport: (ids, protection) async {
            captured = protection;
            return true;
          },
        ),
      ),
    );

    await tester.tap(find.text('Unencrypted images / এনক্রিপশনবিহীন ছবি'));
    await tester.tap(
      find.text('Export emergency pack / জরুরি প্যাক রপ্তানি করুন'),
    );
    await tester.pumpAndSettle();
    expect(captured, isNull);

    await tester.tap(find.text('Export / রপ্তানি করুন'));
    await tester.pumpAndSettle();
    expect(captured!.mode, EmergencyExportEncryption.none);
    expect(captured!.acknowledgedUnencryptedRisk, isTrue);
  });

  testWidgets('creates a password-protected export option', (tester) async {
    _largeViewport(tester);
    EmergencyExportProtection? captured;
    await tester.pumpWidget(
      MaterialApp(
        home: EmergencyPackScreen(
          documents: documents,
          initialSelection: const {'passport'},
          onExport: (ids, protection) async {
            captured = protection;
            return true;
          },
        ),
      ),
    );
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Emergency Pack 2026!');
    await tester.enterText(fields.at(1), 'Emergency Pack 2026!');
    await tester.tap(
      find.text('Export emergency pack / জরুরি প্যাক রপ্তানি করুন'),
    );
    await tester.pumpAndSettle();

    expect(captured!.mode, EmergencyExportEncryption.passwordProtected);
  });
}

void _largeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
