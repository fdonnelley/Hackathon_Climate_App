import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../core/theme/app_theme.dart' show AppTheme, AppRadius;

/// Button types
enum ButtonType {
  /// Primary filled button
  primary,
  
  /// Secondary outline button
  secondary,
  
  /// Tertiary text button
  tertiary,
  
  /// Danger/error button
  danger
}

/// Custom button widget with various styles
class AppButton extends StatelessWidget {
  /// Button text
  final String text;
  
  /// Callback when button is pressed
  final VoidCallback? onPressed;
  
  /// Button type
  final ButtonType type;
  
  /// Loading state
  final bool isLoading;
  
  /// Full width button
  final bool fullWidth;
  
  /// Button icon
  final IconData? icon;
  
  /// Icon position
  final bool iconLeading;
  
  /// Button size
  final double? height;
  
  /// Button padding
  final EdgeInsets? padding;
  
  /// Button border radius
  final double? borderRadius;
  
  /// Creates an app button
  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
    this.iconLeading = true,
    this.height = 48.0,
    this.padding,
    this.borderRadius,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Button styles based on type
    ButtonStyle getButtonStyle() {
      switch (type) {
        case ButtonType.primary:
          return ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.m),
            ),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            minimumSize: Size(fullWidth ? double.infinity : 0, height ?? 48),
          );
        case ButtonType.secondary:
          return OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            side: BorderSide(color: theme.colorScheme.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.m),
            ),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            minimumSize: Size(fullWidth ? double.infinity : 0, height ?? 48),
          );
        case ButtonType.tertiary:
          return TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.m),
            ),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            minimumSize: Size(fullWidth ? double.infinity : 0, height ?? 48),
          );
        case ButtonType.danger:
          return ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.m),
            ),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            minimumSize: Size(fullWidth ? double.infinity : 0, height ?? 48),
          );
      }
    }
    
    // Button content with loading state
    Widget content = isLoading
        ? _buildLoadingIndicator(context)
        : _buildButtonContent(context);
    
    // Button based on type
    Widget button;
    switch (type) {
      case ButtonType.primary:
      case ButtonType.danger:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: getButtonStyle(),
          child: content,
        );
        break;
      case ButtonType.secondary:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: getButtonStyle(),
          child: content,
        );
        break;
      case ButtonType.tertiary:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: getButtonStyle(),
          child: content,
        );
        break;
    }
    
    return button;
  }
  
  /// Build loading indicator
  Widget _buildLoadingIndicator(BuildContext context) {
    final theme = Theme.of(context);
    
    Color color;
    switch (type) {
      case ButtonType.primary:
      case ButtonType.danger:
        color = Colors.white;
        break;
      case ButtonType.secondary:
      case ButtonType.tertiary:
        color = theme.colorScheme.primary;
        break;
    }
    
    return SpinKitFadingCircle(
      color: color,
      size: 24.0,
    );
  }
  
  /// Build button content with text and icon
  Widget _buildButtonContent(BuildContext context) {
    final textWidget = Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
    
    if (icon == null) {
      return textWidget;
    }
    
    final iconWidget = Icon(icon, size: 20);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconLeading
          ? [
              iconWidget,
              const SizedBox(width: 8),
              textWidget,
            ]
          : [
              textWidget,
              const SizedBox(width: 8),
              iconWidget,
            ],
    );
  }
}
