import 'package:get/get.dart';

import '../../carbon_tracker/models/usage_category_model.dart' as carbon_tracker;
import '../../setup/models/setup_data_model.dart';

/// Controller for the Home Screen
class HomeController extends GetxController {
  /// User name
  final userName = "".obs;
  
  /// Selected carbon goal level
  final goalLevel = Rx<CarbonGoalLevel?>(null);
  
  /// Daily carbon budget in grams
  final dailyBudget = 0.0.obs;
  
  /// Weekly carbon budget in kilograms - the target goal
  final weeklyBudget = 0.0.obs;
  
  /// Monthly carbon budget in kilograms
  final monthlyBudget = 0.0.obs;
  
  /// Current daily carbon emissions in grams
  final dailyEmissions = 0.0.obs;
  
  /// Current weekly carbon emissions in kilograms
  final weeklyEmissions = 0.0.obs;
  
  /// Current monthly carbon emissions in kilograms
  final monthlyEmissions = 0.0.obs;
  
  /// Percentage of weekly budget used
  final weeklyUsagePercentage = 0.0.obs;
  
  /// Start date of the current tracking period
  final trackingStartDate = DateTime.now().obs;

  /// List of recent activities
  final recentActivities = <Map<String, dynamic>>[
    {
      'type': 'transportation',
      'subType': null,
      'title': 'Bus to Work',
      'emissions': 0.8,
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
      'icon': 'directions_bus',
    },
    {
      'type': 'energy',
      'subType': 'electricity',
      'title': 'Home Electricity',
      'emissions': 1.2,
      'timestamp': DateTime.now().subtract(const Duration(hours: 12)),
      'icon': 'electric_bolt',
    },
    {
      'type': 'energy',
      'subType': 'gas',
      'title': 'Home Heating',
      'emissions': 1.5,
      'timestamp': DateTime.now().subtract(const Duration(hours: 18)),
      'icon': 'gas_meter',
    },
    {
      'type': 'transportation',
      'subType': null,
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
  
  /// Set user data from setup process
  void setUserData({
    required String name,
    required CarbonGoalLevel goalLevel,
    SetupDataModel? setupData,
  }) {
    // Set user information
    userName.value = name;
    this.goalLevel.value = goalLevel;
    
    // Set emissions to zero (user is just starting)
    weeklyEmissions.value = 0.0;
    monthlyEmissions.value = 0.0;
    dailyEmissions.value = 0.0;
    
    // Set budgets based on selected goal level
    weeklyBudget.value = goalLevel.weeklyBudgetGoal;
    
    // Calculate monthly budget (weekly * 4.33)
    monthlyBudget.value = weeklyBudget.value * 4.33;
    
    // Calculate daily budget (weekly / 7) and convert to grams
    dailyBudget.value = (weeklyBudget.value / 7) * 1000;
    
    // Set tracking start date to today
    trackingStartDate.value = DateTime.now();
    
    // Reset usage percentage
    weeklyUsagePercentage.value = 0.0;
    
    // Clear sample activities
    recentActivities.clear();
    
    // Add the transportation methods from setup as activities
    if (setupData != null && setupData.transportationMethods.isNotEmpty) {
      // Convert transportation methods to activities
      for (var transport in setupData.transportationMethods) {
        final weeklyEmissions = transport.calculateWeeklyEmissions();
        
        if (weeklyEmissions > 0) {
          _addActivity(
            type: 'transportation',
            subType: transport.mode.displayName,
            title: _getTransportTitle(transport),
            emissions: weeklyEmissions / 7, // Daily emissions
            icon: _getTransportIcon(transport.mode),
          );
        }
      }
    }
  }
  
  /// Add new emissions activity and update totals
  void addEmissionsActivity({
    required String type,
    String? subType,
    required String title,
    required double emissions,
    required String icon,
  }) {
    _addActivity(
      type: type,
      subType: subType,
      title: title,
      emissions: emissions,
      icon: icon,
    );
    
    // Update total emissions
    _updateEmissions(emissions);
  }
  
  /// Helper to add an activity
  void _addActivity({
    required String type,
    String? subType,
    required String title,
    required double emissions,
    required String icon,
  }) {
    // Add to recent activities
    recentActivities.insert(0, {
      'type': type,
      'subType': subType,
      'title': title,
      'emissions': emissions,
      'timestamp': DateTime.now(),
      'icon': icon,
    });
    
    // Keep only the last 10 activities
    if (recentActivities.length > 10) {
      recentActivities.removeLast();
    }
  }
  
  /// Update emissions totals and percentages
  void _updateEmissions(double dailyEmissionAmount) {
    // Update daily emissions (in grams)
    dailyEmissions.value += dailyEmissionAmount * 1000;
    
    // Update weekly emissions (in kg)
    weeklyEmissions.value += dailyEmissionAmount;
    
    // Update monthly emissions (in kg)
    monthlyEmissions.value += dailyEmissionAmount;
    
    // Calculate percentage of weekly budget used
    weeklyUsagePercentage.value = (weeklyEmissions.value / weeklyBudget.value) * 100;
  }
  
  /// Reset weekly tracking
  void resetWeeklyTracking() {
    weeklyEmissions.value = 0.0;
    trackingStartDate.value = DateTime.now();
    weeklyUsagePercentage.value = 0.0;
  }
  
  /// Get icon for transport mode
  String _getTransportIcon(TransportMode mode) {
    switch (mode) {
      case TransportMode.walking:
        return 'directions_walk';
      case TransportMode.bicycle:
        return 'directions_bike';
      case TransportMode.car:
        return 'directions_car';
      case TransportMode.publicTransportation:
        return 'directions_bus';
      case TransportMode.airplane:
        return 'flight';
    }
  }
  
  /// Get descriptive title for transportation method
  String _getTransportTitle(TransportationMethod transport) {
    switch (transport.mode) {
      case TransportMode.car:
        if (transport.carUsageType != null) {
          return '${transport.carType?.displayName ?? 'Car'} (${transport.carUsageType!.displayName})';
        }
        return transport.carType?.displayName ?? 'Car Trip';
      
      case TransportMode.publicTransportation:
        return transport.publicTransportType?.displayName ?? 'Public Transit';
        
      default:
        return transport.mode.displayName;
    }
  }
  
  /// Helper method to capitalize the first letter of a string
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
  
  /// Add a new activity to the recent activities list
  void addActivity({
    required String title,
    String? description,
    required String type,
    String? subType,
    required double emissions,
    String? icon,
    DateTime? timestamp,
  }) {
    // Validate the usage category
    carbon_tracker.UsageCategory category;
    carbon_tracker.EnergyType? energyType;
    String iconName;
    
    try {
      // Validate and convert the type to a UsageCategory
      category = carbon_tracker.UsageCategoryExtension.fromString(type);
      
      // Set icon based on category
      iconName = icon ?? category.iconName;
      
      // If it's an energy activity, validate the subType
      if (category == carbon_tracker.UsageCategory.energy && subType != null) {
        energyType = carbon_tracker.EnergyTypeExtension.fromString(subType);
        iconName = icon ?? energyType.iconName;
      }
    } catch (e) {
      // If validation fails, don't add the activity
      print('Invalid activity type or subType: $e');
      return;
    }
    
    // Create the activity
    final activity = {
      'type': category.name.toLowerCase(),
      'subType': energyType?.name.toLowerCase(),
      'title': title,
      'description': description,
      'emissions': emissions,
      'timestamp': timestamp ?? DateTime.now(),
      'icon': iconName,
    };
    
    // Add to the list
    recentActivities.insert(0, activity);
    
    // Keep the list at a reasonable size
    if (recentActivities.length > 20) {
      recentActivities.removeLast();
    }
    
    // Update emissions
    _updateEmissions(emissions);
  }
  
  /// Get activities filtered by type
  List<Map<String, dynamic>> getActivitiesByType(String type, {String? subType}) {
    return recentActivities.where((activity) {
      final matchesType = activity['type'] == type.toLowerCase();
      
      if (subType != null) {
        return matchesType && activity['subType'] == subType.toLowerCase();
      }
      
      return matchesType;
    }).toList();
  }
  
  /// Get transportation activities
  List<Map<String, dynamic>> get transportationActivities => 
      getActivitiesByType('transportation');
  
  /// Get all energy activities
  List<Map<String, dynamic>> get energyActivities => 
      getActivitiesByType('energy');
  
  /// Get electricity activities
  List<Map<String, dynamic>> get electricityActivities => 
      getActivitiesByType('energy', subType: 'electricity');
  
  /// Get gas activities
  List<Map<String, dynamic>> get gasActivities => 
      getActivitiesByType('energy', subType: 'gas');
}
