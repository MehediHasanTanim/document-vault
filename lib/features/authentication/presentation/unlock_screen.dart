import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/app_theme.dart';

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
              'Unlock Document Vault',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'আপনার ডকুমেন্ট ভল্ট খুলুন',
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
              child: const Text('Use PIN'),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Forgot PIN?',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
