import 'package:drift/drift.dart';

import 'vault_database.dart';

/// Persistence interfaces keep feature code independent from SQL queries. The
/// companions are intentionally accepted only at this infrastructure boundary;
/// feature use-cases should construct them from validated domain input.
abstract interface class VaultRepository {
  Future<Vault?> get();
  Future<void> save(VaultsCompanion vault);
}

abstract interface class FamilyRepository {
  Stream<List<FamilyMember>> watchAll({bool includeArchived = false});
  Future<FamilyMember?> getById(String id);
  Future<void> save(FamilyMembersCompanion member);
  Future<void> archive(String id, {required DateTime updatedAt});
  Future<void> restore(String id, {required DateTime updatedAt});
  Future<int> documentCount(String id);
}

abstract interface class CategoryRepository {
  Stream<List<DocumentCategory>> watchAll();
  Future<void> save(DocumentCategoriesCompanion category);
  Future<void> delete(String id);
}

abstract interface class DocumentRepository {
  Future<Document?> getById(String id);
  Stream<List<Document>> watchAll({bool includeTrashed = false});
  Future<void> create(DocumentWrite write);
  Future<void> update(DocumentsCompanion document);
  Future<void> archive(
    String id, {
    required bool archived,
    required DateTime updatedAt,
  });
  Future<void> moveToTrash(String id, {required DateTime deletedAt});
  Future<void> restore(String id, {required DateTime updatedAt});
  Future<void> assignPhysicalLocation(
    String id, {
    required String? physicalLocationId,
    required DateTime updatedAt,
  });
  Future<void> attachImportedFiles(
    String documentId, {
    required List<DocumentFilesCompanion> files,
    required List<DocumentPagesCompanion> pages,
  });

  /// Deletes database records and returns file metadata for journalled storage
  /// cleanup. Callers must not delete encrypted files before this transaction.
  Future<List<DocumentFile>> deletePermanently(String id);
}

abstract interface class TagRepository {
  Stream<List<Tag>> watchAll();
  Future<Tag?> getById(String id);
  Future<Tag?> getByNormalizedNameHash(String normalizedNameHash);
  Future<void> save(TagsCompanion tag);
  Future<void> attach({required String documentId, required String tagId});
  Future<void> detach({required String documentId, required String tagId});
  Future<void> delete(String id);
}

abstract interface class PhysicalLocationRepository {
  Stream<List<PhysicalLocation>> watchAll({bool includeArchived = false});
  Future<PhysicalLocation?> getById(String id);
  Future<void> save(PhysicalLocationsCompanion location);
  Future<void> archive(
    String id, {
    required bool archived,
    required DateTime updatedAt,
  });
  Future<int> documentCount(String id);
}

abstract interface class ReminderRepository {
  Stream<List<Reminder>> watchScheduled();
  Future<void> save(RemindersCompanion reminder);
  Future<void> updateStatus(String id, String status, DateTime updatedAt);
  Future<void> delete(String id);
}

abstract interface class SettingsRepository {
  Future<String?> read(String key);
  Stream<String?> watch(String key);
  Future<void> write(String key, String encryptedValue, DateTime updatedAt);
  Future<void> delete(String key);
}

/// All metadata which must either be written together or not at all.
class DocumentWrite {
  const DocumentWrite({
    required this.document,
    this.owners = const [],
    this.files = const [],
    this.pages = const [],
    this.fields = const [],
    this.tagLinks = const [],
    this.reminders = const [],
  });

  final DocumentsCompanion document;
  final List<DocumentOwnersCompanion> owners;
  final List<DocumentFilesCompanion> files;
  final List<DocumentPagesCompanion> pages;
  final List<DocumentFieldValuesCompanion> fields;
  final List<DocumentTagsCompanion> tagLinks;
  final List<RemindersCompanion> reminders;
}

class DriftVaultRepository implements VaultRepository {
  DriftVaultRepository(this._db);
  final VaultDatabase _db;

  @override
  Future<Vault?> get() => (_db.select(_db.vaults)..limit(1)).getSingleOrNull();

  @override
  Future<void> save(VaultsCompanion vault) =>
      _db.into(_db.vaults).insertOnConflictUpdate(vault);
}

class DriftFamilyRepository implements FamilyRepository {
  DriftFamilyRepository(this._db);
  final VaultDatabase _db;

  @override
  Stream<List<FamilyMember>> watchAll({bool includeArchived = false}) {
    final query = _db.select(_db.familyMembers)
      ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]);
    if (!includeArchived) query.where((m) => m.isArchived.equals(false));
    return query.watch();
  }

  @override
  Future<FamilyMember?> getById(String id) => (_db.select(
    _db.familyMembers,
  )..where((m) => m.id.equals(id))).getSingleOrNull();

  @override
  Future<void> save(FamilyMembersCompanion member) =>
      _db.into(_db.familyMembers).insertOnConflictUpdate(member);

  @override
  Future<void> archive(String id, {required DateTime updatedAt}) =>
      (_db.update(_db.familyMembers)..where((m) => m.id.equals(id))).write(
        FamilyMembersCompanion(
          isArchived: const Value(true),
          updatedAt: Value(updatedAt),
        ),
      );

  @override
  Future<void> restore(String id, {required DateTime updatedAt}) =>
      (_db.update(_db.familyMembers)..where((m) => m.id.equals(id))).write(
        FamilyMembersCompanion(
          isArchived: const Value(false),
          updatedAt: Value(updatedAt),
        ),
      );

  @override
  Future<int> documentCount(String id) async {
    final count = _db.documentOwners.documentId.count();
    final query = _db.selectOnly(_db.documentOwners)
      ..addColumns([count])
      ..where(_db.documentOwners.familyMemberId.equals(id));
    return (await query.map((row) => row.read(count) ?? 0).getSingle());
  }
}

class DriftCategoryRepository implements CategoryRepository {
  DriftCategoryRepository(this._db);
  final VaultDatabase _db;

  @override
  Stream<List<DocumentCategory>> watchAll() =>
      (_db.select(_db.documentCategories)..orderBy([
            (c) => OrderingTerm.asc(c.sortOrder),
            (c) => OrderingTerm.asc(c.code),
          ]))
          .watch();

  @override
  Future<void> save(DocumentCategoriesCompanion category) =>
      _db.into(_db.documentCategories).insertOnConflictUpdate(category);

  @override
  Future<void> delete(String id) =>
      (_db.delete(_db.documentCategories)..where((c) => c.id.equals(id))).go();
}

class DriftPhysicalLocationRepository implements PhysicalLocationRepository {
  DriftPhysicalLocationRepository(this._db);
  final VaultDatabase _db;

  @override
  Stream<List<PhysicalLocation>> watchAll({bool includeArchived = false}) {
    final query = _db.select(_db.physicalLocations)
      ..orderBy([(location) => OrderingTerm.asc(location.createdAt)]);
    if (!includeArchived) {
      query.where((location) => location.isArchived.equals(false));
    }
    return query.watch();
  }

  @override
  Future<PhysicalLocation?> getById(String id) => (_db.select(
    _db.physicalLocations,
  )..where((location) => location.id.equals(id))).getSingleOrNull();

  @override
  Future<void> save(PhysicalLocationsCompanion location) =>
      _db.into(_db.physicalLocations).insertOnConflictUpdate(location);

  @override
  Future<void> archive(
    String id, {
    required bool archived,
    required DateTime updatedAt,
  }) =>
      (_db.update(
        _db.physicalLocations,
      )..where((location) => location.id.equals(id))).write(
        PhysicalLocationsCompanion(
          isArchived: Value(archived),
          updatedAt: Value(updatedAt),
        ),
      );

  @override
  Future<int> documentCount(String id) async {
    final count = _db.documents.id.count();
    final query = _db.selectOnly(_db.documents)
      ..addColumns([count])
      ..where(_db.documents.physicalLocationId.equals(id));
    return (await query.map((row) => row.read(count) ?? 0).getSingle());
  }
}

class DriftDocumentRepository implements DocumentRepository {
  DriftDocumentRepository(this._db);
  final VaultDatabase _db;

  @override
  Future<Document?> getById(String id) => (_db.select(
    _db.documents,
  )..where((d) => d.id.equals(id))).getSingleOrNull();

  @override
  Stream<List<Document>> watchAll({bool includeTrashed = false}) {
    final query = _db.select(_db.documents)
      ..orderBy([(d) => OrderingTerm.desc(d.updatedAt)]);
    if (!includeTrashed) query.where((d) => d.deletedAt.isNull());
    return query.watch();
  }

  @override
  Future<void> create(DocumentWrite write) => _db.transaction(() async {
    await _db.into(_db.documents).insert(write.document);
    await _insertAll(_db.documentOwners, write.owners);
    await _insertAll(_db.documentFiles, write.files);
    await _insertAll(_db.documentPages, write.pages);
    await _insertAll(_db.documentFieldValues, write.fields);
    await _insertAll(_db.documentTags, write.tagLinks);
    await _insertAll(_db.reminders, write.reminders);
  });

  Future<void> _insertAll<T extends Table, D extends DataClass>(
    TableInfo<T, D> table,
    List<Insertable<D>> rows,
  ) async {
    if (rows.isEmpty) return;
    await _db.batch((batch) => batch.insertAll(table, rows));
  }

  @override
  Future<void> update(DocumentsCompanion document) =>
      _db.update(_db.documents).replace(document);

  @override
  Future<void> archive(
    String id, {
    required bool archived,
    required DateTime updatedAt,
  }) => (_db.update(_db.documents)..where((d) => d.id.equals(id))).write(
    DocumentsCompanion(
      isArchived: Value(archived),
      updatedAt: Value(updatedAt),
    ),
  );

  @override
  Future<void> moveToTrash(String id, {required DateTime deletedAt}) =>
      (_db.update(_db.documents)..where((d) => d.id.equals(id))).write(
        DocumentsCompanion(
          deletedAt: Value(deletedAt),
          status: const Value('trashed'),
          updatedAt: Value(deletedAt),
        ),
      );

  @override
  Future<void> restore(String id, {required DateTime updatedAt}) =>
      (_db.update(_db.documents)..where((d) => d.id.equals(id))).write(
        DocumentsCompanion(
          deletedAt: const Value(null),
          status: const Value('active'),
          updatedAt: Value(updatedAt),
        ),
      );

  @override
  Future<void> assignPhysicalLocation(
    String id, {
    required String? physicalLocationId,
    required DateTime updatedAt,
  }) => (_db.update(_db.documents)..where((document) => document.id.equals(id)))
      .write(
        DocumentsCompanion(
          physicalLocationId: Value(physicalLocationId),
          updatedAt: Value(updatedAt),
        ),
      );

  @override
  Future<void> attachImportedFiles(
    String documentId, {
    required List<DocumentFilesCompanion> files,
    required List<DocumentPagesCompanion> pages,
  }) => _db.transaction(() async {
    final exists = await getById(documentId);
    if (exists == null) {
      throw StateError('Document must exist before attaching imported files.');
    }
    await _insertAll(_db.documentFiles, files);
    await _insertAll(_db.documentPages, pages);
  });

  @override
  Future<List<DocumentFile>> deletePermanently(String id) =>
      _db.transaction(() async {
        final files = await (_db.select(
          _db.documentFiles,
        )..where((f) => f.documentId.equals(id))).get();
        await (_db.delete(_db.documents)..where((d) => d.id.equals(id))).go();
        return files;
      });
}

class DriftTagRepository implements TagRepository {
  DriftTagRepository(this._db);
  final VaultDatabase _db;

  @override
  Stream<List<Tag>> watchAll() => (_db.select(
    _db.tags,
  )..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).watch();

  @override
  Future<Tag?> getById(String id) => (_db.select(
    _db.tags,
  )..where((tag) => tag.id.equals(id))).getSingleOrNull();

  @override
  Future<Tag?> getByNormalizedNameHash(String normalizedNameHash) =>
      (_db.select(_db.tags)
            ..where((tag) => tag.normalizedNameHash.equals(normalizedNameHash)))
          .getSingleOrNull();

  @override
  Future<void> save(TagsCompanion tag) =>
      _db.into(_db.tags).insertOnConflictUpdate(tag);

  @override
  Future<void> attach({required String documentId, required String tagId}) =>
      _db
          .into(_db.documentTags)
          .insert(
            DocumentTagsCompanion.insert(documentId: documentId, tagId: tagId),
          );

  @override
  Future<void> detach({required String documentId, required String tagId}) =>
      (_db.delete(_db.documentTags)..where(
            (link) =>
                link.documentId.equals(documentId) & link.tagId.equals(tagId),
          ))
          .go();

  @override
  Future<void> delete(String id) =>
      (_db.delete(_db.tags)..where((t) => t.id.equals(id))).go();
}

class DriftReminderRepository implements ReminderRepository {
  DriftReminderRepository(this._db);
  final VaultDatabase _db;

  @override
  Stream<List<Reminder>> watchScheduled() =>
      (_db.select(_db.reminders)
            ..where((r) => r.status.equals('scheduled'))
            ..orderBy([(r) => OrderingTerm.asc(r.scheduledAt)]))
          .watch();

  @override
  Future<void> save(RemindersCompanion reminder) =>
      _db.into(_db.reminders).insertOnConflictUpdate(reminder);

  @override
  Future<void> updateStatus(String id, String status, DateTime updatedAt) =>
      (_db.update(_db.reminders)..where((r) => r.id.equals(id))).write(
        RemindersCompanion(status: Value(status), updatedAt: Value(updatedAt)),
      );

  @override
  Future<void> delete(String id) =>
      (_db.delete(_db.reminders)..where((r) => r.id.equals(id))).go();
}

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._db);
  final VaultDatabase _db;

  @override
  Future<String?> read(String key) =>
      (_db.select(_db.appSettings)..where((s) => s.key.equals(key)))
          .map((s) => s.valueEncrypted)
          .getSingleOrNull();

  @override
  Stream<String?> watch(String key) =>
      (_db.select(_db.appSettings)..where((s) => s.key.equals(key)))
          .watchSingleOrNull()
          .map((s) => s?.valueEncrypted);

  @override
  Future<void> write(String key, String encryptedValue, DateTime updatedAt) =>
      _db
          .into(_db.appSettings)
          .insertOnConflictUpdate(
            AppSettingsCompanion.insert(
              key: key,
              valueEncrypted: encryptedValue,
              updatedAt: updatedAt,
            ),
          );

  @override
  Future<void> delete(String key) =>
      (_db.delete(_db.appSettings)..where((s) => s.key.equals(key))).go();
}
