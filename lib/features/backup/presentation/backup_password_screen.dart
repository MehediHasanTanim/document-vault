import 'package:flutter/material.dart';

import '../application/backup_models.dart';

/// Password step for the verified backup workflow. The widgets retain text
/// only for this screen; callers receive a short-lived [BackupPassword].
class BackupPasswordScreen extends StatefulWidget {
  const BackupPasswordScreen({required this.onCreate, super.key});
  final Future<void> Function(BackupPassword password) onCreate;

  @override
  State<BackupPasswordScreen> createState() => _BackupPasswordScreenState();
}

class _BackupPasswordScreenState extends State<BackupPasswordScreen> {
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  var _acknowledged = false;
  var _obscure = true;
  var _saving = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strength = BackupPassword.passwordStrength(_password.text);
    return Scaffold(
      appBar: AppBar(title: const Text('Backup password / ব্যাকআপ পাসওয়ার্ড')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Protect this backup with a password. / পাসওয়ার্ড দিয়ে এই ব্যাকআপ সুরক্ষিত করুন।',
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _password,
              obscureText: _obscure,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Backup password / ব্যাকআপ পাসওয়ার্ড',
                suffixIcon: IconButton(
                  tooltip: _obscure
                      ? 'Show password / পাসওয়ার্ড দেখান'
                      : 'Hide password / পাসওয়ার্ড লুকান',
                  icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmation,
              obscureText: _obscure,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                labelText: 'Confirm password / পাসওয়ার্ড নিশ্চিত করুন',
              ),
            ),
            const SizedBox(height: 8),
            Text(_strengthLabel(strength)),
            const SizedBox(height: 16),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _acknowledged,
              onChanged: (value) =>
                  setState(() => _acknowledged = value ?? false),
              title: const Text(
                'I understand that a forgotten backup password may not be recoverable. / আমি বুঝি পাসওয়ার্ড ভুলে গেলে ব্যাকআপ পুনরুদ্ধার করা নাও যেতে পারে।',
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            FilledButton(
              onPressed: _saving ? null : _create,
              child: Text(
                _saving
                    ? 'Creating backup… / ব্যাকআপ তৈরি হচ্ছে…'
                    : 'Create backup / ব্যাকআপ তৈরি করুন',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _strengthLabel(BackupPasswordStrength strength) => switch (strength) {
    BackupPasswordStrength.weak => 'Use 12+ characters; a memorable passphrase is best. / অন্তত ১২টি অক্ষর ব্যবহার করুন।',
    BackupPasswordStrength.good => 'Good password / ভালো পাসওয়ার্ড',
    BackupPasswordStrength.strong => 'Strong password / শক্তিশালী পাসওয়ার্ড',
  };

  Future<void> _create() async {
    try {
      final password = BackupPassword.create(
        password: _password.text,
        confirmation: _confirmation.text,
        acknowledgedRecoveryWarning: _acknowledged,
      );
      setState(() {
        _saving = true;
        _error = null;
      });
      await widget.onCreate(password);
    } on Object catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Check your password and acknowledgement. / পাসওয়ার্ড ও সম্মতি যাচাই করুন।';
        });
      }
    }
  }
}
