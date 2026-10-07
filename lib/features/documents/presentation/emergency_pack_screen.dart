import 'package:flutter/material.dart';

import '../../backup/application/backup_models.dart';
import '../application/emergency/emergency_export_service.dart';

/// Safe, already-unlocked document display data. It deliberately has no
/// document number, filename, path, owner notes, or other hidden metadata.
class EmergencyDocumentOption {
  const EmergencyDocumentOption({
    required this.id,
    required this.title,
    required this.category,
  });

  final String id;
  final String title;
  final String category;
}

class EmergencyPackScreen extends StatefulWidget {
  const EmergencyPackScreen({
    required this.documents,
    required this.initialSelection,
    this.onSaveSelection,
    this.onExport,
    super.key,
  });

  final List<EmergencyDocumentOption> documents;
  final Set<String> initialSelection;

  /// Persists an explicit collection selection. It must not infer extra items.
  final Future<void> Function(List<String> documentIds)? onSaveSelection;

  /// Builds secure page requests and invokes [EmergencyExportService] outside
  /// the widget, so this UI never holds decrypted files or source paths.
  final Future<bool> Function(
    List<String> documentIds,
    EmergencyExportProtection protection,
  )?
  onExport;

  @override
  State<EmergencyPackScreen> createState() => _EmergencyPackScreenState();
}

class _EmergencyPackScreenState extends State<EmergencyPackScreen> {
  late final Set<String> _selected = {...widget.initialSelection};
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  var _passwordProtected = true;
  var _saving = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Emergency Pack / জরুরি প্যাক')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          const Text(
            'Choose only documents you would need in an emergency. Nothing is added automatically. / জরুরি প্রয়োজনে লাগবে এমন নথিই বেছে নিন। কোনো নথি স্বয়ংক্রিয়ভাবে যোগ হবে না।',
          ),
          const SizedBox(height: 16),
          if (widget.documents.isEmpty)
            const _EmergencyEmptyState()
          else ...[
            Text(
              'Selected documents / নির্বাচিত নথি (${_selected.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...widget.documents.map(_documentTile),
            const SizedBox(height: 16),
            _protectionSection(context),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            if (widget.onSaveSelection != null)
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _saving ? null : _saveSelection,
                  child: const Text('Save selection / নির্বাচন সংরক্ষণ করুন'),
                ),
              ),
            if (widget.onSaveSelection != null) const SizedBox(height: 12),
            if (widget.onExport != null)
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _export,
                  icon: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.emergency_share_outlined),
                  label: Text(
                    _saving
                        ? 'Preparing… / প্রস্তুত হচ্ছে…'
                        : 'Export emergency pack / জরুরি প্যাক রপ্তানি করুন',
                  ),
                ),
              ),
          ],
        ],
      ),
    ),
  );

  Widget _documentTile(EmergencyDocumentOption document) => CheckboxListTile(
    contentPadding: EdgeInsets.zero,
    value: _selected.contains(document.id),
    title: Text(document.title),
    subtitle: Text(document.category),
    controlAffinity: ListTileControlAffinity.leading,
    onChanged: _saving
        ? null
        : (checked) => setState(() {
            if (checked ?? false) {
              _selected.add(document.id);
            } else {
              _selected.remove(document.id);
            }
            _error = null;
          }),
  );

  Widget _protectionSection(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export protection / রপ্তানি সুরক্ষা',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          RadioGroup<bool>(
            groupValue: _passwordProtected,
            onChanged: (value) {
              if (_saving || value == null) return;
              setState(() => _passwordProtected = value);
            },
            child: Column(
              children: [
                const RadioListTile<bool>(
                  contentPadding: EdgeInsets.zero,
                  value: true,
                  title: Text('Password protected / পাসওয়ার্ড সুরক্ষিত'),
                  subtitle: Text(
                    'Creates an encrypted emergency package / এনক্রিপ্ট করা জরুরি প্যাক তৈরি করে',
                  ),
                ),
                if (_passwordProtected) ...[
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText:
                          'Emergency pack password / জরুরি প্যাকের পাসওয়ার্ড',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmation,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Confirm password / পাসওয়ার্ড নিশ্চিত করুন',
                      helperText: 'A forgotten export password cannot be recovered / ভুলে গেলে রপ্তানি পাসওয়ার্ড পুনরুদ্ধার করা যাবে না',
                    ),
                  ),
                ],
                const RadioListTile<bool>(
                  contentPadding: EdgeInsets.zero,
                  value: false,
                  title: Text('Unencrypted images / এনক্রিপশনবিহীন ছবি'),
                  subtitle: Text(
                    'Can be read outside the vault / ভল্টের বাইরে পড়া যাবে',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _saveSelection() async {
    if (!_requireSelection()) return;
    setState(() => _saving = true);
    try {
      await widget.onSaveSelection!(_selected.toList(growable: false));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Emergency selection saved / জরুরি নির্বাচন সংরক্ষিত হয়েছে',
            ),
          ),
        );
      }
    } on Object {
      if (mounted) {
        setState(
          () => _error = 'Could not save the emergency selection. / জরুরি নির্বাচন সংরক্ষণ করা যায়নি।',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _export() async {
    if (!_requireSelection()) return;
    final protection = await _protection();
    if (protection == null || !mounted) return;
    setState(() => _saving = true);
    try {
      final complete = await widget.onExport!(
        _selected.toList(growable: false),
        protection,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            complete
                ? 'Emergency export completed / জরুরি রপ্তানি সম্পন্ন হয়েছে'
                : 'Emergency export cancelled / জরুরি রপ্তানি বাতিল করা হয়েছে',
          ),
        ),
      );
    } on Object {
      if (mounted) {
        setState(
          () => _error = 'Could not export the emergency pack. / জরুরি প্যাক রপ্তানি করা যায়নি।',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool _requireSelection() {
    if (_selected.isNotEmpty) return true;
    setState(
      () => _error = 'Choose at least one document. / অন্তত একটি নথি বেছে নিন।',
    );
    return false;
  }

  Future<EmergencyExportProtection?> _protection() async {
    if (_passwordProtected) {
      try {
        return EmergencyExportProtection.password(
          BackupPassword.create(
            password: _password.text,
            confirmation: _confirmation.text,
            acknowledgedRecoveryWarning: true,
          ),
        );
      } on Object {
        if (mounted) {
          setState(
            () => _error = 'Use and confirm a strong password of at least 12 characters. / অন্তত ১২ অক্ষরের শক্তিশালী পাসওয়ার্ড দিন ও নিশ্চিত করুন।',
          );
        }
        return null;
      }
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Export unencrypted images? / এনক্রিপশনবিহীন ছবি রপ্তানি করবেন?',
        ),
        content: const Text(
          'These images can be opened outside Document Vault BD. Share or store them only where you trust the recipient and device. / এই ছবিগুলো Document Vault BD-এর বাইরে খোলা যাবে। শুধুমাত্র বিশ্বস্ত ব্যক্তি ও ডিভাইসের সঙ্গে শেয়ার বা সংরক্ষণ করুন।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel / বাতিল'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Export / রপ্তানি করুন'),
          ),
        ],
      ),
    );
    return confirmed == true
        ? const EmergencyExportProtection.unencrypted(
            acknowledgedUnencryptedRisk: true,
          )
        : null;
  }
}

class _EmergencyEmptyState extends StatelessWidget {
  const _EmergencyEmptyState();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(top: 44),
    child: Column(
      children: [
        Icon(Icons.emergency_outlined, size: 48),
        SizedBox(height: 12),
        Text('No documents available / কোনো নথি উপলব্ধ নেই'),
        SizedBox(height: 6),
        Text(
          'Add documents to your vault before creating an emergency pack. / জরুরি প্যাক তৈরির আগে ভল্টে নথি যোগ করুন।',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
