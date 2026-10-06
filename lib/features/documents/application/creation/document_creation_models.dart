import '../ingestion/import_models.dart';
import 'document_templates.dart';

class DocumentOwnerSelection {
  const DocumentOwnerSelection.household()
    : memberIds = const {},
      isHousehold = true;

  DocumentOwnerSelection.members(Iterable<String> members)
    : memberIds = Set<String>.unmodifiable(
        members.where((id) => id.isNotEmpty),
      ),
      isHousehold = false;

  final Set<String> memberIds;
  final bool isHousehold;

  String? get primaryMemberId => memberIds.isEmpty ? null : memberIds.first;
  bool get isValid => isHousehold || memberIds.isNotEmpty;
  String get ownershipType => isHousehold
      ? 'household'
      : memberIds.length == 1
      ? 'personal'
      : 'multiple';
}

class DynamicFieldInput {
  const DynamicFieldInput({
    required this.key,
    required this.label,
    required this.value,
    required this.type,
  });

  final String key;
  final String label;
  final String value;
  final DocumentFieldType type;
}

class DocumentDraft {
  const DocumentDraft({
    required this.title,
    required this.categoryId,
    required this.categoryCode,
    required this.owners,
    this.documentNumber,
    this.issueDate,
    this.expiryDate,
    this.issuingAuthority,
    this.description,
    this.notes,
    this.physicalLocationId,
    this.tagIds = const [],
    this.fields = const [],
    this.pages = const [],
  });

  final String title;
  final String categoryId;
  final String categoryCode;
  final DocumentOwnerSelection owners;
  final String? documentNumber;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? issuingAuthority;
  final String? description;
  final String? notes;
  final String? physicalLocationId;
  final Iterable<String> tagIds;
  final List<DynamicFieldInput> fields;
  final List<StagedImportFile> pages;
}

class DuplicateWarning {
  const DuplicateWarning({required this.message});
  final String message;
}

/// A non-blocking seam for Sprint 18's encrypted duplicate matching. It keeps
/// the creation flow ready without weakening its offline/privacy guarantees.
abstract interface class DuplicateWarningHook {
  Future<List<DuplicateWarning>> check(DocumentDraft draft);
}

class NoDuplicateWarningHook implements DuplicateWarningHook {
  const NoDuplicateWarningHook();
  @override
  Future<List<DuplicateWarning>> check(DocumentDraft draft) async => const [];
}

class DocumentSaveResult {
  const DocumentSaveResult({
    required this.documentId,
    required this.duplicateWarnings,
  });
  final String documentId;
  final List<DuplicateWarning> duplicateWarnings;
}

enum DocumentSaveStatus { idle, saving, success, failure }

class DocumentSaveState {
  const DocumentSaveState._({
    this.status = DocumentSaveStatus.idle,
    this.result,
    this.error,
  });
  const DocumentSaveState.idle() : this._();
  const DocumentSaveState.saving() : this._(status: DocumentSaveStatus.saving);
  const DocumentSaveState.success(DocumentSaveResult result)
    : this._(status: DocumentSaveStatus.success, result: result);
  const DocumentSaveState.failure(Object error)
    : this._(status: DocumentSaveStatus.failure, error: error);

  final DocumentSaveStatus status;
  final DocumentSaveResult? result;
  final Object? error;
}
