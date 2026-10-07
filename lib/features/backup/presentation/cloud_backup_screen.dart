import 'package:flutter/material.dart';

import '../../../core/errors/app_failure.dart';
import '../application/cloud_backup_provider.dart';
import '../application/cloud_backup_service.dart';

/// Optional cloud-backup control plane. It deliberately shows no account
/// identifier, backup filename, document count, or plaintext metadata.
class CloudBackupScreen extends StatefulWidget {
  const CloudBackupScreen({
    required this.providers,
    this.onCreateEncryptedBackup,
    this.onRestoreVersion,
    super.key,
  });

  final List<BackupProvider> providers;

  /// Must create and locally verify an encrypted package, then use
  /// [CloudBackupDestination] for the selected provider.
  final Future<void> Function(CloudBackupManager manager)?
  onCreateEncryptedBackup;
  final Future<void> Function(
    CloudBackupManager manager,
    CloudBackupVersion version,
  )?
  onRestoreVersion;

  @override
  State<CloudBackupScreen> createState() => _CloudBackupScreenState();
}

class _CloudBackupScreenState extends State<CloudBackupScreen> {
  final _connected = <BackupProviderId, bool>{};
  final _versions = <BackupProviderId, List<CloudBackupVersion>>{};
  BackupProviderId? _busy;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Cloud backup / ক্লাউড ব্যাকআপ')),
    body: SafeArea(
      child: RefreshIndicator(
        onRefresh: _refreshAll,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Cloud backup is optional. Only an already encrypted backup package is uploaded; this provider never becomes your vault source of truth. / ক্লাউড ব্যাকআপ ঐচ্ছিক। শুধু আগে থেকে এনক্রিপ্ট করা ব্যাকআপ আপলোড করা হয়; ক্লাউড কখনো ভল্টের মূল উৎস নয়।',
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (widget.providers.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'Cloud providers are not enabled in this app build. Your local encrypted backups continue to work. / এই অ্যাপ বিল্ডে ক্লাউড প্রোভাইডার চালু নেই। আপনার স্থানীয় এনক্রিপ্ট করা ব্যাকআপ কাজ চালিয়ে যাবে।',
                ),
              ),
            ...widget.providers.map(_providerCard),
          ],
        ),
      ),
    ),
  );

  Widget _providerCard(BackupProvider provider) {
    final connected = _connected[provider.id] ?? false;
    final loading = _busy == provider.id;
    final manager = CloudBackupManager(provider);
    final versions = _versions[provider.id] ?? const <CloudBackupVersion>[];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    provider.descriptor.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  connected
                      ? 'Connected / সংযুক্ত'
                      : 'Not connected / সংযুক্ত নয়',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              connected
                  ? 'Encrypted backup versions only / শুধু এনক্রিপ্ট করা ব্যাকআপ সংস্করণ'
                  : 'Sign in uses the provider’s secure browser flow / সাইন-ইন প্রোভাইডারের নিরাপদ ব্রাউজার ফ্লো ব্যবহার করে',
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (!connected)
                  FilledButton(
                    onPressed: loading ? null : () => _connect(provider),
                    child: const Text('Connect / সংযুক্ত করুন'),
                  ),
                if (connected && widget.onCreateEncryptedBackup != null)
                  FilledButton.icon(
                    onPressed: loading ? null : () => _backup(manager),
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Back up now / এখন ব্যাকআপ করুন'),
                  ),
                if (connected)
                  OutlinedButton(
                    onPressed: loading ? null : () => _refresh(provider),
                    child: const Text('Refresh / রিফ্রেশ'),
                  ),
                if (connected)
                  TextButton(
                    onPressed: loading ? null : () => _disconnect(provider),
                    child: const Text('Disconnect / সংযোগ বিচ্ছিন্ন করুন'),
                  ),
              ],
            ),
            if (loading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
            if (connected && versions.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Available encrypted versions / উপলব্ধ এনক্রিপ্ট করা সংস্করণ',
              ),
              ...versions.map(
                (version) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.lock_outline),
                  title: Text(_date(version.createdAt)),
                  subtitle: Text(_size(version.sizeBytes)),
                  trailing: widget.onRestoreVersion == null
                      ? null
                      : TextButton(
                          onPressed: loading
                              ? null
                              : () => _restore(manager, version),
                          child: const Text('Restore / পুনরুদ্ধার'),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _refreshAll() async {
    for (final provider in widget.providers) {
      await _refresh(provider, quiet: true);
    }
  }

  Future<void> _refresh(BackupProvider provider, {bool quiet = false}) async {
    if (!quiet) setState(() => _busy = provider.id);
    try {
      final connected = await provider.isConnected();
      final versions = connected
          ? await CloudBackupManager(provider).listVersions()
          : const <CloudBackupVersion>[];
      if (mounted) {
        setState(() {
          _connected[provider.id] = connected;
          _versions[provider.id] = versions;
          _error = null;
        });
      }
    } on Object catch (error) {
      _showFailure(
        error,
        'Could not refresh cloud backups. / ক্লাউড ব্যাকআপ রিফ্রেশ করা যায়নি।',
      );
    } finally {
      if (mounted && !quiet) setState(() => _busy = null);
    }
  }

  Future<void> _connect(BackupProvider provider) async {
    setState(() => _busy = provider.id);
    try {
      await provider.authenticate();
      await _refresh(provider, quiet: true);
    } on Object catch (error) {
      _showFailure(
        error,
        'Could not connect this cloud provider. / এই ক্লাউড প্রোভাইডারে সংযুক্ত হওয়া যায়নি।',
      );
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _backup(CloudBackupManager manager) async {
    setState(() => _busy = manager.provider.id);
    try {
      await widget.onCreateEncryptedBackup!(manager);
      await _refresh(manager.provider, quiet: true);
    } on Object catch (error) {
      _showFailure(
        error,
        'Could not create a cloud backup. / ক্লাউড ব্যাকআপ তৈরি করা যায়নি।',
      );
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _restore(
    CloudBackupManager manager,
    CloudBackupVersion version,
  ) async {
    setState(() => _busy = manager.provider.id);
    try {
      await widget.onRestoreVersion!(manager, version);
    } on Object catch (error) {
      _showFailure(
        error,
        'Could not prepare this backup for restore. / পুনরুদ্ধারের জন্য এই ব্যাকআপ প্রস্তুত করা যায়নি।',
      );
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _disconnect(BackupProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Disconnect provider? / প্রোভাইডার সংযোগ বিচ্ছিন্ন করবেন?',
        ),
        content: const Text(
          'This removes the sign-in token only. Your encrypted cloud backups and local vault will not be deleted. / এটি শুধু সাইন-ইন টোকেন মুছবে। আপনার এনক্রিপ্ট করা ক্লাউড ব্যাকআপ ও স্থানীয় ভল্ট মুছে যাবে না।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel / বাতিল'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Disconnect / সংযোগ বিচ্ছিন্ন করুন'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _busy = provider.id);
    try {
      await provider.disconnect();
      if (mounted) {
        setState(() {
          _connected[provider.id] = false;
          _versions.remove(provider.id);
        });
      }
    } on Object catch (error) {
      _showFailure(
        error,
        'Could not disconnect this cloud provider. / এই ক্লাউড প্রোভাইডারের সংযোগ বিচ্ছিন্ন করা যায়নি।',
      );
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  void _showFailure(Object error, String fallback) {
    if (!mounted) return;
    final message = error is AppFailure ? error.message : fallback;
    setState(() => _error = message);
  }

  String _date(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  String _size(int bytes) => bytes < 1024 * 1024
      ? '${(bytes / 1024).ceil()} KB'
      : '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
