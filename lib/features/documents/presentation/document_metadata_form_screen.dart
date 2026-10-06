import 'package:flutter/material.dart';

import '../application/creation/document_creation_models.dart';
import '../application/creation/document_creation_service.dart';
import '../application/creation/document_selection.dart';
import '../application/creation/document_templates.dart';
import '../application/ingestion/import_models.dart';

class DocumentTagChoice {
  const DocumentTagChoice({required this.id, required this.label});
  final String id;
  final String label;
}

class PhysicalLocationChoice {
  const PhysicalLocationChoice({required this.id, required this.label});
  final String id;
  final String label;
}

/// The post-capture, accessible metadata step. It deliberately receives
/// decrypted labels from the unlocked application layer and never displays
/// stored ciphertext or generated secure filenames.
class DocumentMetadataFormScreen extends StatefulWidget {
  const DocumentMetadataFormScreen({
    required this.controller,
    required this.owners,
    required this.categories,
    required this.tags,
    required this.locations,
    required this.pages,
    this.recentCategoryIds = const [],
    this.onCreateTag,
    this.onSaved,
    super.key,
  });

  final DocumentSaveController controller;
  final List<OwnerSearchEntry> owners;
  final List<CategorySearchEntry> categories;
  final List<DocumentTagChoice> tags;
  final List<PhysicalLocationChoice> locations;
  final List<StagedImportFile> pages;
  final List<String> recentCategoryIds;
  final Future<DocumentTagChoice?> Function(String name)? onCreateTag;
  final ValueChanged<DocumentSaveResult>? onSaved;

  @override
  State<DocumentMetadataFormScreen> createState() =>
      _DocumentMetadataFormScreenState();
}

class _DocumentMetadataFormScreenState
    extends State<DocumentMetadataFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _number = TextEditingController();
  final _authority = TextEditingController();
  final _description = TextEditingController();
  final _notes = TextEditingController();
  final _ownerSearch = TextEditingController();
  final _categorySearch = TextEditingController();
  final _tagEntry = TextEditingController();
  final _fields = <String, TextEditingController>{};
  final _templates = const DocumentTemplateCatalog();
  final _tagIds = <String>{};
  final _ownerIds = <String>{};
  late List<DocumentTagChoice> _tags;
  CategorySearchEntry? _category;
  String? _locationId;
  DateTime? _issueDate;
  DateTime? _expiryDate;
  var _household = false;

  @override
  void initState() {
    super.initState();
    _tags = List.of(widget.tags);
    widget.controller.addListener(_onSaveStateChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSaveStateChanged);
    for (final controller in [
      _title,
      _number,
      _authority,
      _description,
      _notes,
      _ownerSearch,
      _categorySearch,
      _tagEntry,
      ..._fields.values,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _resetFields() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    _fields.clear();
  }

  void _onSaveStateChanged() {
    if (!mounted) return;
    final state = widget.controller.state;
    setState(() {});
    if (state.status == DocumentSaveStatus.success && state.result != null) {
      widget.onSaved?.call(state.result!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    return Scaffold(
      appBar: AppBar(title: const Text('Document details / ডকুমেন্টের তথ্য')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _sectionTitle('Owner / মালিক'),
              _ownerSection(),
              const SizedBox(height: 24),
              _sectionTitle('Category / বিভাগ'),
              _categorySection(),
              const SizedBox(height: 24),
              _sectionTitle('Basic information / প্রাথমিক তথ্য'),
              TextFormField(
                controller: _title,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title * / শিরোনাম *',
                  hintText: 'e.g. Amina’s passport / আমিনার পাসপোর্ট',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Title is required / শিরোনাম প্রয়োজন'
                    : null,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _number,
                autocorrect: false,
                enableSuggestions: false,
                decoration: const InputDecoration(
                  labelText: 'Document number / ডকুমেন্ট নম্বর',
                  helperText: 'Private; stored encrypted / ব্যক্তিগত; এনক্রিপ্টেডভাবে সংরক্ষিত',
                ),
              ),
              const SizedBox(height: 12),
              _dateTile(
                label: 'Issue date / ইস্যুর তারিখ',
                value: _issueDate,
                onPick: (date) => setState(() => _issueDate = date),
              ),
              _dateTile(
                label: 'Expiry date / মেয়াদ শেষের তারিখ',
                value: _expiryDate,
                onPick: (date) => setState(() => _expiryDate = date),
              ),
              TextField(
                controller: _authority,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Issuing authority / ইস্যুকারী কর্তৃপক্ষ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _description,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description / বিবরণ',
                ),
              ),
              if (_template != null) ...[
                const SizedBox(height: 24),
                _sectionTitle('Document fields / ডকুমেন্টের তথ্য'),
                ..._template!.fields.map(_dynamicField),
              ],
              const SizedBox(height: 24),
              _sectionTitle('Tags and storage / ট্যাগ ও সংরক্ষণের স্থান'),
              _tagSection(),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _locationId,
                decoration: const InputDecoration(
                  labelText: 'Physical original location / মূল কাগজের অবস্থান',
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Not recorded / দেওয়া হয়নি'),
                  ),
                  ...widget.locations.map(
                    (location) => DropdownMenuItem(
                      value: location.id,
                      child: Text(location.label),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _locationId = value),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notes,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Private notes / ব্যক্তিগত নোট',
                  helperText: 'Do not add PINs, passwords, or CVV codes / পিন, পাসওয়ার্ড বা সিভিভি লিখবেন না',
                ),
              ),
              const SizedBox(height: 24),
              _saveFeedback(state),
              Semantics(
                button: true,
                label: 'Save document securely / নিরাপদে ডকুমেন্ট সংরক্ষণ করুন',
                child: SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: state.status == DocumentSaveStatus.saving
                        ? null
                        : _save,
                    icon: state.status == DocumentSaveStatus.saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.lock_outline),
                    label: Text(
                      state.status == DocumentSaveStatus.saving
                          ? 'Saving securely… / নিরাপদে সংরক্ষণ করা হচ্ছে…'
                          : 'Save document / ডকুমেন্ট সংরক্ষণ করুন',
                    ),
                  ),
                ),
              ),
              if (state.status == DocumentSaveStatus.failure)
                TextButton.icon(
                  onPressed: widget.controller.retry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry save / আবার চেষ্টা করুন'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  DocumentTemplate? get _template =>
      _category == null ? null : _templates.forCategory(_category!.code);

  Widget _sectionTitle(String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(value, style: Theme.of(context).textTheme.titleMedium),
  );

  Widget _ownerSection() {
    final owners = searchOwners(widget.owners, _ownerSearch.text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _household,
          title: const Text('Household / পরিবার'),
          subtitle: const Text(
            'For documents shared by the household / পরিবারের সবার নথি',
          ),
          onChanged: (value) => setState(() {
            _household = value ?? false;
            if (_household) _ownerIds.clear();
          }),
        ),
        TextField(
          controller: _ownerSearch,
          onChanged: (_) => setState(() {}),
          enabled: !_household,
          decoration: const InputDecoration(
            labelText: 'Search family / পরিবারের সদস্য খুঁজুন',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        for (final owner in owners)
          CheckboxListTile(
            enabled: !_household,
            contentPadding: EdgeInsets.zero,
            value: _ownerIds.contains(owner.id),
            title: Text(owner.name),
            subtitle: Text(owner.relationship),
            onChanged: (selected) => setState(() {
              if (selected ?? false) {
                _ownerIds.add(owner.id);
              } else {
                _ownerIds.remove(owner.id);
              }
            }),
          ),
      ],
    );
  }

  Widget _categorySection() {
    final categories = searchCategories(
      widget.categories,
      _categorySearch.text,
    );
    final recent = categories.where(
      (item) => widget.recentCategoryIds.contains(item.id),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _categorySearch,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'Search category / বিভাগ খুঁজুন',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        if (recent.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Text('Recent / সাম্প্রতিক'),
          Wrap(spacing: 8, children: recent.map(_categoryChip).toList()),
        ],
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map(_categoryChip).toList(),
        ),
      ],
    );
  }

  Widget _categoryChip(CategorySearchEntry category) => ChoiceChip(
    label: Text(category.label),
    selected: _category?.id == category.id,
    onSelected: (_) => setState(() {
      _category = category;
      _resetFields();
    }),
  );

  Widget _dynamicField(DocumentFieldTemplate field) {
    final controller = _fields.putIfAbsent(
      field.key,
      TextEditingController.new,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: field.type == DocumentFieldType.date
            ? TextInputType.datetime
            : field.type == DocumentFieldType.number
            ? TextInputType.text
            : TextInputType.text,
        obscureText: field.sensitive,
        autocorrect: !field.sensitive,
        enableSuggestions: !field.sensitive,
        decoration: InputDecoration(
          labelText: '${field.label}${field.required ? ' *' : ''}',
          helperText: field.type == DocumentFieldType.date
              ? 'YYYY-MM-DD'
              : null,
        ),
        validator: (value) =>
            field.required && (value == null || value.trim().isEmpty)
            ? 'This field is required / এই তথ্য প্রয়োজন'
            : null,
      ),
    );
  }

  Widget _tagSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _tags
            .map(
              (tag) => FilterChip(
                label: Text(tag.label),
                selected: _tagIds.contains(tag.id),
                onSelected: (selected) => setState(() {
                  if (selected) {
                    _tagIds.add(tag.id);
                  } else {
                    _tagIds.remove(tag.id);
                  }
                }),
              ),
            )
            .toList(),
      ),
      if (widget.onCreateTag != null) ...[
        const SizedBox(height: 10),
        TextField(
          controller: _tagEntry,
          decoration: InputDecoration(
            labelText: 'New tag / নতুন ট্যাগ',
            suffixIcon: IconButton(
              tooltip: 'Create tag / ট্যাগ তৈরি করুন',
              icon: const Icon(Icons.add),
              onPressed: _createTag,
            ),
          ),
          onSubmitted: (_) => _createTag(),
        ),
      ],
    ],
  );

  Widget _dateTile({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onPick,
  }) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: Text(value == null ? 'Not set / দেওয়া হয়নি' : _dateLabel(value)),
    trailing: IconButton(
      tooltip: 'Choose date / তারিখ বেছে নিন',
      icon: const Icon(Icons.calendar_month_outlined),
      onPressed: () async {
        final date = await showDatePicker(
          context: context,
          firstDate: DateTime(1900),
          lastDate: DateTime(2200),
          initialDate: value ?? DateTime.now(),
        );
        if (date != null) onPick(date);
      },
    ),
  );

  Widget _saveFeedback(DocumentSaveState state) {
    if (state.status == DocumentSaveStatus.failure) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          'Could not save. Your staged files are protected; try again. / সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    }
    if (state.status == DocumentSaveStatus.success) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Text('Saved securely / নিরাপদে সংরক্ষিত'),
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _createTag() async {
    final name = _tagEntry.text.trim();
    if (name.isEmpty || widget.onCreateTag == null) return;
    final tag = await widget.onCreateTag!(name);
    if (!mounted || tag == null) return;
    setState(() {
      if (_tags.every((existing) => existing.id != tag.id)) _tags.add(tag);
      _tagIds.add(tag.id);
      _tagEntry.clear();
    });
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_category == null) {
      _message('Choose a category / একটি বিভাগ নির্বাচন করুন');
      return;
    }
    if (!_household && _ownerIds.isEmpty) {
      _message('Choose an owner or Household / মালিক বা পরিবার নির্বাচন করুন');
      return;
    }
    if (_issueDate != null &&
        _expiryDate != null &&
        _expiryDate!.isBefore(_issueDate!)) {
      _message(
        'Expiry date must follow issue date / মেয়াদ শেষের তারিখ ইস্যুর তারিখের পরে হতে হবে',
      );
      return;
    }
    final template = _template;
    final fields = template == null
        ? const <DynamicFieldInput>[]
        : template.fields
              .map(
                (field) => DynamicFieldInput(
                  key: field.key,
                  label: field.label,
                  value: _fields[field.key]?.text ?? '',
                  type: field.type,
                ),
              )
              .toList(growable: false);
    widget.controller.save(
      DocumentDraft(
        title: _title.text,
        categoryId: _category!.id,
        categoryCode: _category!.code,
        owners: _household
            ? const DocumentOwnerSelection.household()
            : DocumentOwnerSelection.members(_ownerIds),
        documentNumber: _number.text,
        issueDate: _issueDate,
        expiryDate: _expiryDate,
        issuingAuthority: _authority.text,
        description: _description.text,
        notes: _notes.text,
        physicalLocationId: _locationId,
        tagIds: _tagIds,
        fields: fields,
        pages: widget.pages,
      ),
    );
  }

  void _message(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  String _dateLabel(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
