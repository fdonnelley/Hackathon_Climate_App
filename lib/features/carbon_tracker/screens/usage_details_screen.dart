import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_theme.dart';
import '../../home/controllers/home_controller.dart';
import '../../setup/models/setup_data_model.dart';
import '../../../routes/app_routes.dart';

/// Screen for detailed carbon usage statistics and graphs
class UsageDetailsScreen extends StatelessWidget {
  /// Route name for this screen
  static String get routeName => AppRoutes.getRouteName(AppRoute.usageDetails);
  
  /// Creates a usage details screen
  const UsageDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeController = Get.find<HomeController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carbon Usage Details'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weekly Budget Card
              Obx(() {
                final weeklyEmissions = homeController.weeklyEmissions.value;
                final weeklyBudget = homeController.weeklyBudget.value;
                final usagePercentage = homeController.weeklyUsagePercentage.value;
                
                return Container(
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
                            'Weekly Carbon Budget',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Chip(
                            label: Text(
                              homeController.goalLevel.value?.displayName ?? 'Goal',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Colors.white.withOpacity(0.2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Goal-Based on Reduction Level:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${weeklyBudget.toStringAsFixed(1)} kg CO₂ per week',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Usage',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${weeklyEmissions.toStringAsFixed(1)} kg',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Percentage Used',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${usagePercentage.toStringAsFixed(1)}%',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: _getUsageColor(usagePercentage),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (weeklyEmissions / weeklyBudget).clamp(0.0, 1.0),
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getUsageColor(usagePercentage),
                          ),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              
              const SizedBox(height: 24),
              
              // Weekly Emissions Graph
              Text(
                'Weekly Emissions Breakdown',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 250,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Obx(() {
                  // Generate sample emissions data by type
                  final emissionsByType = _getEmissionsByType(homeController);
                  
                  return emissionsByType.isEmpty
                      ? const Center(
                          child: Text(
                            'No emissions data yet. Start tracking your carbon footprint!',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : PieChart(
                          PieChartData(
                            sections: _createPieSections(emissionsByType),
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                          ),
                        );
                }),
              ),
              
              const SizedBox(height: 24),
              
              // Legend
              Obx(() {
                final emissionsByType = _getEmissionsByType(homeController);
                
                return emissionsByType.isEmpty
                    ? const SizedBox.shrink()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...emissionsByType.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: _getColorForType(entry.key),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_getTypeDisplayName(entry.key)}: ${entry.value.toStringAsFixed(1)} kg (${(entry.value / homeController.weeklyEmissions.value * 100).toStringAsFixed(0)}%)',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      );
              }),
              
              const SizedBox(height: 24),
              
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
                
                return activities.isEmpty
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.eco_outlined,
                                size: 48,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No activities yet',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start adding your carbon activities to track your emissions',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: activities.length.clamp(0, 5), // Show at most 5
                        itemBuilder: (context, index) {
                          final activity = activities[index];
                          return ListTile(
                            leading: Icon(
                              _getIconData(activity['icon']),
                              color: theme.colorScheme.primary,
                            ),
                            title: Text(activity['title']),
                            subtitle: Text(
                              '${activity['emissions'].toStringAsFixed(1)} kg CO₂',
                            ),
                            trailing: Text(
                              _formatDate(activity['timestamp']),
                              style: theme.textTheme.bodySmall,
                            ),
                          );
                        },
                      );
              }),
              
              const SizedBox(height: 24),
              
              // Reset Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showResetConfirmation(context, homeController);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Weekly Tracking'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Show confirmation dialog for resetting weekly tracking
  void _showResetConfirmation(BuildContext context, HomeController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Weekly Tracking?'),
        content: const Text(
          'This will reset your weekly emissions to zero. '
          'This action cannot be undone. Are you sure you want to continue?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              controller.resetWeeklyTracking();
              Navigator.of(context).pop();
              Get.snackbar(
                'Tracking Reset',
                'Your weekly carbon tracking has been reset to zero.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('RESET'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
  
  // Get color based on usage percentage
  Color _getUsageColor(double percentage) {
    if (percentage < 50) return Colors.white;
    if (percentage < 80) return Colors.yellowAccent;
    return Colors.redAccent;
  }
  
  // Get emissions grouped by type
  Map<String, double> _getEmissionsByType(HomeController controller) {
    final Map<String, double> result = {};
    
    // If no activities, return empty map
    if (controller.recentActivities.isEmpty) return result;
    
    for (final activity in controller.recentActivities) {
      final type = activity['type'] as String;
      final emissions = activity['emissions'] as double;
      
      if (result.containsKey(type)) {
        result[type] = result[type]! + emissions;
      } else {
        result[type] = emissions;
      }
    }
    
    return result;
  }
  
  // Create pie chart sections
  List<PieChartSectionData> _createPieSections(Map<String, double> emissionsByType) {
    final List<PieChartSectionData> sections = [];
    
    emissionsByType.forEach((type, value) {
      sections.add(
        PieChartSectionData(
          color: _getColorForType(type),
          value: value,
          title: '',
          radius: 100,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    });
    
    return sections;
  }
  
  // Get color for emission type
  Color _getColorForType(String type) {
    switch (type) {
      case 'transportation':
        return Colors.blue;
      case 'energy':
        return Colors.orange;
      case 'food':
        return Colors.green;
      case 'shopping':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
  
  // Get display name for emission type
  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'transportation':
        return 'Transportation';
      case 'energy':
        return 'Energy';
      case 'food':
        return 'Food';
      case 'shopping':
        return 'Shopping';
      default:
        return type.capitalize ?? type;
    }
  }
  
  // Format date for activity display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
  
  // Convert string icon name to IconData
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'directions_car':
        return Icons.directions_car;
      case 'directions_bus':
        return Icons.directions_bus;
      case 'directions_bike':
        return Icons.directions_bike;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'flight':
        return Icons.flight;
      case 'electric_bolt':
        return Icons.electric_bolt;
      case 'gas_meter':
        return Icons.gas_meter;
      case 'restaurant':
        return Icons.restaurant;
      case 'shopping_bag':
        return Icons.shopping_bag;
      default:
        return Icons.eco;
    }
  }
}
