import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:documentvault/core/crypto/vault_data_protector.dart';
import 'package:documentvault/core/database/repositories.dart';
import 'package:documentvault/core/database/vault_database.dart';
import 'package:documentvault/core/errors/app_failure.dart';
import 'package:documentvault/core/files/encrypted_file_store.dart';
import 'package:documentvault/core/files/file_operation_journal.dart';
import 'package:documentvault/features/documents/application/creation/document_creation_models.dart';
import 'package:documentvault/features/documents/application/creation/document_creation_service.dart';
import 'package:documentvault/features/documents/application/creation/document_selection.dart';
import 'package:documentvault/features/documents/application/creation/document_templates.dart';
import 'package:documentvault/features/documents/application/ingestion/import_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;

import '../support/database_test_harness.dart';

void main() {
  late Directory root;
  late VaultDatabase database;
  late EncryptedFileStore files;
  late AesGcmVaultDataProtector protector;
  late DocumentCreationService service;
  final now = DateTime.utc(2026, 10, 6);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('document-vault-create-');
    database = openTestDatabase();
    final key = SecretKey(List<int>.filled(32, 31));
    files = EncryptedFileStore(key, supportDirectory: () async => root);
    protector = AesGcmVaultDataProtector(key);
    service = _service(database, files, protector, key, now);
    await database
        .into(database.documentCategories)
        .insert(
          DocumentCategoriesCompanion.insert(
            id: 'passport-category',
            code: 'identity.passport',
            createdAt: now,
            updatedAt: now,
          ),
        );
    for (final id in ['member-1', 'member-2']) {
      await database
          .into(database.familyMembers)
          .insert(
            FamilyMembersCompanion.insert(
              id: id,
              displayNameEncrypted: 'encrypted-$id',
              relationship: 'Family',
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
    await database
        .into(database.tags)
        .insert(
          TagsCompanion.insert(
            id: 'tag-1',
            nameEncrypted: 'encrypted',
            normalizedNameHash: 'hash-1',
            createdAt: now,
          ),
        );
  });

  tearDown(() async {
    await database.close();
    await root.delete(recursive: true);
  });

  test('creates an encrypted multi-owner document with files, tags and dynamic fields', () async {
    final result = await service.save(
      DocumentDraft(
        title: 'Amina passport',
        categoryId: 'passport-category',
        categoryCode: 'identity.passport',
        owners: DocumentOwnerSelection.members(['member-1', 'member-2']),
        documentNumber: 'AB0123456',
        issueDate: DateTime(2020, 1, 1),
        expiryDate: DateTime(2030, 1, 1),
        issuingAuthority: 'Department of Immigration',
        notes: 'Renew before travel.',
        tagIds: const ['tag-1'],
        pages: [await _stagedJpeg(root)],
        fields: const [
          DynamicFieldInput(
            key: 'passport_number',
            label: 'Passport number / পাসপোর্ট নম্বর',
            value: 'AB0123456',
            type: DocumentFieldType.number,
          ),
          DynamicFieldInput(
            key: 'passport_authority',
            label: 'Issuing authority / ইস্যুকারী কর্তৃপক্ষ',
            value: 'Department of Immigration',
            type: DocumentFieldType.text,
          ),
        ],
      ),
    );

    final stored = await DriftDocumentRepository(database)
        .getById(result.documentId);
    expect(stored!.titleEncrypted, isNot(contains('Amina passport')));
    expect(
      await protector.decrypt(
        stored.titleEncrypted,
        context: 'document:${stored.id}:title',
      ),
      'Amina passport',
    );
    expect(stored.ownershipType, 'multiple');
    expect(
      await (database.select(
        database.documentOwners,
      )..where((row) => row.documentId.equals(result.documentId))).get(),
      hasLength(2),
    );
    expect(await database.select(database.documentFiles).get(), hasLength(1));
    expect(await database.select(database.documentPages).get(), hasLength(1));
    expect(
      await database.select(database.documentFieldValues).get(),
      hasLength(2),
    );
    expect(await database.select(database.documentTags).get(), hasLength(1));
    expect(
      (await database.select(database.pendingOperations).getSingle()).state,
      'completed',
    );
  });

  test(
    'requires title, an owner or household, and valid date relationships',
    () async {
      final valid = _draft();
      await expectLater(
        service.save(
          DocumentDraft(
            title: '',
            categoryId: valid.categoryId,
            categoryCode: valid.categoryCode,
            owners: valid.owners,
          ),
        ),
        throwsA(isA<ValidationFailure>()),
      );
      await expectLater(
        service.save(
          DocumentDraft(
            title: valid.title,
            categoryId: valid.categoryId,
            categoryCode: valid.categoryCode,
            owners: DocumentOwnerSelection.members([]),
          ),
        ),
        throwsA(isA<ValidationFailure>()),
      );
      await expectLater(
        service.save(
          DocumentDraft(
            title: valid.title,
            categoryId: valid.categoryId,
            categoryCode: valid.categoryCode,
            owners: valid.owners,
            issueDate: DateTime(2030, 1, 2),
            expiryDate: DateTime(2030, 1, 1),
          ),
        ),
        throwsA(isA<ValidationFailure>()),
      );
    },
  );

  test('supports household ownership and duplicate warning hooks without blocking save', () async {
    final hooked = _service(
      database,
      files,
      protector,
      SecretKey(List<int>.filled(32, 31)),
      now,
      duplicateWarnings: const _WarningHook(),
    );
    final result = await hooked.save(
      DocumentDraft(
        title: 'House deed',
        categoryId: 'passport-category',
        categoryCode: 'identity.passport',
        owners: const DocumentOwnerSelection.household(),
        fields: const [
          DynamicFieldInput(
            key: 'passport_number',
            label: 'Passport number',
            value: 'x',
            type: DocumentFieldType.number,
          ),
        ],
      ),
    );
    expect(result.duplicateWarnings, hasLength(1));
    expect(
      (await DriftDocumentRepository(database).getById(result.documentId))!
          .ownershipType,
      'household',
    );
  });

  test('removes encrypted output when database commit fails', () async {
    final result = service.save(
      DocumentDraft(
        title: 'Cannot save',
        categoryId: 'missing-category',
        categoryCode: 'other',
        owners: const DocumentOwnerSelection.household(),
        pages: [await _stagedJpeg(root)],
      ),
    );
    await expectLater(result, throwsA(isA<StorageFailure>()));
    final encryptedFiles = <File>[];
    await for (final entity in (await files.documentsDirectory).list(
      recursive: true,
    )) {
      if (entity is File && entity.path.endsWith('.dvf')) {
        encryptedFiles.add(entity);
      }
    }
    expect(encryptedFiles, isEmpty);
    expect(
      (await database.select(database.pendingOperations).getSingle()).state,
      'failed',
    );
  });

  test(
    'surfaces metadata encryption failure before any database write',
    () async {
      final failing = _service(
        database,
        files,
        const _FailingProtector(),
        SecretKey(List<int>.filled(32, 31)),
        now,
      );
      await expectLater(failing.save(_draft()), throwsA(isA<StorageFailure>()));
      expect(await database.select(database.documents).get(), isEmpty);
    },
  );

  test(
    'searches locally and retains a bounded encrypted recent-category list',
    () async {
      expect(
        searchOwners(const [
          OwnerSearchEntry(id: '1', name: 'Amina', relationship: 'Spouse'),
          OwnerSearchEntry(id: '2', name: 'Rafi', relationship: 'Child'),
        ], 'spouse').single.id,
        '1',
      );
      expect(
        searchCategories(const [
          CategorySearchEntry(
            id: 'passport',
            code: 'identity.passport',
            label: 'Passport / পাসপোর্ট',
          ),
        ], 'পাসপোর্ট').single.id,
        'passport',
      );
      final recent = RecentCategoryService(
        _MemorySettings(),
        protector,
        clock: () => now,
      );
      for (final id in ['one', 'two', 'three', 'four', 'five', 'six']) {
        await recent.record(id);
      }
      expect(await recent.read(), ['six', 'five', 'four', 'three', 'two']);
    },
  );
}

DocumentCreationService _service(
  VaultDatabase database,
  EncryptedFileStore files,
  VaultDataProtector protector,
  SecretKey key,
  DateTime now, {
  DuplicateWarningHook? duplicateWarnings,
}) => DocumentCreationService(
  DriftDocumentRepository(database),
  files,
  FileOperationJournal(
    database,
    files,
    AesGcmOperationPayloadCodec(key),
    clock: () => now,
  ),
  protector,
  duplicateWarnings: duplicateWarnings,
  clock: () => now,
);

DocumentDraft _draft() => DocumentDraft(
  title: 'Passport',
  categoryId: 'passport-category',
  categoryCode: 'identity.passport',
  owners: DocumentOwnerSelection.members(['member-1']),
  fields: const [
    DynamicFieldInput(
      key: 'passport_number',
      label: 'Passport number',
      value: 'AB1',
      type: DocumentFieldType.number,
    ),
  ],
);

Future<StagedImportFile> _stagedJpeg(Directory root) async {
  final file = File(
    '${root.path}/source-${DateTime.now().microsecondsSinceEpoch}.jpg',
  );
  await file.writeAsBytes(image.encodeJpg(image.Image(width: 2, height: 2)));
  return StagedImportFile(
    file: file,
    source: ImportSource.photos,
    mimeType: 'image/jpeg',
    sizeBytes: await file.length(),
  );
}

class _WarningHook implements DuplicateWarningHook {
  const _WarningHook();
  @override
  Future<List<DuplicateWarning>> check(DocumentDraft draft) async => const [
    DuplicateWarning(message: 'Possible duplicate / সম্ভাব্য অনুলিপি'),
  ];
}

class _FailingProtector implements VaultDataProtector {
  const _FailingProtector();
  @override
  Future<String> decrypt(String ciphertext, {required String context}) =>
      throw const StorageFailure('No decrypt');
  @override
  Future<String> encrypt(String plaintext, {required String context}) =>
      throw const StorageFailure('Encryption failed');
  @override
  Future<String> normalizedNameHash(String value, {required String context}) =>
      throw const StorageFailure('No hash');
}

class _MemorySettings implements SettingsRepository {
  final values = <String, String>{};
  @override
  Future<void> delete(String key) async => values.remove(key);
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Stream<String?> watch(String key) => Stream.value(values[key]);
  @override
  Future<void> write(
    String key,
    String encryptedValue,
    DateTime updatedAt,
  ) async {
    values[key] = encryptedValue;
  }
}
