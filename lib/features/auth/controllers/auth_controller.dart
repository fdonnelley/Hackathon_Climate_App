import 'dart:convert';

import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/storage_service.dart';
import '../../../routes/app_routes.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

/// Controller for managing authentication state
class AuthController extends GetxController {
  /// Auth repository for authentication operations
  final AuthRepository _authRepository = AuthRepository();
  
  /// User state
  final Rx<UserModel?> _user = Rx<UserModel?>(null);
  
  /// Get current user
  UserModel? get currentUser => _user.value;
  
  /// Is authenticated status
  final RxBool isAuthenticated = false.obs;
  
  /// Auth state
  final RxBool _isLoggedIn = false.obs;
  bool get isLoggedIn => _isLoggedIn.value;
  
  /// Loading state
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  
  /// Error message
  final RxString errorMessage = ''.obs;
  
  /// Initialize the controller
  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }
  
  /// Check if user is logged in
  Future<void> checkLoginStatus() async {
    try {
      final service = Get.find<StorageService>();
      if (!service.isInitialized) {
        _isLoggedIn.value = false;
        isAuthenticated.value = false;
        return;
      }
      
      // Check for token
      final token = service.getSecure('auth_token');
      if (token != null) {
        // Get user data
        final userData = service.getSecure('user_data');
        if (userData != null) {
          if (userData is Map<String, dynamic>) {
            _user.value = UserModel.fromMap(userData);
          } else if (userData is String) {
            // Handle the case where userData is stored as a string
            try {
              final Map<String, dynamic> jsonData = json.decode(userData);
              _user.value = UserModel.fromMap(jsonData);
            } catch (e) {
              print('Error parsing user data: $e');
              _user.value = null;
            }
          }
        }
        
        _isLoggedIn.value = true;
        isAuthenticated.value = true;
      } else {
        _isLoggedIn.value = false;
        isAuthenticated.value = false;
      }
    } catch (e) {
      print('Error checking login status: $e');
      _isLoggedIn.value = false;
      isAuthenticated.value = false;
    }
  }
  
  /// Get registered users
  List<UserModel> getRegisteredUsers() {
    return _authRepository.getRegisteredUsers();
  }
  
  /// Login user
  Future<bool> login(String email, String password) async {
    _isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final response = await _authRepository.login(email, password);
      
      if (response.status == ApiStatus.success && response.data != null) {
        // Store user data
        _user.value = response.data;
        
        _isLoggedIn.value = true;
        isAuthenticated.value = true;
        _isLoading.value = false;
        return true;
      } else {
        _isLoading.value = false;
        errorMessage.value = response.message ?? 'Login failed';
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      _isLoading.value = false;
      errorMessage.value = e.toString();
      return false;
    }
  }
  
  /// Sign up with email and password
  Future<bool> signup(String name, String email, String password) async {
    try {
      _isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _authRepository.signup(name, email, password);
      
      if (response.status == ApiStatus.success && response.data != null) {
        _user.value = response.data;
        _isLoggedIn.value = true;
        isAuthenticated.value = true;
        return true;
      } else {
        errorMessage.value = response.message ?? 'Signup failed';
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Log out
  Future<void> logout() async {
    _isLoading.value = true;
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Here would be the actual API call to logout on server
      await _authRepository.logout();
      
      // Clear user data
      _user.value = null;
      
      _isLoggedIn.value = false;
      isAuthenticated.value = false;
      
      // Always navigate to login screen after logout
      Get.offAllNamed(AppRoutes.getRouteName(AppRoute.login));
    } catch (e) {
      print('Logout error: $e');
      errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _authRepository.resetPassword(email);
      
      if (response.status == ApiStatus.success) {
        return true;
      } else {
        errorMessage.value = response.message ?? 'Password reset failed';
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Update user profile
  Future<bool> updateProfile(UserModel user) async {
    _isLoading.value = true;
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Here would be the actual API call
      final response = await _authRepository.updateProfile(user);
      
      if (response.status == ApiStatus.success && response.data != null) {
        // Update user data
        _user.value = response.data;
        
        _isLoading.value = false;
        return true;
      } else {
        _isLoading.value = false;
        errorMessage.value = response.message ?? 'Profile update failed';
        return false;
      }
    } catch (e) {
      print('Update profile error: $e');
      _isLoading.value = false;
      errorMessage.value = e.toString();
      return false;
    }
  }
  
  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }
}
