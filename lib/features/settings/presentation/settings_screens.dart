import 'package:flutter/material.dart';

import '../application/privacy_permissions_service.dart';
import '../application/settings_models.dart';
import '../application/storage_management_service.dart';

class SettingsHomeScreen extends StatelessWidget {
  const SettingsHomeScreen({
    required this.onGeneral,
    required this.onSecurity,
    required this.onNotifications,
    required this.onStorage,
    required this.onPrivacyPermissions,
    required this.onAbout,
    super.key,
  });
  final VoidCallback onGeneral;
  final VoidCallback onSecurity;
  final VoidCallback onNotifications;
  final VoidCallback onStorage;
  final VoidCallback onPrivacyPermissions;
  final VoidCallback onAbout;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings / সেটিংস')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Section(
            title: 'General / সাধারণ',
            children: [
              _item(
                Icons.tune,
                'General',
                'Language, appearance and defaults',
                onGeneral,
              ),
            ],
          ),
          _Section(
            title: 'Security / নিরাপত্তা',
            children: [
              _item(
                Icons.shield_outlined,
                'Security',
                'PIN, biometrics, auto-lock and privacy',
                onSecurity,
              ),
            ],
          ),
          _Section(
            title: 'Reminders / রিমাইন্ডার',
            children: [
              _item(
                Icons.notifications_outlined,
                'Notifications',
                'Expiry and backup reminders',
                onNotifications,
              ),
            ],
          ),
          _Section(
            title: 'Data / ডেটা',
            children: [
              _item(
                Icons.storage_outlined,
                'Storage',
                'Usage, safe cleanup and integrity check',
                onStorage,
              ),
            ],
          ),
          _Section(
            title: 'Support / সহায়তা',
            children: [
              _item(
                Icons.privacy_tip_outlined,
                'Privacy & permissions',
                'Local storage and device access',
                onPrivacyPermissions,
              ),
              _item(
                Icons.help_outline,
                'Help & about',
                'Guides, security and legal information',
                onAbout,
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _item(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback tap,
  ) => ListTile(
    minVerticalPadding: 12,
    leading: Icon(icon),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.chevron_right),
    onTap: tap,
  );
}

class GeneralSettingsScreen extends StatefulWidget {
  const GeneralSettingsScreen({
    required this.initial,
    required this.onSave,
    this.profiles = const [
      DefaultProfileOption(id: 'household', label: 'Household / পরিবার'),
    ],
    super.key,
  });
  final GeneralSettings initial;
  final Future<void> Function(GeneralSettings value) onSave;
  final List<DefaultProfileOption> profiles;
  @override
  State<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends State<GeneralSettingsScreen> {
  late GeneralSettings _value = widget.initial;
  var _saving = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('General settings / সাধারণ সেটিংস')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _value.languageCode,
            decoration: const InputDecoration(labelText: 'Language / ভাষা'),
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'bn', child: Text('বাংলা')),
            ],
            onChanged: (value) => setState(
              () => _value = _copyGeneral(_value, languageCode: value),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _value.theme,
            decoration: const InputDecoration(labelText: 'Theme / থিম'),
            items: const [
              DropdownMenuItem(
                value: 'system',
                child: Text('System / সিস্টেম'),
              ),
              DropdownMenuItem(value: 'light', child: Text('Light / হালকা')),
              DropdownMenuItem(value: 'dark', child: Text('Dark / গাঢ়')),
            ],
            onChanged: (value) =>
                setState(() => _value = _copyGeneral(_value, theme: value)),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<DateFormatPreference>(
            initialValue: _value.dateFormat,
            decoration: const InputDecoration(
              labelText: 'Date format / তারিখের ধরন',
            ),
            items: DateFormatPreference.values
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(_dateFormatLabel(value)),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) => setState(
              () => _value = _copyGeneral(_value, dateFormat: value),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<DocumentViewPreference>(
            initialValue: _value.defaultView,
            decoration: const InputDecoration(
              labelText: 'Default view / ডিফল্ট ভিউ',
            ),
            items: DocumentViewPreference.values
                .map(
                  (value) =>
                      DropdownMenuItem(value: value, child: Text(value.name)),
                )
                .toList(growable: false),
            onChanged: (value) => setState(
              () => _value = _copyGeneral(_value, defaultView: value),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String?>(
            initialValue: _value.defaultProfileId,
            decoration: const InputDecoration(
              labelText: 'Default profile / ডিফল্ট প্রোফাইল',
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Ask each time / প্রতিবার জিজ্ঞাসা করুন'),
              ),
              ..._profiles.map(
                (profile) => DropdownMenuItem<String?>(
                  value: profile.id,
                  child: Text(profile.label),
                ),
              ),
            ],
            onChanged: (value) => setState(
              () => _value = GeneralSettings(
                languageCode: _value.languageCode,
                theme: _value.theme,
                dateFormat: _value.dateFormat,
                defaultView: _value.defaultView,
                defaultProfileId: value,
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(
              _saving ? 'Saving… / সংরক্ষণ হচ্ছে…' : 'Save / সংরক্ষণ করুন',
            ),
          ),
        ],
      ),
    ),
  );
  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.onSave(_value);
      if (mounted) Navigator.pop(context, _value);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<DefaultProfileOption> get _profiles {
    final current = _value.defaultProfileId;
    if (current == null ||
        widget.profiles.any((profile) => profile.id == current)) {
      return widget.profiles;
    }
    return [
      ...widget.profiles,
      DefaultProfileOption(
        id: current,
        label: 'Saved profile / সংরক্ষিত প্রোফাইল',
      ),
    ];
  }
}

class DefaultProfileOption {
  const DefaultProfileOption({required this.id, required this.label});
  final String id;
  final String label;
}

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({
    required this.initial,
    required this.onSave,
    required this.onChangePin,
    super.key,
  });
  final SecuritySettings initial;
  final Future<void> Function(SecuritySettings value) onSave;
  final VoidCallback onChangePin;
  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  late SecuritySettings _value = widget.initial;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Security / নিরাপত্তা')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text('Change PIN / PIN পরিবর্তন করুন'),
            trailing: const Icon(Icons.chevron_right),
            onTap: widget.onChangePin,
          ),
          SwitchListTile(
            title: const Text('Use biometrics / বায়োমেট্রিক ব্যবহার করুন'),
            subtitle: const Text('Ask after a device biometric is enrolled.'),
            value: _value.biometricsEnabled,
            onChanged: (value) => setState(
              () => _value = _copySecurity(_value, biometricsEnabled: value),
            ),
          ),
          DropdownButtonFormField<AutoLockPreference>(
            initialValue: _value.autoLock,
            decoration: const InputDecoration(
              labelText: 'Auto-lock / স্বয়ংক্রিয় লক',
            ),
            items: AutoLockPreference.values
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(_autoLockLabel(value)),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) =>
                setState(() => _value = _copySecurity(_value, autoLock: value)),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Hide in app switcher / অ্যাপ সুইচারে লুকান'),
            value: _value.hideInAppSwitcher,
            onChanged: (value) => setState(
              () => _value = _copySecurity(_value, hideInAppSwitcher: value),
            ),
          ),
          SwitchListTile(
            title: const Text('Screenshot protection / স্ক্রিনশট সুরক্ষা'),
            subtitle: const Text('Applied where your device supports it.'),
            value: _value.screenshotProtection,
            onChanged: (value) => setState(
              () => _value = _copySecurity(_value, screenshotProtection: value),
            ),
          ),
          SwitchListTile(
            title: const Text(
              'Hide notification details / নোটিফিকেশন তথ্য লুকান',
            ),
            value: _value.hideSensitiveNotificationPreview,
            onChanged: (value) => setState(
              () => _value = _copySecurity(
                _value,
                hideSensitiveNotificationPreview: value,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => widget.onSave(_value),
            child: const Text('Save / সংরক্ষণ করুন'),
          ),
        ],
      ),
    ),
  );
}

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({required this.onChangePin, super.key});
  final Future<void> Function(String current, String next, String confirm)
  onChangePin;
  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;
  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Change PIN / PIN পরিবর্তন করুন')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _pinField(_current, 'Current PIN / বর্তমান PIN'),
          const SizedBox(height: 12),
          _pinField(_next, 'New PIN / নতুন PIN'),
          const SizedBox(height: 12),
          _pinField(_confirm, 'Confirm new PIN / নতুন PIN নিশ্চিত করুন'),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _change,
            child: const Text('Change PIN / PIN পরিবর্তন করুন'),
          ),
        ],
      ),
    ),
  );
  Widget _pinField(TextEditingController controller, String label) => TextField(
    controller: controller,
    obscureText: true,
    keyboardType: TextInputType.number,
    maxLength: 6,
    decoration: InputDecoration(labelText: label),
  );
  Future<void> _change() async {
    try {
      await widget.onChangePin(_current.text, _next.text, _confirm.text);
      if (mounted) Navigator.pop(context);
    } on Object {
      if (mounted) {
        setState(
          () => _error = 'Could not change PIN. Check your current PIN and try again. / PIN পরিবর্তন করা যায়নি।',
        );
      }
    }
  }
}

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({
    required this.initial,
    required this.onSave,
    required this.permissionLabel,
    required this.onOpenSettings,
    super.key,
  });
  final NotificationSettings initial;
  final Future<void> Function(NotificationSettings value) onSave;
  final String permissionLabel;
  final VoidCallback onOpenSettings;
  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late NotificationSettings _value = widget.initial;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Notifications / নোটিফিকেশন')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            title: const Text('Expiry reminders / মেয়াদ শেষের রিমাইন্ডার'),
            value: _value.expiryRemindersEnabled,
            onChanged: (value) => setState(
              () => _value = NotificationSettings(
                expiryRemindersEnabled: value,
                defaultOffsets: _value.defaultOffsets,
                backupReminder: _value.backupReminder,
              ),
            ),
          ),
          ListTile(
            title: const Text('Device permission / ডিভাইস অনুমতি'),
            subtitle: Text(widget.permissionLabel),
            trailing: OutlinedButton(
              onPressed: widget.onOpenSettings,
              child: const Text('Open settings'),
            ),
          ),
          DropdownButtonFormField<BackupReminderPreference>(
            initialValue: _value.backupReminder,
            decoration: const InputDecoration(
              labelText: 'Backup reminder / ব্যাকআপ রিমাইন্ডার',
            ),
            items: BackupReminderPreference.values
                .map(
                  (value) =>
                      DropdownMenuItem(value: value, child: Text(value.name)),
                )
                .toList(growable: false),
            onChanged: (value) => setState(
              () => _value = NotificationSettings(
                expiryRemindersEnabled: _value.expiryRemindersEnabled,
                defaultOffsets: _value.defaultOffsets,
                backupReminder: value ?? _value.backupReminder,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Default expiry reminders: ${_value.defaultOffsets.join(', ')} days / ডিফল্ট মেয়াদ রিমাইন্ডার',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [90, 60, 30, 14, 7, 3, 1, 0]
                .map(
                  (days) => FilterChip(
                    label: Text(days == 0 ? 'On date' : '$days days'),
                    selected: _value.defaultOffsets.contains(days),
                    onSelected: (selected) {
                      final offsets = {..._value.defaultOffsets};
                      selected ? offsets.add(days) : offsets.remove(days);
                      final ordered = offsets.toList()
                        ..sort((left, right) => right.compareTo(left));
                      setState(
                        () => _value = NotificationSettings(
                          expiryRemindersEnabled: _value.expiryRemindersEnabled,
                          defaultOffsets: ordered,
                          backupReminder: _value.backupReminder,
                        ),
                      );
                    },
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => widget.onSave(_value),
            child: const Text('Save / সংরক্ষণ করুন'),
          ),
        ],
      ),
    ),
  );
}

class StorageManagementScreen extends StatefulWidget {
  const StorageManagementScreen({
    required this.load,
    required this.onClearTemporary,
    required this.onEmptyTrash,
    required this.onIntegrityCheck,
    this.onFindLargeFiles,
    super.key,
  });
  final Future<VaultStorageReport> Function() load;
  final Future<void> Function() onClearTemporary;
  final Future<int> Function() onEmptyTrash;
  final Future<IntegrityCheckReport> Function() onIntegrityCheck;
  final Future<List<LargeStoredFile>> Function()? onFindLargeFiles;
  @override
  State<StorageManagementScreen> createState() =>
      _StorageManagementScreenState();
}

class _StorageManagementScreenState extends State<StorageManagementScreen> {
  late Future<VaultStorageReport> _report = widget.load();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Storage / স্টোরেজ')),
    body: SafeArea(
      child: FutureBuilder<VaultStorageReport>(
        future: _report,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final value = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _storageCard('Total vault size', value.totalVaultBytes),
              _storageCard('Documents', value.documentCount),
              _storageCard('Pages / files', value.pageCount),
              _storageCard('Attachments', value.attachmentBytes),
              _storageCard(
                'Thumbnails & cache',
                value.thumbnailBytes + value.cacheBytes,
              ),
              _storageCard('Trash', value.trashBytes),
              _storageCard('Estimated backup', value.estimatedBackupBytes),
              const SizedBox(height: 12),
              const Text(
                'Original documents will never be removed automatically. / আসল নথি কখনও স্বয়ংক্রিয়ভাবে মুছে ফেলা হবে না।',
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  await widget.onClearTemporary();
                  setState(() => _report = widget.load());
                },
                child: const Text(
                  'Clear safe temporary files / নিরাপদ অস্থায়ী ফাইল মুছুন',
                ),
              ),
              OutlinedButton(
                onPressed: _emptyTrash,
                child: const Text('Empty Trash / ট্র্যাশ খালি করুন'),
              ),
              OutlinedButton(
                onPressed: _integrity,
                child: const Text('Run integrity check / অখণ্ডতা পরীক্ষা করুন'),
              ),
              if (widget.onFindLargeFiles != null)
                OutlinedButton(
                  onPressed: _largeFiles,
                  child: const Text('Review large documents / বড় নথি দেখুন'),
                ),
            ],
          );
        },
      ),
    ),
  );
  Widget _storageCard(String label, int value) => Card(
    child: ListTile(title: Text(label), trailing: Text(_size(value))),
  );
  String _size(int bytes) => bytes < 1024 * 1024
      ? '${(bytes / 1024).toStringAsFixed(1)} KB'
      : '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  Future<void> _emptyTrash() async {
    final allowed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Empty Trash? / ট্র্যাশ খালি করবেন?'),
        content: const Text(
          'This permanently deletes trashed documents. / ট্র্যাশে থাকা নথি স্থায়ীভাবে মুছে যাবে।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Empty Trash'),
          ),
        ],
      ),
    );
    if (allowed == true) {
      await widget.onEmptyTrash();
      if (mounted) {
        setState(() => _report = widget.load());
      }
    }
  }

  Future<void> _integrity() async {
    final result = await widget.onIntegrityCheck();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.isHealthy
                ? 'Vault is healthy / ভল্ট ঠিক আছে'
                : 'Issues found in ${result.invalidFileIds.length} file(s).',
          ),
        ),
      );
    }
  }

  Future<void> _largeFiles() async {
    final files = await widget.onFindLargeFiles!();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          children: [
            const ListTile(
              title: Text('Large documents / বড় নথি'),
              subtitle: Text('Names stay hidden here for privacy.'),
            ),
            ...files.map(
              (file) => ListTile(
                leading: const Icon(Icons.insert_drive_file_outlined),
                title: Text(file.mimeType),
                subtitle: Text('Stored file'),
                trailing: Text(_size(file.sizeBytes)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrivacyPermissionsScreen extends StatelessWidget {
  const PrivacyPermissionsScreen({
    required this.snapshot,
    required this.onOpenSettings,
    super.key,
  });
  final PrivacyPermissionSnapshot snapshot;
  final VoidCallback onOpenSettings;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Privacy & permissions / গোপনীয়তা ও অনুমতি'),
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Your document vault stays locally on this device. / আপনার ডকুমেন্ট ভল্ট এই ডিভাইসেই থাকে।',
          ),
          const SizedBox(height: 16),
          _status('Camera / ক্যামেরা', snapshot.camera),
          _status('Photos & files / ছবি ও ফাইল', snapshot.photosAndFiles),
          _status('Notifications / নোটিফিকেশন', snapshot.notifications),
          _status('Biometrics / বায়োমেট্রিক', snapshot.biometrics),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onOpenSettings,
            child: const Text('Open device settings / ডিভাইস সেটিংস খুলুন'),
          ),
        ],
      ),
    ),
  );
  Widget _status(String title, DeviceAccessStatus status) => ListTile(
    leading: Icon(
      status == DeviceAccessStatus.granted
          ? Icons.check_circle_outline
          : Icons.info_outline,
    ),
    title: Text(title),
    trailing: Text(status.name),
  );
}

class AboutHelpScreen extends StatelessWidget {
  const AboutHelpScreen({required this.version, super.key});
  final String version;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Help & about / সহায়তা ও পরিচিতি')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Document Vault BD keeps encrypted documents locally on your device. No account or server is required.\n\nDocument Vault BD আপনার ডিভাইসেই এনক্রিপ্ট করা নথি রাখে। কোনো অ্যাকাউন্ট বা সার্ভার প্রয়োজন নেই।',
          ),
          const SizedBox(height: 16),
          const ListTile(
            title: Text('Security information / নিরাপত্তা তথ্য'),
            subtitle: Text('Use a strong PIN and keep backup passwords safe.'),
          ),
          const ListTile(
            title: Text('Backup warning / ব্যাকআপ সতর্কতা'),
            subtitle: Text('A forgotten backup password cannot be recovered.'),
          ),
          const ListTile(title: Text('Privacy policy / গোপনীয়তা নীতি')),
          const ListTile(
            title: Text('Open-source licences / ওপেন-সোর্স লাইসেন্স'),
          ),
          const ListTile(title: Text('Legal disclaimer / আইনি ঘোষণা')),
          Text('Version: $version'),
        ],
      ),
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
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

GeneralSettings _copyGeneral(
  GeneralSettings value, {
  String? languageCode,
  String? theme,
  DateFormatPreference? dateFormat,
  DocumentViewPreference? defaultView,
}) => GeneralSettings(
  languageCode: languageCode ?? value.languageCode,
  theme: theme ?? value.theme,
  dateFormat: dateFormat ?? value.dateFormat,
  defaultView: defaultView ?? value.defaultView,
  defaultProfileId: value.defaultProfileId,
);
SecuritySettings _copySecurity(
  SecuritySettings value, {
  bool? biometricsEnabled,
  AutoLockPreference? autoLock,
  bool? hideInAppSwitcher,
  bool? screenshotProtection,
  bool? hideSensitiveNotificationPreview,
}) => SecuritySettings(
  biometricsEnabled: biometricsEnabled ?? value.biometricsEnabled,
  autoLock: autoLock ?? value.autoLock,
  hideInAppSwitcher: hideInAppSwitcher ?? value.hideInAppSwitcher,
  screenshotProtection: screenshotProtection ?? value.screenshotProtection,
  hideSensitiveNotificationPreview:
      hideSensitiveNotificationPreview ??
      value.hideSensitiveNotificationPreview,
);
String _dateFormatLabel(DateFormatPreference value) => switch (value) {
  DateFormatPreference.dayMonthYear => 'DD/MM/YYYY',
  DateFormatPreference.monthDayYear => 'MM/DD/YYYY',
  DateFormatPreference.yearMonthDay => 'YYYY-MM-DD',
};
String _autoLockLabel(AutoLockPreference value) => switch (value) {
  AutoLockPreference.immediate => 'Immediately / এখনই',
  AutoLockPreference.seconds30 => '30 seconds / ৩০ সেকেন্ড',
  AutoLockPreference.minute1 => '1 minute / ১ মিনিট',
  AutoLockPreference.minutes5 => '5 minutes / ৫ মিনিট',
};
