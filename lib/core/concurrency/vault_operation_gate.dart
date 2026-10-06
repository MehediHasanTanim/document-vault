import 'dart:async';

/// Serialises cooperative vault mutations and consistent snapshots. Inject the
/// same instance into file/database writers and [BackupSnapshotSource].
class VaultOperationGate {
  Future<void> _tail = Future<void>.value();

  Future<T> runWrite<T>(Future<T> Function() action) => _serial(action);
  Future<T> runSnapshot<T>(Future<T> Function() action) => _serial(action);

  Future<T> _serial<T>(Future<T> Function() action) async {
    final previous = _tail;
    final done = Completer<void>();
    _tail = done.future;
    await previous;
    try {
      return await action();
    } finally {
      done.complete();
    }
  }
}
