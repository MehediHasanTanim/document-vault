import '../creation/document_selection.dart';
import '../search/secure_search_index.dart';
import 'smart_metadata_models.dart';

/// Deterministic local hints from user-provided OCR text. No model, network,
/// or persistence is involved. Suggestions are never applied automatically.
class SmartMetadataSuggester {
  const SmartMetadataSuggester();

  SmartMetadataSuggestions suggest({
    required String recognizedText,
    required Iterable<CategorySearchEntry> categories,
  }) {
    final searchable = SecureSearchIndex.normalize(recognizedText);
    // Keep date separators while normalizing Bangla numerals for extraction.
    // Search normalization intentionally removes punctuation, which would make
    // otherwise valid OCR dates impossible to parse.
    final extractionText = _normalizeForExtraction(recognizedText);
    final category = _category(searchable, categories);
    return SmartMetadataSuggestions(
      category: category,
      title: category == null
          ? null
          : SmartSuggestion(
              field: SmartMetadataField.title,
              value: _titleFor(category.value.code),
              confidence: category.confidence * .75,
              reason: 'Based on the detected document type / শনাক্ত করা নথির ধরন অনুযায়ী',
            ),
      documentNumber: _documentNumber(extractionText),
      issueDate: _labelledDate(extractionText, const [
        'issue',
        'issued',
        'ইস্যু',
      ], SmartMetadataField.issueDate),
      expiryDate: _labelledDate(extractionText, const [
        'expiry',
        'expires',
        'valid until',
        'মেয়াদ',
      ], SmartMetadataField.expiryDate),
    );
  }

  SmartSuggestion<CategorySearchEntry>? _category(
    String text,
    Iterable<CategorySearchEntry> categories,
  ) {
    const rules = <_CategoryRule>[
      _CategoryRule('identity.passport', ['passport', 'পাসপোর্ট']),
      _CategoryRule('identity.nid', ['national id', 'nid', 'জাতীয় পরিচয়']),
      _CategoryRule('tax_financial.tin', ['tin', 'টিন']),
      _CategoryRule('land_property.khatian', ['khatian', 'খতিয়ান']),
      _CategoryRule('land_property.mutation', ['mutation', 'নামজারি']),
      _CategoryRule('travel.visa', ['visa', 'ভিসা']),
      _CategoryRule('warranty_purchases', ['warranty', 'ওয়ারেন্টি']),
      _CategoryRule('vehicle.registration', [
        'vehicle registration',
        'গাড়ি নিবন্ধন',
      ]),
    ];
    for (final rule in rules) {
      if (!rule.keywords.any(text.contains)) continue;
      final category = categories
          .where((item) => item.code == rule.code)
          .firstOrNull;
      if (category != null) {
        return SmartSuggestion(
          field: SmartMetadataField.category,
          value: category,
          confidence: .92,
          reason: 'Detected document keywords / নথির শব্দ শনাক্ত করা হয়েছে',
        );
      }
    }
    return null;
  }

  SmartSuggestion<String>? _documentNumber(String text) {
    final labelled = RegExp(
      r'(?:passport|nid|tin|number|no)\s*(?:number|no)?\s*[:#-]?\s*([a-z0-9]{6,20})',
    ).firstMatch(text);
    final tin = RegExp(r'\b\d{12}\b').firstMatch(text);
    final passport = RegExp(r'\b[a-z]{1,2}\d{6,9}\b').firstMatch(text);
    final value = labelled?.group(1) ?? tin?.group(0) ?? passport?.group(0);
    if (value == null) return null;
    return SmartSuggestion(
      field: SmartMetadataField.documentNumber,
      value: value.toUpperCase(),
      confidence: labelled != null ? .84 : .68,
      reason: 'Possible document identifier / সম্ভাব্য নথি শনাক্তকারী',
    );
  }

  SmartSuggestion<DateTime>? _labelledDate(
    String text,
    List<String> labels,
    SmartMetadataField field,
  ) {
    for (final label in labels) {
      final match = RegExp(
        '${RegExp.escape(label)}[^0-9]{0,24}(\\d{4}[-/.]\\d{1,2}[-/.]\\d{1,2}|\\d{1,2}[-/.]\\d{1,2}[-/.]\\d{4})',
      ).firstMatch(text);
      final date = match == null ? null : _parseDate(match.group(1)!);
      if (date != null) {
        return SmartSuggestion(
          field: field,
          value: date,
          confidence: .78,
          reason: 'Date label found in recognized text / শনাক্ত করা লেখায় তারিখের লেবেল পাওয়া গেছে',
        );
      }
    }
    return null;
  }

  String _normalizeForExtraction(String value) {
    const banglaDigits = '০১২৩৪৫৬৭৮৯';
    const asciiDigits = '0123456789';
    var normalized = value.trim().toLowerCase();
    for (var index = 0; index < banglaDigits.length; index++) {
      normalized = normalized.replaceAll(
        banglaDigits[index],
        asciiDigits[index],
      );
    }
    return normalized.replaceAll(RegExp(r'\s+'), ' ');
  }

  DateTime? _parseDate(String value) {
    final values = value.split(RegExp('[-/.]')).map(int.tryParse).toList();
    if (values.any((item) => item == null) || values.length != 3) return null;
    final first = values[0]!;
    final second = values[1]!;
    final third = values[2]!;
    final year = first >= 1900 ? first : third;
    final month = second;
    final day = first >= 1900 ? third : first;
    if (year < 1900 ||
        year > 2200 ||
        month < 1 ||
        month > 12 ||
        day < 1 ||
        day > 31) {
      return null;
    }
    final result = DateTime.utc(year, month, day);
    return result.month == month && result.day == day ? result : null;
  }

  String _titleFor(String code) => switch (code) {
    'identity.passport' => 'Passport / পাসপোর্ট',
    'identity.nid' => 'National ID / জাতীয় পরিচয়পত্র',
    'tax_financial.tin' => 'TIN certificate / টিআইএন সনদ',
    'land_property.khatian' => 'Khatian / খতিয়ান',
    'land_property.mutation' => 'Mutation record / নামজারি',
    'travel.visa' => 'Visa / ভিসা',
    'warranty_purchases' => 'Warranty / ওয়ারেন্টি',
    _ => 'Document / নথি',
  };
}

class _CategoryRule {
  const _CategoryRule(this.code, this.keywords);
  final String code;
  final List<String> keywords;
}
