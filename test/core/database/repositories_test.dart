import 'package:documentvault/core/database/repositories.dart';
import 'package:documentvault/core/database/vault_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/database_test_harness.dart';

void main() {
  late VaultDatabase database;
  late DriftCategoryRepository categories;
  late DriftDocumentRepository documents;
  final now = DateTime.utc(2026, 1, 1);

  setUp(() {
    database = openTestDatabase();
    categories = DriftCategoryRepository(database);
    documents = DriftDocumentRepository(database);
  });
  tearDown(() => database.close());

  Future<void> addCategory() => categories.save(
    DocumentCategoriesCompanion.insert(
      id: 'category-1',
      code: 'nid',
      createdAt: now,
      updatedAt: now,
    ),
  );

  DocumentsCompanion document(String id) => DocumentsCompanion.insert(
    id: id,
    titleEncrypted: 'ciphertext',
    categoryId: 'category-1',
    createdAt: now,
    updatedAt: now,
  );

  test(
    'document repository creates, archives, trashes and restores a document',
    () async {
      await addCategory();
      await documents.create(DocumentWrite(document: document('document-1')));
      expect((await documents.getById('document-1'))?.isArchived, isFalse);

      await documents.archive(
        'document-1',
        archived: true,
        updatedAt: now.add(const Duration(minutes: 1)),
      );
      expect((await documents.getById('document-1'))?.isArchived, isTrue);

      await documents.moveToTrash(
        'document-1',
        deletedAt: now.add(const Duration(minutes: 2)),
      );
      expect(await documents.watchAll().first, isEmpty);

      await documents.restore(
        'document-1',
        updatedAt: now.add(const Duration(minutes: 3)),
      );
      expect(await documents.watchAll().first, hasLength(1));
    },
  );

  test(
    'document write is atomic when a related row violates a foreign key',
    () async {
      await addCategory();
      final write = DocumentWrite(
        document: document('document-1'),
        owners: [
          DocumentOwnersCompanion.insert(
            documentId: 'document-1',
            familyMemberId: 'missing',
          ),
        ],
      );
      await expectLater(documents.create(write), throwsA(isA<Exception>()));
      expect(await documents.getById('document-1'), isNull);
    },
  );

  test('permanent document deletion cascades metadata and returns files for storage cleanup', () async {
    await addCategory();
    await documents.create(
      DocumentWrite(
        document: document('document-1'),
        files: [
          DocumentFilesCompanion.insert(
            id: 'file-1',
            documentId: 'document-1',
            mimeType: 'image/jpeg',
            encryptedRelativePath: 'document-1/file-1.dvf',
            integrityHash: 'a' * 64,
            sizeBytes: 5,
            encryptionVersion: 1,
            createdAt: now,
          ),
        ],
      ),
    );
    final files = await documents.deletePermanently('document-1');
    expect(files.single.id, 'file-1');
    expect(await documents.getById('document-1'), isNull);
    expect(await database.select(database.documentFiles).get(), isEmpty);
  });
}
