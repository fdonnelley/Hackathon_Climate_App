import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../core/animations/app_animations.dart';
import '../../../core/utils/validators.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

/// Login screen
class LoginScreen extends StatefulWidget {
  /// Route name
  static const String routeName = '/login';
  
  /// Creates login screen
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final _authController = Get.find<AuthController>();
  
  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: AppAnimations.medium,
    );
    
    // Setup animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.1, 1.0, curve: AppAnimations.defaultCurve),
      ),
    );
    
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.1, 1.0, curve: AppAnimations.defaultCurve),
      ),
    );
    
    // Start animation
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await _authController.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (success) {
        Get.offAllNamed(AppRoutes.getRouteName(AppRoute.home));
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: AppAnimations.pulsate(
                        Container(
                          height: 180,
                          child: Hero(
                            tag: 'app_logo',
                            child: Icon(
                              Icons.flutter_dash,
                              size: 120,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Title with animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Text(
                        'Welcome Back',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtitle with animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Text(
                        'Sign in to your account',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Email field with animation
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _animationController.value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - _animationController.value)),
                          child: child,
                        ),
                      );
                    },
                    child: AppTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Password field with animation
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      // Delay the password field animation
                      final delayedValue = _animationController.value < 0.3 
                          ? 0.0 
                          : (_animationController.value - 0.3) / 0.7;
                      return Opacity(
                        opacity: delayedValue,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - delayedValue)),
                          child: child,
                        ),
                      );
                    },
                    child: AppTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      toggleObscureText: true,
                      textInputAction: TextInputAction.done,
                      validator: Validators.password,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onSubmitted: (_) => _login(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Forgot password with animation
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      // Delay the forgot password animation
                      final delayedValue = _animationController.value < 0.4 
                          ? 0.0 
                          : (_animationController.value - 0.4) / 0.6;
                      return Opacity(
                        opacity: delayedValue,
                        child: Transform.translate(
                          offset: Offset(0, 10 * (1 - delayedValue)),
                          child: child,
                        ),
                      );
                    },
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.getRouteName(AppRoute.forgotPassword)),
                        child: Text('Forgot Password?'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Login button with animation
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      // Delay the login button animation
                      final delayedValue = _animationController.value < 0.5 
                          ? 0.0 
                          : (_animationController.value - 0.5) / 0.5;
                      return Opacity(
                        opacity: delayedValue,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - delayedValue)),
                          child: child,
                        ),
                      );
                    },
                    child: Obx(() => AppButton(
                      text: 'Login',
                      onPressed: _login,
                      isLoading: _authController.isLoading,
                      icon: Icons.login,
                      iconLeading: false,
                    )),
                  ),
                  const SizedBox(height: 16),
                  
                  // Error message with animation
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _animationController.value,
                        child: child,
                      );
                    },
                    child: Obx(() {
                      final error = _authController.errorMessage.value;
                      if (error.isEmpty) return const SizedBox.shrink();
                      
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.error.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                error,
                                style: TextStyle(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  
                  // Signup link with animation
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      // Delay the signup link animation
                      final delayedValue = _animationController.value < 0.6 
                          ? 0.0 
                          : (_animationController.value - 0.6) / 0.4;
                      return Opacity(
                        opacity: delayedValue,
                        child: Transform.translate(
                          offset: Offset(0, 10 * (1 - delayedValue)),
                          child: child,
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.getRouteName(AppRoute.signup)),
                          child: Text('Sign Up'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
