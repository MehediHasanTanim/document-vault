import 'protected_thumbnail_service.dart';

/// Pass [onVaultLocked] to the authentication lifecycle's `onLocked` callback.
/// It provides one explicit place to discard every derived document image held
/// in process memory when the vault locks.
class ViewerCacheLockHandler {
  const ViewerCacheLockHandler(this._thumbnails);
  final ProtectedThumbnailService _thumbnails;

  void onVaultLocked() => _thumbnails.clear();
}
