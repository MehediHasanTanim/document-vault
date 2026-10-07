/// Privacy-safe timings for release builds and automated performance checks.
///
/// This deliberately records no document IDs, file names, queries, paths, or
/// payload sizes. Callers may export aggregate timings only after explicit
/// user consent; the application does not persist this data itself.
enum VaultPerformanceOperation {
  coldLaunch,
  unlock,
  searchIndexBuild,
  libraryBrowse,
  search,
  pdfOpen,
  thumbnailGeneration,
  backup,
  restore,
}

class VaultPerformanceBudget {
  const VaultPerformanceBudget(this.operation, this.target);
  final VaultPerformanceOperation operation;
  final Duration target;
}

class VaultPerformanceSample {
  const VaultPerformanceSample({
    required this.operation,
    required this.elapsed,
    required this.succeeded,
  });

  final VaultPerformanceOperation operation;
  final Duration elapsed;
  final bool succeeded;
}

/// Bounded, in-memory measurement store. It is cleared on lock/process exit.
class VaultPerformanceMonitor {
  VaultPerformanceMonitor({this.maxSamples = 120});

  static const releaseBudgets = <VaultPerformanceBudget>[
    VaultPerformanceBudget(
      VaultPerformanceOperation.coldLaunch,
      Duration(seconds: 3),
    ),
    VaultPerformanceBudget(
      VaultPerformanceOperation.unlock,
      Duration(seconds: 2),
    ),
    VaultPerformanceBudget(
      VaultPerformanceOperation.searchIndexBuild,
      Duration(seconds: 2),
    ),
    VaultPerformanceBudget(
      VaultPerformanceOperation.libraryBrowse,
      Duration(seconds: 2),
    ),
    VaultPerformanceBudget(
      VaultPerformanceOperation.search,
      Duration(seconds: 1),
    ),
    VaultPerformanceBudget(
      VaultPerformanceOperation.pdfOpen,
      Duration(seconds: 3),
    ),
    VaultPerformanceBudget(
      VaultPerformanceOperation.thumbnailGeneration,
      Duration(seconds: 2),
    ),
  ];

  final int maxSamples;
  final _samples = <VaultPerformanceSample>[];

  List<VaultPerformanceSample> get samples => List.unmodifiable(_samples);

  Future<T> measure<T>(
    VaultPerformanceOperation operation,
    Future<T> Function() action,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await action();
      _record(operation, stopwatch.elapsed, succeeded: true);
      return result;
    } on Object {
      _record(operation, stopwatch.elapsed, succeeded: false);
      rethrow;
    }
  }

  bool isWithinBudget(VaultPerformanceSample sample) {
    for (final budget in releaseBudgets) {
      if (budget.operation == sample.operation) {
        return sample.elapsed <= budget.target;
      }
    }
    return true;
  }

  void clear() => _samples.clear();

  void _record(
    VaultPerformanceOperation operation,
    Duration elapsed, {
    required bool succeeded,
  }) {
    _samples.add(
      VaultPerformanceSample(
        operation: operation,
        elapsed: elapsed,
        succeeded: succeeded,
      ),
    );
    if (_samples.length > maxSamples) {
      _samples.removeRange(0, _samples.length - maxSamples);
    }
  }
}
