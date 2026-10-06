import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../application/family_member_service.dart';

class FamilyMemberListItem {
  const FamilyMemberListItem({
    required this.id,
    required this.name,
    required this.relationship,
    required this.documentCount,
    this.avatar,
    this.archived = false,
  });
  final String id;
  final String name;
  final String relationship;
  final int documentCount;
  final ImageProvider<Object>? avatar;
  final bool archived;
}

/// Presentation-only list; an unlocked feature controller supplies decrypted
/// list items and connects the callbacks to [FamilyMemberService].
class FamilyMemberListScreen extends StatelessWidget {
  const FamilyMemberListScreen({
    required this.members,
    required this.onAdd,
    this.onOpen,
    this.showArchived = false,
    super.key,
  });
  final List<FamilyMemberListItem> members;
  final VoidCallback onAdd;
  final ValueChanged<FamilyMemberListItem>? onOpen;
  final bool showArchived;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Family / পরিবার')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: onAdd,
      icon: const Icon(Icons.person_add_alt_1),
      label: const Text('Add / যোগ করুন'),
    ),
    body: SafeArea(
      child: members.isEmpty
          ? _FamilyEmptyState(onAdd: onAdd)
          : ListView(
              padding: AppSpacing.page,
              children: [
                const _HouseholdCard(),
                const SizedBox(height: 12),
                for (final member in members)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Semantics(
                      button: true,
                      label:
                          '${member.name}, ${member.relationship}, ${member.documentCount} documents',
                      child: Card(
                        child: ListTile(
                          minVerticalPadding: 12,
                          onTap: onOpen == null ? null : () => onOpen!(member),
                          leading: CircleAvatar(
                            foregroundImage: member.avatar,
                            child: member.avatar == null
                                ? Text(_initials(member.name))
                                : null,
                          ),
                          title: Text(member.name),
                          subtitle: Text(
                            '${member.relationship} · ${member.documentCount} document${member.documentCount == 1 ? '' : 's'}',
                          ),
                          trailing: member.archived
                              ? const Chip(label: Text('Archived / সংরক্ষিত'))
                              : const Icon(Icons.chevron_right),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    ),
  );

  static String _initials(String name) => name
      .trim()
      .split(RegExp(r'\s+'))
      .take(2)
      .map((word) => word.isEmpty ? '' : word[0].toUpperCase())
      .join();
}

class _FamilyEmptyState extends StatelessWidget {
  const _FamilyEmptyState({required this.onAdd});
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: AppSpacing.page,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.groups_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Add your family / পরিবার যোগ করুন',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep documents organised by the people they belong to.\nযাদের নথি, তাদের নামে গুছিয়ে রাখুন।',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Add family member / সদস্য যোগ করুন'),
          ),
        ],
      ),
    ),
  );
}

class _HouseholdCard extends StatelessWidget {
  const _HouseholdCard();
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Household, virtual owner for shared documents',
    child: Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: const ListTile(
        minVerticalPadding: 12,
        leading: CircleAvatar(child: Icon(Icons.home_outlined)),
        title: Text('Household / পরিবার'),
        subtitle: Text('For shared family documents / সবার যৌথ নথি'),
      ),
    ),
  );
}

class FamilyMemberFormScreen extends StatefulWidget {
  const FamilyMemberFormScreen({
    required this.onSave,
    this.initialValue,
    this.onArchive,
    this.onPickAvatar,
    super.key,
  });
  final Future<void> Function(FamilyMemberInput input) onSave;
  final FamilyMemberInput? initialValue;
  final Future<void> Function()? onArchive;
  final Future<String?> Function()? onPickAvatar;

  @override
  State<FamilyMemberFormScreen> createState() => _FamilyMemberFormScreenState();
}

class _FamilyMemberFormScreenState extends State<FamilyMemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _nickname;
  late final TextEditingController _relationship;
  late final TextEditingController _notes;
  DateTime? _dateOfBirth;
  String? _bloodGroup;
  String? _avatarFileId;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    _name = TextEditingController(text: initial?.name ?? '');
    _nickname = TextEditingController(text: initial?.nickname ?? '');
    _relationship = TextEditingController(text: initial?.relationship ?? '');
    _notes = TextEditingController(text: initial?.notes ?? '');
    _dateOfBirth = initial?.dateOfBirth;
    _bloodGroup = initial?.bloodGroup;
    _avatarFileId = initial?.avatarFileId;
  }

  @override
  void dispose() {
    _name.dispose();
    _nickname.dispose();
    _relationship.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.onSave(
        FamilyMemberInput(
          name: _name.text,
          nickname: _nickname.text,
          relationship: _relationship.text,
          dateOfBirth: _dateOfBirth,
          bloodGroup: _bloodGroup,
          avatarFileId: _avatarFileId,
          notes: _notes.text,
        ),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not save family member / সদস্য সংরক্ষণ করা যায়নি',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.initialValue == null
            ? 'Add family member / সদস্য যোগ করুন'
            : 'Edit family member / সদস্য সম্পাদনা',
      ),
    ),
    body: SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.page,
          children: [
            Center(
              child: CircleAvatar(
                radius: 36,
                child: Icon(
                  _avatarFileId == null ? Icons.person_outline : Icons.check,
                  size: 34,
                ),
              ),
            ),
            if (widget.onPickAvatar != null)
              TextButton.icon(
                onPressed: () async {
                  final avatar = await widget.onPickAvatar!();
                  if (mounted) {
                    setState(() => _avatarFileId = avatar);
                  }
                },
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Add avatar / ছবি যোগ করুন'),
              ),
            _field(_name, 'Name / নাম', required: true),
            _field(_nickname, 'Nickname / ডাকনাম'),
            _field(_relationship, 'Relationship / সম্পর্ক', required: true),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date of birth / জন্মতারিখ'),
              subtitle: Text(
                _dateOfBirth == null
                    ? 'Optional / ঐচ্ছিক'
                    : MaterialLocalizations.of(context)
                          .formatMediumDate(_dateOfBirth!),
              ),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dateOfBirth ?? DateTime.now(),
                  firstDate: DateTime(DateTime.now().year - 130),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _dateOfBirth = date);
                }
              },
            ),
            DropdownButtonFormField<String>(
              initialValue: _bloodGroup,
              decoration: const InputDecoration(
                labelText: 'Blood group / রক্তের গ্রুপ',
              ),
              items: const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                  .map(
                    (group) =>
                        DropdownMenuItem(value: group, child: Text(group)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _bloodGroup = value),
            ),
            const SizedBox(height: 12),
            _field(_notes, 'Notes / নোট', maxLines: 3),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(
                _saving ? 'Saving… / সংরক্ষণ হচ্ছে…' : 'Save / সংরক্ষণ করুন',
              ),
            ),
            if (widget.onArchive != null)
              OutlinedButton(
                onPressed: _saving
                    ? null
                    : () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text(
                              'Archive member? / সদস্য আর্কাইভ করবেন?',
                            ),
                            content: const Text(
                              'Their documents stay safely in the vault. / তাদের নথি ভল্টে নিরাপদে থাকবে।',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel / বাতিল'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Archive / আর্কাইভ'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await widget.onArchive!();
                          if (mounted) {
                            Navigator.of(this.context).pop();
                          }
                        }
                      },
                child: const Text('Archive member / সদস্য আর্কাইভ করুন'),
              ),
          ],
        ),
      ),
    ),
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (value) => value == null || value.trim().isEmpty
                ? '$label is required'
                : null
          : null,
    ),
  );
}
