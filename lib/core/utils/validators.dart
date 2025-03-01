import 'package:get/get.dart';

/// Utility class for form validation
class Validators {
  /// Validate email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
  
  /// Validate password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
  
  /// Validate required field
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }
  
  /// Validate name
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }
  
  /// Validate phone number
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone number might be optional
    }
    if (!GetUtils.isPhoneNumber(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
  
  /// Validate confirm password
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
  
  /// Validate URL
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL might be optional
    }
    if (!GetUtils.isURL(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }
  
  /// Validate minimum length
  static String? minLength(String? value, int minLength, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return null; // This validator only checks length, not if it's required
    }
    if (value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    }
    return null;
  }
  
  /// Validate maximum length
  static String? maxLength(String? value, int maxLength, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return null; // This validator only checks length, not if it's required
    }
    if (value.length > maxLength) {
      return '${fieldName ?? 'This field'} must not exceed $maxLength characters';
    }
    return null;
  }
  
  /// Validate numeric value
  static String? numeric(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return null; // This validator only checks if it's numeric, not if it's required
    }
    if (!GetUtils.isNumericOnly(value)) {
      return '${fieldName ?? 'This field'} must contain only numbers';
    }
    return null;
  }
}
