import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../features/home/controllers/home_controller.dart';
import 'package:fl_chart/fl_chart.dart';

/// Extension method to capitalize the first letter of a string
extension StringExtension on String {
  String get capitalize => this.isNotEmpty ? '${this[0].toUpperCase()}${this.substring(1)}' : this;
}

/// Controller that manages data for the analytics screen
class AnalyticsController extends GetxController {
  // Reference to home controller
  final HomeController _homeController = Get.find<HomeController>();
  
  // Current week for weekly emissions chart
  final Rx<DateTime> selectedWeek = DateTime.now().obs;
  
  // Data for carbon footprint breakdown
  final RxList<Map<String, dynamic>> carbonBreakdown = <Map<String, dynamic>>[].obs;
  
  // Data for miles traveled by mode
  final RxList<Map<String, dynamic>> milesByMode = <Map<String, dynamic>>[].obs;
  
  // Data for weekly emissions
  final RxList<Map<String, dynamic>> weeklyEmissions = <Map<String, dynamic>>[].obs;
  
  // Total carbon emissions
  final RxDouble totalCarbon = 0.0.obs;
  
  // Total miles traveled
  final RxDouble totalMiles = 0.0.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Use real data instead of sample data
    _connectToRealData();
    
    // Update weekly data for the current selected week
    updateWeeklyData();
  }
  
  /// Navigate to previous week
  void previousWeek() {
    selectedWeek.value = selectedWeek.value.subtract(const Duration(days: 7));
    updateWeeklyData();
  }
  
  /// Navigate to next week
  void nextWeek() {
    final nextWeek = selectedWeek.value.add(const Duration(days: 7));
    
    // Don't allow navigation to future weeks
    if (nextWeek.isBefore(DateTime.now()) || 
        nextWeek.day == DateTime.now().day) {
      selectedWeek.value = nextWeek;
      updateWeeklyData();
    }
  }
  
  /// Check if the navigation to next week should be disabled
  bool isNextWeekDisabled() {
    final nextWeek = selectedWeek.value.add(const Duration(days: 7));
    return nextWeek.isAfter(DateTime.now());
  }
  
  /// Update data for the selected week
  void updateWeeklyData() {
    // Implementation for real app would fetch actual data for selected week
    _generateWeeklyEmissionsData();
  }
  
  /// Get formatted week date range (e.g., "Feb 24 - Mar 2")
  String getWeekDateRange() {
    final startOfWeek = _getStartOfWeek(selectedWeek.value);
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    // Format: "Feb 24 - Mar 2"
    return '${_getShortMonthName(startOfWeek.month)} ${startOfWeek.day} - '
           '${_getShortMonthName(endOfWeek.month)} ${endOfWeek.day}';
  }
  
  /// Get the start of the week (Sunday) for a given date
  DateTime _getStartOfWeek(DateTime date) {
    // Start of week is Sunday (weekday 7 in DateTime, but we want 0-based)
    final difference = date.weekday;
    return date.subtract(Duration(days: difference));
  }
  
  /// Get short month name
  String _getShortMonthName(int month) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }
  
  /// Get the weekly days labels
  List<String> getWeekDays() {
    return weeklyEmissions.map<String>((item) => item['day'] as String).toList();
  }
  
  /// Get max emission value for chart scaling
  double getMaxEmissionValue() {
    if (weeklyEmissions.isEmpty) return 10.0; // Default value if no data
    
    double maxValue = 0;
    for (var entry in weeklyEmissions) {
      final value = entry['value'] as double;
      if (value > maxValue) {
        maxValue = value;
      }
    }
    
    // Return slightly higher value to avoid bars touching the top
    return (maxValue * 1.1 > 0) ? maxValue * 1.1 : 10.0;
  }
  
  /// Get the maximum value for the weekly emissions chart plus some padding
  double getWeeklyEmissionsMaxValue() {
    if (weeklyEmissions.isEmpty) return 50.0; // Default max if no data
    
    // Find the max value
    double maxValue = 0;
    for (final item in weeklyEmissions) {
      if ((item['value'] as num) > maxValue) {
        maxValue = (item['value'] as num).toDouble();
      }
    }
    
    // Add 20% padding to the top
    maxValue = maxValue * 1.2;
    
    // Round to a nice number
    if (maxValue <= 10) {
      return 10.0;
    } else if (maxValue <= 25) {
      return 25.0;
    } else if (maxValue <= 50) {
      return 50.0;
    } else if (maxValue <= 100) {
      return 100.0;
    } else {
      // Round to nearest 50
      return ((maxValue / 50).ceil() * 50).toDouble();
    }
  }
  
  /// Get weekly emissions bar chart data
  List<BarChartGroupData> getWeeklyEmissionsBarData() {
    final List<BarChartGroupData> barGroups = [];
    
    if (weeklyEmissions.isEmpty) return barGroups;
    
    // Create bar chart groups
    for (int i = 0; i < weeklyEmissions.length; i++) {
      final item = weeklyEmissions[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: item['value'],
              color: item['value'] > 0 
                  ? const Color(0xFF5CC971)  // Green
                  : Colors.grey.shade300,    // Grey for empty bars
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }
    
    return barGroups;
  }
  
  /// Generate sample data for the charts (would be replaced with real data)
  void generateSampleData() {
    // This method is retained for backwards compatibility but not used
    // Real data is now fetched from HomeController
  }
  
  /// Connect to real data from the home controller
  void _connectToRealData() {
    // Clear existing data
    carbonBreakdown.clear();
    milesByMode.clear();
    
    // Generate weekly data
    _generateWeeklyEmissionsData();
  }
  
  /// Generate weekly emissions data for the selected week
  void _generateWeeklyEmissionsData() {
    weeklyEmissions.clear();
    
    final startOfWeek = _getStartOfWeek(selectedWeek.value);
    
    // Get all recent activities from the home controller
    final homeController = _homeController;
    final activities = homeController.recentActivities;
    
    // Define specific transportation and energy categories
    final transportCategories = {
      'car': 'Car',
      'bus': 'Bus',
      'train': 'Train',
      'bike': 'Bicycle',
      'walk': 'Walking',
      'plane': 'Air Travel',
    };
    
    final energyCategories = {
      'electricity': 'Electricity',
      'gas': 'Natural Gas',
      'heating': 'Heating',
      'cooling': 'Cooling',
    };
    
    // Create maps to store totals by category
    final carbonByCategory = <String, double>{};
    final milesByType = <String, double>{};
    
    // Conversion factors for different transportation modes (lbs CO2 per mile)
    final emissionsPerMile = {
      'car': 0.9, // Average car
      'suv': 1.1, // SUV
      'hybrid': 0.5, // Hybrid car
      'bus': 0.5, // Bus
      'train': 0.3, // Train
      'plane': 1.5, // Airplane
      'bike': 0.0, // Bicycle
      'walk': 0.0, // Walking
    };
    
    // Calculate total carbon and miles by category
    for (final activity in activities) {
      final type = activity['type'] as String;
      final subType = activity['subType'] as String?;
      final emissions = activity['emissions'] as num;
      
      // Determine category label
      String category;
      
      if (type == 'transportation') {
        // Use specific category if available, otherwise use generic transportation
        String transportType = 'Other Transport';
        if (subType != null && transportCategories.containsKey(subType)) {
          transportType = transportCategories[subType]!;
        }
        category = transportType;
        
        // Estimate miles based on emissions using conversion factors
        double estimatedMiles = 0.0;
        double conversionFactor = 0.7; // Default factor
        
        if (subType != null && emissionsPerMile.containsKey(subType)) {
          conversionFactor = emissionsPerMile[subType]!;
        }
        
        // Avoid division by zero
        if (conversionFactor > 0) {
          estimatedMiles = emissions.toDouble() / conversionFactor;
        } else {
          // For zero-emission modes, estimate 5 miles per activity
          estimatedMiles = 5.0;
        }
        
        // Add to miles breakdown
        milesByType[transportType] = (milesByType[transportType] ?? 0.0) + estimatedMiles;
      } else if (type == 'energy') {
        // Use specific category if available, otherwise use generic energy
        if (subType != null && energyCategories.containsKey(subType)) {
          category = energyCategories[subType]!;
        } else {
          category = 'Other Energy';
        }
      } else if (type == 'food') {
        category = 'Food';
      } else if (type == 'consumer') {
        category = 'Consumer Goods';
      } else {
        category = StringExtension(type as String).capitalize;
      }
      
      // Add to carbon breakdown
      carbonByCategory[category] = (carbonByCategory[category] ?? 0.0) + emissions.toDouble();
    }
    
    // Calculate totals
    double totalCarbonValue = 0.0;
    double totalMilesValue = 0.0;
    
    // Convert maps to lists for the charts
    final carbonItems = carbonByCategory.entries.map((entry) => {
      'label': entry.key,
      'value': entry.value,
    }).toList();
    
    final milesItems = milesByType.entries.map((entry) => {
      'label': entry.key,
      'value': entry.value,
    }).toList();
    
    // Sort items by value (descending)
    carbonItems.sort((a, b) => (b['value'] as num).compareTo(a['value'] as num));
    milesItems.sort((a, b) => (b['value'] as num).compareTo(a['value'] as num));
    
    // Calculate totals
    totalCarbonValue = carbonItems.fold(0.0, (sum, item) => sum + (item['value'] as num));
    totalMilesValue = milesItems.fold(0.0, (sum, item) => sum + (item['value'] as num));
    
    totalCarbon.value = totalCarbonValue;
    totalMiles.value = totalMilesValue;
    
    // Calculate percentages and add to breakdown lists
    for (final item in carbonItems) {
      carbonBreakdown.add({
        'label': StringExtension(item['label'] as String).capitalize,
        'value': item['value'],
        'percentage': totalCarbonValue > 0 ? (item['value'] as num) / totalCarbonValue * 100 : 0.0,
      });
    }
    
    for (final item in milesItems) {
      milesByMode.add({
        'label': item['label'],
        'value': item['value'],
        'percentage': totalMilesValue > 0 ? (item['value'] as num) / totalMilesValue * 100 : 0.0,
      });
    }
    
    // If we don't have any data, add placeholder data
    if (carbonBreakdown.isEmpty) {
      carbonBreakdown.add({
        'label': 'No Data',
        'value': 0.0,
        'percentage': 100.0,
      });
    }
    
    if (milesByMode.isEmpty) {
      milesByMode.add({
        'label': 'No Data',
        'value': 0.0,
        'percentage': 100.0,
      });
    }
  }
  
  /// Get carbon categories breakdown
  void _calculateCarbonBreakdown() {
    // This method is now replaced by _connectToRealData's functionality
    // We'll keep it as a stub for backwards compatibility
  }

  /// Get miles by mode breakdown
  void _calculateMilesByMode() {
    // This method is now replaced by _connectToRealData's functionality
    // We'll keep it as a stub for backwards compatibility
  }
}
