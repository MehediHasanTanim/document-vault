import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'vault_database.g.dart';

class Vaults extends Table {
  TextColumn get id => text()();
  IntColumn get schemaVersion => integer()();
  IntColumn get securityVersion => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class FamilyMembers extends Table {
  TextColumn get id => text()();
  TextColumn get displayNameEncrypted => text()();
  TextColumn get relationship => text()();
  BoolColumn get isOwner => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class DocumentCategories extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get parentId => text().nullable()();
  TextColumn get customNameEncrypted => text().nullable()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {id};
}

class Documents extends Table {
  TextColumn get id => text()();
  TextColumn get titleEncrypted => text()();
  TextColumn get categoryId => text().references(DocumentCategories, #id)();
  TextColumn get primaryOwnerId =>
      text().nullable().references(FamilyMembers, #id)();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class DocumentOwners extends Table {
  TextColumn get documentId => text().references(Documents, #id)();
  TextColumn get familyMemberId => text().references(FamilyMembers, #id)();
  TextColumn get role => text().withDefault(const Constant('owner'))();
  @override
  Set<Column> get primaryKey => {documentId, familyMemberId};
}

class DocumentFiles extends Table {
  TextColumn get id => text()();
  TextColumn get documentId => text().references(Documents, #id)();
  TextColumn get mimeType => text()();
  TextColumn get encryptedRelativePath => text().unique()();
  TextColumn get integrityHash => text()();
  IntColumn get sizeBytes => integer()();
  IntColumn get encryptionVersion => integer()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class DocumentPages extends Table {
  TextColumn get id => text()();
  TextColumn get documentId => text().references(Documents, #id)();
  TextColumn get documentFileId => text().references(DocumentFiles, #id)();
  IntColumn get pageNumber => integer()();
  IntColumn get rotation => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [
    {documentId, pageNumber},
  ];
}

class DocumentFieldValues extends Table {
  TextColumn get id => text()();
  TextColumn get documentId => text().references(Documents, #id)();
  TextColumn get fieldKey => text()();
  TextColumn get valueEncrypted => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {id};
}

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get nameEncrypted => text()();
  TextColumn get normalizedNameHash => text().unique()();
  @override
  Set<Column> get primaryKey => {id};
}

class DocumentTags extends Table {
  TextColumn get documentId => text().references(Documents, #id)();
  TextColumn get tagId => text().references(Tags, #id)();
  @override
  Set<Column> get primaryKey => {documentId, tagId};
}

class PhysicalLocations extends Table {
  TextColumn get id => text()();
  TextColumn get nameEncrypted => text()();
  TextColumn get notesEncrypted => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get documentId => text().references(Documents, #id)();
  DateTimeColumn get scheduledAt => dateTime()();
  TextColumn get status => text()();
  IntColumn get notificationId => integer().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class BackupRecords extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get sizeBytes => integer()();
  BoolColumn get verified => boolean()();
  @override
  Set<Column> get primaryKey => {id};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get valueEncrypted => text()();
  @override
  Set<Column> get primaryKey => {key};
}

class PendingOperations extends Table {
  TextColumn get id => text()();
  TextColumn get operationType => text()();
  TextColumn get entityId => text()();
  TextColumn get state => text()();
  TextColumn get payloadEncrypted => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Vaults,
    FamilyMembers,
    DocumentCategories,
    Documents,
    DocumentOwners,
    DocumentFiles,
    DocumentPages,
    DocumentFieldValues,
    Tags,
    DocumentTags,
    PhysicalLocations,
    Reminders,
    BackupRecords,
    AppSettings,
    PendingOperations,
  ],
)
class VaultDatabase extends _$VaultDatabase {
  VaultDatabase(super.e);
  VaultDatabase.defaults() : super(driftDatabase(name: 'document_vault'));
  @override
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      throw UnsupportedError('Missing explicit migration from schema $from to $to');
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
