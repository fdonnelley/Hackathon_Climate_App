import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/auth/controllers/auth_controller.dart';

/// Middleware to check if user is authenticated
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    
    // If not authenticated, redirect to login
    if (!authController.isAuthenticated.value) {
      return const RouteSettings(name: '/login');
    }
    
    // Continue to the requested route
    return null;
  }
}
