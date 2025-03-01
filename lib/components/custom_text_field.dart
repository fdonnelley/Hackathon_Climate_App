import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../typescale/app_text_styles.dart';

/// A custom text field component with consistent styling and validation.
///
/// This text field can be configured for different input types while
/// maintaining the app's visual identity and providing common validation.
class CustomTextField extends StatelessWidget {
  /// Controller for the text input
  final TextEditingController? controller;
  
  /// Label text to display above the field
  final String label;
  
  /// Hint text to display when the field is empty
  final String? hint;
  
  /// Whether to obscure the text (for passwords)
  final bool obscureText;
  
  /// Optional icon to display at the start of the field
  final IconData? prefixIcon;
  
  /// Optional icon to display at the end of the field
  final IconData? suffixIcon;
  
  /// Function to call when the suffix icon is tapped
  final VoidCallback? onSuffixIconPressed;
  
  /// Keyboard type to display (e.g., email, number)
  final TextInputType keyboardType;
  
  /// Function to validate the input
  final String? Function(String?)? validator;
  
  /// Function to call when the text changes
  final void Function(String)? onChanged;
  
  /// Maximum length of input
  final int? maxLength;
  
  /// Whether the field is enabled
  final bool enabled;
  
  /// Input formatters for special formatting requirements
  final List<TextInputFormatter>? inputFormatters;
  
  /// Creates a custom text field with the specified parameters.
  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.maxLength,
    this.enabled = true,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label above the field
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        // Text form field with custom styling
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          maxLength: maxLength,
          enabled: enabled,
          inputFormatters: inputFormatters,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body.copyWith(
              color: Colors.black38,
            ),
            errorStyle: AppTextStyles.error,
            filled: true,
            fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: Colors.red[700]!,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: Colors.red[700]!,
                width: 2.0,
              ),
            ),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon),
                    onPressed: onSuffixIconPressed,
                  )
                : null,
            counterText: '', // Hide character counter
          ),
        ),
      ],
    );
  }

  /// Factory constructor for creating an email text field.
  factory CustomTextField.email({
    TextEditingController? controller,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return CustomTextField(
      controller: controller,
      label: 'Email Address',
      hint: 'example@email.com',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
      onChanged: onChanged,
      enabled: enabled,
    );
  }

  /// Factory constructor for creating a password text field.
  factory CustomTextField.password({
    TextEditingController? controller,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
    bool obscureText = true,
    VoidCallback? onSuffixIconPressed,
    bool enabled = true,
  }) {
    return CustomTextField(
      controller: controller,
      label: 'Password',
      hint: '••••••••',
      obscureText: obscureText,
      prefixIcon: Icons.lock_outline,
      suffixIcon: obscureText ? Icons.visibility : Icons.visibility_off,
      onSuffixIconPressed: onSuffixIconPressed,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
      onChanged: onChanged,
      enabled: enabled,
    );
  }
}
