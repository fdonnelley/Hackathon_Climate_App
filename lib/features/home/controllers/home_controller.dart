import 'package:get/get.dart';

import '../../carbon_tracker/models/usage_category_model.dart' as carbon_tracker;
import '../../setup/models/setup_data_model.dart';

/// Controller for the Home Screen
class HomeController extends GetxController {
  /// User name
  final userName = "".obs;
  
  /// Selected carbon goal level
  final goalLevel = Rx<CarbonGoalLevel?>(null);
  
  /// Daily carbon budget in pounds
  final dailyBudget = 0.0.obs;
  
  /// Weekly carbon budget in pounds
  final weeklyBudget = 0.0.obs;
  
  /// Monthly carbon budget in pounds
  final monthlyBudget = 0.0.obs;
  
  /// Current daily carbon emissions in pounds
  final dailyEmissions = 0.0.obs;
  
  /// Current weekly carbon emissions in pounds
  final weeklyEmissions = 0.0.obs;
  
  /// Current monthly carbon emissions in pounds
  final monthlyEmissions = 0.0.obs;
  
  /// Percentage of weekly budget used
  final weeklyUsagePercentage = 0.0.obs;
  
  /// Start date of the current tracking period
  final trackingStartDate = DateTime.now().obs;

  /// List of recent activities
  final recentActivities = <Map<String, dynamic>>[].obs;
  
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
    
    // Set emissions to zero initially
    weeklyEmissions.value = 0.0;
    monthlyEmissions.value = 0.0;
    dailyEmissions.value = 0.0;
    
    // Set budgets based on selected goal level (already in pounds)
    weeklyBudget.value = goalLevel.weeklyBudgetGoal;
    
    // Calculate monthly budget (weekly * 4.33)
    monthlyBudget.value = weeklyBudget.value * 4.33;
    
    // Calculate daily budget (weekly / 7)
    dailyBudget.value = (weeklyBudget.value / 7);
    
    // Set tracking start date to today
    trackingStartDate.value = DateTime.now();
    
    // If we have setup data with a calculated footprint, set initial weekly emissions
    // if (setupData != null && setupData.calculatedCarbonFootprint > 0) {
    //   // Setup data's footprint is monthly in kg - convert to weekly in pounds
    //   final conversionFactor = 2.20462; // kg to lbs
      
    //   // Monthly kg -> Weekly pounds
    //   weeklyEmissions.value = (setupData.calculatedCarbonFootprint * conversionFactor) / 4.33;
      
    //   // Weekly -> Monthly
    //   monthlyEmissions.value = weeklyEmissions.value * 4.33;
      
    //   // Weekly -> Daily 
    //   dailyEmissions.value = weeklyEmissions.value / 7.0;
      
    //   // Calculate usage percentage
    //   weeklyUsagePercentage.value = (weeklyEmissions.value / weeklyBudget.value) * 100;
      
    //   print('Initial weekly emissions: ${weeklyEmissions.value} lbs');
    //   print('Initial weekly budget: ${weeklyBudget.value} lbs');
    //   print('Initial weekly usage percentage: ${weeklyUsagePercentage.value}%');
    // }
    
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
    
    // Update UI
    update(['carbon_usage', 'recent_activities']);
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
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'icon': icon,
    });
    
    // Keep only the last 10 activities
    if (recentActivities.length > 10) {
      recentActivities.removeLast();
    }
  }
  
  /// Update emissions totals and percentages
  void _updateEmissions(double dailyEmissionAmount) {
    // Update daily emissions (in pounds)
    dailyEmissions.value += dailyEmissionAmount;
    
    // Update weekly emissions (in pounds)
    weeklyEmissions.value += dailyEmissionAmount;
    
    // Update monthly emissions (in pounds)
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
      'timestamp': timestamp ?? DateTime.now().millisecondsSinceEpoch,
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
  
  /// Add carbon usage to the tracker
  void addCarbonUsage(double emissions, String type, {
    String? specificMode, 
    String? subType,
    Map<String, dynamic>? additionalData,
  }) {
    // Create a more descriptive title based on the type and specificMode
    String title;
    String icon;
    
    if (type == 'transportation') {
      title = specificMode != null ? '$specificMode' : 'Transportation';
      
      // Select appropriate icon based on mode
      if (specificMode != null) {
        if (specificMode.toLowerCase().contains('car')) {
          icon = 'directions_car';
        } else if (specificMode.toLowerCase().contains('bus') || 
                  specificMode.toLowerCase().contains('transit')) {
          icon = 'directions_bus';
        } else if (specificMode.toLowerCase().contains('bike') || 
                  specificMode.toLowerCase().contains('bicycle')) {
          icon = 'directions_bike';
        } else if (specificMode.toLowerCase().contains('walk')) {
          icon = 'directions_walk';
        } else if (specificMode.toLowerCase().contains('train') || 
                  specificMode.toLowerCase().contains('subway')) {
          icon = 'train';
        } else if (specificMode.toLowerCase().contains('plane') || 
                  specificMode.toLowerCase().contains('air')) {
          icon = 'flight';
        } else {
          icon = 'directions_car'; // Default transportation icon
        }
      } else {
        icon = 'directions_car';
      }
    } else if (type == 'energy') {
      if (subType == 'electricity') {
        title = 'Electricity Usage';
        icon = 'bolt';
      } else if (subType == 'gas') {
        title = 'Natural Gas Usage';
        icon = 'local_fire_department';
      } else {
        title = 'Energy Usage';
        icon = 'bolt';
      }
    } else if (type == 'food') {
      title = 'Food Consumption';
      icon = 'restaurant';
    } else if (type == 'waste') {
      title = 'Waste Disposal';
      icon = 'delete';
    } else {
      // Generic fallback
      title = 'Carbon Usage';
      icon = 'eco';
    }
    
    // Store emissions in pounds internally
    final usage = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'emissions': emissions, // pounds CO2e
      'type': type,
      'subType': subType,
      'title': title,
      'icon': icon,
    };
    
    // Add any additional data if provided
    if (additionalData != null && additionalData.isNotEmpty) {
      usage.addAll(additionalData);
    }
    
    // Update running totals
    dailyEmissions.value += emissions;
    weeklyEmissions.value += emissions;
    monthlyEmissions.value += emissions;
    
    // Create a new list to trigger reactive update
    final newList = <Map<String, dynamic>>[usage, ...recentActivities];
    
    // Sort by timestamp (newest first)
    newList.sort((a, b) => 
      (b['timestamp'] as int).compareTo(a['timestamp'] as int)
    );
    
    // Replace the entire list to trigger reactivity
    recentActivities.value = newList;
    
    // Save update
    _saveUsageHistory();
    
    // Calculate updated percentage
    weeklyUsagePercentage.value = (weeklyEmissions.value / weeklyBudget.value).clamp(0.0, 1.0);
    
    // Force UI update
    update(['carbon_usage', 'recent_activities']);
    
    // Debug log
    print('Carbon usage added: $emissions lbs CO2 for $type');
    print('Daily emissions: ${dailyEmissions.value}');
    print('Weekly emissions: ${weeklyEmissions.value}');
  }
  
  /// Save usage history to persistent storage
  /// This method would be implemented to store data in a real app
  void _saveUsageHistory() {
    // In a real application, this would save the usage history to
    // persistent storage such as shared preferences, a local database,
    // or a cloud database.
    
    // For now, we'll just print a message
    print('Saving usage history data...');
    
    // Example implementation:
    // final jsonData = jsonEncode(recentActivities.map((e) => e).toList());
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString('usage_history', jsonData);
  }
  
  /// Calculate week number (1-52) for a given date
  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(firstDayOfYear).inDays;
    return ((dayOfYear / 7) + 1).floor();
  }
}
