import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Controller for the bottom navigation bar
class BottomNavController extends GetxController {
  /// Current index
  final RxInt currentIndex = 0.obs;
  
  /// Change the current index
  void changeIndex(int index) {
    currentIndex.value = index;
  }
}

/// Custom bottom navigation bar
class AppBottomNavBar extends StatelessWidget {
  /// List of items
  final List<BottomNavItem> items;
  
  /// Controller
  final BottomNavController controller;
  
  /// Callback when an item is tapped
  final Function(int)? onTap;
  
  /// Background color
  final Color? backgroundColor;
  
  /// Selected item color
  final Color? selectedItemColor;
  
  /// Unselected item color
  final Color? unselectedItemColor;
  
  /// Creates a bottom navigation bar
  const AppBottomNavBar({
    Key? key,
    required this.items,
    required this.controller,
    this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Obx(() => NavigationBar(
      selectedIndex: controller.currentIndex.value,
      onDestinationSelected: (index) {
        // Change tab and navigate if needed
        controller.changeIndex(index);
        if (onTap != null) {
          onTap!(index);
        }
      },
      destinations: items.map((item) => NavigationDestination(
        icon: Icon(item.icon),
        selectedIcon: Icon(item.selectedIcon ?? item.icon),
        label: item.label,
      )).toList(),
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      indicatorColor: selectedItemColor ?? theme.colorScheme.primary,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ));
  }
}

/// Bottom navigation item
class BottomNavItem {
  /// Item label
  final String label;
  
  /// Item icon
  final IconData icon;
  
  /// Selected icon (optional)
  final IconData? selectedIcon;
  
  /// Creates a bottom navigation item
  const BottomNavItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
  });
}

/// Page with bottom navigation
class AppNavigationPage extends StatelessWidget {
  /// Bottom navigation items
  final List<BottomNavItem> items;
  
  /// Pages to display
  final List<Widget> pages;
  
  /// Controller
  final BottomNavController controller;
  
  /// Creates a navigation page
  const AppNavigationPage({
    Key? key,
    required this.items,
    required this.pages,
    required this.controller,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: pages,
      )),
      bottomNavigationBar: AppBottomNavBar(
        items: items,
        controller: controller,
      ),
    );
  }
}
