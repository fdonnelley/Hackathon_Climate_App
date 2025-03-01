import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

/// Signup screen
class SignupScreen extends StatefulWidget {
  /// Route name
  static const String routeName = '/signup';
  
  /// Creates signup screen
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _authController = Get.find<AuthController>();
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  void _signup() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await _authController.signup(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (success) {
        // Navigate to setup flow instead of home
        Get.offAllNamed(
          AppRoutes.getRouteName(AppRoute.setup),
          arguments: {'userName': _nameController.text.trim()}
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
        elevation: 0,
      ),
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
                  // Animation
                  Container(
                    height: 160,
                    child: Icon(
                      Icons.app_registration_rounded,
                      size: 120,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Title
                  Text(
                    'Join Us Today',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  Text(
                    'Create your account',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Name field
                  AppTextField(
                    controller: _nameController,
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    validator: Validators.name,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 16),
                  
                  // Email field
                  AppTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: Validators.email,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 16),
                  
                  // Password field
                  AppTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    toggleObscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: Validators.password,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 16),
                  
                  // Confirm password field
                  AppTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    hintText: 'Confirm your password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    toggleObscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: (value) => Validators.confirmPassword(
                      value,
                      _passwordController.text,
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onSubmitted: (_) => _signup(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Signup button
                  Obx(() => AppButton(
                    text: 'Create Account',
                    onPressed: _signup,
                    isLoading: _authController.isLoading,
                    icon: Icons.arrow_forward,
                    iconLeading: false,
                  )),
                  const SizedBox(height: 16),
                  
                  // Error message
                  Obx(() {
                    final error = _authController.errorMessage.value;
                    if (error.isEmpty) return const SizedBox.shrink();
                    
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
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
                  const SizedBox(height: 24),
                  
                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.offNamed(AppRoutes.getRouteName(AppRoute.login)),
                        child: Text('Login'),
                      ),
                    ],
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
