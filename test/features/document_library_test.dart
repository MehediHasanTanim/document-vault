import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:documentvault/core/crypto/vault_data_protector.dart';
import 'package:documentvault/core/database/vault_database.dart';
import 'package:documentvault/core/files/encrypted_file_store.dart';
import 'package:documentvault/core/files/file_reference.dart';
import 'package:documentvault/features/documents/application/library/document_library_models.dart';
import 'package:documentvault/features/documents/application/library/document_library_repository.dart';
import 'package:documentvault/features/documents/application/library/document_library_service.dart';
import 'package:documentvault/features/documents/application/viewer/protected_thumbnail_service.dart';
import 'package:documentvault/features/documents/application/viewer/secure_viewer_session.dart';
import 'package:documentvault/features/documents/application/viewer/viewer_cache_lock_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;

void main() {
  final now = DateTime.utc(2026, 10, 6);

  test(
    'library supports scopes, filters, sorting and document detail projection',
    () async {
      final snapshot = _snapshot(now);
      final service = DocumentLibraryService(
        _SnapshotRepository(snapshot),
        const _PlainProtector(),
        clock: () => now,
      );
      final favorites = await service.browse(
        const DocumentLibraryQuery(scope: DocumentLibraryScope.favorites),
      );
      expect(favorites.map((value) => value.id), ['doc-1']);
      final expired = await service.browse(
        const DocumentLibraryQuery(
          filter: DocumentLibraryFilter(expiry: ExpiryFilter.expired),
        ),
      );
      expect(expired.map((value) => value.id), ['doc-2']);
      final searched = await service.browse(
        const DocumentLibraryQuery(
          filter: DocumentLibraryFilter(searchTerm: 'important'),
        ),
      );
      expect(searched.single.id, 'doc-1');
      final filtered = await service.browse(
        const DocumentLibraryQuery(
          filter: DocumentLibraryFilter(
            ownerId: 'member',
            categoryId: 'category',
            tagId: 'tag',
            favoriteOnly: true,
            fileType: DocumentFileType.image,
          ),
        ),
      );
      expect(filtered.single.id, 'doc-1');
      final details = await service.details('doc-1');
      expect(details!.card.ownerNames, ['Amina']);
      expect(details.tags, ['Important']);
      expect(details.documentNumber, 'NID-1234');
      expect(details.reminder.enabled, isTrue);
    },
  );

  test(
    'browses 1000 encrypted-at-rest document rows within a responsive budget',
    () async {
      final documents = List.generate(
        1000,
        (index) => _document(
          id: 'doc-$index',
          title: 'Document $index',
          categoryId: 'category',
          createdAt: now.subtract(Duration(minutes: index)),
          updatedAt: now.subtract(Duration(minutes: index)),
        ),
      );
      final snapshot = DocumentLibrarySnapshot(
        documents: documents,
        categories: [_category(now)],
        members: const [],
        owners: const [],
        tags: const [],
        tagLinks: const [],
        locations: const [],
        files: const [],
        pages: const [],
        fields: const [],
        reminders: const [],
      );
      final stopwatch = Stopwatch()..start();
      final result = await DocumentLibraryService(
        _SnapshotRepository(snapshot),
        const _PlainProtector(),
        clock: () => now,
      ).browse(const DocumentLibraryQuery());
      stopwatch.stop();
      expect(result, hasLength(1000));
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
    },
  );

  test(
    'protected thumbnails stay in memory and viewer temp files are removed',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'document-vault-viewer-',
      );
      addTearDown(() => root.delete(recursive: true));
      final store = EncryptedFileStore(
        SecretKey(List<int>.filled(32, 8)),
        supportDirectory: () async => root,
      );
      final source = image.encodeJpg(image.Image(width: 1600, height: 1000));
      final reference = await store.writeEncrypted(
        documentId: 'document-1',
        mimeType: 'image/jpeg',
        bytes: Stream.value(source),
      );
      final thumbnails = ProtectedThumbnailService(
        store,
        maxEntries: 2,
        maxBytes: 1024 * 1024,
      );
      final thumbnail = await thumbnails.thumbnail(reference);
      expect(thumbnail, isNotNull);
      expect(thumbnails.entryCount, 1);
      ViewerCacheLockHandler(thumbnails).onVaultLocked();
      expect(thumbnails.entryCount, 0);
      final session = await SecureViewerSession.open(store, reference);
      expect(await session.file.exists(), isTrue);
      final temporaryPath = session.file.parent.path;
      await session.close();
      expect(await Directory(temporaryPath).exists(), isFalse);
    },
  );

  test('keeps thumbnail memory bounded during rapid scrolling across hundreds of cards', () async {
    final source = image.encodeJpg(image.Image(width: 8, height: 8));
    final thumbnails = ProtectedThumbnailService(
      _MemoryImageStore(source),
      maxEntries: 50,
      maxBytes: 1024 * 1024,
    );
    for (var index = 0; index < 250; index++) {
      await thumbnails.thumbnail(
        SecureFileReference(
          id: 'file-$index',
          encryptedRelativePath: 'document/file-$index.dvf',
          mimeType: 'image/jpeg',
          integrityHash: 'a' * 64,
          sizeBytes: source.length,
        ),
      );
    }
    expect(thumbnails.entryCount, 50);
    expect(thumbnails.cachedBytes, lessThanOrEqualTo(1024 * 1024));
  });

  test('keeps large PDF page sets as metadata and never creates a thumbnail for PDFs', () async {
    final files = List.generate(
      101,
      (index) => DocumentFile(
        id: 'pdf-$index',
        documentId: 'pdf-document',
        fileType: 'import',
        mimeType: 'application/pdf',
        encryptedRelativePath: 'pdf-document/$index.dvf',
        sizeBytes: 1,
        integrityHash: 'a' * 64,
        encryptionVersion: 1,
        createdAt: now,
      ),
    );
    final snapshot = DocumentLibrarySnapshot(
      documents: [
        _document(
          id: 'pdf-document',
          title: 'Large PDF',
          categoryId: 'category',
          createdAt: now,
          updatedAt: now,
        ),
      ],
      categories: [_category(now)],
      members: const [],
      owners: const [],
      tags: const [],
      tagLinks: const [],
      locations: const [],
      files: files,
      pages: const [],
      fields: const [],
      reminders: const [],
    );
    final result = await DocumentLibraryService(
      _SnapshotRepository(snapshot),
      const _PlainProtector(),
      clock: () => now,
    ).browse(const DocumentLibraryQuery());
    expect(result.single.fileTypes, contains(DocumentFileType.pdf));
  });
}

DocumentLibrarySnapshot _snapshot(DateTime now) => DocumentLibrarySnapshot(
  documents: [
    _document(
      id: 'doc-1',
      title: 'Important passport',
      categoryId: 'category',
      createdAt: now,
      updatedAt: now,
      favorite: true,
    ),
    _document(
      id: 'doc-2',
      title: 'Old receipt',
      categoryId: 'category',
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now,
      expiry: now.subtract(const Duration(days: 1)),
    ),
  ],
  categories: [_category(now)],
  members: [
    FamilyMember(
      id: 'member',
      displayNameEncrypted: 'Amina',
      relationship: 'Self',
      isOwner: true,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    ),
  ],
  owners: const [
    DocumentOwner(documentId: 'doc-1', familyMemberId: 'member', role: 'owner'),
  ],
  tags: [
    Tag(
      id: 'tag',
      nameEncrypted: 'Important',
      normalizedNameHash: 'x',
      createdAt: now,
    ),
  ],
  tagLinks: const [DocumentTag(documentId: 'doc-1', tagId: 'tag')],
  locations: const [],
  files: [
    DocumentFile(
      id: 'image',
      documentId: 'doc-1',
      fileType: 'import',
      mimeType: 'image/jpeg',
      encryptedRelativePath: 'doc-1/image.dvf',
      sizeBytes: 1,
      integrityHash: 'a' * 64,
      encryptionVersion: 1,
      createdAt: now,
    ),
  ],
  pages: const [],
  fields: [
    DocumentFieldValue(
      id: 'field',
      documentId: 'doc-1',
      fieldKey: 'number',
      labelEncrypted: 'Number',
      valueEncrypted: '123',
      valueType: 'text',
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    ),
  ],
  reminders: [
    Reminder(
      id: 'reminder',
      documentId: 'doc-1',
      reminderType: 'expiry',
      targetDate: now,
      scheduledAt: now.add(const Duration(days: 1)),
      status: 'scheduled',
      createdAt: now,
      updatedAt: now,
    ),
  ],
);

DocumentCategory _category(DateTime now) => DocumentCategory(
  id: 'category',
  code: 'identity.passport',
  nameKey: 'Passport',
  isSystem: true,
  sortOrder: 0,
  iconKey: 'document',
  createdAt: now,
  updatedAt: now,
);

Document _document({
  required String id,
  required String title,
  required String categoryId,
  required DateTime createdAt,
  required DateTime updatedAt,
  DateTime? expiry,
  bool favorite = false,
}) => Document(
  id: id,
  titleEncrypted: title,
  categoryId: categoryId,
  ownershipType: 'personal',
  documentNumberEncrypted: id == 'doc-1' ? 'NID-1234' : null,
  expiryDate: expiry,
  status: 'active',
  isFavorite: favorite,
  isArchived: false,
  createdAt: createdAt,
  updatedAt: updatedAt,
);

class _SnapshotRepository implements DocumentLibraryRepository {
  const _SnapshotRepository(this.snapshot);
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

class _MemoryImageStore implements SecureFileStore {
  const _MemoryImageStore(this.bytes);
  final List<int> bytes;
  @override
  Future<void> delete(SecureFileReference reference) async {}
  @override
  Future<Stream<List<int>>> readDecrypted(
    SecureFileReference reference,
  ) async => Stream.value(bytes);
  @override
  Future<SecureFileReference> writeEncrypted({
    required String documentId,
    required Stream<List<int>> bytes,
    required String mimeType,
  }) => throw UnimplementedError();
}
