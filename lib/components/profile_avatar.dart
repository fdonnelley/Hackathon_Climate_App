import 'package:flutter/material.dart';

/// A reusable profile avatar component.
///
/// This component displays a profile avatar with either an image
/// or initials, and can be configured with different sizes and styles.
class ProfileAvatar extends StatelessWidget {
  /// The size of the avatar (diameter)
  final double size;
  
  /// Optional image URL for the avatar
  final String? imageUrl;
  
  /// User's name or display name (used for initials if no image)
  final String name;
  
  /// Background color when showing initials
  final Color? backgroundColor;
  
  /// Border color for the avatar
  final Color? borderColor;
  
  /// Border width for the avatar
  final double borderWidth;
  
  /// Whether to add a border
  final bool hasBorder;
  
  /// Whether the avatar is clickable
  final bool isInteractive;
  
  /// Function to call when the avatar is tapped
  final VoidCallback? onTap;

  /// Creates a profile avatar with the specified parameters.
  const ProfileAvatar({
    super.key,
    this.size = 40.0,
    this.imageUrl,
    required this.name,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 2.0,
    this.hasBorder = false,
    this.isInteractive = false,
    this.onTap,
  });

  /// Get the initials from the name (first letter of first and last name)
  String get _getInitials {
    final nameParts = name.trim().split(' ');
    if (nameParts.isEmpty) return '';
    
    if (nameParts.length == 1) {
      return nameParts[0].isNotEmpty 
          ? nameParts[0][0].toUpperCase() 
          : '';
    }
    
    return '${nameParts[0][0]}${nameParts[nameParts.length - 1][0]}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBackgroundColor = theme.colorScheme.primary;
    
    Widget avatar = imageUrl != null && imageUrl!.isNotEmpty
        ? CircleAvatar(
            radius: size / 2,
            backgroundImage: NetworkImage(imageUrl!),
            backgroundColor: Colors.grey[200],
          )
        : CircleAvatar(
            radius: size / 2,
            backgroundColor: backgroundColor ?? defaultBackgroundColor,
            child: Text(
              _getInitials,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.35,
              ),
            ),
          );
    
    // Add border if requested
    if (hasBorder) {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? theme.colorScheme.primary.withOpacity(0.3),
            width: borderWidth,
          ),
        ),
        child: avatar,
      );
    }
    
    // Add tap behavior if interactive
    if (isInteractive) {
      return InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: avatar,
      );
    }
    
    return avatar;
  }
}
