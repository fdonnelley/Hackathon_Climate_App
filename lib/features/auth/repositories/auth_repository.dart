import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/storage_service.dart';
import '../models/user_model.dart';

/// Repository for authentication operations
class AuthRepository {
  /// API client for network requests
  final ApiClient _apiClient = ApiClient();
  
  /// Storage service for local data
  final StorageService _storageService = Get.find<StorageService>();
  
  /// Base endpoint for auth requests
  final String _authEndpoint = '/auth';
  
  /// Login with email and password
  Future<ApiResponse<UserModel>> login(String email, String password) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Check registered users for matching email/password
      final registeredUsers = getRegisteredUsers();
      UserModel? matchedUser;
      
      // Find user with matching email AND password
      for (final user in registeredUsers) {
        if (user.email.toLowerCase() == email.toLowerCase() && user.password == password) {
          matchedUser = user;
          break;
        }
      }
      
      // Special case for the default test account
      if (matchedUser == null && email == 'test@example.com' && password == 'password') {
        matchedUser = UserModel(
          id: '1',
          email: email,
          name: 'Test User',
          photoUrl: 'https://i.pravatar.cc/150?img=1',
          password: password,
        );
      }
      
      if (matchedUser != null) {
        // Save current user session data
        await _storageService.setSecure('user_data', matchedUser.toMap());
        await _storageService.setSecure('auth_token', 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
        
        // Return user without password for security
        final sanitizedUser = matchedUser.copyWith(password: null);
        return ApiResponse.success(sanitizedUser);
      } else {
        // Look for email without checking password to give appropriate error
        final emailExists = registeredUsers.any((user) => user.email.toLowerCase() == email.toLowerCase());
        if (emailExists) {
          return ApiResponse.error('Incorrect password');
        } else {
          return ApiResponse.error('User not found');
        }
      }
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
  
  /// Sign up with email and password
  Future<ApiResponse<UserModel>> signup(String name, String email, String password) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Validate email format
      if (!GetUtils.isEmail(email)) {
        return ApiResponse.error('Please enter a valid email address');
      }
      
      // Validate password length
      if (password.length < 6) {
        return ApiResponse.error('Password must be at least 6 characters');
      }
      
      // Check if email already exists
      final registeredUsers = getRegisteredUsers();
      final emailExists = registeredUsers.any((user) => user.email.toLowerCase() == email.toLowerCase());
      
      if (emailExists) {
        return ApiResponse.error('Email already registered');
      }
      
      // Create new user with password
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        photoUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}',
        password: password, // Store password
      );
      
      // Store in current session
      await _storageService.setSecure('user_data', user.toMap());
      await _storageService.setSecure('auth_token', 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
      
      // Save registered user for future logins
      await saveRegisteredUser(user);
      
      // Return user without password for security
      final sanitizedUser = user.copyWith(password: null);
      return ApiResponse.success(sanitizedUser);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
  
  /// Log out
  Future<void> logout() async {
    // Only clear the auth token and current user data, but preserve registered user info
    await _storageService.deleteSecure('auth_token');
    await _storageService.deleteSecure('user_data');
  }
  
  /// Save a registered user
  Future<void> saveRegisteredUser(UserModel user) async {
    // Get existing registered users
    final registeredUsers = getRegisteredUsers();
    
    // Check if user already exists
    bool userExists = registeredUsers.any((u) => u.email.toLowerCase() == user.email.toLowerCase());
    
    // If user doesn't exist, add them
    if (!userExists) {
      registeredUsers.add(user);
      
      // Convert to list of maps for storage
      final userMaps = registeredUsers.map((u) => u.toMap()).toList();
      
      // Store the updated list
      await _storageService.set('registered_users', userMaps);
    } else {
      // Update existing user (e.g., in case password changed)
      final index = registeredUsers.indexWhere((u) => u.email.toLowerCase() == user.email.toLowerCase());
      if (index >= 0) {
        registeredUsers[index] = user;
        
        // Convert to list of maps for storage
        final userMaps = registeredUsers.map((u) => u.toMap()).toList();
        
        // Store the updated list
        await _storageService.set('registered_users', userMaps);
      }
    }
  }
  
  /// Get all registered users
  List<UserModel> getRegisteredUsers() {
    final userMaps = _storageService.get('registered_users');
    
    if (userMaps == null) return [];
    
    // If stored as JSON string, parse it
    if (userMaps is String) {
      try {
        final List<dynamic> parsedList = json.decode(userMaps);
        return parsedList.map((map) => UserModel.fromMap(map)).toList();
      } catch (e) {
        print('Error parsing registered users: $e');
        return [];
      }
    }
    
    // If stored as List, convert each map to UserModel
    if (userMaps is List) {
      return userMaps.map((map) => UserModel.fromMap(map)).toList();
    }
    
    return [];
  }
  
  /// Retrieve user profile
  Future<ApiResponse<UserModel>> getUserProfile() async {
    try {
      // In a real app, this would fetch the user profile from your API
      // For demo purposes, we'll just return the stored user
      final userData = _storageService.getSecure('user_data');
      if (userData != null) {
        return ApiResponse.success(UserModel.fromMap(userData));
      }
      return ApiResponse.error('User not found');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
  
  /// Reset password
  Future<ApiResponse<bool>> resetPassword(String email) async {
    try {
      // In a real app, this would send a password reset email
      // For demo purposes, we'll simulate a network delay and success
      await Future.delayed(const Duration(seconds: 1));
      
      // Validate email format
      if (!GetUtils.isEmail(email)) {
        return ApiResponse.error('Please enter a valid email address');
      }
      
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
  
  /// Update user profile
  Future<ApiResponse<UserModel>> updateProfile(UserModel updatedUser) async {
    try {
      // In a real app, this would update the user profile via your API
      // For demo purposes, we'll simulate a network delay and success
      await Future.delayed(const Duration(seconds: 1));
      
      // Save updated user
      await _storageService.setSecure('user_data', updatedUser.toMap());
      
      return ApiResponse.success(updatedUser);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
  
  /// Check if user is logged in
  bool isLoggedIn() {
    return _storageService.getSecure('auth_token') != null;
  }
  
  /// Get current user
  UserModel? getCurrentUser() {
    final userData = _storageService.getSecure('user_data');
    if (userData != null) {
      return UserModel.fromMap(userData);
    }
    return null;
  }
}
