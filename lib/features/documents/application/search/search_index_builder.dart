import '../../../../core/crypto/vault_data_protector.dart';
import '../../../../core/database/vault_database.dart';
import '../library/document_library_models.dart';
import '../library/document_library_repository.dart';
import 'secure_search_index.dart';

/// Performs the one-time post-unlock decryption needed by the ephemeral index.
/// Call [rebuildAfterUnlock] only after a successful vault unlock and call the
/// matching [SearchIndexLockHandler] before the key is discarded.
class SearchIndexBuilder {
  SearchIndexBuilder(this._repository, this._protector, this._index);
  final DocumentLibraryRepository _repository;
  final VaultDataProtector _protector;
  final SecureSearchIndex _index;

  Future<void> rebuildAfterUnlock() async {
    final snapshot = await _repository.loadSnapshot();
    _index.build(await _records(snapshot));
  }

  Future<void> upsertDocument(String documentId) async {
    final snapshot = await _repository.loadSnapshot();
    final record = (await _records(snapshot))
        .where((candidate) => candidate.documentId == documentId)
        .firstOrNull;
    if (record == null) {
      _index.remove(documentId);
    } else {
      _index.upsert(record);
    }
  }

  /// CRUD use-cases that already hold decrypted, validated form data can avoid
  /// any snapshot reload by sending just their changed document here.
  void upsertRecord(DocumentSearchRecord record) => _index.upsert(record);

  void removeDocument(String documentId) => _index.remove(documentId);

  Future<List<DocumentSearchRecord>> _records(
    DocumentLibrarySnapshot snapshot,
  ) async {
    final owners = _group(snapshot.owners, (value) => value.documentId);
    final tagLinks = _group(snapshot.tagLinks, (value) => value.documentId);
    final files = _group(snapshot.files, (value) => value.documentId);
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
          ? (category.nameKey ?? category.code.replaceAll('_', ' '))
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

    final records = <DocumentSearchRecord>[];
    for (final document in snapshot.documents) {
      if (document.deletedAt != null) continue;
      final documentOwners = owners[document.id] ?? const <DocumentOwner>[];
      final documentTags = tagLinks[document.id] ?? const <DocumentTag>[];
      records.add(
        DocumentSearchRecord(
          documentId: document.id,
          title: await _decrypt(
            document.titleEncrypted,
            'document:${document.id}:title',
          ),
          documentNumber: await _decryptOptional(
            document.documentNumberEncrypted,
            'document:${document.id}:number',
          ),
          ownerIds: documentOwners.map((value) => value.familyMemberId).toSet(),
          ownerNames: documentOwners
              .map((value) => memberNames[value.familyMemberId])
              .whereType<String>()
              .toList(growable: false),
          categoryId: document.categoryId,
          category: categoryNames[document.categoryId] ?? 'Other / অন্যান্য',
          tagIds: documentTags.map((value) => value.tagId).toSet(),
          tags: documentTags
              .map((value) => tagNames[value.tagId])
              .whereType<String>()
              .toList(growable: false),
          notes: await _decryptOptional(
            document.notesEncrypted,
            'document:${document.id}:notes',
          ),
          issuingAuthority: await _decryptOptional(
            document.issuingAuthorityEncrypted,
            'document:${document.id}:authority',
          ),
          expiryDate: document.expiryDate,
          isFavorite: document.isFavorite,
          isArchived: document.isArchived,
          fileTypes: (files[document.id] ?? const <DocumentFile>[])
              .map((value) => _fileType(value.mimeType))
              .toSet(),
        ),
      );
    }
    return records;
  }

  Future<String> _decrypt(String value, String context) =>
      _protector.decrypt(value, context: context);
  Future<String?> _decryptOptional(String? value, String context) =>
      value == null ? Future.value(null) : _decrypt(value, context);
  static DocumentFileType _fileType(String mimeType) =>
      mimeType.startsWith('image/')
      ? DocumentFileType.image
      : mimeType == 'application/pdf'
      ? DocumentFileType.pdf
      : DocumentFileType.other;
  static Map<String, List<T>> _group<T>(
    Iterable<T> items,
    String Function(T value) key,
  ) {
    final grouped = <String, List<T>>{};
    for (final item in items) {
      (grouped[key(item)] ??= []).add(item);
    }
    return grouped;
  }
}
