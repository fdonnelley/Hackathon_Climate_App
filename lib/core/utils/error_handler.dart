import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Error handler utility for API and application errors
class ErrorHandler {
  /// Singleton instance
  static final ErrorHandler _instance = ErrorHandler._internal();
  
  /// Factory constructor
  factory ErrorHandler() => _instance;
  
  /// Internal constructor
  ErrorHandler._internal();
  
  /// Handle error and return user-friendly message
  String handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is SocketException) {
      return 'No internet connection. Please check your network settings.';
    } else if (error is FormatException) {
      return 'Invalid data format. Please try again later.';
    } else if (error is String) {
      return error;
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
  
  /// Handle Dio specific errors
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Unable to send data. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server is taking too long to respond. Please try again later.';
      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response?.statusCode);
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network settings.';
      case DioExceptionType.unknown:
      default:
        if (error.error is SocketException) {
          return 'No internet connection. Please check your network settings.';
        }
        return 'An unexpected error occurred. Please try again.';
    }
  }
  
  /// Handle HTTP status codes
  String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input and try again.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Forbidden. You do not have permission to access this resource.';
      case 404:
        return 'Resource not found. Please try again later.';
      case 408:
        return 'Request timeout. Please try again.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      case 504:
        return 'Gateway timeout. Please try again later.';
      default:
        return 'An error occurred with status code: $statusCode';
    }
  }
  
  /// Show error snackbar
  void showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.errorContainer,
      colorText: Get.theme.colorScheme.onErrorContainer,
      margin: EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }
  
  /// Show success snackbar
  void showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primaryContainer,
      colorText: Get.theme.colorScheme.onPrimaryContainer,
      margin: EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }
}
