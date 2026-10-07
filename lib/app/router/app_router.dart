import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/unlock_screen.dart';
import '../../features/backup/presentation/cloud_backup_feature.dart';
import '../../features/backup/presentation/cloud_backup_screen.dart';
import '../../features/documents/presentation/emergency_pack_feature.dart';
import '../../features/documents/presentation/emergency_pack_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/more_screen.dart';
import '../../features/onboarding/presentation/onboarding_screens.dart';
import '../../core/presentation/vault_feedback_states.dart';
import '../../l10n/localization_extension.dart';

enum VaultAccessState { onboarding, locked, unlocked }

final vaultAccessProvider =
    NotifierProvider<VaultAccessController, VaultAccessState>(
      VaultAccessController.new,
    );

class VaultAccessController extends Notifier<VaultAccessState> {
  @override
  VaultAccessState build() => VaultAccessState.onboarding;
  void completeSetup() => state = VaultAccessState.locked;
  void unlock() => state = VaultAccessState.unlocked;
  void lock() => state = VaultAccessState.locked;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final access = ref.watch(vaultAccessProvider);
  return GoRouter(
    initialLocation: '/splash',
    redirect: (_, state) => routeForAccessState(access, state.uri.path),
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/language', builder: (_, _) => const LanguageScreen()),
      GoRoute(path: '/privacy', builder: (_, _) => const PrivacyScreen()),
      GoRoute(path: '/setup/pin', builder: (_, _) => const PinSetupScreen()),
      GoRoute(path: '/unlock', builder: (_, _) => const UnlockScreen()),
      GoRoute(
        path: '/home',
        builder: (_, _) => VaultShell(
          tab: VaultTab.home,
          onLock: ref.read(vaultAccessProvider.notifier).lock,
        ),
      ),
      GoRoute(
        path: '/documents',
        builder: (_, _) => const VaultShell(tab: VaultTab.documents),
      ),
      GoRoute(
        path: '/scan',
        builder: (_, _) => const VaultShell(tab: VaultTab.scan),
      ),
      GoRoute(
        path: '/reminders',
        builder: (_, _) => const VaultShell(tab: VaultTab.reminders),
      ),
      GoRoute(
        path: '/more',
        builder: (_, _) => const VaultShell(tab: VaultTab.more),
      ),
      GoRoute(
        path: '/more/cloud-backup',
        builder: (_, _) {
          final feature = ref.watch(cloudBackupFeatureProvider);
          return CloudBackupScreen(
            providers: feature.providers,
            onCreateEncryptedBackup: feature.createEncryptedBackup,
            onRestoreVersion: feature.restoreVersion,
          );
        },
      ),
      GoRoute(
        path: '/more/emergency-pack',
        builder: (_, _) {
          final feature = ref.watch(emergencyPackFeatureProvider);
          return EmergencyPackScreen(
            documents: feature.documents,
            initialSelection: feature.initialSelection,
            onSaveSelection: feature.saveSelection,
            onExport: feature.export,
          );
        },
      ),
      GoRoute(
        path: '/more/:destination',
        builder: (_, state) => MoreDestinationScreen(
          destination: state.pathParameters['destination'] ?? 'more',
        ),
      ),
    ],
  );
});

String? routeForAccessState(VaultAccessState access, String path) {
  const public = {
    '/splash',
    '/welcome',
    '/language',
    '/privacy',
    '/setup/pin',
    '/unlock',
  };
  final isPublic = public.contains(path);
  return switch (access) {
    VaultAccessState.onboarding when !isPublic || path == '/unlock' =>
      '/welcome',
    VaultAccessState.locked when !isPublic => '/unlock',
    VaultAccessState.unlocked when isPublic => '/home',
    _ => null,
  };
}

enum VaultTab { home, documents, scan, reminders, more }

class VaultShell extends StatelessWidget {
  const VaultShell({required this.tab, this.onLock, super.key});
  final VaultTab tab;
  final VoidCallback? onLock;
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final child = switch (tab) {
      VaultTab.home => HomeScreen(
        onLock: onLock,
        onSearch: () => context.go('/documents'),
        onScan: () => context.go('/scan'),
        onImport: () => context.go('/scan'),
        onAddDocument: () => context.go('/scan'),
        onOpenBackup: () => context.push('/more/backup_restore'),
      ),
      VaultTab.documents => MvpTabState(
        icon: Icons.description_outlined,
        title: l10n.noDocumentsYet,
        message: l10n.noDocumentsYetMessage,
      ),
      VaultTab.scan => MvpTabState(
        icon: Icons.document_scanner_outlined,
        title: l10n.readyToAddDocument,
        message: l10n.readyToAddDocumentMessage,
      ),
      VaultTab.reminders => MvpTabState(
        icon: Icons.notifications_none_rounded,
        title: l10n.noUpcomingReminders,
        message: l10n.noUpcomingRemindersMessage,
      ),
      VaultTab.more => MoreScreen(
        onOpen: (destination) => context.push('/more/${destination.name}'),
      ),
    };
    return FocusTraversalGroup(
      child: Scaffold(
        body: child,
        floatingActionButton: Semantics(
          button: true,
          label: l10n.scanNewDocument,
          child: FloatingActionButton(
            onPressed: () => context.go('/scan'),
            tooltip: l10n.scanNewDocument,
            child: const Icon(Icons.document_scanner_outlined),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab.index,
          onDestinationSelected: (index) => context.go(
            const [
              '/home',
              '/documents',
              '/scan',
              '/reminders',
              '/more',
            ][index],
          ),
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: l10n.home,
            ),
            NavigationDestination(
              icon: Icon(Icons.description_outlined),
              selectedIcon: Icon(Icons.description),
              label: l10n.documents,
            ),
            NavigationDestination(
              icon: Icon(Icons.document_scanner_outlined),
              selectedIcon: Icon(Icons.document_scanner),
              label: l10n.scan,
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_none),
              selectedIcon: Icon(Icons.notifications),
              label: l10n.reminders,
            ),
            NavigationDestination(
              icon: Icon(Icons.more_horiz),
              selectedIcon: Icon(Icons.more_horiz),
              label: l10n.more,
            ),
          ],
        ),
      ),
    );
  }
}

class MvpTabState extends StatelessWidget {
  const MvpTabState({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });
  final IconData icon;
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) =>
      VaultEmptyState(icon: icon, title: title, message: message);
}

class MoreDestinationScreen extends StatelessWidget {
  const MoreDestinationScreen({required this.destination, super.key});
  final String destination;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_label(context, destination))),
    body: MvpTabState(
      icon: _icon(destination),
      title: _label(context, destination),
      message: _emptyCopy(context, destination),
    ),
  );
  String _label(BuildContext context, String value) => switch (value) {
    'family' => context.l10n.family,
    'categories' => context.l10n.categories,
    'tags' => context.l10n.tags,
    'archive' => context.l10n.archive,
    'trash' => context.l10n.trash,
    'backupRestore' || 'backup_restore' => context.l10n.backupAndRestore,
    'storage' => context.l10n.storage,
    'settings' => context.l10n.settings,
    'help' => context.l10n.helpAndAbout,
    _ => context.l10n.more,
  };
  IconData _icon(String value) => switch (value) {
    'family' => Icons.groups_outlined,
    'categories' => Icons.category_outlined,
    'tags' => Icons.sell_outlined,
    'archive' => Icons.archive_outlined,
    'trash' => Icons.delete_outline,
    'storage' => Icons.storage_outlined,
    _ => Icons.more_horiz,
  };
  String _emptyCopy(BuildContext context, String value) => switch (value) {
    'family' => context.l10n.familyEmptyMessage,
    'categories' => context.l10n.categoriesEmptyMessage,
    'tags' => context.l10n.tagsEmptyMessage,
    'archive' => context.l10n.archiveEmptyMessage,
    'trash' => context.l10n.trashEmptyMessage,
    _ => context.l10n.moreEmptyMessage,
  };
}
