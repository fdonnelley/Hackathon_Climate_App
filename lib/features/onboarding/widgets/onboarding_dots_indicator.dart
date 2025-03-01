import 'package:flutter/material.dart';

/// Widget that displays dots to indicate the current page in a PageView
class OnboardingDotsIndicator extends StatelessWidget {
  /// The current page index
  final int currentPage;
  
  /// The total number of pages
  final int pageCount;
  
  /// The size of each dot
  final double dotSize;
  
  /// The color of the active dot
  final Color? activeColor;
  
  /// The color of inactive dots
  final Color? inactiveColor;
  
  /// The spacing between dots
  final double spacing;
  
  /// Constructor for dot indicators
  const OnboardingDotsIndicator({
    Key? key,
    required this.currentPage,
    required this.pageCount,
    this.dotSize = 10.0,
    this.activeColor,
    this.inactiveColor,
    this.spacing = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          height: dotSize,
          width: index == currentPage ? dotSize * 3 : dotSize,
          decoration: BoxDecoration(
            color: index == currentPage
                ? (activeColor ?? colorScheme.primary)
                : (inactiveColor ?? colorScheme.onSurface.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(dotSize / 2),
          ),
        ),
      ),
    );
  }
}
