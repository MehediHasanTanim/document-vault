import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/unlock_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/more_screen.dart';
import '../../features/onboarding/presentation/onboarding_screens.dart';
import '../../core/presentation/vault_feedback_states.dart';

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
    final child = switch (tab) {
      VaultTab.home => HomeScreen(
        onLock: onLock,
        onSearch: () => context.go('/documents'),
        onScan: () => context.go('/scan'),
        onImport: () => context.go('/scan'),
        onAddDocument: () => context.go('/scan'),
        onOpenBackup: () => context.push('/more/backup_restore'),
      ),
      VaultTab.documents => const MvpTabState(
        icon: Icons.description_outlined,
        title: 'No documents yet / এখনো কোনো ডকুমেন্ট নেই',
        message: 'Scan or import a document to build your private vault. / আপনার ব্যক্তিগত ভল্টে নথি স্ক্যান বা ইমপোর্ট করুন।',
      ),
      VaultTab.scan => const MvpTabState(
        icon: Icons.document_scanner_outlined,
        title: 'Ready to add a document / নথি যোগ করতে প্রস্তুত',
        message: 'Choose Scan, Import photos, or Import PDF from the add-document flow. / স্ক্যান, ছবি বা PDF ইমপোর্ট বেছে নিন।',
      ),
      VaultTab.reminders => const MvpTabState(
        icon: Icons.notifications_none_rounded,
        title: 'No upcoming reminders / কোনো আসন্ন রিমাইন্ডার নেই',
        message: 'Expiry reminders will appear here and never show document numbers. / মেয়াদের রিমাইন্ডার এখানে দেখাবে; নথির নম্বর দেখাবে না।',
      ),
      VaultTab.more => MoreScreen(
        onOpen: (destination) => context.push('/more/${destination.name}'),
      ),
    };
    return Scaffold(
      body: child,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/scan'),
        tooltip: 'Scan new document',
        child: const Icon(Icons.document_scanner_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab.index,
        onDestinationSelected: (index) => context.go(
          const ['/home', '/documents', '/scan', '/reminders', '/more'][index],
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home / হোম',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: 'Documents / ডকুমেন্ট',
          ),
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner),
            label: 'Scan / স্ক্যান',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none),
            selectedIcon: Icon(Icons.notifications),
            label: 'Reminders / রিমাইন্ডার',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'More / আরও',
          ),
        ],
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
    appBar: AppBar(title: Text(_label(destination))),
    body: MvpTabState(
      icon: _icon(destination),
      title: _label(destination),
      message: _emptyCopy(destination),
    ),
  );
  String _label(String value) => switch (value) {
    'family' => 'Family / পরিবার',
    'categories' => 'Categories / বিভাগ',
    'tags' => 'Tags / ট্যাগ',
    'archive' => 'Archive / আর্কাইভ',
    'trash' => 'Trash / ট্র্যাশ',
    'backupRestore' ||
    'backup_restore' => 'Backup & Restore / ব্যাকআপ ও পুনরুদ্ধার',
    'storage' => 'Storage / স্টোরেজ',
    'settings' => 'Settings / সেটিংস',
    'help' => 'Help & About / সহায়তা ও পরিচিতি',
    _ => 'More / আরও',
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
  String _emptyCopy(String value) => switch (value) {
    'family' => 'Add family members to organise documents by person. / ব্যক্তির নামে নথি গুছাতে সদস্য যোগ করুন।',
    'categories' => 'System categories will organise your documents. / সিস্টেম বিভাগ দিয়ে নথি গুছিয়ে নিন।',
    'tags' => 'Create tags to group related documents. / সম্পর্কিত নথি গুছাতে ট্যাগ তৈরি করুন।',
    'archive' => 'No archived documents / কোনো আর্কাইভ করা নথি নেই',
    'trash' => 'Trash is empty / ট্র্যাশ খালি',
    _ => 'Choose an option from More after your vault is unlocked. / ভল্ট খোলার পর আরও থেকে একটি অপশন বেছে নিন।',
  };
}
