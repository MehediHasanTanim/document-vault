import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../application/export/secure_export_models.dart';
import '../application/export/secure_export_service.dart';

/// Deliberate share confirmation. The caller supplies only safe display text;
/// this screen never displays a document number, filename, or recipient.
class SecureShareExportScreen extends StatefulWidget {
  const SecureShareExportScreen({
    required this.documentLabel,
    required this.request,
    required this.exports,
    required this.coordinator,
    super.key,
  });

  final String documentLabel;
  final SecureExportRequest request;
  final SecureExportService exports;
  final SecureShareCoordinator coordinator;

  @override
  State<SecureShareExportScreen> createState() =>
      _SecureShareExportScreenState();
}

class _SecureShareExportScreenState extends State<SecureShareExportScreen> {
  late final Set<int> _selected = {...widget.request.selectedPageNumbers};
  final _watermark = TextEditingController();
  Uint8List? _preview;
  Object? _previewError;
  var _useWatermark = false;
  var _preparing = false;

  @override
  void dispose() {
    _watermark.dispose();
    super.dispose();
  }

  SecureExportRequest get _request => SecureExportRequest(
    documentId: widget.request.documentId,
    pages: widget.request.pages,
    selectedPageNumbers: _selected,
    watermark: _useWatermark && _watermark.text.trim().isNotEmpty
        ? ExportWatermark(_watermark.text.trim())
        : null,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Share document? / ডকুমেন্ট শেয়ার করবেন?'),
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.documentLabel,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Shared files leave the protected vault and may be stored by another app or person. / শেয়ার করা ফাইল সুরক্ষিত ভল্টের বাইরে চলে যাবে এবং অন্য অ্যাপ বা ব্যক্তির কাছে সংরক্ষিত হতে পারে।',
          ),
          const SizedBox(height: 24),
          Text(
            'Pages / পৃষ্ঠা',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          ...widget.request.pages.map(
            (page) => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _selected.contains(page.pageNumber),
              title: Text(
                'Page ${page.pageNumber} / পৃষ্ঠা ${page.pageNumber}',
              ),
              subtitle: Text(
                page.redactions.isEmpty
                    ? 'No redactions / কোনো রেডাকশন নেই'
                    : '${page.redactions.length} permanent redaction(s) / স্থায়ী রেডাকশন',
              ),
              onChanged: _preparing
                  ? null
                  : (selected) => setState(() {
                      if (selected ?? false) {
                        _selected.add(page.pageNumber);
                      } else {
                        _selected.remove(page.pageNumber);
                      }
                      _preview = null;
                      _previewError = null;
                    }),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _useWatermark,
            title: const Text('Watermark / ওয়াটারমার্ক'),
            subtitle: const Text(
              'Permanently flattened into each image / প্রতিটি ছবিতে স্থায়ীভাবে যুক্ত হবে',
            ),
            onChanged: _preparing
                ? null
                : (value) => setState(() {
                    _useWatermark = value;
                    if (value && _watermark.text.isEmpty) {
                      _watermark.text = 'Shared copy';
                    }
                    _preview = null;
                  }),
          ),
          if (_useWatermark)
            TextFormField(
              controller: _watermark,
              maxLength: 80,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                labelText: 'Watermark text / ওয়াটারমার্ক লেখা',
                helperText: 'Use English letters, numbers, and punctuation / ইংরেজি অক্ষর, সংখ্যা ও চিহ্ন ব্যবহার করুন',
              ),
              onChanged: (_) => setState(() => _preview = null),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _preparing || _selected.isEmpty ? null : _loadPreview,
            icon: const Icon(Icons.preview_outlined),
            label: const Text('Preview export / রপ্তানি প্রিভিউ'),
          ),
          if (_previewError != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Preview could not be prepared. / প্রিভিউ তৈরি করা যায়নি।',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (_preview != null) ...[
            const SizedBox(height: 12),
            Semantics(
              label: 'Flattened export preview / সমতল করা রপ্তানি প্রিভিউ',
              image: true,
              child: Image.memory(_preview!, fit: BoxFit.contain),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: _preparing || _selected.isEmpty ? null : _share,
              icon: _preparing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.ios_share),
              label: Text(
                _preparing
                    ? 'Preparing secure export… / নিরাপদ রপ্তানি তৈরি হচ্ছে…'
                    : 'Continue to Share / শেয়ার করতে চালিয়ে যান',
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _loadPreview() async {
    final pageNumber = _selected.first;
    try {
      final preview = await widget.exports.preview(_request, pageNumber);
      if (mounted) {
        setState(() {
          _preview = preview.jpegBytes;
          _previewError = null;
        });
      }
    } on Object catch (error) {
      if (mounted) setState(() => _previewError = error);
    }
  }

  Future<void> _share() async {
    if (!_validWatermark()) return;
    setState(() => _preparing = true);
    try {
      final handedOff = await widget.coordinator.exportAndShare(_request);
      if (!mounted) return;
      if (handedOff) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sharing cancelled / শেয়ার বাতিল করা হয়েছে'),
          ),
        );
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not prepare secure export / নিরাপদ রপ্তানি তৈরি করা যায়নি',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _preparing = false);
    }
  }

  bool _validWatermark() {
    if (!_useWatermark ||
        RegExp(r'^[\x20-\x7e]{1,80}$').hasMatch(_watermark.text.trim())) {
      return true;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Use supported watermark characters / সমর্থিত ওয়াটারমার্ক অক্ষর ব্যবহার করুন',
        ),
      ),
    );
    return false;
  }
}
