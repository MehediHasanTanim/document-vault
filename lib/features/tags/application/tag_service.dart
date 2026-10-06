import '../../../core/crypto/vault_data_protector.dart';
import '../../../core/database/repositories.dart';
import '../../../core/database/vault_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/uuid/uuid_generator.dart';

class TagDetails {
  const TagDetails({required this.tag, required this.name});
  final Tag tag;
  final String name;
}

class TagService {
  TagService(
    this._repository,
    this._protector,
    this._uuid, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;
  final TagRepository _repository;
  final VaultDataProtector _protector;
  final UuidGenerator _uuid;
  final DateTime Function() _clock;

  Future<String> create(String name) async {
    _validate(name);
    final id = _uuid.v4();
    await _save(id, name, createdAt: _clock().toUtc());
    return id;
  }

  Future<void> rename(String id, String name) async {
    _validate(name);
    final existing = await _repository.getById(id);
    if (existing == null) throw const ValidationFailure('Tag was not found.');
    await _save(id, name, createdAt: existing.createdAt);
  }

  Future<void> delete(String id) => _repository.delete(id);
  Future<void> assign({required String documentId, required String tagId}) =>
      _repository.attach(documentId: documentId, tagId: tagId);
  Future<void> remove({required String documentId, required String tagId}) =>
      _repository.detach(documentId: documentId, tagId: tagId);

  Future<TagDetails?> getDetails(String id) async {
    final tag = await _repository.getById(id);
    if (tag == null) return null;
    return TagDetails(
      tag: tag,
      name: await _protector.decrypt(tag.nameEncrypted, context: _context(id)),
    );
  }

  Future<void> _save(
    String id,
    String rawName, {
    required DateTime createdAt,
  }) async {
    final name = rawName.trim();
    final normalizedHash = await _protector.normalizedNameHash(
      name,
      context: 'tag-name',
    );
    final duplicate = await _repository.getByNormalizedNameHash(normalizedHash);
    if (duplicate != null && duplicate.id != id) {
      throw const ValidationFailure('A tag with this name already exists.');
    }
    try {
      await _repository.save(
        TagsCompanion.insert(
          id: id,
          nameEncrypted: await _protector.encrypt(name, context: _context(id)),
          normalizedNameHash: normalizedHash,
          createdAt: createdAt,
        ),
      );
    } on Object catch (error) {
      if (error is ValidationFailure) rethrow;
      throw ValidationFailure('A tag with this name already exists.');
    }
  }

  static void _validate(String name) {
    if (name.trim().isEmpty) {
      throw const ValidationFailure('Tag name is required.');
    }
  }

  static String _context(String id) => 'tag:$id:name';
}
