import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_constants.dart';
import '../../core/storage/storage_service.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/app_loading.dart'; 
import '../auth/controllers/auth_controller.dart';
import '../onboarding/controllers/onboarding_controller.dart';

class SplashScreen extends StatefulWidget {
  static String get routeName => AppRoutes.getRouteName(AppRoute.splash);

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  // Controllers
  final AuthController _authController = Get.find<AuthController>();
  final StorageService _storageService = Get.find<StorageService>();
  
  // Track initialization status
  bool _isInitializing = true;
  String? _initializationError;

  // Animation controller
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Set up animations
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    // Start animation
    _controller.forward();
    
    // Initialize and navigate after delay
    _initializeAndNavigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeAndNavigate() async {
    try {
      // Delay for splash animation
      await Future.delayed(const Duration(seconds: 2));
      
      // Check if storage is available
      if (!_storageService.isInitialized) {
        setState(() {
          _isInitializing = false;
          _initializationError = 'Storage initialization failed. Some features may be limited.';
        });
        
        // Display error for a short time before proceeding
        await Future.delayed(const Duration(seconds: 2));
      }
      
      // Check auth status
      await _authController.checkLoginStatus();
      
      // Navigate to appropriate screen based on auth status
      _navigateToNextScreen();
    } catch (error) {
      setState(() {
        _isInitializing = false;
        _initializationError = 'Failed to initialize: $error';
      });
      
      // Display error for a short time before proceeding to login
      await Future.delayed(const Duration(seconds: 3));
      Get.offAllNamed(AppRoutes.getRouteName(AppRoute.login));
    }
  }

  void _navigateToNextScreen() async {
    // Add a small delay for a smoother experience
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Get the auth controller
    final authController = Get.find<AuthController>();
    
    // Initialize the onboarding controller
    final onboardingController = Get.put(OnboardingController());
    
    // Check if the user has completed onboarding
    final hasCompletedOnboarding = await onboardingController.hasCompletedOnboarding();
    
    // Check if the user is logged in
    final isLoggedIn = authController.isLoggedIn;
    
    // Navigate based on conditions:
    // 1. If user hasn't completed onboarding, show onboarding
    // 2. If user completed onboarding but not logged in, show login
    // 3. If user is logged in, show home
    if (!hasCompletedOnboarding) {
      Get.offAllNamed(AppRoutes.getRouteName(AppRoute.onboarding));
    } else if (isLoggedIn) {
      Get.offAllNamed(AppRoutes.getRouteName(AppRoute.home));
    } else {
      Get.offAllNamed(AppRoutes.getRouteName(AppRoute.login));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeInAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Logo
                          Container(
                            width: 180,
                            height: 180,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              AppConstants.logoImage,
                              width: 120,
                              height: 120,
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // App name
                          Text(
                            AppConstants.appName,
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Tagline
                          Text(
                            'Track, Reduce, Save the Planet',
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Loading indicator or error message
                          if (_isInitializing)
                            const AppLoading(message: 'Initializing...')
                          else if (_initializationError != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: colorScheme.error,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _initializationError!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: colorScheme.error,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
