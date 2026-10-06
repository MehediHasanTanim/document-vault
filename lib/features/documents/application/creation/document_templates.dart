/// Category-specific fields are deliberately modeled separately from the UI.
/// This lets a future custom category editor use the same save pipeline.
enum DocumentFieldType { text, number, date }

class DocumentFieldTemplate {
  const DocumentFieldTemplate({
    required this.key,
    required this.label,
    required this.type,
    this.required = false,
    this.sensitive = false,
  });

  final String key;
  final String label;
  final DocumentFieldType type;
  final bool required;
  final bool sensitive;
}

class DocumentTemplate {
  const DocumentTemplate({required this.categoryCode, required this.fields});

  final String categoryCode;
  final List<DocumentFieldTemplate> fields;
}

/// Built-in, Bangladesh-relevant document templates. The persisted field keys
/// are stable identifiers; their user-facing translations may evolve safely.
class DocumentTemplateCatalog {
  const DocumentTemplateCatalog();

  static const passport = DocumentTemplate(
    categoryCode: 'identity.passport',
    fields: [
      DocumentFieldTemplate(
        key: 'passport_number',
        label: 'Passport number / পাসপোর্ট নম্বর',
        type: DocumentFieldType.number,
        required: true,
        sensitive: true,
      ),
      DocumentFieldTemplate(
        key: 'passport_issue_date',
        label: 'Issue date / ইস্যুর তারিখ',
        type: DocumentFieldType.date,
      ),
      DocumentFieldTemplate(
        key: 'passport_expiry_date',
        label: 'Expiry date / মেয়াদ শেষের তারিখ',
        type: DocumentFieldType.date,
      ),
      DocumentFieldTemplate(
        key: 'passport_authority',
        label: 'Issuing authority / ইস্যুকারী কর্তৃপক্ষ',
        type: DocumentFieldType.text,
      ),
    ],
  );

  static const warranty = DocumentTemplate(
    categoryCode: 'warranty_purchases',
    fields: [
      DocumentFieldTemplate(
        key: 'brand',
        label: 'Brand / ব্র্যান্ড',
        type: DocumentFieldType.text,
      ),
      DocumentFieldTemplate(
        key: 'model',
        label: 'Model / মডেল',
        type: DocumentFieldType.text,
      ),
      DocumentFieldTemplate(
        key: 'serial_number',
        label: 'Serial number / সিরিয়াল নম্বর',
        type: DocumentFieldType.number,
        sensitive: true,
      ),
      DocumentFieldTemplate(
        key: 'purchase_date',
        label: 'Purchase date / কেনার তারিখ',
        type: DocumentFieldType.date,
      ),
      DocumentFieldTemplate(
        key: 'warranty_end',
        label: 'Warranty end / ওয়ারেন্টি শেষ',
        type: DocumentFieldType.date,
      ),
    ],
  );

  DocumentTemplate? forCategory(String categoryCode) {
    if (categoryCode == passport.categoryCode) return passport;
    if (categoryCode == warranty.categoryCode ||
        categoryCode == 'warranty_purchases.warranty') {
      return warranty;
    }
    return null;
  }
}
