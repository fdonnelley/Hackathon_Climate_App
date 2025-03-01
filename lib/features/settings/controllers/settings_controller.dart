import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/storage/storage_service.dart';

/// Controller for managing app settings
class SettingsController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  // Theme mode
  final RxBool isDarkMode = false.obs;
  
  // Notification settings
  final RxBool notificationsEnabled = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }
  
  /// Load settings from storage
  void _loadSettings() {
    // Load theme preference
    final darkMode = _storageService.get('dark_mode') ?? false;
    isDarkMode.value = darkMode as bool;
    
    // Load notification settings
    final notifications = _storageService.get('notifications_enabled') ?? true;
    notificationsEnabled.value = notifications as bool;
    
    // Apply theme
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
  
  /// Toggle between light and dark theme
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    _storageService.set('dark_mode', isDarkMode.value);
  }
  
  /// Toggle notifications
  void toggleNotifications() {
    notificationsEnabled.value = !notificationsEnabled.value;
    _storageService.set('notifications_enabled', notificationsEnabled.value);
  }
}
