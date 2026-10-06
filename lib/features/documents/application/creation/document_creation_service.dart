import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/crypto/vault_data_protector.dart';
import '../../../../core/database/repositories.dart';
import '../../../../core/database/vault_database.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/files/encrypted_file_store.dart';
import '../../../../core/files/file_reference.dart';
import '../../../../core/files/file_operation_journal.dart';
import '../ingestion/import_models.dart';
import 'document_creation_models.dart';
import 'document_selection.dart';
import 'document_templates.dart';

/// Creates a document only after every selected file is encrypted. The journal
/// bridges the unavoidable filesystem/SQLite boundary so an interrupted save
/// is completed or cleaned up at next unlock by [ImportRecoveryService].
class DocumentCreationService {
  DocumentCreationService(
    this._documents,
    this._files,
    this._journal,
    this._protector, {
    DocumentTemplateCatalog? templates,
    DuplicateWarningHook? duplicateWarnings,
    this.recentCategories,
    Uuid? uuid,
    DateTime Function()? clock,
  }) : _templates = templates ?? const DocumentTemplateCatalog(),
       _duplicateWarnings = duplicateWarnings ?? const NoDuplicateWarningHook(),
       _uuid = uuid ?? const Uuid(),
       _clock = clock ?? DateTime.now;

  final DocumentRepository _documents;
  final EncryptedFileStore _files;
  final FileOperationJournal _journal;
  final VaultDataProtector _protector;
  final DocumentTemplateCatalog _templates;
  final DuplicateWarningHook _duplicateWarnings;
  final RecentCategoryService? recentCategories;
  final Uuid _uuid;
  final DateTime Function() _clock;

  Future<DocumentSaveResult> save(DocumentDraft draft) async {
    _validate(draft);
    final warnings = await _duplicateWarnings.check(draft);
    final documentId = _uuid.v4();
    final now = _clock().toUtc();
    final references = <SecureFileReference>[];
    String? operationId;
    var databaseCommitted = false;
    try {
      final document = await _documentCompanion(documentId, draft, now);
      final fields = await _fieldCompanions(documentId, draft, now);

      if (draft.pages.isNotEmpty) {
        operationId = await _journal.start(
          operationType: 'document_create',
          entityId: documentId,
        );
        for (final page in draft.pages) {
          final reference = await _files.writeEncrypted(
            documentId: documentId,
            bytes: page.file.openRead(),
            mimeType: page.mimeType,
          );
          references.add(reference);
          await _journal.markFilesWritten(
            operationId,
            FileOperationPayload(
              encryptedPaths: references
                  .map((reference) => reference.encryptedRelativePath)
                  .toList(),
              fileIds: references.map((reference) => reference.id).toList(),
            ),
          );
        }
      }

      await _documents.create(
        DocumentWrite(
          document: document,
          owners: draft.owners.memberIds
              .map(
                (memberId) => DocumentOwnersCompanion.insert(
                  documentId: documentId,
                  familyMemberId: memberId,
                ),
              )
              .toList(growable: false),
          files: _fileCompanions(documentId, draft.pages, references, now),
          pages: _pageCompanions(documentId, draft.pages, references, now),
          fields: fields,
          tagLinks: draft.tagIds
              .where((tagId) => tagId.isNotEmpty)
              .toSet()
              .map(
                (tagId) => DocumentTagsCompanion.insert(
                  documentId: documentId,
                  tagId: tagId,
                ),
              )
              .toList(growable: false),
        ),
      );
      databaseCommitted = true;
      if (operationId != null) {
        await _journal.markDatabaseCommitted(operationId);
        await _journal.complete(operationId);
      }
      // A convenience history must never turn an already-committed document
      // into an apparent save failure.
      try {
        await recentCategories?.record(draft.categoryId);
      } on Object {
        // The document remains safely committed; history is retried on a
        // future save and never carries sensitive metadata.
      }
      return DocumentSaveResult(
        documentId: documentId,
        duplicateWarnings: warnings,
      );
    } on Object catch (error) {
      // If SQLite committed but the journal update did not, preserve the files:
      // startup reconciliation can prove their metadata exists and complete it.
      if (!databaseCommitted) {
        for (final reference in references) {
          await _files.delete(reference);
        }
        if (operationId != null) await _journal.fail(operationId);
      }
      if (error is AppFailure) rethrow;
      throw StorageFailure(
        'The document could not be saved securely.',
        cause: error,
      );
    }
  }

  Future<DocumentsCompanion> _documentCompanion(
    String id,
    DocumentDraft draft,
    DateTime now,
  ) async {
    final context = 'document:$id';
    return DocumentsCompanion.insert(
      id: id,
      titleEncrypted: await _protector.encrypt(
        draft.title.trim(),
        context: '$context:title',
      ),
      categoryId: draft.categoryId,
      primaryOwnerId: Value(draft.owners.primaryMemberId),
      ownershipType: Value(draft.owners.ownershipType),
      documentNumberEncrypted: await _encryptOptional(
        draft.documentNumber,
        '$context:number',
      ),
      issueDate: Value(_toUtcDate(draft.issueDate)),
      expiryDate: Value(_toUtcDate(draft.expiryDate)),
      issuingAuthorityEncrypted: await _encryptOptional(
        draft.issuingAuthority,
        '$context:authority',
      ),
      descriptionEncrypted: await _encryptOptional(
        draft.description,
        '$context:description',
      ),
      notesEncrypted: await _encryptOptional(draft.notes, '$context:notes'),
      physicalLocationId: Value(_blankToNull(draft.physicalLocationId)),
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<List<DocumentFieldValuesCompanion>> _fieldCompanions(
    String documentId,
    DocumentDraft draft,
    DateTime now,
  ) async {
    final fields = <DocumentFieldValuesCompanion>[];
    for (var index = 0; index < draft.fields.length; index++) {
      final field = draft.fields[index];
      fields.add(
        DocumentFieldValuesCompanion.insert(
          id: _uuid.v4(),
          documentId: documentId,
          fieldKey: field.key,
          labelEncrypted: Value(
            await _protector.encrypt(
              field.label,
              context: 'document:$documentId:field-label:${field.key}',
            ),
          ),
          valueEncrypted: await _protector.encrypt(
            field.value.trim(),
            context: 'document:$documentId:field:${field.key}',
          ),
          valueType: Value(field.type.name),
          sortOrder: Value(index),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    return fields;
  }

  List<DocumentFilesCompanion> _fileCompanions(
    String documentId,
    List<StagedImportFile> inputs,
    List<SecureFileReference> references,
    DateTime now,
  ) => List.generate(references.length, (index) {
    final input = inputs[index];
    final reference = references[index];
    return DocumentFilesCompanion.insert(
      id: reference.id,
      documentId: documentId,
      fileType: Value(
        input.source == ImportSource.camera ? 'capture' : 'import',
      ),
      mimeType: reference.mimeType,
      encryptedRelativePath: reference.encryptedRelativePath,
      sizeBytes: reference.sizeBytes,
      integrityHash: reference.integrityHash,
      encryptionVersion: reference.encryptionVersion,
      createdAt: now,
    );
  });

  List<DocumentPagesCompanion> _pageCompanions(
    String documentId,
    List<StagedImportFile> inputs,
    List<SecureFileReference> references,
    DateTime now,
  ) {
    final pages = <DocumentPagesCompanion>[];
    for (var index = 0; index < references.length; index++) {
      if (!inputs[index].mimeType.startsWith('image/')) continue;
      pages.add(
        DocumentPagesCompanion.insert(
          id: _uuid.v4(),
          documentId: documentId,
          documentFileId: references[index].id,
          pageNumber: pages.length + 1,
          encryptedPath: Value(references[index].encryptedRelativePath),
          rotation: Value(inputs[index].rotation),
          createdAt: now,
        ),
      );
    }
    return pages;
  }

  void _validate(DocumentDraft draft) {
    if (draft.title.trim().isEmpty) {
      throw const ValidationFailure('Title is required. / শিরোনাম প্রয়োজন।');
    }
    if (draft.categoryId.trim().isEmpty || draft.categoryCode.trim().isEmpty) {
      throw const ValidationFailure(
        'Choose a category. / একটি বিভাগ নির্বাচন করুন।',
      );
    }
    if (!draft.owners.isValid) {
      throw const ValidationFailure(
        'Choose an owner or Household. / মালিক বা পরিবার নির্বাচন করুন।',
      );
    }
    if (draft.issueDate != null &&
        draft.expiryDate != null &&
        draft.expiryDate!.isBefore(draft.issueDate!)) {
      throw const ValidationFailure(
        'Expiry date cannot be before issue date. / মেয়াদ শেষের তারিখ ইস্যুর তারিখের আগে হতে পারে না।',
      );
    }
    final duplicateKeys = <String>{};
    for (final field in draft.fields) {
      if (field.key.trim().isEmpty || !duplicateKeys.add(field.key)) {
        throw const ValidationFailure('Each document field must be unique.');
      }
      if (field.type == DocumentFieldType.date &&
          field.value.trim().isNotEmpty &&
          DateTime.tryParse(field.value) == null) {
        throw const ValidationFailure(
          'Enter a valid date in the document fields.',
        );
      }
    }
    final template = _templates.forCategory(draft.categoryCode);
    if (template == null) return;
    final values = {
      for (final field in draft.fields) field.key: field.value.trim(),
    };
    for (final field in template.fields.where((field) => field.required)) {
      if ((values[field.key] ?? '').isEmpty) {
        throw ValidationFailure('${field.label} is required.');
      }
    }
  }

  Future<Value<String?>> _encryptOptional(String? value, String context) async {
    final normalized = _blankToNull(value);
    if (normalized == null) return const Value(null);
    return Value(await _protector.encrypt(normalized, context: context));
  }

  String? _blankToNull(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  DateTime? _toUtcDate(DateTime? date) =>
      date == null ? null : DateTime.utc(date.year, date.month, date.day);
}

/// Lightweight presentation state with retry. Widgets may listen to this
/// directly or expose it through Riverpod; it contains no sensitive content.
class DocumentSaveController extends ChangeNotifier {
  DocumentSaveController(this._service);
  final DocumentCreationService _service;
  DocumentSaveState _state = const DocumentSaveState.idle();
  DocumentDraft? _lastDraft;

  DocumentSaveState get state => _state;

  Future<void> save(DocumentDraft draft) async {
    _lastDraft = draft;
    _state = const DocumentSaveState.saving();
    notifyListeners();
    try {
      _state = DocumentSaveState.success(await _service.save(draft));
    } on Object catch (error) {
      _state = DocumentSaveState.failure(error);
    }
    notifyListeners();
  }

  Future<void> retry() async {
    final draft = _lastDraft;
    if (draft == null) return;
    await save(draft);
  }
}
