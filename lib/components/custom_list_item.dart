import 'package:flutter/material.dart';
import '../typescale/app_text_styles.dart';

/// A custom list item component with consistent styling.
///
/// This component can be used in list views to display items with
/// title, subtitle, and optional leading/trailing elements.
class CustomListItem extends StatelessWidget {
  /// Title text for the list item
  final String title;
  
  /// Optional subtitle text
  final String? subtitle;
  
  /// Optional leading widget (typically an icon or avatar)
  final Widget? leading;
  
  /// Optional trailing widget (typically an icon or button)
  final Widget? trailing;
  
  /// Function to call when the item is tapped
  final VoidCallback? onTap;
  
  /// Whether to show a divider at the bottom of the item
  final bool showDivider;
  
  /// Optional background color for the item
  final Color? backgroundColor;
  
  /// Height of the item (null for auto sizing)
  final double? height;
  
  /// Creates a custom list item with the specified parameters.
  const CustomListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.backgroundColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            height: height,
            color: backgroundColor ?? Colors.transparent,
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 16.0),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4.0),
                        Text(
                          subtitle!,
                          style: AppTextStyles.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 16.0),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1.0,
            thickness: 1.0,
            color: Colors.grey[200],
            indent: leading != null ? 56.0 : 16.0,
            endIndent: 16.0,
          ),
      ],
    );
  }

  /// Factory constructor for creating a list item with an icon.
  factory CustomListItem.withIcon({
    required String title,
    String? subtitle,
    required IconData icon,
    Color? iconColor,
    double iconSize = 24.0,
    Widget? trailing,
    VoidCallback? onTap,
    bool showDivider = true,
    Color? backgroundColor,
  }) {
    return CustomListItem(
      title: title,
      subtitle: subtitle,
      leading: Icon(
        icon,
        size: iconSize,
        color: iconColor ?? Colors.grey[700],
      ),
      trailing: trailing,
      onTap: onTap,
      showDivider: showDivider,
      backgroundColor: backgroundColor,
    );
  }

  /// Factory constructor for creating a list item with a circular avatar.
  factory CustomListItem.withAvatar({
    required String title,
    String? subtitle,
    required String avatarText,
    Color? avatarColor,
    Widget? trailing,
    VoidCallback? onTap,
    bool showDivider = true,
    Color? backgroundColor,
  }) {
    return CustomListItem(
      title: title,
      subtitle: subtitle,
      leading: CircleAvatar(
        backgroundColor: avatarColor ?? Colors.teal,
        radius: 20.0,
        child: Text(
          avatarText.substring(0, 1).toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      showDivider: showDivider,
      backgroundColor: backgroundColor,
    );
  }
}
