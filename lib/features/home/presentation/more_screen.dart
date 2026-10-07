import 'package:flutter/material.dart';

enum MoreDestination {
  family,
  categories,
  tags,
  archive,
  trash,
  backupRestore,
  cloudBackup,
  emergencyPack,
  storage,
  settings,
  help,
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({required this.onOpen, super.key});
  final ValueChanged<MoreDestination> onOpen;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Text('More / আরও', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 16),
        _Group(
          title: 'Organize / গুছিয়ে নিন',
          children: [
            _item(
              Icons.groups_outlined,
              'Family / পরিবার',
              MoreDestination.family,
            ),
            _item(
              Icons.category_outlined,
              'Categories / বিভাগ',
              MoreDestination.categories,
            ),
            _item(Icons.sell_outlined, 'Tags / ট্যাগ', MoreDestination.tags),
            _item(
              Icons.archive_outlined,
              'Archive / আর্কাইভ',
              MoreDestination.archive,
            ),
            _item(
              Icons.delete_outline,
              'Trash / ট্র্যাশ',
              MoreDestination.trash,
            ),
          ],
        ),
        _Group(
          title: 'Data / ডেটা',
          children: [
            _item(
              Icons.backup_outlined,
              'Backup & Restore / ব্যাকআপ ও পুনরুদ্ধার',
              MoreDestination.backupRestore,
            ),
            _item(
              Icons.storage_outlined,
              'Storage / স্টোরেজ',
              MoreDestination.storage,
            ),
            _item(
              Icons.cloud_outlined,
              'Cloud backup / ক্লাউড ব্যাকআপ',
              MoreDestination.cloudBackup,
            ),
            _item(
              Icons.emergency_outlined,
              'Emergency Pack / জরুরি প্যাক',
              MoreDestination.emergencyPack,
            ),
          ],
        ),
        _Group(
          title: 'Support / সহায়তা',
          children: [
            _item(
              Icons.settings_outlined,
              'Settings / সেটিংস',
              MoreDestination.settings,
            ),
            _item(
              Icons.help_outline,
              'Help & About / সহায়তা ও পরিচিতি',
              MoreDestination.help,
            ),
          ],
        ),
      ],
    ),
  );

  Widget _item(IconData icon, String label, MoreDestination destination) =>
      ListTile(
        minVerticalPadding: 12,
        leading: Icon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => onOpen(destination),
      );
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          ...children,
        ],
      ),
    ),
  );
}
