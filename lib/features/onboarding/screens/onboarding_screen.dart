import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/animations/app_animations.dart';
import '../../../routes/app_routes.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_dots_indicator.dart';
import '../widgets/onboarding_page.dart';

/// Screen that displays the onboarding experience to new users
class OnboardingScreen extends StatelessWidget {
  /// Route name getter
  static String get routeName => AppRoutes.getRouteName(AppRoute.onboarding);

  /// Constructor
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the onboarding controller
    final OnboardingController controller = Get.find<OnboardingController>();
    
    // Theme data
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0, right: 16.0),
                child: TextButton(
                  onPressed: controller.skipOnboarding,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            
            // Page view with onboarding content
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: (index) => controller.currentPage.value = index,
                children: [
                  // Page 1: Welcome
                  OnboardingPage(
                    title: 'Welcome to Base App',
                    description: 'Your ultimate hackathon companion with everything you need to build amazing apps quickly!',
                    icon: Icon(
                      Icons.rocket_launch,
                      size: 120,
                      color: colorScheme.primary,
                    ),
                    color: colorScheme.primary,
                  ),
                  
                  // Page 2: Features
                  OnboardingPage(
                    title: 'Powerful Features',
                    description: 'Authentication, storage, networking, and UI components are ready to use out of the box.',
                    icon: Icon(
                      Icons.dashboard_customize,
                      size: 120,
                      color: colorScheme.secondary,
                    ),
                    color: colorScheme.secondary,
                  ),
                  
                  // Page 3: Get Started
                  OnboardingPage(
                    title: 'Ready, Set, Code!',
                    description: 'Start building your next great idea now. Your hackathon success starts here!',
                    icon: Icon(
                      Icons.code,
                      size: 120,
                      color: colorScheme.tertiary,
                    ),
                    color: colorScheme.tertiary,
                    extraContent: Padding(
                      padding: const EdgeInsets.only(top: 32.0),
                      child: ElevatedButton(
                        onPressed: controller.finishOnboarding,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.tertiary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32.0,
                            vertical: 16.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Navigation controls
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 32.0,
                horizontal: 24.0,
              ),
              child: Column(
                children: [
                  // Dots indicator
                  Obx(
                    () => OnboardingDotsIndicator(
                      currentPage: controller.currentPage.value,
                      pageCount: OnboardingController.pageCount,
                      activeColor: [
                        colorScheme.primary,
                        colorScheme.secondary,
                        colorScheme.tertiary,
                      ][controller.currentPage.value],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Next/Previous buttons
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Previous button
                        Visibility(
                          visible: controller.currentPage.value > 0,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: IconButton(
                            onPressed: controller.previousPage,
                            icon: const Icon(Icons.arrow_back_rounded),
                            color: colorScheme.onBackground,
                          ),
                        ),
                        
                        // Next button (hidden on last page)
                        if (controller.currentPage.value < OnboardingController.pageCount - 1)
                          IconButton(
                            onPressed: controller.nextPage,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            color: [
                              colorScheme.primary,
                              colorScheme.secondary,
                              colorScheme.tertiary,
                            ][controller.currentPage.value],
                          )
                        else
                          const SizedBox(width: 48), // Placeholder to maintain layout
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
