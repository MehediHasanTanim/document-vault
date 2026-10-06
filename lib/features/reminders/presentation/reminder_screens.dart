import 'package:flutter/material.dart';

import '../application/reminder_models.dart';
import '../application/reminder_scheduler.dart';

class ReminderSetupSheet extends StatefulWidget {
  const ReminderSetupSheet({
    required this.documentTitle,
    required this.expiryDate,
    required this.onSave,
    this.initial = const ReminderSetup(rules: [ReminderRule.daysBefore(30)]),
    super.key,
  });
  final String documentTitle;
  final DateTime expiryDate;
  final ReminderSetup initial;
  final ValueChanged<ReminderSetup> onSave;

  @override
  State<ReminderSetupSheet> createState() => _ReminderSetupSheetState();
}

class _ReminderSetupSheetState extends State<ReminderSetupSheet> {
  late final _selected = <int>{
    ...widget.initial.rules
        .where((rule) => rule.kind == ReminderRuleKind.daysBefore)
        .map((rule) => rule.days!),
  };
  DateTime? _custom;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: ListView(
        shrinkWrap: true,
        children: [
          Text(
            'Remind me before expiry / মেয়াদের আগে মনে করান',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [90, 60, 30, 14, 7, 3, 1]
                .map(
                  (days) => FilterChip(
                    label: Text('$days days / $days দিন'),
                    selected: _selected.contains(days),
                    onSelected: (selected) => setState(
                      () => selected
                          ? _selected.add(days)
                          : _selected.remove(days),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('On expiry date / মেয়াদ শেষের দিনে'),
            trailing: Checkbox(
              value: _selected.contains(0),
              onChanged: (selected) => setState(
                () =>
                    selected ?? false ? _selected.add(0) : _selected.remove(0),
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Custom date / নিজের তারিখ'),
            subtitle: Text(
              _custom == null ? 'Not set / দেওয়া হয়নি' : _date(_custom!),
            ),
            trailing: const Icon(Icons.calendar_month_outlined),
            onTap: _pickCustom,
          ),
          const Divider(height: 28),
          Text(
            'Preview / প্রিভিউ',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text('${widget.documentTitle} renewal reminder'),
          Text(_previewBody(), style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          const Text(
            'Document numbers are hidden from notifications by default. / ডকুমেন্ট নম্বর নোটিফিকেশনে দেখানো হয় না।',
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _selected.isEmpty && _custom == null ? null : _save,
            child: const Text('Save reminders / রিমাইন্ডার সংরক্ষণ করুন'),
          ),
        ],
      ),
    ),
  );

  Future<void> _pickCustom() async {
    final value = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: widget.expiryDate,
      initialDate: _custom ?? widget.expiryDate,
    );
    if (value != null) setState(() => _custom = value);
  }

  void _save() {
    final rules = [
      ..._selected.map(
        (days) => days == 0
            ? const ReminderRule.onDate()
            : ReminderRule.daysBefore(days),
      ),
      if (_custom != null) ReminderRule.custom(_custom),
    ];
    widget.onSave(ReminderSetup(rules: rules));
    Navigator.pop(context);
  }

  String _previewBody() {
    if (_selected.isEmpty) return 'Custom reminder';
    final days = _selected.reduce((a, b) => a < b ? a : b);
    return days == 0 ? 'Expires on this date' : 'Expires in $days days';
  }

  String _date(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}

class NotificationPermissionCard extends StatelessWidget {
  const NotificationPermissionCard({
    required this.status,
    required this.onRequest,
    required this.onOpenSettings,
    super.key,
  });
  final LocalNotificationPermission status;
  final VoidCallback onRequest;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    if (status == LocalNotificationPermission.granted) {
      return const SizedBox.shrink();
    }
    final permanentlyDenied =
        status == LocalNotificationPermission.permanentlyDenied;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Never miss an expiry date / মেয়াদ শেষের তারিখ মিস করবেন না',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              permanentlyDenied
                  ? 'Notifications are disabled in device settings. / ডিভাইস সেটিংসে নোটিফিকেশন বন্ধ আছে।'
                  : 'Enable private local reminders. Document numbers will stay hidden. / ব্যক্তিগত লোকাল রিমাইন্ডার চালু করুন।',
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: permanentlyDenied ? onOpenSettings : onRequest,
              child: Text(
                permanentlyDenied
                    ? 'Open Settings / সেটিংস খুলুন'
                    : 'Enable Reminders / রিমাইন্ডার চালু করুন',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReminderDashboardScreen extends StatelessWidget {
  const ReminderDashboardScreen({
    required this.scheduler,
    required this.documentLabels,
    this.onOpenReminder,
    super.key,
  });
  final ReminderScheduler scheduler;
  final Map<String, String> documentLabels;
  final ValueChanged<String>? onOpenReminder;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Reminders / রিমাইন্ডার')),
    body: FutureBuilder<List<ReminderDashboardItem>>(
      future: scheduler.dashboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final values = snapshot.data ?? const [];
        if (values.isEmpty) {
          return const Center(
            child: Text('No upcoming reminders / কোনো আসন্ন রিমাইন্ডার নেই'),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            for (final section in ReminderDashboardSection.values) ...[
              if (values.any((value) => value.section == section))
                _section(
                  context,
                  section,
                  values.where((value) => value.section == section),
                ),
            ],
          ],
        );
      },
    ),
  );

  Widget _section(
    BuildContext context,
    ReminderDashboardSection section,
    Iterable<ReminderDashboardItem> values,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(_label(section), style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      ...values.map(
        (value) => Card(
          child: ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(
              documentLabels[value.documentId] ?? 'Document / ডকুমেন্ট',
            ),
            subtitle: Text(_date(value.scheduledAt)),
            trailing: const Icon(Icons.chevron_right),
            onTap: onOpenReminder == null
                ? null
                : () => onOpenReminder!(value.reminderId),
          ),
        ),
      ),
      const SizedBox(height: 16),
    ],
  );
  String _label(ReminderDashboardSection section) => switch (section) {
    ReminderDashboardSection.overdue => 'Overdue / মেয়াদ পেরিয়েছে',
    ReminderDashboardSection.next7Days => 'Next 7 days / আগামী ৭ দিন',
    ReminderDashboardSection.next30Days => 'Next 30 days / আগামী ৩০ দিন',
    ReminderDashboardSection.next90Days => 'Next 90 days / আগামী ৯০ দিন',
    ReminderDashboardSection.later => 'Later / পরে',
  };
  String _date(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
