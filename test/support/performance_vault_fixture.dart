import 'package:documentvault/features/documents/application/library/document_library_models.dart';
import 'package:documentvault/features/documents/application/search/secure_search_index.dart';

/// Deterministic, in-memory vault data for performance and reliability tests.
/// It intentionally has no file-system output and contains no real documents.
class PerformanceVaultFixture {
  static List<DocumentSearchRecord> searchableRecords(int count) {
    return List.generate(
      count,
      (index) => DocumentSearchRecord(
        documentId: 'fixture-document-$index',
        title: 'Synthetic household document $index',
        documentNumber: 'TEST-$index',
        ownerIds: {'member-${index % 8}'},
        ownerNames: ['Family member ${index % 8}'],
        categoryId: 'category-${index % 14}',
        category: 'Category ${index % 14}',
        tagIds: {'tag-${index % 10}'},
        tags: ['Tag ${index % 10}'],
        notes: 'Synthetic metadata record $index',
        issuingAuthority: 'Fixture authority',
        expiryDate: DateTime.utc(2030, 1, 1),
        isFavorite: index.isEven,
        isArchived: false,
        fileTypes: const {DocumentFileType.image},
      ),
    );
  }
}
