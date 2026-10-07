import 'package:uuid/uuid.dart';

import '../../../../core/database/repositories.dart';
import '../../../../core/database/vault_database.dart';

/// Keeps minimal, local export evidence. Sensitive content, destination and
/// recipient information are deliberately excluded from the schema and API.
class ShareAuditService {
  ShareAuditService(this._repository, {Uuid? uuid, DateTime Function()? clock})
    : _uuid = uuid ?? const Uuid(),
      _clock = clock ?? DateTime.now;

  final ShareAuditRepository _repository;
  final Uuid _uuid;
  final DateTime Function() _clock;

  Future<void> recordHandoff({
    required String documentId,
    required int pageCount,
    required bool hadWatermark,
    required bool hadRedactions,
  }) => _repository.record(
    ShareAuditEventsCompanion.insert(
      id: _uuid.v4(),
      documentId: documentId,
      eventType: 'share_handoff',
      pageCount: pageCount,
      exportFormat: 'image/jpeg',
      hadWatermark: hadWatermark,
      hadRedactions: hadRedactions,
      createdAt: _clock().toUtc(),
    ),
  );
}
