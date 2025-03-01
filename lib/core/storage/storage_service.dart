import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A robust storage service with fallback mechanism
/// 
/// This service will attempt to use Hive for storage first.
/// If Hive initialization fails, it will fall back to SharedPreferences.
class StorageService extends GetxService {
  // Singleton instance
  static StorageService get instance => Get.find<StorageService>();
  
  // Storage status
  final RxBool _isInitialized = false.obs;
  final RxBool _isUsingFallback = false.obs;
  
  // Storage instances
  Box<dynamic>? _secureBox;
  Box<dynamic>? _generalBox;
  SharedPreferences? _prefs;
  
  // Status getters
  bool get isInitialized => _isInitialized.value;
  bool get isUsingFallback => _isUsingFallback.value;
  
  /// Initialize the storage service with fallback
  Future<void> initialize() async {
    try {
      // Attempt to initialize Hive
      await _initializeHive();
      _isInitialized.value = true;
      print('StorageService: Initialized with Hive');
    } catch (e) {
      print('StorageService: Hive initialization failed - $e');
      // Fallback to SharedPreferences
      try {
        await _initializeSharedPreferences();
        _isUsingFallback.value = true;
        _isInitialized.value = true;
        print('StorageService: Initialized with SharedPreferences (fallback)');
      } catch (e) {
        print('StorageService: SharedPreferences initialization failed - $e');
        _isInitialized.value = false;
        throw Exception('Failed to initialize any storage mechanism: $e');
      }
    }
  }
  
  /// Initialize Hive storage
  Future<void> _initializeHive() async {
    // Initialize Hive with a directory
    Directory directory;
    
    try {
      // Get application documents directory
      directory = await getApplicationDocumentsDirectory();
    } catch (e) {
      print('StorageService: Could not get application documents directory - $e');
      
      // Fallback to application support directory
      try {
        directory = await getApplicationSupportDirectory();
      } catch (e) {
        print('StorageService: Could not get application support directory - $e');
        
        // Fallback to temporary directory
        directory = await getTemporaryDirectory();
      }
    }
    
    // Initialize Hive with the chosen directory
    await Hive.initFlutter(directory.path);
    
    // Open the secure box
    _secureBox = await Hive.openBox('secure_box');
    
    // Open the general box
    _generalBox = await Hive.openBox('general_box');
  }
  
  /// Initialize SharedPreferences as fallback
  Future<void> _initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  /// Set a secure value in storage
  Future<void> setSecure(String key, dynamic value) async {
    _assertInitialized();
    
    // Encode complex objects to JSON if necessary
    final storedValue = _prepareValueForStorage(value);
    
    if (_isUsingFallback.value) {
      // Using SharedPreferences
      if (storedValue is String) {
        await _prefs!.setString('secure_$key', storedValue);
      } else if (storedValue is int) {
        await _prefs!.setInt('secure_$key', storedValue);
      } else if (storedValue is double) {
        await _prefs!.setDouble('secure_$key', storedValue);
      } else if (storedValue is bool) {
        await _prefs!.setBool('secure_$key', storedValue);
      } else if (storedValue is List<String>) {
        await _prefs!.setStringList('secure_$key', storedValue);
      } else {
        // Fallback to string conversion for other types
        await _prefs!.setString('secure_$key', json.encode(storedValue));
      }
    } else {
      // Using Hive
      await _secureBox!.put(key, storedValue);
    }
  }
  
  /// Get a secure value from storage
  dynamic getSecure(String key, {dynamic defaultValue}) {
    _assertInitialized();
    
    if (_isUsingFallback.value) {
      // Using SharedPreferences
      if (!_prefs!.containsKey('secure_$key')) {
        return defaultValue;
      }
      return _prefs!.get('secure_$key');
    } else {
      // Using Hive
      return _secureBox!.get(key, defaultValue: defaultValue);
    }
  }
  
  /// Set a general value in storage
  Future<void> set(String key, dynamic value) async {
    _assertInitialized();
    
    // Encode complex objects to JSON if necessary
    final storedValue = _prepareValueForStorage(value);
    
    if (_isUsingFallback.value) {
      // Using SharedPreferences
      if (storedValue is String) {
        await _prefs!.setString(key, storedValue);
      } else if (storedValue is int) {
        await _prefs!.setInt(key, storedValue);
      } else if (storedValue is double) {
        await _prefs!.setDouble(key, storedValue);
      } else if (storedValue is bool) {
        await _prefs!.setBool(key, storedValue);
      } else if (storedValue is List<String>) {
        await _prefs!.setStringList(key, storedValue);
      } else {
        // Fallback to string conversion for other types
        await _prefs!.setString(key, json.encode(storedValue));
      }
    } else {
      // Using Hive
      await _generalBox!.put(key, storedValue);
    }
  }
  
  /// Get a general value from storage
  dynamic get(String key, {dynamic defaultValue}) {
    _assertInitialized();
    
    if (_isUsingFallback.value) {
      // Using SharedPreferences
      if (!_prefs!.containsKey(key)) {
        return defaultValue;
      }
      return _prefs!.get(key);
    } else {
      // Using Hive
      return _generalBox!.get(key, defaultValue: defaultValue);
    }
  }
  
  /// Delete a secure value from storage
  Future<void> deleteSecure(String key) async {
    _assertInitialized();
    
    if (_isUsingFallback.value) {
      // Using SharedPreferences
      await _prefs!.remove('secure_$key');
    } else {
      // Using Hive
      await _secureBox!.delete(key);
    }
  }
  
  /// Delete a general value from storage
  Future<void> delete(String key) async {
    _assertInitialized();
    
    if (_isUsingFallback.value) {
      // Using SharedPreferences
      await _prefs!.remove(key);
    } else {
      // Using Hive
      await _generalBox!.delete(key);
    }
  }
  
  /// Clear all secure storage
  Future<void> clearSecure() async {
    _assertInitialized();
    
    if (_isUsingFallback.value) {
      // Using SharedPreferences
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        if (key.startsWith('secure_')) {
          await _prefs!.remove(key);
        }
      }
    } else {
      // Using Hive
      await _secureBox!.clear();
    }
  }
  
  /// Clear all general storage
  Future<void> clear() async {
    _assertInitialized();
    
    if (_isUsingFallback.value) {
      // Using SharedPreferences
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        if (!key.startsWith('secure_')) {
          await _prefs!.remove(key);
        }
      }
    } else {
      // Using Hive
      await _generalBox!.clear();
    }
  }
  
  /// Check if a secure key exists
  bool hasSecure(String key) {
    _assertInitialized();
    
    if (_isUsingFallback.value) {
      // Using SharedPreferences
      return _prefs!.containsKey('secure_$key');
    } else {
      // Using Hive
      return _secureBox!.containsKey(key);
    }
  }
  
  /// Check if a general key exists
  bool has(String key) {
    _assertInitialized();
    
    if (_isUsingFallback.value) {
      // Using SharedPreferences
      return _prefs!.containsKey(key);
    } else {
      // Using Hive
      return _generalBox!.containsKey(key);
    }
  }
  
  /// Prepare a value for storage
  dynamic _prepareValueForStorage(dynamic value) {
    if (value is Map || value is List) {
      return json.encode(value);
    }
    return value;
  }
  
  /// Assert that the storage service is initialized
  void _assertInitialized() {
    if (!_isInitialized.value) {
      throw Exception('StorageService is not initialized');
    }
  }
}
