import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/unlock_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/onboarding_screens.dart';

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
        builder: (_, _) => const VaultShell(tab: VaultTab.home),
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
  const VaultShell({required this.tab, super.key});
  final VaultTab tab;
  @override
  Widget build(BuildContext context) {
    final child = switch (tab) {
      VaultTab.home => const HomeScreen(),
      VaultTab.documents => const FeaturePlaceholder(
        icon: Icons.description_outlined,
        title: 'Documents',
        subtitle: 'ডকুমেন্ট',
      ),
      VaultTab.scan => const FeaturePlaceholder(
        icon: Icons.document_scanner_outlined,
        title: 'Scan a document',
        subtitle: 'ডকুমেন্ট স্ক্যান করুন',
      ),
      VaultTab.reminders => const FeaturePlaceholder(
        icon: Icons.notifications_none_rounded,
        title: 'Reminders',
        subtitle: 'রিমাইন্ডার',
      ),
      VaultTab.more => const FeaturePlaceholder(
        icon: Icons.more_horiz_rounded,
        title: 'More',
        subtitle: 'আরও',
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
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: 'Documents',
          ),
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none),
            selectedIcon: Icon(Icons.notifications),
            label: 'Reminders',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

class FeaturePlaceholder extends StatelessWidget {
  const FeaturePlaceholder({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: Semantics(
        label: '$title — $subtitle',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 58, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    ),
  );
}
