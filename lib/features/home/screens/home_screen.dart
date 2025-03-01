import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../chatbot/controllers/chatbot_controller.dart';
import '../controllers/home_controller.dart';
import '../widgets/feature_card.dart';

/// Home screen for Carbon Budget Tracker
class HomeScreen extends StatelessWidget {
  /// Route name
  static String get routeName => AppRoutes.getRouteName(AppRoute.home);
  
  /// Creates home screen
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = Get.find<AuthController>();
    
    // Get or create the home controller
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController());
    }
    final homeController = Get.find<HomeController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carbon Budget Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
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
        backgroundColor: theme.colorScheme.secondary,
        child: const Icon(Icons.eco, color: Colors.white),
        tooltip: 'Smart Eco Tips',
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
                final name = user?.name ?? 'Earth Friend';
                
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
                      'Monitor and reduce your carbon footprint',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 32),
              
              // Carbon Budget Progress Card
              GestureDetector(
                onTap: () {
                  // Navigate to usage details screen
                  Get.toNamed(AppRoutes.getRouteName(AppRoute.usageDetails));
                },
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primaryDark,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withOpacity(0.3),
                        offset: const Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Carbon Budget',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'Daily',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Obx(() {
                        final dailyUsage = homeController.dailyEmissions.value;
                        final dailyBudget = homeController.dailyBudget.value;
                        final usagePercent = (dailyUsage / dailyBudget).clamp(0.0, 1.0);
                        
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${(usagePercent * 100).toStringAsFixed(1)}% Used',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${dailyUsage.toStringAsFixed(1)} / ${dailyBudget.toStringAsFixed(0)} g CO₂',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: usagePercent,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  usagePercent < 0.7 
                                      ? Colors.white 
                                      : AppColors.warning,
                                ),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCarbonStat(
                            context,
                            'This Week',
                            '${homeController.weeklyEmissions.value.toStringAsFixed(1)} kg',
                            '${(homeController.weeklyEmissions.value / homeController.weeklyBudget.value * 100).toStringAsFixed(0)}%',
                          ),
                          _buildCarbonStat(
                            context,
                            'This Month',
                            '${homeController.monthlyEmissions.value.toStringAsFixed(1)} kg',
                            '${(homeController.monthlyEmissions.value / homeController.monthlyBudget.value * 100).toStringAsFixed(0)}%',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Feature Cards - Add Your Emissions
              Text(
                'Track Your Emissions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  FeatureCard(
                    title: 'Add Trip',
                    description: 'Log transportation',
                    icon: Icons.directions_car,
                    color: theme.colorScheme.primary,
                    onTap: () => Get.toNamed(AppRoutes.getRouteName(AppRoute.list)),
                  ),
                  FeatureCard(
                    title: 'Add Energy Use',
                    description: 'Log electricity & gas',
                    icon: Icons.electric_bolt,
                    color: theme.colorScheme.secondary,
                    onTap: () => Get.toNamed(AppRoutes.getRouteName(AppRoute.analytics)),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Leaderboard & Social section
              Text(
                'Leaderboard & Friends',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  FeatureCard(
                    title: 'Leaderboard',
                    icon: Icons.leaderboard,
                    color: Colors.purple,
                    onTap: () {
                      Get.toNamed(AppRoutes.getRouteName(AppRoute.leaderboard));
                    },
                  ),
                  FeatureCard(
                    title: 'Friends',
                    icon: Icons.people,
                    color: Colors.blue,
                    onTap: () {
                      Get.toNamed(AppRoutes.getRouteName(AppRoute.friends));
                    },
                  ),
                  FeatureCard(
                    title: 'Badges',
                    icon: Icons.workspace_premium,
                    color: Colors.amber,
                    onTap: () {
                      // Navigate to badges
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Game Features
              Text(
                'Gamification',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  FeatureCard(
                    title: 'Challenges',
                    description: 'Earn badges & rewards',
                    icon: Icons.emoji_events,
                    color: AppColors.accent,
                    onTap: () => Get.toNamed(AppRoutes.getRouteName(AppRoute.messages)),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Recent Activities
              Text(
                'Recent Activities',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Obx(() {
                final activities = homeController.recentActivities;
                if (activities.isEmpty) {
                  return const Center(
                    child: Text('No recent activities'),
                  );
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activities.length.clamp(0, 3),
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    
                    // Determine icon based on activity type
                    IconData activityIcon = Icons.eco;
                    if (activity['icon'] != null) {
                      // Convert string icon name to IconData
                      switch (activity['icon']) {
                        case 'directions_bus':
                          activityIcon = Icons.directions_bus;
                          break;
                        case 'electrical_services':
                          activityIcon = Icons.electrical_services;
                          break;
                        case 'directions_bike':
                          activityIcon = Icons.directions_bike;
                          break;
                        default:
                          activityIcon = Icons.eco;
                      }
                    }
                    
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
                            activityIcon,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        title: Text(activity['title']),
                        subtitle: Text(_getActivityDescription(activity)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${activity['emissions'].toStringAsFixed(1)} kg CO₂',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Text(
                              _getTimeAgo(activity['timestamp']),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
              
              const SizedBox(height: 16),
              
              // View Profile
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'View your profile to update your carbon budget settings',
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
  
  String _getActivityDescription(Map<String, dynamic> activity) {
    switch (activity['type']) {
      case 'transport':
        return 'Transport activity';
      case 'energy':
        return 'Energy consumption';
      default:
        return 'Carbon footprint activity';
    }
  }
  
  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
  
  Widget _buildCarbonStat(
    BuildContext context,
    String label,
    String value,
    String percentage,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            percentage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
