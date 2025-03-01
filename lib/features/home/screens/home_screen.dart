import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../chatbot/controllers/chatbot_controller.dart';
import '../widgets/feature_card.dart';

/// Home screen
class HomeScreen extends StatelessWidget {
  /// Route name
  static String get routeName => AppRoutes.getRouteName(AppRoute.home);
  
  /// Creates home screen
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = Get.find<AuthController>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Hackathon App'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined),
            onPressed: () {
              // Navigate to settings
              Get.toNamed(AppRoutes.getRouteName(AppRoute.settings));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Make sure the ChatbotController is initialized before navigation
          if (!Get.isRegistered<ChatbotController>()) {
            Get.put(ChatbotController(), permanent: true);
          }
          Get.toNamed(AppRoutes.getRouteName(AppRoute.chatbot));
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.chat, color: Colors.white),
        tooltip: 'Chat with AI',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Obx(() {
                final user = authController.currentUser;
                final name = user?.name ?? 'Guest';
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $name',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome to your dashboard',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 32),
              
              // Stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Stats',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem(
                          context,
                          Icons.task_alt,
                          '12',
                          'Tasks',
                        ),
                        _buildStatItem(
                          context,
                          Icons.category,
                          '4',
                          'Projects',
                        ),
                        _buildStatItem(
                          context,
                          Icons.people,
                          '8',
                          'Team Members',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Feature Cards
              const SizedBox(height: 32),
              Text(
                'Features',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.7, // Increase childAspectRatio further for the redesigned cards
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  FeatureCard(
                    title: 'My List',
                    description: 'View and manage your items',
                    icon: Icons.list_alt,
                    color: theme.colorScheme.primary,
                    onTap: () => Get.toNamed(AppRoutes.getRouteName(AppRoute.list)),
                  ),
                  FeatureCard(
                    title: 'Analytics',
                    description: 'View your statistics and data',
                    icon: Icons.bar_chart,
                    color: theme.colorScheme.secondary,
                    onTap: () => Get.toNamed(AppRoutes.getRouteName(AppRoute.analytics)),
                  ),
                  FeatureCard(
                    title: 'Calendar',
                    description: 'Plan your schedule',
                    icon: Icons.calendar_today,
                    color: theme.colorScheme.tertiary,
                    onTap: () => Get.toNamed(AppRoutes.getRouteName(AppRoute.calendar)),
                  ),
                  FeatureCard(
                    title: 'Messages',
                    description: 'View your messages',
                    icon: Icons.message,
                    color: theme.colorScheme.primaryContainer,
                    onTap: () => Get.toNamed(AppRoutes.getRouteName(AppRoute.messages)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Recent activity
              Text(
                'Recent Activity',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.notifications,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      title: Text('Activity ${index + 1}'),
                      subtitle: Text('This is a recent activity item'),
                      trailing: Text(
                        '${index + 1}h ago',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // View Profile
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'View your profile to update your information and account details',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.getRouteName(AppRoute.profile));
                    },
                    child: Text(
                      'View Profile',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Logout button
              Obx(() => AppButton(
                text: 'Logout',
                onPressed: () => authController.logout(),
                isLoading: authController.isLoading,
                type: ButtonType.secondary,
                icon: Icons.logout,
              )),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.onPrimary,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
