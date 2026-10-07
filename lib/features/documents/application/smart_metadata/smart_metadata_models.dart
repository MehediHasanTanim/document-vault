import '../creation/document_selection.dart';

enum SmartMetadataField {
  category,
  title,
  documentNumber,
  issueDate,
  expiryDate,
}

class SmartSuggestion<T> {
  const SmartSuggestion({
    required this.field,
    required this.value,
    required this.confidence,
    required this.reason,
  });

  final SmartMetadataField field;
  final T value;

  /// A bounded heuristic confidence, not a guarantee of correctness.
  final double confidence;
  final String reason;
}

class SmartMetadataSuggestions {
  const SmartMetadataSuggestions({
    this.category,
    this.title,
    this.documentNumber,
    this.issueDate,
    this.expiryDate,
  });

  final SmartSuggestion<CategorySearchEntry>? category;
  final SmartSuggestion<String>? title;
  final SmartSuggestion<String>? documentNumber;
  final SmartSuggestion<DateTime>? issueDate;
  final SmartSuggestion<DateTime>? expiryDate;

  bool get isEmpty =>
      category == null &&
      title == null &&
      documentNumber == null &&
      issueDate == null &&
      expiryDate == null;
}

enum DuplicateKind { exactFile, metadata, perceptualImagePrototype }

class DuplicateMatch {
  const DuplicateMatch({
    required this.kind,
    required this.documentIds,
    required this.confidence,
    required this.message,
    this.distance,
  });

  final DuplicateKind kind;
  final List<String> documentIds;
  final double confidence;
  final String message;
  final int? distance;
}
