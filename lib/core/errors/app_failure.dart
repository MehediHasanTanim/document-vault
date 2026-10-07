sealed class AppFailure implements Exception {
  const AppFailure(this.message, {this.cause});
  final String message;
  final Object? cause;
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}

final class SecurityFailure extends AppFailure {
  const SecurityFailure(super.message, {super.cause});
}

final class StorageFailure extends AppFailure {
  const StorageFailure(super.message, {super.cause});
}

final class UnsupportedFileFailure extends AppFailure {
  const UnsupportedFileFailure(super.message, {super.cause});
}

final class InsufficientStorageFailure extends AppFailure {
  const InsufficientStorageFailure(super.message, {super.cause});
}

final class PermissionFailure extends AppFailure {
  const PermissionFailure(super.message, {super.cause});
}

final class NotificationSchedulingFailure extends AppFailure {
  const NotificationSchedulingFailure(super.message, {super.cause});
}

/// Local OCR failed or is unavailable. Its message is safe for presentation
/// and must never contain recognized text, a file path, or engine diagnostics.
final class OcrFailure extends AppFailure {
  const OcrFailure(super.message, {super.cause});
}

/// Deliberately does not reveal whether a backup failed authentication,
/// structure validation, or password verification.
final class BackupFailure extends AppFailure {
  const BackupFailure(super.message, {super.cause});
}

final class BackupCancelledFailure extends AppFailure {
  const BackupCancelledFailure() : super('Backup was cancelled.');
}
