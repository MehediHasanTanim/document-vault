import 'package:flutter/material.dart';

import '../application/library/document_library_models.dart';
import '../application/search/secure_search_controller.dart';

/// Unlocked-only search UI. The controller has no disk-backed history; recent
/// query chips appear only when its caller explicitly enables in-memory recents.
class SecureSearchScreen extends StatefulWidget {
  const SecureSearchScreen({
    required this.controller,
    this.onOpenDocument,
    this.onEditFilters,
    super.key,
  });
  final SecureSearchController controller;
  final ValueChanged<String>? onOpenDocument;
  final Future<DocumentLibraryFilter?> Function(
    BuildContext context,
    DocumentLibraryFilter current,
  )?
  onEditFilters;

  @override
  State<SecureSearchScreen> createState() => _SecureSearchScreenState();
}

class _SecureSearchScreenState extends State<SecureSearchScreen> {
  late final TextEditingController _query;

  @override
  void initState() {
    super.initState();
    _query = TextEditingController(text: widget.controller.query);
    widget.controller.addListener(_changed);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    _query.dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final query = controller.query.trim();
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _query,
          autofocus: true,
          onChanged: controller.search,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search documents / ডকুমেন্ট খুঁজুন',
            border: InputBorder.none,
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search / খোঁজা মুছুন',
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _query.clear();
                      controller.clearQuery();
                    },
                  ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Search filters / সার্চ ফিল্টার',
            icon: const Icon(Icons.tune),
            onPressed: widget.onEditFilters == null ? null : _editFilters,
          ),
        ],
      ),
      body: SafeArea(
        child: query.isEmpty ? _suggestions(controller) : _results(controller),
      ),
    );
  }

  Widget _suggestions(SecureSearchController controller) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      if (controller.recentSearches.isNotEmpty) ...[
        Row(
          children: [
            Expanded(
              child: Text(
                'This session / এই সেশন',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton(
              onPressed: controller.clearRecentSearches,
              child: const Text('Clear / মুছুন'),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.recentSearches.map(_queryChip).toList(),
        ),
        const SizedBox(height: 20),
      ],
      Text(
        'Suggestions / পরামর্শ',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      ...controller.suggestions.map(
        (suggestion) => ListTile(
          leading: const Icon(Icons.search),
          title: Text(suggestion.label),
          onTap: () => _useQuery(suggestion.query),
        ),
      ),
    ],
  );

  Widget _results(SecureSearchController controller) {
    if (controller.results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'No documents found for “${controller.query}” / কোনো ডকুমেন্ট পাওয়া যায়নি',
                textAlign: TextAlign.center,
              ),
              TextButton(
                onPressed: () {
                  _query.clear();
                  controller.clearQuery();
                },
                child: const Text('Clear search / খোঁজা মুছুন'),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final result = controller.results[index];
        return ListTile(
          leading: const Icon(Icons.description_outlined),
          title: Text(result.title),
          subtitle: Text('${result.ownerLabel} • ${result.category}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: widget.onOpenDocument == null
              ? null
              : () => widget.onOpenDocument!(result.documentId),
        );
      },
    );
  }

  Widget _queryChip(String value) =>
      ActionChip(label: Text(value), onPressed: () => _useQuery(value));
  void _useQuery(String value) {
    _query.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    widget.controller.search(value);
  }

  Future<void> _editFilters() async {
    final filter = await widget.onEditFilters!(
      context,
      widget.controller.filter,
    );
    if (filter != null) widget.controller.updateFilter(filter);
  }
}
