import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/storage/storage_service.dart';
import '../../../routes/app_routes.dart';

/// Controller for the onboarding flow
class OnboardingController extends GetxController {
  // Page controller for onboarding slides
  final pageController = PageController();
  
  // Current page index
  final RxInt currentPage = 0.obs;
  
  // Storage service for persisting onboarding completion status
  final StorageService _storageService = Get.find<StorageService>();
  
  // Key for storing onboarding status
  static const String _hasCompletedOnboardingKey = 'has_completed_onboarding';
  
  // Number of onboarding pages
  static const int pageCount = 3;
  
  // Check if the user has already completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    return _storageService.get(_hasCompletedOnboardingKey, defaultValue: false);
  }
  
  // Mark onboarding as completed
  Future<void> completeOnboarding() async {
    await _storageService.set(_hasCompletedOnboardingKey, true);
  }
  
  // Reset onboarding status (for testing)
  Future<void> resetOnboarding() async {
    await _storageService.set(_hasCompletedOnboardingKey, false);
  }
  
  // Go to the next page
  void nextPage() {
    if (currentPage.value < pageCount - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      finishOnboarding();
    }
  }
  
  // Go to the previous page
  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  // Skip to the last page
  void skipToEnd() {
    pageController.animateToPage(
      pageCount - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
  
  // Skip onboarding and go to login screen
  void skipOnboarding() async {
    await completeOnboarding();
    Get.offAllNamed(AppRoutes.getRouteName(AppRoute.login));
  }
  
  // Finish onboarding and proceed to the login screen
  void finishOnboarding() async {
    await completeOnboarding();
    Get.offAllNamed(AppRoutes.getRouteName(AppRoute.login));
  }
  
  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

/// Binding for onboarding related dependencies
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}
