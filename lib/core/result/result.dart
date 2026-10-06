import '../errors/app_failure.dart';

sealed class Result<T> {
  const Result();
  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(AppFailure error) = Failure<T>;
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);
  final AppFailure error;
}
