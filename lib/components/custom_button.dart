import 'package:flutter/material.dart';
import '../typescale/app_text_styles.dart';

/// A custom button component with consistent styling.
///
/// This button can be configured with different text, colors,
/// and behaviors while maintaining the app's visual identity.
class CustomButton extends StatelessWidget {
  /// The text to display on the button
  final String text;
  
  /// The function to call when the button is pressed
  final VoidCallback? onPressed;
  
  /// Optional icon to display before the text
  final IconData? icon;
  
  /// Whether the button should take the full available width
  final bool fullWidth;
  
  /// Whether to use an outlined style instead of filled
  final bool outlined;
  
  /// Custom background color (if not using outlined style)
  final Color? backgroundColor;
  
  /// Loading state that shows a progress indicator instead of text
  final bool isLoading;

  /// Creates a custom button with the specified parameters.
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.fullWidth = true,
    this.outlined = false,
    this.backgroundColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine button style based on parameters
    final buttonStyle = outlined
        ? OutlinedButton.styleFrom(
            side: BorderSide(color: theme.colorScheme.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? theme.colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          );

    // Create the button child (either loading indicator or text with optional icon)
    Widget buttonChild = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                outlined ? theme.colorScheme.primary : Colors.white,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: outlined
                    ? AppTextStyles.button.copyWith(
                        color: theme.colorScheme.primary,
                      )
                    : AppTextStyles.button,
              ),
            ],
          );

    // Return the appropriate button type
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: outlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: buttonChild,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: buttonChild,
            ),
    );
  }
}
