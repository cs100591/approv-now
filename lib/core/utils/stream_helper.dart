import 'dart:async';

/// Helper class for creating safe, cancellable streams
class StreamHelper {
  /// Creates a polling stream with proper lifecycle management
  ///
  /// [fetchData] - Function to fetch data
  /// [interval] - Polling interval (default 30 seconds)
  /// [initialDelay] - Delay before first fetch (default 0)
  static Stream<T> createPollingStream<T>({
    required Future<T> Function() fetchData,
    Duration interval = const Duration(seconds: 30),
    Duration initialDelay = Duration.zero,
  }) {
    final controller = StreamController<T>();
    Timer? timer;
    bool isCancelled = false;

    void safeAdd(T data) {
      if (!isCancelled && !controller.isClosed) {
        controller.add(data);
      }
    }

    void safeAddError(Object error, StackTrace stack) {
      if (!isCancelled && !controller.isClosed) {
        controller.addError(error, stack);
      }
    }

    Future<void> fetchAndEmit() async {
      if (isCancelled || controller.isClosed) return;

      try {
        final data = await fetchData();
        safeAdd(data);
      } catch (e, stack) {
        safeAddError(e, stack);
      }
    }

    // Initial fetch after delay
    if (initialDelay > Duration.zero) {
      Future.delayed(initialDelay, fetchAndEmit);
    } else {
      fetchAndEmit();
    }

    // Periodic refresh
    timer = Timer.periodic(interval, (_) => fetchAndEmit());

    // Cleanup
    controller.onCancel = () {
      isCancelled = true;
      timer?.cancel();
      if (!controller.isClosed) {
        controller.close();
      }
    };

    return controller.stream;
  }

  /// Creates a stream from a one-time fetch with error handling
  static Stream<T> createSingleStream<T>({
    required Future<T> Function() fetchData,
  }) {
    final controller = StreamController<T>();

    fetchData().then((data) {
      if (!controller.isClosed) {
        controller.add(data);
        controller.close();
      }
    }).catchError((error, stack) {
      if (!controller.isClosed) {
        controller.addError(error, stack);
        controller.close();
      }
    });

    return controller.stream;
  }
}

/// Mixin for repositories that use polling streams
mixin PollingStreamMixin {
  final Map<String, StreamController> _activeControllers = {};

  /// Creates a cached polling stream that shares the same stream for same key
  Stream<T> getOrCreatePollingStream<T>({
    required String key,
    required Future<T> Function() fetchData,
    Duration interval = const Duration(seconds: 30),
  }) {
    if (_activeControllers.containsKey(key)) {
      return _activeControllers[key]!.stream as Stream<T>;
    }

    final stream = StreamHelper.createPollingStream(
      fetchData: fetchData,
      interval: interval,
    );

    return stream;
  }

  /// Disposes all active stream controllers
  void disposePollingStreams() {
    for (final controller in _activeControllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _activeControllers.clear();
  }
}
