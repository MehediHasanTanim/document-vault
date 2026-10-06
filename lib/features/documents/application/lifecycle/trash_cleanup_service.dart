import '../../../../core/database/repositories.dart';
import 'document_lifecycle_service.dart';

/// Configuration is intentionally a policy object so SettingsRepository can
/// persist it later without changing cleanup semantics. MVP defaults to 30
/// days and can be disabled; emptying Trash is always explicit.
class TrashRetentionPolicy {
  const TrashRetentionPolicy({
    this.enabled = true,
    this.retention = const Duration(days: 30),
  });
  final bool enabled;
  final Duration retention;
}

class TrashCleanupService {
  TrashCleanupService(
    this._documents,
    this._lifecycle, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final DocumentRepository _documents;
  final DocumentLifecycleService _lifecycle;
  final DateTime Function() _clock;

  Future<int> run(TrashRetentionPolicy policy) async {
    if (!policy.enabled) return 0;
    final threshold = _clock().toUtc().subtract(policy.retention);
    final trashed = await _documents.watchAll(includeTrashed: true).first;
    final expired = trashed.where(
      (document) =>
          document.deletedAt != null && document.deletedAt!.isBefore(threshold),
    );
    var removed = 0;
    for (final document in expired) {
      await _lifecycle.deletePermanently(document.id);
      removed++;
    }
    return removed;
  }

  Future<int> emptyNow() async {
    final documents = await _documents.watchAll(includeTrashed: true).first;
    var removed = 0;
    for (final document in documents.where((item) => item.deletedAt != null)) {
      await _lifecycle.deletePermanently(document.id);
      removed++;
    }
    return removed;
  }
}
