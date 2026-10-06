import 'package:drift/drift.dart' show Value;

import '../../../core/crypto/vault_data_protector.dart';
import '../../../core/database/repositories.dart';
import '../../../core/database/vault_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/uuid/uuid_generator.dart';

class FamilyMemberInput {
  const FamilyMemberInput({
    required this.name,
    required this.relationship,
    this.nickname,
    this.dateOfBirth,
    this.bloodGroup,
    this.avatarFileId,
    this.notes,
    this.isOwner = false,
  });
  final String name;
  final String relationship;
  final String? nickname;
  final DateTime? dateOfBirth;
  final String? bloodGroup;
  final String? avatarFileId;
  final String? notes;
  final bool isOwner;
}

class FamilyMemberDetails {
  const FamilyMemberDetails({
    required this.member,
    required this.name,
    required this.nickname,
    required this.notes,
    required this.documentCount,
  });
  final FamilyMember member;
  final String name;
  final String? nickname;
  final String? notes;
  final int documentCount;
}

/// A virtual owner, not a database family-member row. Document creation can use
/// [ownershipType] with no primary member for shared household records.
class HouseholdOwnership {
  const HouseholdOwnership();
  static const id = 'household';
  static const englishLabel = 'Household';
  static const banglaLabel = 'পরিবার';
  static const ownershipType = 'household';
}

class PermanentDeletionPlan {
  const PermanentDeletionPlan({
    required this.allowed,
    required this.documentCount,
  });
  final bool allowed;
  final int documentCount;
  bool get requiresReassignment => documentCount > 0;
}

class FamilyMemberService {
  FamilyMemberService(
    this._repository,
    this._protector,
    this._uuid, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final FamilyRepository _repository;
  final VaultDataProtector _protector;
  final UuidGenerator _uuid;
  final DateTime Function() _clock;

  Future<String> create(FamilyMemberInput input) async {
    _validate(input);
    final id = _uuid.v4();
    final now = _clock().toUtc();
    await _repository.save(
      await _companion(id, input, createdAt: now, updatedAt: now),
    );
    return id;
  }

  Future<void> update(String id, FamilyMemberInput input) async {
    _validate(input);
    final existing = await _repository.getById(id);
    if (existing == null) {
      throw const ValidationFailure('Family member was not found.');
    }
    await _repository.save(
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
      _repository.archive(id, updatedAt: _clock().toUtc());
  Future<void> restore(String id) =>
      _repository.restore(id, updatedAt: _clock().toUtc());

  Future<PermanentDeletionPlan> permanentDeletionPlan(String id) async =>
      PermanentDeletionPlan(
        allowed: false,
        documentCount: await _repository.documentCount(id),
      );

  Future<FamilyMemberDetails?> getDetails(String id) async {
    final member = await _repository.getById(id);
    if (member == null) return null;
    return FamilyMemberDetails(
      member: member,
      name: await _protector.decrypt(
        member.displayNameEncrypted,
        context: _context(id, 'name'),
      ),
      nickname: member.nicknameEncrypted == null
          ? null
          : await _protector.decrypt(
              member.nicknameEncrypted!,
              context: _context(id, 'nickname'),
            ),
      notes: member.notesEncrypted == null
          ? null
          : await _protector.decrypt(
              member.notesEncrypted!,
              context: _context(id, 'notes'),
            ),
      documentCount: await _repository.documentCount(id),
    );
  }

  Future<FamilyMembersCompanion> _companion(
    String id,
    FamilyMemberInput input, {
    required DateTime createdAt,
    required DateTime updatedAt,
    bool archived = false,
    bool clearOptional = false,
  }) async => FamilyMembersCompanion.insert(
    id: id,
    displayNameEncrypted: await _protector.encrypt(
      input.name.trim(),
      context: _context(id, 'name'),
    ),
    nicknameEncrypted: input.nickname == null || input.nickname!.trim().isEmpty
        ? (clearOptional ? const Value(null) : const Value.absent())
        : Value(
            await _protector.encrypt(
              input.nickname!.trim(),
              context: _context(id, 'nickname'),
            ),
          ),
    relationship: input.relationship.trim(),
    dateOfBirth: input.dateOfBirth == null
        ? (clearOptional ? const Value(null) : const Value.absent())
        : Value(_dateOnly(input.dateOfBirth!)),
    bloodGroup: _optional(input.bloodGroup, clear: clearOptional),
    avatarFileId: _optional(input.avatarFileId, clear: clearOptional),
    notesEncrypted: input.notes == null || input.notes!.trim().isEmpty
        ? (clearOptional ? const Value(null) : const Value.absent())
        : Value(
            await _protector.encrypt(
              input.notes!.trim(),
              context: _context(id, 'notes'),
            ),
          ),
    isOwner: Value(input.isOwner),
    isArchived: Value(archived),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  void _validate(FamilyMemberInput input) {
    if (input.name.trim().isEmpty) {
      throw const ValidationFailure('Name is required.');
    }
    if (input.relationship.trim().isEmpty) {
      throw const ValidationFailure('Relationship is required.');
    }
    if (input.dateOfBirth != null) {
      final date = _dateOnly(input.dateOfBirth!);
      final today = _dateOnly(_clock());
      if (date.isAfter(today) || date.isBefore(DateTime(today.year - 130))) {
        throw const ValidationFailure('Enter a valid date of birth.');
      }
    }
  }

  static Value<String?> _optional(String? value, {required bool clear}) =>
      value == null || value.trim().isEmpty
      ? (clear ? const Value(null) : const Value.absent())
      : Value(value.trim());
  static DateTime _dateOnly(DateTime value) =>
      DateTime.utc(value.year, value.month, value.day);
  static String _context(String id, String field) => 'family:$id:$field';
}
