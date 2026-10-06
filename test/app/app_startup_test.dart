import 'package:documentvault/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('application starts on the privacy-safe splash screen', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: DocumentVaultApp()));
    await tester.pump();
    expect(find.text('Document Vault BD'), findsOneWidget);
    expect(find.bySemanticsLabel('Preparing your vault'), findsOneWidget);
  });
}
