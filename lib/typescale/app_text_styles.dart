import 'package:flutter/material.dart';

/// A class that defines text styles for the application.
///
/// This helps maintain consistent typography throughout the app
/// and makes it easy to update text styles in one place.
class AppTextStyles {
  /// Private constructor to prevent instantiation
  AppTextStyles._();

  /// The base font family for the application
  static const String _fontFamily = 'Poppins';
  
  /// Primary color for text
  static const Color _primaryTextColor = Colors.black87;
  
  /// Secondary color for subtitles, captions, etc.
  static const Color _secondaryTextColor = Colors.black54;

  /// Style for headings (large, bold text)
  static final TextStyle heading = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    color: _primaryTextColor,
    letterSpacing: -0.5,
  );
  
  /// Style for subheadings (medium-sized, semibold text)
  static final TextStyle subheading = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: _primaryTextColor,
    letterSpacing: -0.25,
  );

  /// Style for body text (regular text used in most content)
  static final TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: _primaryTextColor,
    height: 1.5,
  );
  
  /// Style for caption text (smaller text used for captions)
  static final TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: _secondaryTextColor,
    height: 1.4,
  );

  /// Style for button text
  static final TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );
  
  /// Style for error messages
  static final TextStyle error = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: Colors.red[700],
    height: 1.4,
  );
}
