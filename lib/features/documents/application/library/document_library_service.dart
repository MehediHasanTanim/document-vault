import 'dart:collection';

import '../../../../core/crypto/vault_data_protector.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/files/file_reference.dart';
import 'document_library_models.dart';
import 'document_library_repository.dart';

/// Builds short-lived, decrypted library view models after vault unlock. No
/// title, number, tag, or owner text is written back to a search index/cache.
class DocumentLibraryService {
  DocumentLibraryService(
    this._repository,
    this._protector, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final DocumentLibraryRepository _repository;
  final VaultDataProtector _protector;
  final DateTime Function() _clock;

  Future<List<DocumentCardData>> browse(DocumentLibraryQuery query) async {
    final snapshot = await _repository.loadSnapshot();
    final context = await _buildContext(snapshot);
    final cards = <DocumentCardData>[];
    for (final document in snapshot.documents) {
      if (!_matches(document.id, document, context, query)) continue;
      final card = await _card(document, context);
      final searchable = [
        card.title,
        card.category,
        card.ownerLabel,
        ...(context.tagNamesByDocument[document.id] ?? const []),
      ].join(' ').toLowerCase();
      if (query.filter.searchTerm.trim().isNotEmpty &&
          !searchable.contains(query.filter.searchTerm.trim().toLowerCase())) {
        continue;
      }
      cards.add(card);
    }
    _sort(cards, query.sort);
    return cards;
  }

  Future<DocumentDetailsData?> details(String documentId) async {
    final snapshot = await _repository.loadSnapshot();
    final document = snapshot.documents
        .where((candidate) => candidate.id == documentId)
        .firstOrNull;
    if (document == null) return null;
    final context = await _buildContext(snapshot);
    final card = await _card(document, context);
    final fields = <DocumentFieldDetail>[];
    for (final field in context.fieldsByDocument[document.id] ?? const []) {
      fields.add(
        DocumentFieldDetail(
          key: field.fieldKey,
          label: field.labelEncrypted == null
              ? null
              : await _decrypt(
                  field.labelEncrypted!,
                  'document:${document.id}:field-label:${field.fieldKey}',
                ),
          value: await _decrypt(
            field.valueEncrypted,
            'document:${document.id}:field:${field.fieldKey}',
          ),
          valueType: field.valueType,
        ),
      );
    }
    final reminders =
        (context.remindersByDocument[document.id] ?? const [])
            .where((reminder) => reminder.status == 'scheduled')
            .toList()
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final files = (context.filesByDocument[document.id] ?? const [])
        .map(_reference)
        .toList(growable: false);
    final location = document.physicalLocationId == null
        ? null
        : context.locations[document.physicalLocationId];
    return DocumentDetailsData(
      card: card,
      documentNumber: await _decryptOptional(
        document.documentNumberEncrypted,
        'document:${document.id}:number',
      ),
      issueDate: document.issueDate,
      expiryDate: document.expiryDate,
      issuingAuthority: await _decryptOptional(
        document.issuingAuthorityEncrypted,
        'document:${document.id}:authority',
      ),
      description: await _decryptOptional(
        document.descriptionEncrypted,
        'document:${document.id}:description',
      ),
      notes: await _decryptOptional(
        document.notesEncrypted,
        'document:${document.id}:notes',
      ),
      tags: context.tagNamesByDocument[document.id] ?? const [],
      physicalLocation: location == null
          ? null
          : await _decrypt(
              location.nameEncrypted,
              'location:${location.id}:name',
            ),
      fields: fields,
      reminder: ReminderSummary(
        enabled: reminders.isNotEmpty,
        nextScheduledAt: reminders.isEmpty ? null : reminders.first.scheduledAt,
        count: reminders.length,
      ),
      files: files,
      pageCount: (context.pagesByDocument[document.id] ?? const []).length,
    );
  }

  Future<_LibraryContext> _buildContext(
    DocumentLibrarySnapshot snapshot,
  ) async {
    final members = {for (final member in snapshot.members) member.id: member};
    final categories = {
      for (final category in snapshot.categories) category.id: category,
    };
    final tags = {for (final tag in snapshot.tags) tag.id: tag};
    final locations = {
      for (final location in snapshot.locations) location.id: location,
    };
    final ownerIdsByDocument = _group(
      snapshot.owners,
      (value) => value.documentId,
    );
    final tagIdsByDocument = _group(
      snapshot.tagLinks,
      (value) => value.documentId,
    );
    final filesByDocument = _group(snapshot.files, (value) => value.documentId);
    final pagesByDocument = _group(snapshot.pages, (value) => value.documentId);
    final fieldsByDocument = _group(
      snapshot.fields,
      (value) => value.documentId,
    );
    final remindersByDocument = _group(
      snapshot.reminders,
      (value) => value.documentId,
    );

    final memberNames = <String, String>{};
    for (final member in snapshot.members) {
      memberNames[member.id] = await _decrypt(
        member.displayNameEncrypted,
        'family:${member.id}:name',
      );
    }
    final categoryNames = <String, String>{};
    for (final category in snapshot.categories) {
      categoryNames[category.id] = category.customNameEncrypted == null
          ? _categoryLabel(category.nameKey, category.code)
          : await _decrypt(
              category.customNameEncrypted!,
              'category:${category.id}:name',
            );
    }
    final tagNames = <String, String>{};
    for (final tag in snapshot.tags) {
      tagNames[tag.id] = await _decrypt(
        tag.nameEncrypted,
        'tag:${tag.id}:name',
      );
    }
    final tagNamesByDocument = <String, List<String>>{};
    for (final entry in tagIdsByDocument.entries) {
      tagNamesByDocument[entry.key] = entry.value
          .map((link) => tagNames[link.tagId])
          .whereType<String>()
          .toList(growable: false);
    }
    return _LibraryContext(
      members: members,
      categories: categories,
      tags: tags,
      locations: locations,
      ownerIdsByDocument: ownerIdsByDocument,
      tagIdsByDocument: tagIdsByDocument,
      filesByDocument: filesByDocument,
      pagesByDocument: pagesByDocument,
      fieldsByDocument: fieldsByDocument,
      remindersByDocument: remindersByDocument,
      memberNames: memberNames,
      categoryNames: categoryNames,
      tagNamesByDocument: tagNamesByDocument,
    );
  }

  Future<DocumentCardData> _card(
    dynamic document,
    _LibraryContext context,
  ) async {
    final owners = context.ownerIdsByDocument[document.id] ?? const [];
    final ownerNames = owners
        .map((owner) => context.memberNames[owner.familyMemberId])
        .whereType<String>()
        .toList(growable: false);
    final files = context.filesByDocument[document.id] ?? const [];
    return DocumentCardData(
      id: document.id as String,
      title: await _decrypt(
        document.titleEncrypted as String,
        'document:${document.id}:title',
      ),
      ownerNames: ownerNames,
      category:
          context.categoryNames[document.categoryId] ?? 'Other / অন্যান্য',
      expiryState: _expiryState(document.expiryDate as DateTime?),
      issueDate: document.issueDate as DateTime?,
      expiryDate: document.expiryDate as DateTime?,
      isFavorite: document.isFavorite as bool,
      isArchived: document.isArchived as bool,
      isTrashed: document.deletedAt != null,
      updatedAt: document.updatedAt as DateTime,
      createdAt: document.createdAt as DateTime,
      fileTypes: files.map((file) => _fileType(file.mimeType)).toSet(),
      preview: files.isEmpty ? null : _reference(files.first),
    );
  }

  bool _matches(
    String id,
    dynamic document,
    _LibraryContext context,
    DocumentLibraryQuery query,
  ) {
    final trashed = document.deletedAt != null;
    if (query.scope == DocumentLibraryScope.trash) return trashed;
    if (trashed || document.status == 'superseded') return false;
    final archived = document.isArchived as bool;
    final scopeMatches = switch (query.scope) {
      DocumentLibraryScope.archived => archived,
      DocumentLibraryScope.favorites =>
        !archived && document.isFavorite as bool,
      DocumentLibraryScope.category =>
        !archived && document.categoryId == query.categoryId,
      DocumentLibraryScope.person =>
        !archived &&
            (context.ownerIdsByDocument[id] ?? const []).any(
              (owner) => owner.familyMemberId == query.personId,
            ),
      DocumentLibraryScope.all || DocumentLibraryScope.recent =>
        query.filter.archive == ArchiveFilter.all ||
            (query.filter.archive == ArchiveFilter.archived
                ? archived
                : !archived),
      DocumentLibraryScope.trash => false,
    };
    if (!scopeMatches) {
      return false;
    }
    final filter = query.filter;
    if (query.scope != DocumentLibraryScope.archived &&
        query.scope != DocumentLibraryScope.trash) {
      if (filter.archive == ArchiveFilter.archived && !archived) {
        return false;
      }
      if (filter.archive == ArchiveFilter.active && archived) {
        return false;
      }
    }
    if (filter.ownerId != null &&
        !(context.ownerIdsByDocument[id] ?? const []).any(
          (owner) => owner.familyMemberId == filter.ownerId,
        )) {
      return false;
    }
    if (filter.categoryId != null && document.categoryId != filter.categoryId) {
      return false;
    }
    if (filter.tagId != null &&
        !(context.tagIdsByDocument[id] ?? const []).any(
          (tag) => tag.tagId == filter.tagId,
        )) {
      return false;
    }
    if (filter.favoriteOnly && !(document.isFavorite as bool)) {
      return false;
    }
    if (filter.fileType != DocumentFileType.any &&
        !(context.filesByDocument[id] ?? const []).any(
          (file) => _fileType(file.mimeType) == filter.fileType,
        )) {
      return false;
    }
    final expiry = _expiryState(document.expiryDate as DateTime?);
    if (!_matchesExpiry(expiry, filter.expiry)) {
      return false;
    }
    return true;
  }

  bool _matchesExpiry(DocumentExpiryState state, ExpiryFilter filter) =>
      filter == ExpiryFilter.any ||
      (filter == ExpiryFilter.expired &&
          state == DocumentExpiryState.expired) ||
      (filter == ExpiryFilter.expiringSoon &&
          state == DocumentExpiryState.soon) ||
      (filter == ExpiryFilter.valid && state == DocumentExpiryState.valid) ||
      (filter == ExpiryFilter.noExpiry && state == DocumentExpiryState.none);

  DocumentExpiryState _expiryState(DateTime? date) {
    if (date == null) return DocumentExpiryState.none;
    final today = DateTime.utc(_clock().year, _clock().month, _clock().day);
    if (date.isBefore(today)) return DocumentExpiryState.expired;
    if (!date.isAfter(today.add(const Duration(days: 30)))) {
      return DocumentExpiryState.soon;
    }
    return DocumentExpiryState.valid;
  }

  void _sort(List<DocumentCardData> cards, DocumentSort sort) {
    int nullLast<T extends Comparable<T>>(T? left, T? right) {
      if (left == null && right == null) return 0;
      if (left == null) return 1;
      if (right == null) return -1;
      return left.compareTo(right);
    }

    cards.sort(
      (left, right) => switch (sort) {
        DocumentSort.recentlyAdded => right.createdAt.compareTo(left.createdAt),
        DocumentSort.recentlyUpdated => right.updatedAt.compareTo(
          left.updatedAt,
        ),
        DocumentSort.title => left.title.toLowerCase().compareTo(
          right.title.toLowerCase(),
        ),
        DocumentSort.issueDate => nullLast(left.issueDate, right.issueDate),
        DocumentSort.expiryDate => nullLast(left.expiryDate, right.expiryDate),
        DocumentSort.category => left.category.compareTo(right.category),
        DocumentSort.owner => left.ownerLabel.compareTo(right.ownerLabel),
      },
    );
  }

  Future<String> _decrypt(String value, String context) async {
    try {
      return await _protector.decrypt(value, context: context);
    } on Object catch (error) {
      if (error is AppFailure) rethrow;
      throw StorageFailure(
        'Document metadata could not be opened safely.',
        cause: error,
      );
    }
  }

  Future<String?> _decryptOptional(String? value, String context) =>
      value == null ? Future.value(null) : _decrypt(value, context);

  static SecureFileReference _reference(dynamic file) => SecureFileReference(
    id: file.id as String,
    encryptedRelativePath: file.encryptedRelativePath as String,
    mimeType: file.mimeType as String,
    integrityHash: file.integrityHash as String,
    sizeBytes: file.sizeBytes as int,
    encryptionVersion: file.encryptionVersion as int,
  );

  static DocumentFileType _fileType(String mimeType) =>
      mimeType.startsWith('image/')
      ? DocumentFileType.image
      : mimeType == 'application/pdf'
      ? DocumentFileType.pdf
      : DocumentFileType.other;

  static String _categoryLabel(String? nameKey, String code) =>
      nameKey ?? code.replaceAll('_', ' ');

  static Map<String, List<T>> _group<T>(
    Iterable<T> values,
    String Function(T value) key,
  ) {
    final grouped = <String, List<T>>{};
    for (final value in values) {
      (grouped[key(value)] ??= []).add(value);
    }
    return UnmodifiableMapView(grouped);
  }
}

class _LibraryContext {
  const _LibraryContext({
    required this.members,
    required this.categories,
    required this.tags,
    required this.locations,
    required this.ownerIdsByDocument,
    required this.tagIdsByDocument,
    required this.filesByDocument,
    required this.pagesByDocument,
    required this.fieldsByDocument,
    required this.remindersByDocument,
    required this.memberNames,
    required this.categoryNames,
    required this.tagNamesByDocument,
  });
  final Map<String, dynamic> members;
  final Map<String, dynamic> categories;
  final Map<String, dynamic> tags;
  final Map<String, dynamic> locations;
  final Map<String, List<dynamic>> ownerIdsByDocument;
  final Map<String, List<dynamic>> tagIdsByDocument;
  final Map<String, List<dynamic>> filesByDocument;
  final Map<String, List<dynamic>> pagesByDocument;
  final Map<String, List<dynamic>> fieldsByDocument;
  final Map<String, List<dynamic>> remindersByDocument;
  final Map<String, String> memberNames;
  final Map<String, String> categoryNames;
  final Map<String, List<String>> tagNamesByDocument;
}
