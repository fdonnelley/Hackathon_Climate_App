import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration that loads from .env file
class AppConfig {
  static Future<void> initialize() async {
    await dotenv.load();
  }

  /// API base URL for network requests
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'https://api.example.com';
  
  /// API timeout in milliseconds
  static int get apiTimeout => int.parse(dotenv.env['API_TIMEOUT'] ?? '30000');
  
  /// Whether analytics are enabled
  static bool get enableAnalytics => dotenv.env['ENABLE_ANALYTICS'] == 'true';
  
  /// Whether crashlytics is enabled
  static bool get enableCrashlytics => dotenv.env['ENABLE_CRASHLYTICS'] == 'true';
  
  /// Whether push notifications are enabled
  static bool get enablePushNotifications => dotenv.env['ENABLE_PUSH_NOTIFICATIONS'] == 'true';
  
  /// Application name
  static String get appName => dotenv.env['APP_NAME'] ?? 'Hackathon App';
  
  /// Current environment (development, staging, production)
  static String get environment => dotenv.env['APP_ENV'] ?? 'development';
  
  /// Whether the app is running in development mode
  static bool get isDevelopment => environment == 'development';
  
  /// Whether the app is running in production mode
  static bool get isProduction => environment == 'production';
}
