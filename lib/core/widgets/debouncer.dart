import 'dart:async';
import 'package:flutter/foundation.dart';

/// A class that helps debounce multiple calls to a function.
/// Useful for search bars, text field validation, etc.
class Debouncer {
  /// The duration to wait before executing the callback
  final Duration delay;
  
  /// The timer that keeps track of the delay
  Timer? _timer;

  /// Creates a debouncer with the specified delay
  Debouncer({this.delay = const Duration(milliseconds: 500)});

  /// Run the function after the specified delay
  /// If run is called again before the delay is over, the timer resets
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancel the current timer if any
  void cancel() {
    _timer?.cancel();
  }
}

/// A global instance of the debouncer for convenience
final debounce = Debouncer();
