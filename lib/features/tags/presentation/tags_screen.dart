import 'package:flutter/material.dart';

class TagListItem {
  const TagListItem({
    required this.id,
    required this.name,
    required this.documentCount,
  });
  final String id;
  final String name;
  final int documentCount;
}

/// Callback-driven, unlocked-only tag management screen. Its controller owns
/// decrypted tag names and delegates changes to [TagService].
class TagsScreen extends StatelessWidget {
  const TagsScreen({
    required this.tags,
    required this.onCreate,
    required this.onRename,
    required this.onDelete,
    super.key,
  });
  final List<TagListItem> tags;
  final Future<void> Function(String name) onCreate;
  final Future<void> Function(TagListItem tag, String name) onRename;
  final Future<void> Function(TagListItem tag) onDelete;

  Future<void> _edit(BuildContext context, {TagListItem? tag}) async {
    final controller = TextEditingController(text: tag?.name ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          tag == null
              ? 'Add tag / ট্যাগ যোগ করুন'
              : 'Rename tag / ট্যাগের নাম বদলান',
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Tag name / ট্যাগের নাম',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel / বাতিল'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save / সংরক্ষণ করুন'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty) {
      return;
    }
    try {
      if (tag == null) {
        await onCreate(name);
      } else {
        await onRename(tag, name);
      }
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tag name is required and must be unique. / ট্যাগের নাম আলাদা হতে হবে।',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tags / ট্যাগ')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _edit(context),
      icon: const Icon(Icons.add),
      label: const Text('Add / যোগ করুন'),
    ),
    body: tags.isEmpty
        ? const Center(child: Text('No tags yet / এখনো কোনো ট্যাগ নেই'))
        : ListView.builder(
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
              return ListTile(
                leading: const Icon(Icons.sell_outlined),
                title: Text(tag.name),
                subtitle: Text(
                  '${tag.documentCount} document${tag.documentCount == 1 ? '' : 's'}',
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (action) async {
                    if (action == 'rename') return _edit(context, tag: tag);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete tag? / ট্যাগ মুছবেন?'),
                        content: const Text(
                          'Documents will not be deleted. / ডকুমেন্ট মুছে যাবে না।',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel / বাতিল'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete / মুছুন'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) await onDelete(tag);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'rename',
                      child: Text('Rename / নাম বদলান'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete / মুছুন'),
                    ),
                  ],
                ),
              );
            },
          ),
  );
}
