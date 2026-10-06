import 'package:drift/drift.dart' as drift;

import '../../../core/database/repositories.dart';
import '../../../core/database/vault_database.dart';

class SystemCategorySeed {
  const SystemCategorySeed({
    required this.code,
    required this.nameKey,
    this.parentCode,
  });
  final String code;
  final String nameKey;
  final String? parentCode;
}

/// Idempotent Bangladesh-first category seed. Codes are stable public
/// identifiers; IDs are deterministic UUIDs so imports/restores can refer to
/// the same system categories without using visible names.
class SystemCategorySeeder {
  SystemCategorySeeder(this._repository, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;
  final CategoryRepository _repository;
  final DateTime Function() _clock;

  Future<void> seed() async {
    final now = _clock().toUtc();
    final ids = {
      for (var i = 0; i < categories.length; i++)
        categories[i].code: _idFor(i + 1),
    };
    for (var index = 0; index < categories.length; index++) {
      final category = categories[index];
      await _repository.save(
        DocumentCategoriesCompanion.insert(
          id: ids[category.code]!,
          code: category.code,
          parentId: category.parentCode == null
              ? const drift.Value.absent()
              : drift.Value(ids[category.parentCode]),
          nameKey: drift.Value(category.nameKey),
          isSystem: const drift.Value(true),
          sortOrder: drift.Value(index),
          iconKey: drift.Value(_iconFor(category.code)),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }

  static const categories = <SystemCategorySeed>[
    SystemCategorySeed(code: 'identity', nameKey: 'categoryIdentity'),
    SystemCategorySeed(
      code: 'identity.nid',
      nameKey: 'categoryNid',
      parentCode: 'identity',
    ),
    SystemCategorySeed(
      code: 'identity.birth_certificate',
      nameKey: 'categoryBirthCertificate',
      parentCode: 'identity',
    ),
    SystemCategorySeed(
      code: 'identity.passport',
      nameKey: 'categoryPassport',
      parentCode: 'identity',
    ),
    SystemCategorySeed(code: 'tax_financial', nameKey: 'categoryTaxFinancial'),
    SystemCategorySeed(
      code: 'tax_financial.tin',
      nameKey: 'categoryTin',
      parentCode: 'tax_financial',
    ),
    SystemCategorySeed(
      code: 'tax_financial.bank',
      nameKey: 'categoryBank',
      parentCode: 'tax_financial',
    ),
    SystemCategorySeed(code: 'education', nameKey: 'categoryEducation'),
    SystemCategorySeed(
      code: 'education.certificate',
      nameKey: 'categoryCertificate',
      parentCode: 'education',
    ),
    SystemCategorySeed(code: 'land_property', nameKey: 'categoryLandProperty'),
    SystemCategorySeed(
      code: 'land_property.khatian',
      nameKey: 'categoryKhatian',
      parentCode: 'land_property',
    ),
    SystemCategorySeed(
      code: 'land_property.mutation',
      nameKey: 'categoryMutation',
      parentCode: 'land_property',
    ),
    SystemCategorySeed(code: 'vehicle', nameKey: 'categoryVehicle'),
    SystemCategorySeed(
      code: 'vehicle.registration',
      nameKey: 'categoryVehicleRegistration',
      parentCode: 'vehicle',
    ),
    SystemCategorySeed(code: 'medical', nameKey: 'categoryMedical'),
    SystemCategorySeed(
      code: 'medical.prescription',
      nameKey: 'categoryPrescription',
      parentCode: 'medical',
    ),
    SystemCategorySeed(
      code: 'marriage_family',
      nameKey: 'categoryMarriageFamily',
    ),
    SystemCategorySeed(
      code: 'marriage_family.nikahnama',
      nameKey: 'categoryNikahnama',
      parentCode: 'marriage_family',
    ),
    SystemCategorySeed(code: 'employment', nameKey: 'categoryEmployment'),
    SystemCategorySeed(
      code: 'employment.appointment',
      nameKey: 'categoryAppointmentLetter',
      parentCode: 'employment',
    ),
    SystemCategorySeed(code: 'business', nameKey: 'categoryBusiness'),
    SystemCategorySeed(
      code: 'business.trade_licence',
      nameKey: 'categoryTradeLicence',
      parentCode: 'business',
    ),
    SystemCategorySeed(
      code: 'school_children',
      nameKey: 'categorySchoolChildren',
    ),
    SystemCategorySeed(
      code: 'school_children.admission',
      nameKey: 'categorySchoolAdmission',
      parentCode: 'school_children',
    ),
    SystemCategorySeed(code: 'travel', nameKey: 'categoryTravel'),
    SystemCategorySeed(
      code: 'travel.visa',
      nameKey: 'categoryVisa',
      parentCode: 'travel',
    ),
    SystemCategorySeed(
      code: 'warranty_purchases',
      nameKey: 'categoryWarrantyPurchases',
    ),
    SystemCategorySeed(
      code: 'warranty_purchases.receipt',
      nameKey: 'categoryPurchaseReceipt',
      parentCode: 'warranty_purchases',
    ),
    SystemCategorySeed(code: 'legal', nameKey: 'categoryLegal'),
    SystemCategorySeed(
      code: 'legal.affidavit',
      nameKey: 'categoryAffidavit',
      parentCode: 'legal',
    ),
    SystemCategorySeed(code: 'other', nameKey: 'categoryOther'),
  ];

  static String _idFor(int value) =>
      '00000000-0000-5000-8000-${value.toString().padLeft(12, '0')}';
  static String _iconFor(String code) => code.split('.').first;
}
