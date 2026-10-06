import 'package:documentvault/core/crypto/vault_data_protector.dart';
import 'package:documentvault/core/database/vault_database.dart';
import 'package:documentvault/features/documents/application/library/document_library_models.dart';
import 'package:documentvault/features/documents/application/library/document_library_repository.dart';
import 'package:documentvault/features/documents/application/search/search_index_builder.dart';
import 'package:documentvault/features/documents/application/search/secure_search_index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 10, 6);

  test('searches Bengali, English, mixed text, numerals, and case-normalized values', () {
    final index = SecureSearchIndex()..build([_record()]);
    for (final query in [
      'জাতীয়',
      'nid',
      'রহিম Rahim',
      '1234',
      '১২৩৪',
      'IMPORTANT',
      'ঢাকা',
    ]) {
      expect(
        index.search(query, clock: () => now).single.documentId,
        'document-1',
        reason: query,
      );
    }
  });

  test('indexes every approved metadata field and applies library filters', () {
    final index = SecureSearchIndex()..build([_record()]);
    for (final query in [
      'AB-1234',
      'আলম',
      'পরিচয়',
      'travel',
      'renew',
      'immigration',
    ]) {
      expect(
        index.search(query, clock: () => now),
        hasLength(1),
        reason: query,
      );
    }
    expect(
      index.search(
        'nid',
        clock: () => now,
        filter: const DocumentLibraryFilter(
          ownerId: 'owner-1',
          categoryId: 'identity',
          tagId: 'tag-travel',
          favoriteOnly: true,
          fileType: DocumentFileType.image,
        ),
      ),
      hasLength(1),
    );
    expect(
      index.search(
        'nid',
        filter: const DocumentLibraryFilter(ownerId: 'other'),
        clock: () => now,
      ),
      isEmpty,
    );
  });

  test('updates incrementally and destroys plaintext records on lock', () {
    final index = SecureSearchIndex()..upsert(_record());
    final recent = InMemoryRecentSearches(enabled: true)..add('NID');
    index.upsert(_record(title: 'Updated licence'));
    expect(index.search('updated').single.documentId, 'document-1');
    index.remove('document-1');
    expect(index.search('updated'), isEmpty);
    index.upsert(_record());
    SearchIndexLockHandler(index, recent).onVaultLocked();
    expect(index.count, 0);
    expect(index.search('nid'), isEmpty);
    expect(recent.values, isEmpty);
  });

  test(
    'archived documents are searchable only through the archived filter',
    () {
      final index = SecureSearchIndex()
        ..build([
          _record(id: 'active'),
          _record(id: 'archived', archived: true),
        ]);
      expect(
        index
            .search(
              'nid',
              clock: () => now,
              filter: const DocumentLibraryFilter(),
            )
            .map((result) => result.documentId),
        ['active'],
      );
      expect(
        index
            .search(
              'nid',
              clock: () => now,
              filter: const DocumentLibraryFilter(
                archive: ArchiveFilter.archived,
              ),
            )
            .map((result) => result.documentId),
        ['archived'],
      );
    },
  );

  test('recent searches are not stored unless explicitly enabled', () {
    final private = InMemoryRecentSearches()..add('Passport');
    expect(private.values, isEmpty);
  });

  test(
    'builds after unlock from encrypted database rows and upserts after CRUD',
    () async {
      final now = DateTime.utc(2026, 10, 6);
      final snapshot = DocumentLibrarySnapshot(
        documents: [
          Document(
            id: 'document-row',
            titleEncrypted: 'Passport',
            categoryId: 'category',
            ownershipType: 'personal',
            documentNumberEncrypted: 'P-123',
            notesEncrypted: 'Private renewal note',
            issuingAuthorityEncrypted: 'Immigration',
            status: 'active',
            isFavorite: false,
            isArchived: false,
            createdAt: now,
            updatedAt: now,
          ),
        ],
        categories: [
          DocumentCategory(
            id: 'category',
            code: 'identity.passport',
            nameKey: 'Passport',
            isSystem: true,
            sortOrder: 0,
            iconKey: 'document',
            createdAt: now,
            updatedAt: now,
          ),
        ],
        members: [
          FamilyMember(
            id: 'owner',
            displayNameEncrypted: 'Amina',
            relationship: 'Self',
            isOwner: true,
            isArchived: false,
            createdAt: now,
            updatedAt: now,
          ),
        ],
        owners: const [
          DocumentOwner(
            documentId: 'document-row',
            familyMemberId: 'owner',
            role: 'owner',
          ),
        ],
        tags: [
          Tag(
            id: 'tag',
            nameEncrypted: 'Travel',
            normalizedNameHash: 'hash',
            createdAt: now,
          ),
        ],
        tagLinks: const [DocumentTag(documentId: 'document-row', tagId: 'tag')],
        locations: const [],
        files: const [],
        pages: const [],
        fields: const [],
        reminders: const [],
      );
      final index = SecureSearchIndex();
      final builder = SearchIndexBuilder(
        _SearchSnapshotRepository(snapshot),
        const _PlainProtector(),
        index,
      );
      await builder.rebuildAfterUnlock();
      expect(index.search('renewal').single.documentId, 'document-row');
      builder.removeDocument('document-row');
      expect(index.count, 0);
    },
  );

  test('builds and searches 100, 1000 and 10000 in-memory records quickly', () {
    for (final count in [100, 1000, 10000]) {
      final records = List.generate(
        count,
        (index) =>
            _record(id: 'document-$index', title: 'Household record $index'),
      );
      final stopwatch = Stopwatch()..start();
      final index = SecureSearchIndex()..build(records);
      final result = index.search('record ${count - 1}');
      stopwatch.stop();
      expect(result.single.documentId, 'document-${count - 1}');
      expect(
        stopwatch.elapsed,
        lessThan(const Duration(seconds: 2)),
        reason: '$count records',
      );
    }
  });
}

DocumentSearchRecord _record({
  String id = 'document-1',
  String title = 'জাতীয় পরিচয়পত্র NID',
  bool archived = false,
}) => DocumentSearchRecord(
  documentId: id,
  title: title,
  documentNumber: 'AB-১২৩৪',
  ownerIds: const {'owner-1'},
  ownerNames: const ['রহিম আলম / Rahim Alam'],
  categoryId: 'identity',
  category: 'পরিচয় / Identity',
  tagIds: const {'tag-travel'},
  tags: const ['Travel', 'Important'],
  notes: 'ঢাকা থেকে ভ্রমণের আগে renew করুন',
  issuingAuthority: 'Department of Immigration',
  expiryDate: DateTime.utc(2030, 1, 1),
  isFavorite: true,
  isArchived: archived,
  fileTypes: const {DocumentFileType.image},
);

class _SearchSnapshotRepository implements DocumentLibraryRepository {
  const _SearchSnapshotRepository(this.snapshot);
  final DocumentLibrarySnapshot snapshot;
  @override
  Future<DocumentLibrarySnapshot> loadSnapshot() async => snapshot;
}

class _PlainProtector implements VaultDataProtector {
  const _PlainProtector();
  @override
  Future<String> decrypt(String ciphertext, {required String context}) async =>
      ciphertext;
  @override
  Future<String> encrypt(String plaintext, {required String context}) async =>
      plaintext;
  @override
  Future<String> normalizedNameHash(
    String value, {
    required String context,
  }) async => value;
}
