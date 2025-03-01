import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

/// Custom text field widget
class AppTextField extends StatefulWidget {
  /// Controller for the text field
  final TextEditingController? controller;
  
  /// Hint text
  final String? hintText;
  
  /// Label text
  final String? labelText;
  
  /// Helper text
  final String? helperText;
  
  /// Error text
  final String? errorText;
  
  /// Prefix icon
  final IconData? prefixIcon;
  
  /// Suffix icon
  final IconData? suffixIcon;
  
  /// Suffix icon action
  final VoidCallback? suffixIconAction;
  
  /// Auto-validation mode
  final AutovalidateMode? autovalidateMode;
  
  /// Validator function
  final String? Function(String?)? validator;
  
  /// On changed callback
  final Function(String)? onChanged;
  
  /// On submitted callback
  final Function(String)? onSubmitted;
  
  /// Text input type
  final TextInputType? keyboardType;
  
  /// Text input action
  final TextInputAction? textInputAction;
  
  /// Text capitalization
  final TextCapitalization textCapitalization;
  
  /// Obscure text for passwords
  final bool obscureText;
  
  /// Toggle obscure text
  final bool toggleObscureText;
  
  /// Input formatters
  final List<TextInputFormatter>? inputFormatters;
  
  /// Max lines
  final int? maxLines;
  
  /// Min lines
  final int? minLines;
  
  /// Max length
  final int? maxLength;
  
  /// Focus node
  final FocusNode? focusNode;
  
  /// Read only
  final bool readOnly;
  
  /// Enabled
  final bool enabled;
  
  /// Fill color
  final Color? fillColor;
  
  /// Border radius
  final double borderRadius;
  
  /// Creates a text field
  const AppTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.labelText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixIconAction,
    this.autovalidateMode,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.toggleObscureText = false,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.focusNode,
    this.readOnly = false,
    this.enabled = true,
    this.fillColor,
    this.borderRadius = AppRadius.m,
  }) : super(key: key);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Suffix icon widget
    Widget? suffixIconWidget;
    
    if (widget.toggleObscureText) {
      suffixIconWidget = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    } else if (widget.suffixIcon != null) {
      suffixIconWidget = IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onPressed: widget.suffixIconAction,
      );
    }
    
    // Prefix icon widget
    Widget? prefixIconWidget;
    
    if (widget.prefixIcon != null) {
      prefixIconWidget = Icon(
        widget.prefixIcon,
        color: theme.colorScheme.onSurfaceVariant,
      );
    }
    
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.labelText,
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefixIcon: prefixIconWidget,
        suffixIcon: suffixIconWidget,
        filled: true,
        fillColor: widget.fillColor ?? theme.colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: const BorderSide(width: 0, style: BorderStyle.none),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      autovalidateMode: widget.autovalidateMode,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      obscureText: _obscureText,
      inputFormatters: widget.inputFormatters,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}
