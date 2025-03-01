import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../core/utils/validators.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

/// Forgot password screen
class ForgotPasswordScreen extends StatefulWidget {
  /// Route name
  static const String routeName = '/forgot-password';
  
  /// Creates forgot password screen
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  final _authController = Get.find<AuthController>();
  
  bool _isSuccess = false;
  
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  
  void _resetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await _authController.resetPassword(
        _emailController.text.trim(),
      );
      
      if (success) {
        setState(() {
          _isSuccess = true;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _isSuccess
                ? _buildSuccessContent(theme)
                : _buildRequestContent(theme),
          ),
        ),
      ),
    );
  }
  
  Widget _buildRequestContent(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Animation
          Container(
            height: 180,
            child: Icon(
              Icons.lock_reset_rounded,
              size: 120,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          
          // Title
          Text(
            'Forgot Password?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            'Enter your email to receive a password reset link',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Email field
          AppTextField(
            controller: _emailController,
            labelText: 'Email',
            hintText: 'Enter your email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: Validators.email,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onSubmitted: (_) => _resetPassword(),
          ),
          const SizedBox(height: 24),
          
          // Reset button
          Obx(() => AppButton(
            text: 'Reset Password',
            onPressed: _resetPassword,
            isLoading: _authController.isLoading,
            icon: Icons.mail_outline,
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
          
          // Back to login link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Remember your password?',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              TextButton(
                onPressed: () => Get.offAllNamed(AppRoutes.getRouteName(AppRoute.login)),
                child: Text('Back to Login'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuccessContent(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Success animation
        Container(
          height: 200,
          child: Icon(
            Icons.check_circle_outline_rounded,
            size: 120,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 32),
        
        // Success title
        Text(
          'Email Sent!',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        
        // Success message
        Text(
          'We have sent a password reset link to ${_emailController.text}. Please check your email inbox.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        
        // Back to login button
        AppButton(
          text: 'Back to Login',
          onPressed: () => Get.offAllNamed(AppRoutes.getRouteName(AppRoute.login)),
          type: ButtonType.secondary,
          icon: Icons.arrow_back,
        ),
      ],
    );
  }
}
