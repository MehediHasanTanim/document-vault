import 'package:drift/drift.dart' show Value;

import '../../../core/crypto/vault_data_protector.dart';
import '../../../core/database/repositories.dart';
import '../../../core/database/vault_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/uuid/uuid_generator.dart';

class PhysicalLocationInput {
  const PhysicalLocationInput({required this.name, this.notes});
  final String name;
  final String? notes;
}

class PhysicalLocationDetails {
  const PhysicalLocationDetails({
    required this.location,
    required this.name,
    required this.notes,
  });
  final PhysicalLocation location;
  final String name;
  final String? notes;
}

class PhysicalLocationService {
  PhysicalLocationService(
    this._locations,
    this._documents,
    this._protector,
    this._uuid, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;
  final PhysicalLocationRepository _locations;
  final DocumentRepository _documents;
  final VaultDataProtector _protector;
  final UuidGenerator _uuid;
  final DateTime Function() _clock;

  Future<String> create(PhysicalLocationInput input) async {
    _validate(input);
    final id = _uuid.v4();
    final now = _clock().toUtc();
    await _locations.save(
      await _companion(id, input, createdAt: now, updatedAt: now),
    );
    return id;
  }

  Future<void> update(String id, PhysicalLocationInput input) async {
    _validate(input);
    final existing = await _locations.getById(id);
    if (existing == null) {
      throw const ValidationFailure('Physical location was not found.');
    }
    await _locations.save(
      await _companion(
        id,
        input,
        createdAt: existing.createdAt,
        updatedAt: _clock().toUtc(),
        archived: existing.isArchived,
        clearOptional: true,
      ),
    );
  }

  Future<void> archive(String id) =>
      _locations.archive(id, archived: true, updatedAt: _clock().toUtc());
  Future<void> restore(String id) =>
      _locations.archive(id, archived: false, updatedAt: _clock().toUtc());
  Future<void> assignToDocument({
    required String documentId,
    required String? locationId,
  }) => _documents.assignPhysicalLocation(
    documentId,
    physicalLocationId: locationId,
    updatedAt: _clock().toUtc(),
  );

  Future<PhysicalLocationDetails?> getDetails(String id) async {
    final location = await _locations.getById(id);
    if (location == null) return null;
    return PhysicalLocationDetails(
      location: location,
      name: await _protector.decrypt(
        location.nameEncrypted,
        context: _context(id, 'name'),
      ),
      notes: location.descriptionEncrypted == null
          ? null
          : await _protector.decrypt(
              location.descriptionEncrypted!,
              context: _context(id, 'notes'),
            ),
    );
  }

  Future<PhysicalLocationsCompanion> _companion(
    String id,
    PhysicalLocationInput input, {
    required DateTime createdAt,
    required DateTime updatedAt,
    bool archived = false,
    bool clearOptional = false,
  }) async => PhysicalLocationsCompanion.insert(
    id: id,
    nameEncrypted: await _protector.encrypt(
      input.name.trim(),
      context: _context(id, 'name'),
    ),
    descriptionEncrypted: input.notes == null || input.notes!.trim().isEmpty
        ? (clearOptional ? const Value(null) : const Value.absent())
        : Value(
            await _protector.encrypt(
              input.notes!.trim(),
              context: _context(id, 'notes'),
            ),
          ),
    isArchived: Value(archived),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  static void _validate(PhysicalLocationInput input) {
    if (input.name.trim().isEmpty) {
      throw const ValidationFailure('Location name is required.');
    }
  }

  static String _context(String id, String field) => 'location:$id:$field';
}
