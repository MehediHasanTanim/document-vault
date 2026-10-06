import 'package:flutter/material.dart';

import '../application/backup_models.dart';

/// Password input holds the value only until [onContinue] finishes. Errors are
/// intentionally generic so a damaged file cannot be distinguished from an
/// incorrect password.
class RestorePasswordScreen extends StatefulWidget {
  const RestorePasswordScreen({required this.onContinue, super.key});
  final Future<void> Function(BackupPassword password) onContinue;

  @override
  State<RestorePasswordScreen> createState() => _RestorePasswordScreenState();
}

class _RestorePasswordScreenState extends State<RestorePasswordScreen> {
  final _password = TextEditingController();
  var _obscure = true;
  var _working = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Restore backup / ব্যাকআপ পুনরুদ্ধার')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Enter the password used when this backup was created. '
            'Your current vault will not change until validation finishes.\n\n'
            'ব্যাকআপ তৈরির সময়ের পাসওয়ার্ড দিন। যাচাই শেষ না হওয়া পর্যন্ত বর্তমান ভল্ট বদলাবে না।',
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _password,
            obscureText: _obscure,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: 'Backup password / ব্যাকআপ পাসওয়ার্ড',
              errorText: _error,
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                tooltip: _obscure
                    ? 'Show password / পাসওয়ার্ড দেখান'
                    : 'Hide password / পাসওয়ার্ড লুকান',
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _working ? null : _continue,
            child: Text(
              _working
                  ? 'Checking backup… / ব্যাকআপ যাচাই হচ্ছে…'
                  : 'Continue / চালিয়ে যান',
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _continue() async {
    try {
      setState(() {
        _working = true;
        _error = null;
      });
      await widget.onContinue(BackupPassword.forRestore(_password.text));
    } on Object {
      if (mounted) {
        setState(() {
          _working = false;
          _error = 'Password is incorrect or this backup is damaged. / পাসওয়ার্ড ভুল অথবা ব্যাকআপটি ক্ষতিগ্রস্ত।';
        });
      }
    }
  }
}

class RestoreSummaryScreen extends StatelessWidget {
  const RestoreSummaryScreen({
    required this.summary,
    required this.onRestore,
    super.key,
  });
  final RestoreSummary summary;
  final Future<void> Function() onRestore;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Restore summary / পুনরুদ্ধার সারসংক্ষেপ'),
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Backup date: ${MaterialLocalizations.of(context).formatMediumDate(summary.backupDate.toLocal())}',
            ),
            Text(
              'Documents: ${summary.documentCount} / নথি: ${summary.documentCount}',
            ),
            Text(
              'Family members: ${summary.familyMemberCount} / পরিবারের সদস্য: ${summary.familyMemberCount}',
            ),
            Text('Approximate size: ${_size(summary.approximateSizeBytes)}'),
            const Spacer(),
            const Text(
              'Restoring replaces this device vault after a verified rollback snapshot is made.\nবর্তমান ভল্টের যাচাইকৃত কপি রেখে পুনরুদ্ধার করা হবে।',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.restore),
              label: const Text(
                'Restore this backup / এই ব্যাকআপ পুনরুদ্ধার করুন',
              ),
              onPressed: () async => onRestore(),
            ),
          ],
        ),
      ),
    ),
  );

  String _size(int bytes) => '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

/// Offline instructions presented during device migration. They never suggest
/// an app account or upload; transfer the already encrypted backup yourself.
class DeviceMigrationInstructionsScreen extends StatelessWidget {
  const DeviceMigrationInstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Move to a new phone / নতুন ফোনে নিন')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            'Old phone / পুরোনো ফোন',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '1. Create a verified encrypted backup.\n2. Transfer the .dvbak file yourself with a cable, removable storage, or a provider you choose.\n3. Keep the password private.\n\n১. যাচাইকৃত এনক্রিপ্টেড ব্যাকআপ তৈরি করুন।\n২. কেবল, স্টোরেজ বা আপনার পছন্দের মাধ্যমে .dvbak ফাইল পাঠান।\n৩. পাসওয়ার্ড গোপন রাখুন।',
          ),
          SizedBox(height: 24),
          Text(
            'New phone / নতুন ফোন',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '1. Install Document Vault BD.\n2. Choose Restore and select the transferred file.\n3. Enter the backup password, review the authenticated summary, and restore.\n4. Set a new app PIN and re-enable biometrics if desired.\n\n১. Document Vault BD ইনস্টল করুন।\n২. Restore বেছে ফাইল নির্বাচন করুন।\n৩. পাসওয়ার্ড দিয়ে সারসংক্ষেপ দেখে পুনরুদ্ধার করুন।\n৪. নতুন অ্যাপ PIN দিন এবং চাইলে বায়োমেট্রিক চালু করুন।',
          ),
        ],
      ),
    ),
  );
}
