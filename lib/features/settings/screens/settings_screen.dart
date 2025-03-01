import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  /// Route name
  static String get routeName => AppRoutes.getRouteName(AppRoute.settings);
  
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = Get.find<AuthController>();
    final settingsController = Get.find<SettingsController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User profile section
              Obx(() {
                final user = authController.currentUser;
                
                return Card(
                  elevation: 1,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // User avatar
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: theme.colorScheme.primary,
                          child: Text(
                            user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                            style: TextStyle(
                              fontSize: 32,
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // User name
                        Text(
                          user?.name ?? 'User',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        // User email
                        Text(
                          user?.email ?? 'user@example.com',
                          style: theme.textTheme.bodyMedium,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Edit profile button
                        AppButton(
                          text: 'Edit Profile',
                          onPressed: () {
                            // Navigate to profile edit screen
                            Get.toNamed(AppRoutes.getRouteName(AppRoute.profile));
                          },
                          type: ButtonType.secondary,
                          icon: Icons.edit,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              
              const SizedBox(height: 24),
              
              // Settings sections
              Text(
                'App Settings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Theme toggle
              Card(
                elevation: 1,
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.dark_mode),
                      title: const Text('Dark Mode'),
                      trailing: Obx(() => Switch(
                        value: settingsController.isDarkMode.value,
                        onChanged: (value) {
                          settingsController.toggleTheme();
                        },
                      )),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text('Notifications'),
                      trailing: Obx(() => Switch(
                        value: settingsController.notificationsEnabled.value,
                        onChanged: (value) {
                          settingsController.toggleNotifications();
                        },
                      )),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Account',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              Card(
                elevation: 1,
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.security),
                      title: const Text('Change Password'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigate to change password screen
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('Language'),
                      trailing: const Text('English'),
                      onTap: () {
                        // Show language selection
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'About',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              Card(
                elevation: 1,
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('App Version'),
                      trailing: const Text('1.0.0'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Show privacy policy
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: const Text('Terms of Service'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Show terms of service
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Logout button
              Obx(() => AppButton(
                text: 'Logout',
                onPressed: () {
                  authController.logout();
                  Get.offAllNamed(AppRoutes.getRouteName(AppRoute.login));
                },
                isLoading: authController.isLoading,
                type: ButtonType.secondary,
                icon: Icons.logout,
              )),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
