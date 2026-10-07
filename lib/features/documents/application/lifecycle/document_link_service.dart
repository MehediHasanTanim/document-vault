import '../../../../core/database/repositories.dart';
import '../../../../core/database/vault_database.dart';
import '../../../../core/errors/app_failure.dart';

enum DocumentRelationship { related, supporting, household }

/// Creates canonical, symmetric document relationships. Renewal lineage stays
/// in [DocumentVersionRepository]; links are for user-visible associations.
class DocumentLinkService {
  DocumentLinkService(
    this._documents,
    this._links, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final DocumentRepository _documents;
  final DocumentLinkRepository _links;
  final DateTime Function() _clock;

  Future<List<DocumentLink>> linksFor(String documentId) =>
      _links.listForDocument(documentId);

  Future<void> link({
    required String documentId,
    required String relatedDocumentId,
    required DocumentRelationship relationship,
  }) async {
    final pair = await _validatedPair(documentId, relatedDocumentId);
    await _links.link(
      DocumentLinksCompanion.insert(
        sourceDocumentId: pair.$1,
        targetDocumentId: pair.$2,
        relationshipType: relationship.name,
        createdAt: _clock().toUtc(),
      ),
    );
  }

  /// A household relationship is limited to records marked as household-owned,
  /// avoiding an ambiguous implied family relationship.
  Future<void> linkHouseholdDocuments({
    required String documentId,
    required String relatedDocumentId,
  }) async {
    final pair = await _validatedPair(documentId, relatedDocumentId);
    final first = await _documents.getById(pair.$1);
    final second = await _documents.getById(pair.$2);
    if (first?.ownershipType != 'household' ||
        second?.ownershipType != 'household') {
      throw const ValidationFailure(
        'Both documents must be household-owned. / দুটি নথিই পরিবার-মালিকানাধীন হতে হবে।',
      );
    }
    await _links.link(
      DocumentLinksCompanion.insert(
        sourceDocumentId: pair.$1,
        targetDocumentId: pair.$2,
        relationshipType: DocumentRelationship.household.name,
        createdAt: _clock().toUtc(),
      ),
    );
  }

  Future<void> unlink({
    required String documentId,
    required String relatedDocumentId,
  }) {
    final pair = _canonicalPair(documentId, relatedDocumentId);
    return _links.unlink(sourceDocumentId: pair.$1, targetDocumentId: pair.$2);
  }

  Future<(String, String)> _validatedPair(String first, String second) async {
    final pair = _canonicalPair(first, second);
    final documents = await Future.wait([
      _documents.getById(pair.$1),
      _documents.getById(pair.$2),
    ]);
    if (documents.any(
      (document) => document == null || document.deletedAt != null,
    )) {
      throw const ValidationFailure(
        'Both linked documents must be available in the vault. / দুটি সংযুক্ত নথিই ভল্টে থাকতে হবে।',
      );
    }
    return pair;
  }

  (String, String) _canonicalPair(String first, String second) {
    final left = first.trim();
    final right = second.trim();
    if (left.isEmpty || right.isEmpty || left == right) {
      throw const ValidationFailure(
        'Choose two different documents to link. / সংযোগের জন্য দুটি ভিন্ন নথি বেছে নিন।',
      );
    }
    return left.compareTo(right) < 0 ? (left, right) : (right, left);
  }
}
