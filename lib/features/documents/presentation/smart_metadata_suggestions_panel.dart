import 'package:flutter/material.dart';

import '../application/smart_metadata/smart_metadata_models.dart';
import '../application/creation/document_selection.dart';

/// Displays local suggestions as reviewable choices. Values are deliberately
/// passed back only after an explicit user action; this widget never writes to
/// a form controller or a database itself.
class SmartMetadataSuggestionsPanel extends StatelessWidget {
  const SmartMetadataSuggestionsPanel({
    required this.suggestions,
    this.onUseCategory,
    this.onUseTitle,
    this.onUseDocumentNumber,
    this.onUseIssueDate,
    this.onUseExpiryDate,
    super.key,
  });

  final SmartMetadataSuggestions suggestions;
  final ValueChanged<CategorySearchEntry>? onUseCategory;
  final ValueChanged<String>? onUseTitle;
  final ValueChanged<String>? onUseDocumentNumber;
  final ValueChanged<DateTime>? onUseIssueDate;
  final ValueChanged<DateTime>? onUseExpiryDate;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Local suggestions / স্থানীয় পরামর্শ',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'Nothing is filled in until you choose Use. Review each value carefully. / ব্যবহার না করা পর্যন্ত কোনো তথ্য যোগ হবে না। প্রতিটি তথ্য যাচাই করুন।',
            ),
            if (suggestions.category case final value?)
              _SuggestionRow(
                label: 'Category / বিভাগ',
                value: value.value.label,
                suggestion: value,
                onUse: onUseCategory == null
                    ? null
                    : () => onUseCategory!(value.value),
              ),
            if (suggestions.title case final value?)
              _SuggestionRow(
                label: 'Title / শিরোনাম',
                value: value.value,
                suggestion: value,
                onUse: onUseTitle == null
                    ? null
                    : () => onUseTitle!(value.value),
              ),
            if (suggestions.documentNumber case final value?)
              _SuggestionRow(
                label: 'Document number / ডকুমেন্ট নম্বর',
                value: _masked(value.value),
                suggestion: value,
                onUse: onUseDocumentNumber == null
                    ? null
                    : () => onUseDocumentNumber!(value.value),
              ),
            if (suggestions.issueDate case final value?)
              _SuggestionRow(
                label: 'Issue date / ইস্যুর তারিখ',
                value: _date(value.value),
                suggestion: value,
                onUse: onUseIssueDate == null
                    ? null
                    : () => onUseIssueDate!(value.value),
              ),
            if (suggestions.expiryDate case final value?)
              _SuggestionRow(
                label: 'Expiry date / মেয়াদ শেষের তারিখ',
                value: _date(value.value),
                suggestion: value,
                onUse: onUseExpiryDate == null
                    ? null
                    : () => onUseExpiryDate!(value.value),
              ),
          ],
        ),
      ),
    );
  }

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  static String _masked(String value) {
    if (value.length <= 4) return '••••';
    return '${'•' * (value.length - 4)}${value.substring(value.length - 4)}';
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({
    required this.label,
    required this.value,
    required this.suggestion,
    required this.onUse,
  });

  final String label;
  final String value;
  final SmartSuggestion<Object> suggestion;
  final VoidCallback? onUse;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 2),
        Text(value),
        const SizedBox(height: 2),
        Text(
          '${(suggestion.confidence * 100).round()}% confidence · ${suggestion.reason}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: onUse,
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Use / ব্যবহার করুন'),
        ),
      ],
    ),
  );
}
