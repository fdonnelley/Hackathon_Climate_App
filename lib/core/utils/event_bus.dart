import 'dart:async';
import 'package:get/get.dart';

/// A simple event bus implementation for app-wide communication
class EventBus extends GetxService {
  /// Singleton instance
  static final EventBus _instance = EventBus._internal();
  
  /// Get the singleton instance
  factory EventBus() => _instance;
  
  /// Private constructor
  EventBus._internal();
  
  /// Stream controllers for different event types
  final Map<Type, StreamController<dynamic>> _controllers = {};
  
  /// Get a stream of specific event type
  Stream<T> on<T>() {
    if (!_controllers.containsKey(T)) {
      // Create a broadcast controller for this event type
      _controllers[T] = StreamController<T>.broadcast();
    }
    return _controllers[T]!.stream as Stream<T>;
  }
  
  /// Fire an event
  void fire<T>(T event) {
    if (_controllers.containsKey(T)) {
      _controllers[T]!.add(event);
    }
  }
  
  /// Dispose all controllers
  void dispose() {
    for (var controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
}

/// Base class for all events
abstract class AppEvent {}

/// Example events - add your own as needed

/// Network status change event
class NetworkStatusEvent extends AppEvent {
  final bool isConnected;
  
  NetworkStatusEvent(this.isConnected);
}

/// User logged in event
class UserLoggedInEvent extends AppEvent {
  final String userId;
  
  UserLoggedInEvent(this.userId);
}

/// User logged out event
class UserLoggedOutEvent extends AppEvent {}

/// App theme changed event
class ThemeChangedEvent extends AppEvent {
  final bool isDarkMode;
  
  ThemeChangedEvent(this.isDarkMode);
}

/// New notification event
class NotificationEvent extends AppEvent {
  final String title;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  
  NotificationEvent({
    required this.title,
    required this.message,
    DateTime? timestamp,
    this.data,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Data updated event
class DataUpdatedEvent<T> extends AppEvent {
  final T data;
  final String source;
  
  DataUpdatedEvent(this.data, {this.source = 'unknown'});
}

/// Example usage:
/// 
/// ```dart
/// // Listen for an event
/// EventBus().on<UserLoggedInEvent>().listen((event) {
///   print('User logged in: ${event.userId}');
/// });
/// 
/// // Fire an event
/// EventBus().fire(UserLoggedInEvent('user123'));
/// ```
