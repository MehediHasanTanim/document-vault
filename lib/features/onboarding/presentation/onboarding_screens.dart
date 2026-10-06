import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/locale_controller.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_outlined, size: 82, color: AppColors.blue),
            const SizedBox(height: 18),
            Text(
              'Document Vault BD',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 22),
            const CircularProgressIndicator(
              semanticsLabel: 'Preparing your vault',
            ),
          ],
        ),
      ),
    ),
  );
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) => OnboardingPage(
    title: 'Keep your important documents safe and organized',
    bangla: 'গুরুত্বপূর্ণ কাগজপত্র নিরাপদে গুছিয়ে রাখুন',
    icon: Icons.folder_outlined,
    body: const [
      'Works offline',
      'Stored on this device',
      'Expiry reminders and encrypted backup',
    ],
    action: 'Get Started',
    onAction: () => context.go('/language'),
    secondary: 'Change Language',
    onSecondary: () => context.go('/language'),
  );
}

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => OnboardingPage(
    title: 'Choose Language',
    bangla: 'ভাষা নির্বাচন করুন',
    icon: Icons.language_rounded,
    body: const ['বাংলা', 'English'],
    action: 'Continue',
    onAction: () {
      ref.read(localeControllerProvider.notifier).setLocale(const Locale('bn'));
      context.go('/privacy');
    },
  );
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});
  @override
  Widget build(BuildContext context) => OnboardingPage(
    title: 'Your documents stay with you',
    bangla: 'আপনার নথি আপনার ডিভাইসেই থাকে',
    icon: Icons.verified_user_outlined,
    body: const [
      'Stored on your device',
      'No app account required',
      'Keep an encrypted backup',
      'Be careful when sharing',
    ],
    action: 'I Understand — Continue',
    onAction: () => context.go('/setup/pin'),
  );
}

class PinSetupScreen extends ConsumerWidget {
  const PinSetupScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => OnboardingPage(
    title: 'Create Vault PIN',
    bangla: 'ভল্ট পিন তৈরি করুন',
    icon: Icons.lock_outline,
    body: const [
      'Use a 6-digit PIN to unlock your vault.',
      'Do not use an easy PIN such as 123456.',
    ],
    action: 'Continue',
    onAction: () {
      ref.read(vaultAccessProvider.notifier).completeSetup();
      context.go('/unlock');
    },
  );
}

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    required this.title,
    required this.bangla,
    required this.icon,
    required this.body,
    required this.action,
    required this.onAction,
    this.secondary,
    this.onSecondary,
    super.key,
  });
  final String title;
  final String bangla;
  final IconData icon;
  final List<String> body;
  final String action;
  final VoidCallback onAction;
  final String? secondary;
  final VoidCallback? onSecondary;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: AppSpacing.page,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Icon(icon, size: 84, color: AppColors.blue),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              bangla,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            ...body.map(
              (item) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(item),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(onPressed: onAction, child: Text(action)),
            if (secondary != null) ...[
              const SizedBox(height: 8),
              OutlinedButton(onPressed: onSecondary, child: Text(secondary!)),
            ],
          ],
        ),
      ),
    ),
  );
}
