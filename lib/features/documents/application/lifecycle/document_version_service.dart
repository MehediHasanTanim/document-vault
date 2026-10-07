import '../../../../core/database/repositories.dart';
import '../../../../core/database/vault_database.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/uuid/uuid_generator.dart';

/// Minimal renewal foundation. A replacement document already created through
/// the normal secure-import flow becomes current; its predecessor remains a
/// preserved, non-current record marked `superseded`.
class DocumentVersionService {
  DocumentVersionService(
    this._documents,
    this._versions,
    this._uuid, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final DocumentRepository _documents;
  final DocumentVersionRepository _versions;
  final UuidGenerator _uuid;
  final DateTime Function() _clock;

  Future<void> beginRenewal(String documentId) async {
    final document = await _documents.getById(documentId);
    if (document == null || document.deletedAt != null) {
      throw const ValidationFailure('Document was not found.');
    }
    if (document.status == 'superseded') {
      throw const ValidationFailure(
        'A superseded document cannot be renewed. / প্রতিস্থাপিত নথি নবায়ন করা যাবে না।',
      );
    }
    await _documents.setStatus(
      documentId,
      status: 'renewal_in_progress',
      updatedAt: _clock().toUtc(),
    );
  }

  Future<void> markReplacement({
    required String supersededDocumentId,
    required String replacementDocumentId,
    String? supersededVersionId,
  }) async {
    if (supersededDocumentId == replacementDocumentId) {
      throw const ValidationFailure(
        'Choose a different replacement document. / ভিন্ন প্রতিস্থাপন নথি বেছে নিন।',
      );
    }
    final documents = await Future.wait([
      _documents.getById(supersededDocumentId),
      _documents.getById(replacementDocumentId),
    ]);
    if (documents.any(
      (document) => document == null || document.deletedAt != null,
    )) {
      throw const ValidationFailure('Both documents must be available.');
    }
    await _versions.createReplacement(
      oldDocumentId: supersededDocumentId,
      replacementDocumentId: replacementDocumentId,
      oldVersionId: supersededVersionId ?? _uuid.v4(),
      replacementVersionId: _uuid.v4(),
      createdAt: _clock().toUtc(),
    );
  }

  Future<List<DocumentVersion>> historyFor(String documentId) async {
    final document = await _documents.getById(documentId);
    final current = document?.currentVersionId;
    if (document == null || current == null) return const [];
    return _versions.listLineage(current);
  }
}
