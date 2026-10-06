import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: AppSpacing.page,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'My Vault',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              tooltip: 'Search documents',
              icon: const Icon(Icons.search),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        const Row(
          children: [
            Expanded(
              child: _Action(
                icon: Icons.document_scanner_outlined,
                label: 'Scan',
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _Action(icon: Icons.upload_file_outlined, label: 'Import'),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _Action(icon: Icons.add_circle_outline, label: 'Add'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 56,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your vault is empty',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Scan or import your first important document.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label document',
    button: true,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Icon(icon, color: AppColors.blue),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      ),
    ),
  );
}
