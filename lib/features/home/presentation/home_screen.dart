import 'package:flutter/material.dart';

import '../../../core/presentation/vault_feedback_states.dart';
import '../application/home_dashboard_models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    this.dashboard = const HomeDashboardData(),
    this.onSearch,
    this.onLock,
    this.onScan,
    this.onImport,
    this.onAddDocument,
    this.onOpenDocument,
    this.onOpenFamily,
    this.onOpenBackup,
    super.key,
  });
  final HomeDashboardData dashboard;
  final VoidCallback? onSearch;
  final VoidCallback? onLock;
  final VoidCallback? onScan;
  final VoidCallback? onImport;
  final VoidCallback? onAddDocument;
  final ValueChanged<String>? onOpenDocument;
  final ValueChanged<String>? onOpenFamily;
  final VoidCallback? onOpenBackup;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          sliver: SliverToBoxAdapter(child: _header(context)),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.list(
            children: [
              _quickActions(context),
              const SizedBox(height: 20),
              _backupHealth(context),
              if (dashboard.isEmpty) ...[
                const SizedBox(height: 24),
                VaultEmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'Your vault is empty / আপনার ভল্ট খালি',
                  message: 'Scan or import your first important document. / প্রথম গুরুত্বপূর্ণ নথিটি স্ক্যান বা ইমপোর্ট করুন।',
                  action: FilledButton.icon(
                    onPressed: onScan,
                    icon: const Icon(Icons.document_scanner_outlined),
                    label: const Text('Scan document / নথি স্ক্যান করুন'),
                  ),
                ),
              ] else ...[
                _documentsSection(
                  context,
                  title: 'Favorites / পছন্দের',
                  values: dashboard.favorites,
                  empty: 'No favorites yet / এখনো কোনো পছন্দের নথি নেই',
                ),
                _documentsSection(
                  context,
                  title: 'Expiring soon / শিগগির মেয়াদ শেষ',
                  values: dashboard.expiringSoon,
                  empty: 'Nothing is expiring soon / শিগগির কোনো মেয়াদ শেষ হচ্ছে না',
                ),
                _familySection(context),
                _documentsSection(
                  context,
                  title: 'Recent documents / সাম্প্রতিক নথি',
                  values: dashboard.recent,
                  empty: 'No recent documents / কোনো সাম্প্রতিক নথি নেই',
                ),
              ],
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _header(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dashboard.greeting,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              dashboard.vaultName,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ],
        ),
      ),
      IconButton(
        tooltip: 'Search documents / নথি খুঁজুন',
        onPressed: onSearch,
        icon: const Icon(Icons.search),
      ),
      IconButton(
        tooltip: 'Lock vault / ভল্ট লক করুন',
        onPressed: onLock,
        icon: const Icon(Icons.lock_outline),
      ),
    ],
  );

  Widget _quickActions(BuildContext context) => Semantics(
    container: true,
    label: 'Quick actions / দ্রুত কাজ',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick actions / দ্রুত কাজ',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _QuickAction(
              icon: Icons.document_scanner_outlined,
              label: 'Scan / স্ক্যান',
              onTap: onScan,
            ),
            const SizedBox(width: 8),
            _QuickAction(
              icon: Icons.upload_file_outlined,
              label: 'Import / ইমপোর্ট',
              onTap: onImport,
            ),
            const SizedBox(width: 8),
            _QuickAction(
              icon: Icons.add_circle_outline,
              label: 'Add / যোগ করুন',
              onTap: onAddDocument,
            ),
          ],
        ),
      ],
    ),
  );

  Widget _backupHealth(BuildContext context) {
    final (icon, label, detail, color) = switch (dashboard.backupHealth) {
      BackupHealth.protected => (
        Icons.verified_outlined,
        'Backup protected / ব্যাকআপ সুরক্ষিত',
        'Your last backup was verified. / আপনার শেষ ব্যাকআপ যাচাই করা হয়েছে।',
        Theme.of(context).colorScheme.primary,
      ),
      BackupHealth.due => (
        Icons.backup_outlined,
        'Backup recommended / ব্যাকআপ করার পরামর্শ',
        'Create an encrypted backup soon. / শিগগির এনক্রিপ্ট করা ব্যাকআপ করুন।',
        Theme.of(context).colorScheme.tertiary,
      ),
      BackupHealth.unavailable => (
        Icons.cloud_off_outlined,
        'No verified backup / যাচাইকৃত ব্যাকআপ নেই',
        'Keep a password-protected backup in a safe place. / পাসওয়ার্ড সুরক্ষিত ব্যাকআপ নিরাপদ জায়গায় রাখুন।',
        Theme.of(context).colorScheme.error,
      ),
    };
    return Card(
      child: ListTile(
        minVerticalPadding: 12,
        leading: Icon(icon, color: color),
        title: Text(label),
        subtitle: Text(detail),
        trailing: const Icon(Icons.chevron_right),
        onTap: onOpenBackup,
      ),
    );
  }

  Widget _documentsSection(
    BuildContext context, {
    required String title,
    required List<DashboardDocument> values,
    required String empty,
  }) => Padding(
    padding: const EdgeInsets.only(top: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (values.isEmpty)
          Text(empty)
        else
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, index) => _DashboardDocumentCard(
                document: values[index],
                onTap: onOpenDocument == null
                    ? null
                    : () => onOpenDocument!(values[index].id),
              ),
            ),
          ),
      ],
    ),
  );

  Widget _familySection(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Family / পরিবার', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (dashboard.family.isEmpty)
          const Text('No family members yet / এখনো পরিবারের সদস্য নেই')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: dashboard.family
                .map(
                  (member) => ActionChip(
                    avatar: CircleAvatar(
                      child: Text(member.name.characters.first.toUpperCase()),
                    ),
                    label: Text('${member.name} · ${member.documentCount}'),
                    onPressed: onOpenFamily == null
                        ? null
                        : () => onOpenFamily!(member.id),
                  ),
                )
                .toList(growable: false),
          ),
      ],
    ),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      button: true,
      label: label,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 76),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon),
                  const SizedBox(height: 6),
                  Text(label, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _DashboardDocumentCard extends StatelessWidget {
  const _DashboardDocumentCard({required this.document, this.onTap});
  final DashboardDocument document;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    label: '${document.title}, ${document.subtitle}',
    child: SizedBox(
      width: 190,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description_outlined),
                    const Spacer(),
                    if (document.favorite)
                      const Icon(Icons.star_rounded, color: Colors.amber),
                  ],
                ),
                const Spacer(),
                Text(
                  document.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  document.expiryLabel ?? document.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
