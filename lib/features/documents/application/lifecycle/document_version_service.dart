import '../../../../core/database/repositories.dart';
import '../../../../core/uuid/uuid_generator.dart';

/// Minimal renewal foundation. A replacement document already created through
/// the normal secure-import flow becomes current; its predecessor remains a
/// preserved, non-current record marked `superseded`.
class DocumentVersionService {
  DocumentVersionService(
    this._versions,
    this._uuid, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final DocumentVersionRepository _versions;
  final UuidGenerator _uuid;
  final DateTime Function() _clock;

  Future<void> markReplacement({
    required String supersededDocumentId,
    required String replacementDocumentId,
    String? supersededVersionId,
  }) => _versions.createReplacement(
    oldDocumentId: supersededDocumentId,
    replacementDocumentId: replacementDocumentId,
    oldVersionId: supersededVersionId ?? _uuid.v4(),
    replacementVersionId: _uuid.v4(),
    createdAt: _clock().toUtc(),
  );
}
