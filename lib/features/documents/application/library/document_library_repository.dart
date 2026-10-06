import '../../../../core/database/vault_database.dart';
import 'document_library_models.dart';

abstract interface class DocumentLibraryRepository {
  Future<DocumentLibrarySnapshot> loadSnapshot();
}

/// Deliberately loads only encrypted rows and relationship IDs. Filtering and
/// presentation decryption happen after unlock in [DocumentLibraryService].
class DriftDocumentLibraryRepository implements DocumentLibraryRepository {
  DriftDocumentLibraryRepository(this._database);
  final VaultDatabase _database;

  @override
  Future<DocumentLibrarySnapshot> loadSnapshot() async {
    final values = await Future.wait([
      _database.select(_database.documents).get(),
      _database.select(_database.documentCategories).get(),
      _database.select(_database.familyMembers).get(),
      _database.select(_database.documentOwners).get(),
      _database.select(_database.tags).get(),
      _database.select(_database.documentTags).get(),
      _database.select(_database.physicalLocations).get(),
      _database.select(_database.documentFiles).get(),
      _database.select(_database.documentPages).get(),
      _database.select(_database.documentFieldValues).get(),
      _database.select(_database.reminders).get(),
    ]);
    return DocumentLibrarySnapshot(
      documents: values[0] as List<Document>,
      categories: values[1] as List<DocumentCategory>,
      members: values[2] as List<FamilyMember>,
      owners: values[3] as List<DocumentOwner>,
      tags: values[4] as List<Tag>,
      tagLinks: values[5] as List<DocumentTag>,
      locations: values[6] as List<PhysicalLocation>,
      files: values[7] as List<DocumentFile>,
      pages: values[8] as List<DocumentPage>,
      fields: values[9] as List<DocumentFieldValue>,
      reminders: values[10] as List<Reminder>,
    );
  }
}
