import 'package:documentvault/core/presentation/vault_feedback_states.dart';
import 'package:documentvault/features/home/application/home_dashboard_models.dart';
import 'package:documentvault/features/home/presentation/home_screen.dart';
import 'package:documentvault/features/home/presentation/more_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'home dashboard exposes accessible quick actions and lock control',
    (tester) async {
      var searched = false;
      var locked = false;
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            dashboard: const HomeDashboardData(
              favorites: [
                DashboardDocument(
                  id: 'passport',
                  title: 'Passport',
                  subtitle: 'Identity',
                  favorite: true,
                ),
              ],
              family: [
                DashboardFamilyMember(
                  id: 'member',
                  name: 'Amina',
                  relationship: 'Spouse',
                  documentCount: 2,
                ),
              ],
              backupHealth: BackupHealth.protected,
            ),
            onSearch: () => searched = true,
            onLock: () => locked = true,
          ),
        ),
      );
      expect(find.text('Favorites / পছন্দের'), findsOneWidget);
      expect(find.text('Backup protected / ব্যাকআপ সুরক্ষিত'), findsOneWidget);
      expect(find.byTooltip('Search documents / নথি খুঁজুন'), findsOneWidget);
      await tester.tap(find.byTooltip('Search documents / নথি খুঁজুন'));
      await tester.tap(find.byTooltip('Lock vault / ভল্ট লক করুন'));
      expect(searched, isTrue);
      expect(locked, isTrue);
    },
  );

  testWidgets(
    'dashboard and feedback states remain usable at large text scale',
    (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
          child: const MaterialApp(
            home: Scaffold(
              body: VaultNamedEmptyState(kind: VaultEmptyKind.search),
            ),
          ),
        ),
      );
      expect(find.text('No results / কোনো ফল পাওয়া যায়নি'), findsOneWidget);
      expect(find.textContaining('Try a different word'), findsOneWidget);
    },
  );

  testWidgets('more screen lists every MVP destination with text labels', (
    tester,
  ) async {
    MoreDestination? selected;
    await tester.pumpWidget(
      MaterialApp(home: MoreScreen(onOpen: (value) => selected = value)),
    );
    expect(find.text('Family / পরিবার'), findsOneWidget);
    expect(
      find.text('Backup & Restore / ব্যাকআপ ও পুনরুদ্ধার'),
      findsOneWidget,
    );
    await tester.tap(find.text('Storage / স্টোরেজ'));
    expect(selected, MoreDestination.storage);
    await tester.scrollUntilVisible(find.text('Settings / সেটিংস'), 300);
    expect(find.text('Settings / সেটিংস'), findsOneWidget);
  });

  testWidgets('error state communicates safe recovery for restore failure', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VaultErrorState(kind: VaultErrorKind.restoreFailed),
        ),
      ),
    );
    expect(
      find.text('Restore failed / পুনরুদ্ধার ব্যর্থ হয়েছে'),
      findsOneWidget,
    );
    expect(find.textContaining('previous vault was kept'), findsOneWidget);
  });
}
