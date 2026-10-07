import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../application/library/document_library_controller.dart';
import '../application/library/document_library_models.dart';
import '../application/viewer/protected_thumbnail_service.dart';

class LibraryFilterOption {
  const LibraryFilterOption({required this.id, required this.label});
  final String id;
  final String label;
}

class DocumentLibraryScreen extends StatefulWidget {
  const DocumentLibraryScreen({
    required this.controller,
    required this.thumbnails,
    this.ownerOptions = const [],
    this.categoryOptions = const [],
    this.tagOptions = const [],
    this.onOpenDocument,
    super.key,
  });
  final DocumentLibraryController controller;
  final ProtectedThumbnailService thumbnails;
  final List<LibraryFilterOption> ownerOptions;
  final List<LibraryFilterOption> categoryOptions;
  final List<LibraryFilterOption> tagOptions;
  final ValueChanged<String>? onOpenDocument;

  @override
  State<DocumentLibraryScreen> createState() => _DocumentLibraryScreenState();
}

class _DocumentLibraryScreenState extends State<DocumentLibraryScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
    widget.controller.refresh();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents / ডকুমেন্ট'),
        actions: [
          IconButton(
            tooltip: 'Filter and sort / ফিল্টার ও সাজান',
            icon: const Icon(Icons.tune),
            onPressed: _openControls,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _scopeBar(controller.query.scope),
            Expanded(child: _body(controller)),
          ],
        ),
      ),
    );
  }

  Widget _scopeBar(DocumentLibraryScope selected) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
    child: Row(
      children:
          [
                (DocumentLibraryScope.all, 'All / সব'),
                (DocumentLibraryScope.recent, 'Recent / সাম্প্রতিক'),
                (DocumentLibraryScope.favorites, 'Favorites / পছন্দের'),
                (DocumentLibraryScope.archived, 'Archived / আর্কাইভ'),
                (DocumentLibraryScope.trash, 'Trash / ট্র্যাশ'),
              ]
              .map(
                (value) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(value.$2),
                    selected: selected == value.$1,
                    onSelected: (_) => widget.controller.setScope(value.$1),
                  ),
                ),
              )
              .toList(),
    ),
  );

  Widget _body(DocumentLibraryController controller) {
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.error != null) {
      return _MessageState(
        icon: Icons.error_outline,
        title: 'Could not open documents / ডকুমেন্ট খোলা যায়নি',
        action: FilledButton(
          onPressed: controller.refresh,
          child: const Text('Try again / আবার চেষ্টা করুন'),
        ),
      );
    }
    if (controller.documents.isEmpty) {
      return const _MessageState(
        icon: Icons.folder_open_outlined,
        title: 'No documents here / এখানে কোনো ডকুমেন্ট নেই',
      );
    }
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: controller.documents.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, index) => DocumentCard(
          document: controller.documents[index],
          thumbnails: widget.thumbnails,
          onTap: widget.onOpenDocument == null
              ? null
              : () => widget.onOpenDocument!(controller.documents[index].id),
        ),
      ),
    );
  }

  Future<void> _openControls() async {
    final query = widget.controller.query;
    final result = await showModalBottomSheet<DocumentLibraryQuery>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _LibraryControlsSheet(
        query: query,
        owners: widget.ownerOptions,
        categories: widget.categoryOptions,
        tags: widget.tagOptions,
      ),
    );
    if (result != null) await widget.controller.update(result);
  }
}

class DocumentCard extends StatelessWidget {
  const DocumentCard({
    required this.document,
    required this.thumbnails,
    this.onTap,
    super.key,
  });
  final DocumentCardData document;
  final ProtectedThumbnailService thumbnails;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    label: '${document.title}, ${document.ownerLabel}, ${document.category}',
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(10),
        leading: _Preview(reference: document.preview, thumbnails: thumbnails),
        title: Text(
          document.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              document.ownerLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text('${document.category} • ${_expiryLabel(document)}'),
          ],
        ),
        trailing: document.isFavorite
            ? const Icon(Icons.star_rounded, color: Colors.amber)
            : const Icon(Icons.chevron_right),
      ),
    ),
  );

  String _expiryLabel(DocumentCardData data) => switch (data.expiryState) {
    DocumentExpiryState.expired => 'Expired / মেয়াদ শেষ',
    DocumentExpiryState.soon => 'Expiring soon / শিগগির শেষ',
    DocumentExpiryState.valid => 'Valid / কার্যকর',
    DocumentExpiryState.none => 'No expiry / মেয়াদ নেই',
  };
}

class _Preview extends StatelessWidget {
  const _Preview({required this.reference, required this.thumbnails});
  final dynamic reference;
  final ProtectedThumbnailService thumbnails;
  @override
  Widget build(BuildContext context) {
    if (reference == null) return const _PreviewFallback();
    return FutureBuilder<Uint8List?>(
      future: thumbnails.thumbnail(reference),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) return const _PreviewFallback();
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(bytes, width: 56, height: 64, fit: BoxFit.cover),
        );
      },
    );
  }
}

class _PreviewFallback extends StatelessWidget {
  const _PreviewFallback();
  @override
  Widget build(BuildContext context) => Container(
    width: 56,
    height: 64,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.description_outlined),
  );
}

class DocumentDetailsScreen extends StatelessWidget {
  const DocumentDetailsScreen({
    required this.details,
    required this.thumbnails,
    this.onOpenPreview,
    this.onShareExport,
    this.onEditReminder,
    this.onSetFavorite,
    this.onArchive,
    this.onRestoreArchive,
    this.onMoveToTrash,
    this.onRestoreFromTrash,
    this.onDeletePermanently,
    super.key,
  });
  final DocumentDetailsData details;
  final ProtectedThumbnailService thumbnails;
  final VoidCallback? onOpenPreview;
  final VoidCallback? onShareExport;
  final VoidCallback? onEditReminder;
  final Future<void> Function(bool favorite)? onSetFavorite;
  final Future<void> Function()? onArchive;
  final Future<void> Function()? onRestoreArchive;
  final Future<void> Function()? onMoveToTrash;
  final Future<void> Function()? onRestoreFromTrash;
  final Future<void> Function()? onDeletePermanently;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(details.card.category),
      actions: [
        IconButton(
          tooltip: 'Favorite / পছন্দের',
          icon: Icon(details.card.isFavorite ? Icons.star : Icons.star_outline),
          onPressed: onSetFavorite == null
              ? null
              : () => onSetFavorite!(!details.card.isFavorite),
        ),
        PopupMenuButton<_DocumentLifecycleAction>(
          tooltip: 'Document actions / ডকুমেন্টের কাজ',
          onSelected: (action) => _runAction(context, action),
          itemBuilder: (context) => [
            if (details.card.isTrashed) ...[
              if (onRestoreFromTrash != null)
                const PopupMenuItem(
                  value: _DocumentLifecycleAction.restoreTrash,
                  child: Text('Restore from Trash / ট্র্যাশ থেকে পুনরুদ্ধার'),
                ),
              if (onDeletePermanently != null)
                const PopupMenuItem(
                  value: _DocumentLifecycleAction.deletePermanently,
                  child: Text('Delete permanently / স্থায়ীভাবে মুছুন'),
                ),
            ] else ...[
              if (onShareExport != null)
                const PopupMenuItem(
                  value: _DocumentLifecycleAction.shareExport,
                  child: Text('Share/Export / শেয়ার বা রপ্তানি'),
                ),
              if (details.card.isArchived && onRestoreArchive != null)
                const PopupMenuItem(
                  value: _DocumentLifecycleAction.restoreArchive,
                  child: Text('Restore from Archive / আর্কাইভ থেকে পুনরুদ্ধার'),
                ),
              if (!details.card.isArchived && onArchive != null)
                const PopupMenuItem(
                  value: _DocumentLifecycleAction.archive,
                  child: Text('Archive / আর্কাইভ করুন'),
                ),
              if (onMoveToTrash != null)
                const PopupMenuItem(
                  value: _DocumentLifecycleAction.moveToTrash,
                  child: Text('Move to Trash / ট্র্যাশে পাঠান'),
                ),
            ],
          ],
        ),
      ],
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (details.card.preview != null)
            SizedBox(
              height: 180,
              child: Center(
                child: InkWell(
                  onTap: onOpenPreview,
                  child: _Preview(
                    reference: details.card.preview,
                    thumbnails: thumbnails,
                  ),
                ),
              ),
            ),
          Text(
            details.card.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text('${details.card.ownerLabel} • ${details.card.category}'),
          _section(context, 'Important dates / গুরুত্বপূর্ণ তারিখ', [
            _line('Issue / ইস্যু', _date(details.issueDate)),
            _line('Expiry / মেয়াদ শেষ', _date(details.expiryDate)),
          ]),
          _section(context, 'Document information / ডকুমেন্টের তথ্য', [
            _line('Number / নম্বর', _mask(details.documentNumber)),
            _line('Authority / কর্তৃপক্ষ', details.issuingAuthority),
            ...details.fields.map(
              (field) => _line(field.label ?? field.key, field.value),
            ),
          ]),
          _section(context, 'Organisation / সংগঠন', [
            _line('Tags / ট্যাগ', details.tags.join(', ')),
            _line(
              'Original location / মূল কাগজের অবস্থান',
              details.physicalLocation,
            ),
          ]),
          _section(context, 'Notes / নোট', [_line('', details.notes)]),
          _section(context, 'Reminder / রিমাইন্ডার', [
            _line(
              'Status / অবস্থা',
              details.reminder.enabled ? 'Enabled / চালু' : 'Off / বন্ধ',
            ),
            _line('Next / পরবর্তী', _date(details.reminder.nextScheduledAt)),
            if (onEditReminder != null)
              OutlinedButton.icon(
                onPressed: onEditReminder,
                icon: const Icon(Icons.notifications_outlined),
                label: const Text('Edit reminder / রিমাইন্ডার পরিবর্তন করুন'),
              ),
          ]),
          _section(context, 'Record / রেকর্ড', [
            _line('Created / তৈরি', _date(details.card.createdAt)),
            _line('Updated / হালনাগাদ', _date(details.card.updatedAt)),
            _line('Pages / পৃষ্ঠা', '${details.pageCount}'),
          ]),
        ],
      ),
    ),
  );

  Future<void> _runAction(
    BuildContext context,
    _DocumentLifecycleAction action,
  ) async {
    switch (action) {
      case _DocumentLifecycleAction.shareExport:
        onShareExport?.call();
        return;
      case _DocumentLifecycleAction.archive:
        await onArchive?.call();
        return;
      case _DocumentLifecycleAction.restoreArchive:
        await onRestoreArchive?.call();
        return;
      case _DocumentLifecycleAction.moveToTrash:
        if (await _confirm(
          context,
          title: 'Move to Trash? / ট্র্যাশে পাঠাবেন?',
          body: 'You can restore this document before it is permanently deleted. / স্থায়ীভাবে মোছার আগে এটি পুনরুদ্ধার করা যাবে।',
          action: 'Move to Trash / ট্র্যাশে পাঠান',
        )) {
          await onMoveToTrash?.call();
        }
        return;
      case _DocumentLifecycleAction.restoreTrash:
        await onRestoreFromTrash?.call();
        return;
      case _DocumentLifecycleAction.deletePermanently:
        if (await _confirm(
          context,
          title: 'Delete permanently? / স্থায়ীভাবে মুছবেন?',
          body: 'This removes the encrypted files and related reminders. It cannot be undone. / এনক্রিপ্ট করা ফাইল ও সম্পর্কিত রিমাইন্ডার মুছে যাবে। এটি ফেরানো যাবে না।',
          action: 'Delete permanently / স্থায়ীভাবে মুছুন',
          destructive: true,
        )) {
          await onDeletePermanently?.call();
        }
        return;
    }
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String action,
    bool destructive = false,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel / বাতিল'),
            ),
            FilledButton(
              style: destructive
                  ? FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    )
                  : null,
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(action),
            ),
          ],
        ),
      ) ??
      false;

  Widget _section(BuildContext context, String title, List<Widget> content) =>
      Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...content,
          ],
        ),
      );
  Widget _line(String label, String? value) => value == null || value.isEmpty
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(label.isEmpty ? value : '$label: $value'),
        );
  String _date(DateTime? value) => value == null
      ? 'Not set / দেওয়া হয়নি'
      : '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  String? _mask(String? value) => value == null || value.length <= 4
      ? value
      : '${'•' * (value.length - 4)}${value.substring(value.length - 4)}';
}

enum _DocumentLifecycleAction {
  shareExport,
  archive,
  restoreArchive,
  moveToTrash,
  restoreTrash,
  deletePermanently,
}

class _LibraryControlsSheet extends StatefulWidget {
  const _LibraryControlsSheet({
    required this.query,
    required this.owners,
    required this.categories,
    required this.tags,
  });
  final DocumentLibraryQuery query;
  final List<LibraryFilterOption> owners;
  final List<LibraryFilterOption> categories;
  final List<LibraryFilterOption> tags;

  @override
  State<_LibraryControlsSheet> createState() => _LibraryControlsSheetState();
}

class _LibraryControlsSheetState extends State<_LibraryControlsSheet> {
  late DocumentSort _sort = widget.query.sort;
  late DocumentLibraryFilter _filter = widget.query.filter;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: ListView(
        shrinkWrap: true,
        children: [
          Text(
            'Filter and sort / ফিল্টার ও সাজান',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _choice<String>(
            label: 'Owner / মালিক',
            value: _filter.ownerId,
            choices: widget.owners,
            onChanged: (value) => setState(
              () => _filter = _filter.copyWith(
                ownerId: value,
                clearOwner: value == null,
              ),
            ),
          ),
          _choice<String>(
            label: 'Category / বিভাগ',
            value: _filter.categoryId,
            choices: widget.categories,
            onChanged: (value) => setState(
              () => _filter = _filter.copyWith(
                categoryId: value,
                clearCategory: value == null,
              ),
            ),
          ),
          _choice<String>(
            label: 'Tag / ট্যাগ',
            value: _filter.tagId,
            choices: widget.tags,
            onChanged: (value) => setState(
              () => _filter = _filter.copyWith(
                tagId: value,
                clearTag: value == null,
              ),
            ),
          ),
          DropdownButtonFormField<ExpiryFilter>(
            initialValue: _filter.expiry,
            decoration: const InputDecoration(labelText: 'Expiry / মেয়াদ'),
            items: ExpiryFilter.values
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(_expiryLabel(value)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _filter = _filter.copyWith(expiry: value));
              }
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<DocumentFileType>(
            initialValue: _filter.fileType,
            decoration: const InputDecoration(
              labelText: 'File type / ফাইলের ধরন',
            ),
            items: DocumentFileType.values
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(_fileTypeLabel(value)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _filter = _filter.copyWith(fileType: value));
              }
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _filter.favoriteOnly,
            title: const Text('Favorites only / শুধু পছন্দের'),
            onChanged: (value) =>
                setState(() => _filter = _filter.copyWith(favoriteOnly: value)),
          ),
          DropdownButtonFormField<ArchiveFilter>(
            initialValue: _filter.archive,
            decoration: const InputDecoration(labelText: 'Archive / আর্কাইভ'),
            items: ArchiveFilter.values
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(_archiveLabel(value)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _filter = _filter.copyWith(archive: value));
              }
            },
          ),
          const SizedBox(height: 18),
          Text(
            'Sort by / সাজানোর ধরন',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final sort in DocumentSort.values)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_sortLabel(sort)),
              trailing: sort == _sort ? const Icon(Icons.check) : null,
              onTap: () => setState(() => _sort = sort),
            ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              widget.query.copyWith(sort: _sort, filter: _filter),
            ),
            child: const Text('Apply / প্রয়োগ করুন'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              widget.query.copyWith(filter: const DocumentLibraryFilter()),
            ),
            child: const Text('Reset filters / ফিল্টার মুছুন'),
          ),
        ],
      ),
    ),
  );

  Widget _choice<T>({
    required String label,
    required T? value,
    required List<LibraryFilterOption> choices,
    required ValueChanged<T?> onChanged,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        DropdownMenuItem<T>(value: null, child: const Text('Any / সব')),
        ...choices.map(
          (choice) => DropdownMenuItem<T>(
            value: choice.id as T,
            child: Text(choice.label),
          ),
        ),
      ],
      onChanged: onChanged,
    ),
  );

  String _sortLabel(DocumentSort value) => switch (value) {
    DocumentSort.recentlyAdded => 'Recently added / সম্প্রতি যোগ করা',
    DocumentSort.recentlyUpdated => 'Recently updated / সম্প্রতি হালনাগাদ',
    DocumentSort.title => 'Title / শিরোনাম',
    DocumentSort.issueDate => 'Issue date / ইস্যুর তারিখ',
    DocumentSort.expiryDate => 'Expiry / মেয়াদ শেষ',
    DocumentSort.category => 'Category / বিভাগ',
    DocumentSort.owner => 'Owner / মালিক',
  };
  String _expiryLabel(ExpiryFilter value) => switch (value) {
    ExpiryFilter.any => 'Any expiry / সব',
    ExpiryFilter.expired => 'Expired / মেয়াদ শেষ',
    ExpiryFilter.expiringSoon => 'Expiring soon / শিগগির শেষ',
    ExpiryFilter.valid => 'Valid / কার্যকর',
    ExpiryFilter.noExpiry => 'No expiry / মেয়াদ নেই',
  };
  String _fileTypeLabel(DocumentFileType value) => switch (value) {
    DocumentFileType.any => 'Any file / সব ফাইল',
    DocumentFileType.image => 'Images / ছবি',
    DocumentFileType.pdf => 'PDF',
    DocumentFileType.other => 'Other / অন্যান্য',
  };
  String _archiveLabel(ArchiveFilter value) => switch (value) {
    ArchiveFilter.active => 'Active / সক্রিয়',
    ArchiveFilter.archived => 'Archived / আর্কাইভ',
    ArchiveFilter.all => 'All / সব',
  };
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.icon, required this.title, this.action});
  final IconData icon;
  final String title;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    ),
  );
}
