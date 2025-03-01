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
    required double monthlyEmissions,
    required double monthlyBudget,
    required CarbonGoalLevel goalLevel,
    SetupDataModel? setupData,
  }) {
    // Set user information
    userName.value = name;
    this.goalLevel.value = goalLevel;
    
    // Set emissions and budgets
    this.monthlyEmissions.value = monthlyEmissions;
    this.monthlyBudget.value = monthlyBudget;
    
    // Calculate weekly values (divide by 4.33 weeks per month)
    weeklyEmissions.value = monthlyEmissions / 4.33;
    weeklyBudget.value = monthlyBudget / 4.33;
    
    // Calculate daily values (divide by 30 days per month)
    dailyEmissions.value = (monthlyEmissions / 30) * 1000; // Convert to grams
    dailyBudget.value = (monthlyBudget / 30) * 1000; // Convert to grams
    
    // Clear sample activities
    recentActivities.clear();
    
    // Add initial activities based on setup data
    if (setupData != null) {
      _addInitialActivitiesFromSetupData(setupData);
    }
  }
  
  /// Add initial activities from setup data
  void _addInitialActivitiesFromSetupData(SetupDataModel setupData) {
    // Add energy activities
    if (setupData.monthlyElectricBill > 0) {
      addActivity(
        title: 'Monthly Electricity',
        description: 'Based on your monthly bill of \$${setupData.monthlyElectricBill.toStringAsFixed(2)}',
        emissions: setupData.monthlyElectricBill / 0.15 * 0.48,
        type: 'energy',
        subType: 'electricity',
      );
    }
    
    if (setupData.monthlyGasBill > 0) {
      addActivity(
        title: 'Monthly Natural Gas',
        description: 'Based on your monthly bill of \$${setupData.monthlyGasBill.toStringAsFixed(2)}',
        emissions: setupData.monthlyGasBill / 1.5 * 5.5,
        type: 'energy',
        subType: 'gas',
      );
    }
    
    // Add transportation activities
    for (var method in setupData.transportationMethods) {
      final modeName = method.mode.name;
      final title = method.mode == carbon_tracker.TransportMode.car && method.carType != null 
          ? '${_capitalize(method.carType!.name)} Car - ${method.milesPerWeek.toStringAsFixed(0)} miles/week'
          : '${_capitalize(modeName)} - ${method.milesPerWeek.toStringAsFixed(0)} miles/week';
      
      final description = method.mode == carbon_tracker.TransportMode.car 
          ? 'Vehicle with ${method.mpg?.toStringAsFixed(0) ?? method.carType?.defaultMpg.toStringAsFixed(0) ?? "25"} MPG'
          : '${method.milesPerWeek.toStringAsFixed(0)} miles per week';
      
      addActivity(
        title: title,
        description: description,
        emissions: method.calculateWeeklyEmissions() * 4.33, // Convert to monthly
        type: 'transportation',
      );
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
  
  /// Update emissions after adding a new activity
  void _updateEmissions(double emissions) {
    // Update daily emissions
    dailyEmissions.value += emissions * 1000; // Convert kg to g
    
    // Update weekly and monthly emissions
    weeklyEmissions.value += emissions;
    monthlyEmissions.value += emissions;
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
