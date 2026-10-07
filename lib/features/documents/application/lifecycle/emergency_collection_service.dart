import '../../../../core/database/repositories.dart';
import '../../../../core/database/vault_database.dart';
import '../../../../core/errors/app_failure.dart';

/// Maintains the single emergency collection. It is intentionally explicit:
/// users choose every document and no category, owner, or expiry rule can add
/// a record automatically.
class EmergencyCollectionService {
  EmergencyCollectionService(
    this._collection,
    this._documents, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final EmergencyCollectionRepository _collection;
  final DocumentRepository _documents;
  final DateTime Function() _clock;

  Future<List<EmergencyCollectionItem>> items() => _collection.listItems();

  Future<void> selectExplicitly(Iterable<String> documentIds) async {
    final ids = documentIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
    if (ids.length != ids.toSet().length) {
      throw const ValidationFailure(
        'Choose each emergency document only once. / প্রতিটি জরুরি নথি একবারই বেছে নিন।',
      );
    }
    for (final id in ids) {
      final document = await _documents.getById(id);
      if (document == null || document.deletedAt != null) {
        throw const ValidationFailure(
          'Only available vault documents can be added to the emergency collection. / শুধু ভল্টে থাকা নথি জরুরি সংগ্রহে যোগ করা যাবে।',
        );
      }
    }
    await _collection.replaceSelection(
      documentIds: ids,
      updatedAt: _clock().toUtc(),
    );
  }
}
