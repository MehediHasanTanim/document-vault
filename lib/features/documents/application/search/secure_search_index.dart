import '../library/document_library_models.dart';

/// Plaintext is permitted only inside this object while the vault is unlocked.
/// No persistence, logging, or settings dependency is intentionally present.
class DocumentSearchRecord {
  const DocumentSearchRecord({
    required this.documentId,
    required this.title,
    required this.documentNumber,
    required this.ownerIds,
    required this.ownerNames,
    required this.categoryId,
    required this.category,
    required this.tagIds,
    required this.tags,
    required this.notes,
    required this.issuingAuthority,
    this.ocrText,
    required this.expiryDate,
    required this.isFavorite,
    required this.isArchived,
    required this.fileTypes,
  });
  final String documentId;
  final String title;
  final String? documentNumber;
  final Set<String> ownerIds;
  final List<String> ownerNames;
  final String categoryId;
  final String category;
  final Set<String> tagIds;
  final List<String> tags;
  final String? notes;
  final String? issuingAuthority;
  final String? ocrText;
  final DateTime? expiryDate;
  final bool isFavorite;
  final bool isArchived;
  final Set<DocumentFileType> fileTypes;
}

class SearchResult {
  const SearchResult({
    required this.documentId,
    required this.title,
    required this.ownerLabel,
    required this.category,
  });
  final String documentId;
  final String title;
  final String ownerLabel;
  final String category;
}

class SearchSuggestion {
  const SearchSuggestion({required this.label, required this.query});
  final String label;
  final String query;
}

class SecureSearchIndex {
  final _entries = <String, _IndexedRecord>{};

  bool get isReady => _entries.isNotEmpty;
  int get count => _entries.length;

  void build(Iterable<DocumentSearchRecord> records) {
    clear();
    for (final record in records) {
      upsert(record);
    }
  }

  void upsert(DocumentSearchRecord record) {
    _entries[record.documentId] = _IndexedRecord(
      record,
      _normalize(
        [
          record.title,
          record.documentNumber,
          ...record.ownerNames,
          record.category,
          ...record.tags,
          record.notes,
          record.issuingAuthority,
          record.ocrText,
        ].whereType<String>().join(' '),
      ),
    );
  }

  void remove(String documentId) => _entries.remove(documentId);

  List<SearchResult> search(
    String query, {
    DocumentLibraryFilter filter = const DocumentLibraryFilter(),
    DateTime Function()? clock,
  }) {
    final tokens = _normalize(query)
        .split(' ')
        .where((token) => token.isNotEmpty)
        .toList();
    final now = (clock ?? DateTime.now)().toUtc();
    final matches = <SearchResult>[];
    for (final indexed in _entries.values) {
      if (!_matchesFilter(indexed.record, filter, now)) {
        continue;
      }
      if (tokens.any((token) => !indexed.normalizedValues.contains(token))) {
        continue;
      }
      matches.add(
        SearchResult(
          documentId: indexed.record.documentId,
          title: indexed.record.title,
          ownerLabel: indexed.record.ownerNames.isEmpty
              ? 'Household / পরিবার'
              : indexed.record.ownerNames.join(', '),
          category: indexed.record.category,
        ),
      );
    }
    matches.sort(
      (left, right) =>
          left.title.toLowerCase().compareTo(right.title.toLowerCase()),
    );
    return matches;
  }

  List<SearchSuggestion> suggestions(String query, {int limit = 8}) {
    final normalized = _normalize(query);
    final seen = <String>{};
    final values = <SearchSuggestion>[];
    for (final record in _entries.values) {
      for (final value in [
        record.record.title,
        record.record.category,
        ...record.record.ownerNames,
        ...record.record.tags,
      ]) {
        final key = _normalize(value);
        if ((normalized.isEmpty || key.contains(normalized)) && seen.add(key)) {
          values.add(SearchSuggestion(label: value, query: value));
          if (values.length == limit) return values;
        }
      }
    }
    return values;
  }

  /// Clears all normalized and raw search values immediately on lock.
  void clear() => _entries.clear();

  static String normalize(String value) => _normalize(value);

  static String _normalize(String value) {
    const banglaDigits = '০১২৩৪৫৬৭৮৯';
    const asciiDigits = '0123456789';
    var normalized = value.trim().toLowerCase();
    for (var index = 0; index < banglaDigits.length; index++) {
      normalized = normalized.replaceAll(
        banglaDigits[index],
        asciiDigits[index],
      );
    }
    return normalized
        .replaceAll(RegExp(r'[\-_./,;:()\[\]{}]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  bool _matchesFilter(
    DocumentSearchRecord record,
    DocumentLibraryFilter filter,
    DateTime now,
  ) {
    if (filter.ownerId != null && !record.ownerIds.contains(filter.ownerId)) {
      return false;
    }
    if (filter.categoryId != null && record.categoryId != filter.categoryId) {
      return false;
    }
    if (filter.tagId != null && !record.tagIds.contains(filter.tagId)) {
      return false;
    }
    if (filter.favoriteOnly && !record.isFavorite) {
      return false;
    }
    if (filter.archive == ArchiveFilter.active && record.isArchived) {
      return false;
    }
    if (filter.archive == ArchiveFilter.archived && !record.isArchived) {
      return false;
    }
    if (filter.fileType != DocumentFileType.any &&
        !record.fileTypes.contains(filter.fileType)) {
      return false;
    }
    final expiry = record.expiryDate;
    return switch (filter.expiry) {
      ExpiryFilter.any => true,
      ExpiryFilter.noExpiry => expiry == null,
      ExpiryFilter.expired => expiry != null && expiry.isBefore(now),
      ExpiryFilter.expiringSoon =>
        expiry != null &&
            !expiry.isBefore(now) &&
            !expiry.isAfter(now.add(const Duration(days: 30))),
      ExpiryFilter.valid =>
        expiry != null && expiry.isAfter(now.add(const Duration(days: 30))),
    };
  }
}

class _IndexedRecord {
  const _IndexedRecord(this.record, this.normalizedValues);
  final DocumentSearchRecord record;
  final String normalizedValues;
}

/// Memory-only recents are opt-in. They are intentionally not persisted, even
/// as encrypted settings, so a lock or process exit forgets query history.
class InMemoryRecentSearches {
  InMemoryRecentSearches({this.enabled = false, this.limit = 5});
  final bool enabled;
  final int limit;
  final _values = <String>[];
  List<String> get values => List.unmodifiable(_values);

  void add(String query) {
    final value = query.trim();
    if (!enabled || value.isEmpty) return;
    _values
      ..removeWhere(
        (existing) =>
            SecureSearchIndex.normalize(existing) ==
            SecureSearchIndex.normalize(value),
      )
      ..insert(0, value);
    if (_values.length > limit) _values.removeRange(limit, _values.length);
  }

  void clear() => _values.clear();
}

class SearchIndexLockHandler {
  SearchIndexLockHandler(this._index, [this._recent]);
  final SecureSearchIndex _index;
  final InMemoryRecentSearches? _recent;
  void onVaultLocked() {
    _index.clear();
    _recent?.clear();
  }
}
