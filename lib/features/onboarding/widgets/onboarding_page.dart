import 'package:flutter/material.dart';

/// A widget for displaying a single onboarding page
class OnboardingPage extends StatelessWidget {
  /// The title of the onboarding page
  final String title;
  
  /// The description of the onboarding page
  final String description;
  
  /// The icon or image to display
  final Widget? icon;
  
  /// Optional custom widget to display below the description
  final Widget? extraContent;
  
  /// The color to use for the page background, icon, and title text
  final Color? color;
  
  /// The asset image path to display (if [icon] is not provided)
  final String? imagePath;
  
  /// If true, the image will be displayed as a lottie animation
  final bool isLottie;
  
  /// Constructor for an onboarding page
  const OnboardingPage({
    Key? key,
    required this.title,
    required this.description,
    this.icon,
    this.extraContent,
    this.color,
    this.imagePath,
    this.isLottie = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final pageColor = color ?? colorScheme.primary;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon or image
          if (icon != null)
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 24.0),
                child: icon,
              ),
            )
          else if (imagePath != null)
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 24.0),
                child: isLottie
                    ? Container() // Replace with your Lottie animation if needed
                    : Image.asset(
                        imagePath!,
                        fit: BoxFit.contain,
                      ),
              ),
            )
          else
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 24.0),
                decoration: BoxDecoration(
                  color: pageColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  size: 100,
                  color: pageColor,
                ),
              ),
            ),
            
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              color: pageColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          
          if (extraContent != null) 
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: extraContent,
            ),
            
          // Bottom space
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
