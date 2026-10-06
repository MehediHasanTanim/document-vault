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
