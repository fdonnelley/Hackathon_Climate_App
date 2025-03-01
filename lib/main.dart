import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/config/app_config.dart';
import 'core/config/env_config.dart';
import 'core/constants/app_constants.dart';
import 'core/middleware/auth_middleware.dart';
import 'core/network/api_client.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/analytics/screens/analytics_screen.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/calendar/screens/calendar_screen.dart';
import 'features/chatbot/controllers/chatbot_controller.dart';
import 'features/home/screens/home_screen.dart';
import 'features/list/controllers/list_controller.dart';
import 'features/list/screens/list_screen.dart';
import 'features/messages/screens/messages_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/settings/controllers/settings_controller.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/splash/splash_screen.dart';
import 'routes/app_routes.dart';

void main() async {
  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter error: ${details.exception}');
  };
  
  // Capture any errors that occur during initialization
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    try {
      // Initialize environment configuration
      await EnvConfig().init();
      
      // Initialize configuration
      AppConfig.initialize();
      
      try {
        // Initialize storage service (now with fallback mechanism)
        final storageService = StorageService();
        await storageService.initialize();
        Get.put(storageService);
        
        // Initialize API client
        ApiClient().initialize();
        
        // Initialize controllers
        _registerControllers();
        
        // Launch the app
        runApp(const HackathonApp());
      } catch (e) {
        print('Services initialization error: $e');
        // Launch app in limited mode that doesn't require storage
        runApp(const HackathonApp(limitedMode: true));
      }
    } catch (e) {
      // Critical error that prevents app from functioning
      print('Critical initialization error: $e');
      runApp(ErrorApp(error: e.toString()));
    }
  }, (error, stack) {
    // Global error handler for uncaught exceptions
    print('Uncaught error: $error');
    print(stack);
  });
}

/// Register all controllers
void _registerControllers() {
  // Core services
  Get.put(StorageService());
  Get.put(ApiClient());
  
  // Controllers
  Get.put(AuthController(), permanent: true);
  Get.put(SettingsController(), permanent: true);
  Get.put(ListController(), permanent: true);
  Get.put(ChatbotController(), permanent: true);
}

/// App that displays a critical error message when initialization fails
class ErrorApp extends StatelessWidget {
  final String error;
  
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.red[900],
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.yellow,
                    size: 60,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'App Initialization Error',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    error,
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Try to restart the app
                      main();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.red[900],
                      backgroundColor: Colors.yellow,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HackathonApp extends StatelessWidget {
  /// Whether to run in limited mode with minimal features
  final bool limitedMode;
  
  /// Constructor
  const HackathonApp({this.limitedMode = false, super.key});

  @override
  Widget build(BuildContext context) {
    // Theme setup
    const themeMode = ThemeMode.system;
    
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      
      // Localization
      locale: const Locale('en', 'US'),
      
      // Navigation
      initialRoute: AppRoutes.getRouteName(AppRoute.splash),
      getPages: AppRoutes.pages,
      defaultTransition: Transition.fadeIn,
    );
  }
}
