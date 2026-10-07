import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../l10n/localization_extension.dart';

class UnlockScreen extends ConsumerWidget {
  const UnlockScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    backgroundColor: AppColors.navy,
    body: SafeArea(
      child: Padding(
        padding: AppSpacing.page,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.folder_outlined, size: 86, color: Colors.white),
            const SizedBox(height: 24),
            Text(
              context.l10n.unlockVault,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.unlockVaultDescription,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 36),
            ElevatedButton(
              onPressed: () {
                ref.read(vaultAccessProvider.notifier).unlock();
                context.go('/home');
              },
              child: Text(context.l10n.usePin),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                context.l10n.forgotPin,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
