import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'vault_database.g.dart';

/// Initial production schema. Values marked encrypted are encrypted before
/// persistence; raw vault keys never enter this database.
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
  TextColumn get nicknameEncrypted => text().nullable()();
  TextColumn get relationship => text()();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  TextColumn get bloodGroup => text().nullable()();
  TextColumn get avatarFileId => text().nullable()();
  TextColumn get notesEncrypted => text().nullable()();
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
  TextColumn get parentId => text().nullable().references(
    DocumentCategories,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get nameKey => text().nullable()();
  TextColumn get customNameEncrypted => text().nullable()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get iconKey => text().withDefault(const Constant('document'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class PhysicalLocations extends Table {
  TextColumn get id => text()();
  TextColumn get nameEncrypted => text()();
  TextColumn get descriptionEncrypted => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class Documents extends Table {
  TextColumn get id => text()();
  TextColumn get titleEncrypted => text()();
  TextColumn get categoryId => text().references(DocumentCategories, #id)();
  TextColumn get primaryOwnerId => text().nullable().references(
    FamilyMembers,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get ownershipType =>
      text().withDefault(const Constant('personal'))();
  TextColumn get documentNumberEncrypted => text().nullable()();
  DateTimeColumn get issueDate => dateTime().nullable()();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  TextColumn get issuingAuthorityEncrypted => text().nullable()();
  TextColumn get descriptionEncrypted => text().nullable()();
  TextColumn get notesEncrypted => text().nullable()();
  TextColumn get physicalLocationId => text().nullable().references(
    PhysicalLocations,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get status => text().withDefault(const Constant('active'))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  TextColumn get currentVersionId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

/// Lightweight lineage for document renewals. The document rows retain their
/// metadata and files; this table only records replacement relationships.
class DocumentVersions extends Table {
  TextColumn get id => text()();
  TextColumn get documentId =>
      text().references(Documents, #id, onDelete: KeyAction.cascade)();
  TextColumn get previousVersionId => text().nullable()();
  IntColumn get versionNumber => integer().withDefault(const Constant(1))();
  TextColumn get versionLabelEncrypted => text().nullable()();
  BoolColumn get isCurrent => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get supersededAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

/// The single, opt-in emergency collection. Documents are never automatically
/// included: every row represents an explicit user choice.
class EmergencyCollectionItems extends Table {
  TextColumn get documentId =>
      text().references(Documents, #id, onDelete: KeyAction.cascade)();
  IntColumn get sortOrder => integer()();
  DateTimeColumn get addedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {documentId};
}

/// Symmetric document relationships. The repository stores the lower document
/// ID first, preventing duplicate A→B and B→A links without persisting a
/// relationship label that could reveal sensitive content.
class DocumentLinks extends Table {
  @ReferenceName('documentLinkSource')
  TextColumn get sourceDocumentId =>
      text().references(Documents, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('documentLinkTarget')
  TextColumn get targetDocumentId =>
      text().references(Documents, #id, onDelete: KeyAction.cascade)();
  TextColumn get relationshipType => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {sourceDocumentId, targetDocumentId};
}

class DocumentOwners extends Table {
  TextColumn get documentId =>
      text().references(Documents, #id, onDelete: KeyAction.cascade)();
  TextColumn get familyMemberId => text().references(FamilyMembers, #id)();
  TextColumn get role => text().withDefault(const Constant('owner'))();
  @override
  Set<Column> get primaryKey => {documentId, familyMemberId};
}

class DocumentFiles extends Table {
  TextColumn get id => text()();
  TextColumn get documentId =>
      text().references(Documents, #id, onDelete: KeyAction.cascade)();
  TextColumn get fileType => text().withDefault(const Constant('original'))();
  TextColumn get mimeType => text()();
  TextColumn get encryptedRelativePath => text().unique()();
  TextColumn get originalFilenameEncrypted => text().nullable()();
  IntColumn get sizeBytes => integer()();
  TextColumn get integrityHash => text()();
  IntColumn get encryptionVersion => integer()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class DocumentPages extends Table {
  TextColumn get id => text()();
  TextColumn get documentId =>
      text().references(Documents, #id, onDelete: KeyAction.cascade)();
  TextColumn get documentFileId =>
      text().references(DocumentFiles, #id, onDelete: KeyAction.cascade)();
  IntColumn get pageNumber => integer()();
  TextColumn get encryptedPath => text().nullable()();
  TextColumn get thumbnailPath => text().nullable()();
  IntColumn get rotation => integer().withDefault(const Constant(0))();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [
    {documentId, pageNumber},
  ];
}

class DocumentFieldValues extends Table {
  TextColumn get id => text()();
  TextColumn get documentId =>
      text().references(Documents, #id, onDelete: KeyAction.cascade)();
  TextColumn get fieldKey => text()();
  TextColumn get labelEncrypted => text().nullable()();
  TextColumn get valueEncrypted => text()();
  TextColumn get valueType => text().withDefault(const Constant('text'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [
    {documentId, fieldKey},
  ];
}

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get nameEncrypted => text()();
  TextColumn get normalizedNameHash => text().unique()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class DocumentTags extends Table {
  TextColumn get documentId =>
      text().references(Documents, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();
  @override
  Set<Column> get primaryKey => {documentId, tagId};
}

class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get documentId =>
      text().references(Documents, #id, onDelete: KeyAction.cascade)();
  TextColumn get reminderType => text().withDefault(const Constant('expiry'))();
  DateTimeColumn get targetDate => dateTime()();
  IntColumn get offsetDays => integer().nullable()();
  DateTimeColumn get scheduledAt => dateTime()();
  TextColumn get status => text().withDefault(const Constant('scheduled'))();
  IntColumn get notificationId => integer().nullable()();
  DateTimeColumn get snoozedUntil => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class BackupRecords extends Table {
  TextColumn get id => text()();
  TextColumn get relativePath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get sizeBytes => integer()();
  BoolColumn get verified => boolean()();

  /// A coarse value such as `device_folder` or `system_provider`; never store
  /// a provider path, URI, account, or filename in local backup history.
  TextColumn get destinationType => text().nullable()();
  IntColumn get vaultChangesSinceBackup => integer().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

/// Contains only non-sensitive evidence that a protected export was handed to
/// the OS share flow. It deliberately omits document titles, numbers, paths,
/// recipient apps, recipients, watermark text, and redaction geometry.
class ShareAuditEvents extends Table {
  TextColumn get id => text()();
  TextColumn get documentId =>
      text().references(Documents, #id, onDelete: KeyAction.cascade)();
  TextColumn get eventType => text()();
  IntColumn get pageCount => integer()();
  TextColumn get exportFormat => text()();
  BoolColumn get hadWatermark => boolean()();
  BoolColumn get hadRedactions => boolean()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get valueEncrypted => text()();
  DateTimeColumn get updatedAt => dateTime()();
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
    PhysicalLocations,
    Documents,
    DocumentVersions,
    EmergencyCollectionItems,
    DocumentLinks,
    DocumentOwners,
    DocumentFiles,
    DocumentPages,
    DocumentFieldValues,
    Tags,
    DocumentTags,
    Reminders,
    BackupRecords,
    ShareAuditEvents,
    AppSettings,
    PendingOperations,
  ],
)
class VaultDatabase extends _$VaultDatabase {
  VaultDatabase(super.e);
  VaultDatabase.defaults() : super(driftDatabase(name: 'document_vault'));

  static const currentSchemaVersion = 6;
  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createIndexes();
    },
    onUpgrade: (m, from, to) => _upgrade(m, from: from, to: to),
    beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
  );

  Future<void> _upgrade(
    Migrator m, {
    required int from,
    required int to,
  }) async {
    if (from >= to) return;
    await transaction(() async {
      if (from < 2 && to >= 2) {
        await m.addColumn(physicalLocations, physicalLocations.isArchived);
      }
      if (from < 3 && to >= 3) {
        await m.createTable(documentVersions);
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_document_versions_document ON document_versions(document_id)',
        );
      }
      if (from < 4 && to >= 4) {
        await m.addColumn(backupRecords, backupRecords.destinationType);
        await m.addColumn(backupRecords, backupRecords.vaultChangesSinceBackup);
      }
      if (from < 5 && to >= 5) {
        await m.createTable(shareAuditEvents);
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_share_audit_document_created ON share_audit_events(document_id, created_at)',
        );
      }
      if (from < 6 && to >= 6) {
        // Databases older than v3 receive the current table definition in the
        // v3 create-table step above. Existing v3-v5 databases need additive
        // columns instead.
        if (from >= 3) {
          await m.addColumn(documentVersions, documentVersions.versionNumber);
          await m.addColumn(
            documentVersions,
            documentVersions.versionLabelEncrypted,
          );
          await m.addColumn(documentVersions, documentVersions.supersededAt);
        }
        await m.createTable(emergencyCollectionItems);
        await m.createTable(documentLinks);
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_emergency_collection_order ON emergency_collection_items(sort_order)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_document_links_target ON document_links(target_document_id)',
        );
      }
    });
  }

  Future<void> _createIndexes() async {
    for (final statement in _indexStatements) {
      await customStatement(statement);
    }
  }

  static const _indexStatements = <String>[
    'CREATE INDEX IF NOT EXISTS idx_documents_category ON documents(category_id)',
    'CREATE INDEX IF NOT EXISTS idx_documents_owner ON documents(primary_owner_id)',
    'CREATE INDEX IF NOT EXISTS idx_documents_expiry ON documents(expiry_date)',
    'CREATE INDEX IF NOT EXISTS idx_documents_created ON documents(created_at)',
    'CREATE INDEX IF NOT EXISTS idx_documents_updated ON documents(updated_at)',
    'CREATE INDEX IF NOT EXISTS idx_documents_favorite ON documents(is_favorite)',
    'CREATE INDEX IF NOT EXISTS idx_documents_archived ON documents(is_archived)',
    'CREATE INDEX IF NOT EXISTS idx_documents_trashed ON documents(deleted_at)',
    'CREATE INDEX IF NOT EXISTS idx_reminders_schedule ON reminders(scheduled_at)',
    'CREATE INDEX IF NOT EXISTS idx_reminders_status ON reminders(status)',
    'CREATE INDEX IF NOT EXISTS idx_document_owners_member ON document_owners(family_member_id)',
    'CREATE INDEX IF NOT EXISTS idx_document_tags_tag ON document_tags(tag_id)',
    'CREATE INDEX IF NOT EXISTS idx_document_versions_document ON document_versions(document_id)',
    'CREATE INDEX IF NOT EXISTS idx_emergency_collection_order ON emergency_collection_items(sort_order)',
    'CREATE INDEX IF NOT EXISTS idx_document_links_target ON document_links(target_document_id)',
    'CREATE INDEX IF NOT EXISTS idx_share_audit_document_created ON share_audit_events(document_id, created_at)',
  ];
}
