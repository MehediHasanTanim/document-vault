import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/locale_controller.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../l10n/localization_extension.dart';

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
              context.l10n.appName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 22),
            CircularProgressIndicator(
              semanticsLabel: context.l10n.preparingVault,
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
    title: context.l10n.onboardingWelcomeTitle,
    icon: Icons.folder_outlined,
    body: [
      context.l10n.onboardingWelcomeOffline,
      context.l10n.onboardingWelcomeDevice,
      context.l10n.onboardingWelcomeBackup,
    ],
    action: context.l10n.getStarted,
    onAction: () => context.go('/language'),
    secondary: context.l10n.changeLanguage,
    onSecondary: () => context.go('/language'),
  );
}

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => OnboardingPage(
    title: context.l10n.chooseLanguage,
    icon: Icons.language_rounded,
    body: [context.l10n.languageBangla, context.l10n.languageEnglish],
    action: context.l10n.continueLabel,
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
    title: context.l10n.privacyTitle,
    icon: Icons.verified_user_outlined,
    body: [
      context.l10n.privacyDevice,
      context.l10n.privacyNoAccount,
      context.l10n.privacyBackup,
      context.l10n.privacySharing,
    ],
    action: context.l10n.understandContinue,
    onAction: () => context.go('/setup/pin'),
  );
}

class PinSetupScreen extends ConsumerWidget {
  const PinSetupScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => OnboardingPage(
    title: context.l10n.createVaultPin,
    icon: Icons.lock_outline,
    body: [context.l10n.pinSetupInstruction, context.l10n.pinSetupWarning],
    action: context.l10n.continueLabel,
    onAction: () {
      ref.read(vaultAccessProvider.notifier).completeSetup();
      context.go('/unlock');
    },
  );
}

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    required this.title,
    required this.icon,
    required this.body,
    required this.action,
    required this.onAction,
    this.secondary,
    this.onSecondary,
    super.key,
  });
  final String title;
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
