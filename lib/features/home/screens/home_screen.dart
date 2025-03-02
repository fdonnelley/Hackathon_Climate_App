import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/emissions_utils.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../carbon_tracker/widgets/add_usage_bottom_sheet.dart';
import '../../chatbot/controllers/chatbot_controller.dart';
import '../controllers/home_controller.dart';
import '../widgets/feature_card.dart';

/// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String get capitalize => isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : this;
}

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
          AddUsageBottomSheet.show();
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Carbon Usage',
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
                  // Navigate to analytics screen instead of usage details
                  Get.toNamed(AppRoutes.getRouteName(AppRoute.analytics));
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
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GetBuilder<HomeController>(
                        id: 'carbon_usage',
                        builder: (_) => Obx(() {
                          print('homeController.goalLevel.value: ${homeController.goalLevel.value}');
                          final weeklyUsage = homeController.weeklyEmissions.value;
                          final weeklyBudget = homeController.weeklyBudget.value;
                          final usagePercent = (weeklyUsage / weeklyBudget).clamp(0.0, 1.0);
                          
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
                                    '${weeklyUsage.toStringAsFixed(1)} / ${weeklyBudget.toStringAsFixed(1)} lbs CO₂e',
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
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCarbonStat(
                            context,
                            'This Week',
                            '${homeController.weeklyEmissions.value.toStringAsFixed(1)} lbs',
                            '${(homeController.weeklyEmissions.value / homeController.weeklyBudget.value * 100).toStringAsFixed(0)}%',
                          ),
                          _buildCarbonStat(
                            context,
                            'This Month',
                            '${homeController.monthlyEmissions.value.toStringAsFixed(1)} lbs',
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
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       'Track Your Impact',
              //       style: theme.textTheme.titleLarge?.copyWith(
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //     IconButton(
              //       onPressed: () => AddUsageBottomSheet.show(),
              //       icon: const Icon(Icons.add_circle),
              //       tooltip: 'Add New Usage',
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 16),
              
              // const SizedBox(height: 32),
              
              // Chatbot Card
              Text(
                'Get AI Assistance',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () {
                    // Make sure the ChatbotController is initialized before navigation
                    if (!Get.isRegistered<ChatbotController>()) {
                      Get.put(ChatbotController(), permanent: true);
                    }
                    Get.toNamed(AppRoutes.getRouteName(AppRoute.chatbot));
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.eco,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Smart Eco Tips',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Get personalized advice to reduce your carbon footprint',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
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
              
              // Recent Activity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Activity',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.toNamed(AppRoutes.getRouteName(AppRoute.analytics));
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Recent activity list
              GetBuilder<HomeController>(
                id: 'recent_activities',
                builder: (_) => Obx(() {
                  if (homeController.recentActivities.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'No activities yet. Add your first carbon usage!',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    );
                  }
                  
                  // Just show the first 3 activities
                  final activities = homeController.recentActivities.take(3).toList();
                  
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activities.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIconData(activity['icon'] as String? ?? ''),
                            color: activity['type'] == 'transportation'
                                ? theme.colorScheme.primary
                                : theme.colorScheme.secondary,
                          ),
                        ),
                        title: Text(
                          activity['title'] as String? ?? 'Carbon Activity',
                          style: theme.textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          _getActivityDescription(activity),
                          style: theme.textTheme.bodySmall,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '+${EmissionsUtils.formatPounds(activity['emissions'] as double)} lbs',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: _getEmissionsColor(activity['emissions'] as double),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getTimeAgo(activity['timestamp']),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.getRouteName(AppRoute.usageDetails),
                            arguments: activity,
                          );
                        },
                      );
                    },
                  );
                }),
              ),
              
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
    final type = activity['type'] as String? ?? '';
    final subType = activity['subType'] as String? ?? '';
    
    // Show miles for transportation activities
    if (type == 'transportation') {
      final miles = activity['miles'] as double?;
      if (miles != null) {
        return '${miles.toStringAsFixed(1)} miles';
      }
      
      final mode = activity['title'] as String? ?? 'Transport';
      return mode;
    }
    
    // Show bill amount for energy activities
    if (type == 'energy') {
      final billAmount = activity['billAmount'] as double?;
      if (billAmount != null) {
        return '\$${billAmount.toStringAsFixed(0)} ${_capitalize(subType)} bill';
      }
      
      if (subType.isNotEmpty) {
        return '${_capitalize(subType)} energy usage';
      }
      return 'Energy consumption';
    }
    
    // Use the subtype if available
    if (subType.isNotEmpty) {
      return _capitalize(subType);
    }
    
    // Fallback for other activity types
    switch (type) {
      case 'food':
        return 'Food consumption';
      case 'waste':
        return 'Waste disposal';
      default:
        return 'Carbon footprint activity';
    }
  }
  
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
  
  String _getTimeAgo(dynamic timestamp) {
    final DateTime dateTime = timestamp is int 
        ? DateTime.fromMillisecondsSinceEpoch(timestamp) 
        : timestamp;
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
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
  
  Color _getEmissionsColor(double emissions) {
    if (emissions <= 0.01) {
      return Colors.green; // Zero or very low emissions (green)
    } else if (emissions < 5.0) {
      return Colors.amber; // Medium emissions (yellow/amber)
    } else {
      return Theme.of(Get.context!).colorScheme.error; // High emissions (red)
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
  
  IconData _getIconData(String iconName) {
    switch (iconName) {
      // Transportation icons
      case 'directions_bus':
        return Icons.directions_bus;
      case 'directions_car':
        return Icons.directions_car;
      case 'directions_bike':
        return Icons.directions_bike;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'flight':
        return Icons.flight;
      case 'train':
        return Icons.train;
      case 'subway':
        return Icons.subway;
      
      // Energy icons
      case 'bolt':
        return Icons.bolt;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'propane_tank':
        return Icons.propane_tank;
      
      // Food icons
      case 'restaurant':
        return Icons.restaurant;
      case 'lunch_dining':
        return Icons.lunch_dining;
      
      // Waste icons
      case 'delete':
        return Icons.delete;
      case 'recycling':
        return Icons.recycling;
      
      // Default icon when nothing else matches
      default:
        return Icons.eco;
    }
  }
}
