import 'package:cryptography/cryptography.dart';
import 'package:documentvault/core/crypto/vault_data_protector.dart';
import 'package:documentvault/core/database/repositories.dart';
import 'package:documentvault/core/database/vault_database.dart';
import 'package:documentvault/core/errors/app_failure.dart';
import 'package:documentvault/core/uuid/uuid_generator.dart';
import 'package:documentvault/features/categories/application/system_category_seeder.dart';
import 'package:documentvault/features/family/application/family_member_service.dart';
import 'package:documentvault/features/locations/application/physical_location_service.dart';
import 'package:documentvault/features/tags/application/tag_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/database_test_harness.dart';

void main() {
  late VaultDatabase database;
  late AesGcmVaultDataProtector protector;
  late FamilyMemberService family;
  late TagService tags;
  late PhysicalLocationService locations;
  final now = DateTime.utc(2026, 10, 6);

  setUp(() {
    database = openTestDatabase();
    protector = AesGcmVaultDataProtector(SecretKey(List<int>.filled(32, 42)));
    final ids = _FixedUuid();
    family = FamilyMemberService(
      DriftFamilyRepository(database),
      protector,
      ids,
      clock: () => now,
    );
    tags = TagService(
      DriftTagRepository(database),
      protector,
      ids,
      clock: () => now,
    );
    locations = PhysicalLocationService(
      DriftPhysicalLocationRepository(database),
      DriftDocumentRepository(database),
      protector,
      ids,
      clock: () => now,
    );
  });
  tearDown(() => database.close());

  test(
    'family member CRUD encrypts private fields and validates dates',
    () async {
      final id = await family.create(
        FamilyMemberInput(
          name: 'Amina Rahman',
          nickname: 'Ami',
          relationship: 'Spouse',
          notes: 'Keep emergency contacts updated.',
          dateOfBirth: DateTime(1990, 4, 12),
          bloodGroup: 'B+',
        ),
      );
      final stored = await DriftFamilyRepository(database).getById(id);
      expect(stored!.displayNameEncrypted, isNot(contains('Amina')));
      expect((await family.getDetails(id))!.name, 'Amina Rahman');

      await family.update(
        id,
        const FamilyMemberInput(name: 'Amina Rahman', relationship: 'Spouse'),
      );
      expect((await family.getDetails(id))!.nickname, isNull);
      await expectLater(
        family.create(
          FamilyMemberInput(
            name: 'Future child',
            relationship: 'Child',
            dateOfBirth: now.add(const Duration(days: 1)),
          ),
        ),
        throwsA(isA<ValidationFailure>()),
      );
    },
  );

  test(
    'system categories seed idempotently with Bangladesh-first subcategories',
    () async {
      final seeder = SystemCategorySeeder(
        DriftCategoryRepository(database),
        clock: () => now,
      );
      await seeder.seed();
      await seeder.seed();
      final categories = await DriftCategoryRepository(database)
          .watchAll()
          .first;
      expect(categories, hasLength(SystemCategorySeeder.categories.length));
      expect(
        categories.any((category) => category.code == 'land_property.khatian'),
        isTrue,
      );
      expect(
        categories.any((category) => category.code == 'identity.nid'),
        isTrue,
      );
    },
  );

  test('tag names are unique after normalizing whitespace and case', () async {
    final id = await tags.create('Important');
    expect((await tags.getDetails(id))!.name, 'Important');
    await expectLater(
      tags.create('  important  '),
      throwsA(isA<ValidationFailure>()),
    );
    await tags.rename(id, 'Emergency');
    expect((await tags.getDetails(id))!.name, 'Emergency');
  });

  test(
    'household is a virtual owner and archived members retain their documents',
    () async {
      expect(HouseholdOwnership.id, 'household');
      expect(HouseholdOwnership.ownershipType, 'household');
      final memberId = await family.create(
        const FamilyMemberInput(name: 'Rahim', relationship: 'Self'),
      );
      await DriftCategoryRepository(database).save(
        DocumentCategoriesCompanion.insert(
          id: 'category-1',
          code: 'other',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await DriftDocumentRepository(database).create(
        DocumentWrite(
          document: DocumentsCompanion.insert(
            id: 'document-1',
            titleEncrypted: 'encrypted',
            categoryId: 'category-1',
            createdAt: now,
            updatedAt: now,
          ),
          owners: [
            DocumentOwnersCompanion.insert(
              documentId: 'document-1',
              familyMemberId: memberId,
            ),
          ],
        ),
      );

      await family.archive(memberId);
      expect((await family.getDetails(memberId))!.member.isArchived, isTrue);
      expect(
        (await family.permanentDeletionPlan(memberId)).requiresReassignment,
        isTrue,
      );
      expect(
        await DriftDocumentRepository(database).getById('document-1'),
        isNotNull,
      );
      await family.restore(memberId);
      expect((await family.getDetails(memberId))!.member.isArchived, isFalse);
    },
  );

  test('locations can be updated, archived and assigned without storing their name in plaintext', () async {
    await DriftCategoryRepository(database).save(
      DocumentCategoriesCompanion.insert(
        id: 'category-location',
        code: 'location-other',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await DriftDocumentRepository(database).create(
      DocumentWrite(
        document: DocumentsCompanion.insert(
          id: 'document-location',
          titleEncrypted: 'encrypted',
          categoryId: 'category-location',
          createdAt: now,
          updatedAt: now,
        ),
      ),
    );
    final locationId = await locations.create(
      const PhysicalLocationInput(name: 'Bedroom locker', notes: 'Top shelf'),
    );
    final stored = await DriftPhysicalLocationRepository(database)
        .getById(locationId);
    expect(stored!.nameEncrypted, isNot(contains('Bedroom')));
    expect((await locations.getDetails(locationId))!.name, 'Bedroom locker');
    await locations.assignToDocument(
      documentId: 'document-location',
      locationId: locationId,
    );
    expect(
      (await DriftDocumentRepository(database).getById('document-location'))!
          .physicalLocationId,
      locationId,
    );
    await locations.archive(locationId);
    expect(
      (await DriftPhysicalLocationRepository(database).getById(locationId))!
          .isArchived,
      isTrue,
    );
  });
}

class _FixedUuid implements UuidGenerator {
  var _next = 1;
  @override
  String v4() =>
      '00000000-0000-4000-8000-${(_next++).toString().padLeft(12, '0')}';
}
