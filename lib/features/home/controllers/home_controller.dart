import 'package:get/get.dart';

/// Controller for the Home Screen
class HomeController extends GetxController {
  /// Daily carbon budget in grams
  final dailyBudget = 5000.0.obs;
  
  /// Weekly carbon budget in kilograms
  final weeklyBudget = 35.0.obs;
  
  /// Monthly carbon budget in kilograms
  final monthlyBudget = 150.0.obs;
  
  /// Current daily carbon emissions in grams
  final dailyEmissions = 2750.0.obs;
  
  /// Current weekly carbon emissions in kilograms
  final weeklyEmissions = 19.5.obs;
  
  /// Current monthly carbon emissions in kilograms
  final monthlyEmissions = 84.3.obs;
  
  /// List of recent activities
  final recentActivities = <Map<String, dynamic>>[
    {
      'type': 'transport',
      'title': 'Bus to Work',
      'emissions': 0.8,
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
      'icon': 'directions_bus',
    },
    {
      'type': 'energy',
      'title': 'Home Electricity',
      'emissions': 1.2,
      'timestamp': DateTime.now().subtract(const Duration(hours: 12)),
      'icon': 'electrical_services',
    },
    {
      'type': 'transport',
      'title': 'Cycling',
      'emissions': 0.0,
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'icon': 'directions_bike',
    },
  ].obs;
  
  /// Initialize controller
  @override
  void onInit() {
    super.onInit();
    // In a real app, you would load these values from a database
    // and update them periodically
  }
}
