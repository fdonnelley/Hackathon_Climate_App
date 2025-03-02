import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
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
  
  // Maximum weekly emission value for chart scaling
  final RxDouble maxWeeklyEmission = 0.0.obs;
  
  // Weekly percentage change (positive = increase, negative = decrease)
  final RxDouble weeklyChangePercentage = 0.0.obs;
  
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
    _generateMilesByMode();
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
    return date.subtract(Duration(days: date.weekday % 7));
  }
  
  /// Get short month name
  String _getShortMonthName(int month) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }
  
  /// Get days of the week for the chart
  List<String> getWeekDays() {
    return ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  }
  
  /// Get max emission value for chart scaling
  double getMaxEmissionValue() {
    if (weeklyEmissions.isEmpty) return 10.0; // Default value if no data
    
    double maxValue = 0;
    for (var entry in weeklyEmissions) {
      final value = entry['emissions'] as double;
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
      if ((item['emissions'] as num) > maxValue) {
        maxValue = (item['emissions'] as num).toDouble();
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
    
    if (weeklyEmissions.isEmpty) {
      // Create empty bar groups if no data
      for (int i = 0; i < 7; i++) {
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: 0,
                color: Colors.grey.shade300,
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
    
    // Find the maximum value for color scaling
    double maxValue = 0;
    for (final item in weeklyEmissions) {
      final value = item['emissions'] as double;
      if (value > maxValue) {
        maxValue = value;
      }
    }
    
    // Create bar chart groups
    for (int i = 0; i < weeklyEmissions.length; i++) {
      final item = weeklyEmissions[i];
      final value = item['emissions'] as double;
      
      // Calculate a color from green to red based on percentage of max
      Color barColor;
      if (maxValue > 0) {
        final percentage = value / maxValue;
        if (percentage < 0.3) {
          barColor = const Color(0xFF5CC971); // Green for low emissions
        } else if (percentage < 0.7) {
          barColor = const Color(0xFFFEBD12); // Yellow for medium emissions
        } else {
          barColor = const Color(0xFFFF6150); // Red for high emissions
        }
      } else {
        barColor = Colors.grey.shade300; // Default for empty bars
      }
      
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: value > 0 ? barColor : Colors.grey.shade300,
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
          // Show the value on top of the bar
          showingTooltipIndicators: value > 0 ? [0] : [],
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
    // No need to reassign _homeController since it's already initialized as final
    
    // Generate initial data
    _generateWeeklyEmissionsData();
    _generateCarbonBreakdown();
    _generateMilesByMode();
    
    // Listen for changes in activities
    ever(_homeController.recentActivities, (_) {
      _generateWeeklyEmissionsData();
      _generateCarbonBreakdown();
      _generateMilesByMode();
      update();
    });
  }
  
  /// Generate weekly emissions data based on selected week
  void _generateWeeklyEmissionsData() {
    weeklyEmissions.clear();
    
    // Get non-recursive emissions data
    List<Map<String, dynamic>> emissionsData = _generateWeeklyEmissionsDataWithoutRecursion();
    
    // Add data to observable list
    weeklyEmissions.addAll(emissionsData);
    
    // Calculate max emission value for chart scaling
    double maxEmission = 0;
    for (final item in weeklyEmissions) {
      final emissions = item['emissions'] as double;
      if (emissions > maxEmission) {
        maxEmission = emissions;
      }
    }
    maxWeeklyEmission.value = maxEmission > 0 ? maxEmission : 10.0;
    
    // Calculate week-over-week percentage change
    _calculateWeeklyChangePercentage();
    
    // If we have no data for this week, create empty data
    if (weeklyEmissions.isEmpty) {
      _generateEmptyWeekData();
    }
  }
  
  /// Calculate percentage change in emissions compared to previous week
  void _calculateWeeklyChangePercentage() {
    // Get current week's total emissions
    double currentWeekTotal = 0;
    for (final item in weeklyEmissions) {
      currentWeekTotal += item['emissions'] as double;
    }
    
    // Store the current week's data
    final currentWeekData = List<Map<String, dynamic>>.from(weeklyEmissions);
    
    // Get previous week's data
    final DateTime previousWeekDate = selectedWeek.value.subtract(const Duration(days: 7));
    
    // Save current selected week
    final DateTime savedCurrentWeek = selectedWeek.value;
    
    // Temporarily set to previous week
    selectedWeek.value = previousWeekDate;
    
    // Generate data for previous week without recursive call to _calculateWeeklyChangePercentage
    List<Map<String, dynamic>> previousWeekEmissions = _generateWeeklyEmissionsDataWithoutRecursion();
    
    // Calculate previous week's total
    double previousWeekTotal = 0;
    for (final item in previousWeekEmissions) {
      previousWeekTotal += item['emissions'] as double;
    }
    
    // Restore current week's data
    selectedWeek.value = savedCurrentWeek;
    weeklyEmissions.clear();
    weeklyEmissions.addAll(currentWeekData);
    
    // Calculate percentage change
    if (previousWeekTotal > 0) {
      final change = ((currentWeekTotal - previousWeekTotal) / previousWeekTotal) * 100;
      weeklyChangePercentage.value = change;
    } else if (currentWeekTotal > 0) {
      weeklyChangePercentage.value = 100; // Previous week had zero emissions
    } else {
      weeklyChangePercentage.value = 0; // Both weeks had zero emissions
    }
  }
  
  /// Generate weekly emissions data without calculating weekly percentage change
  List<Map<String, dynamic>> _generateWeeklyEmissionsDataWithoutRecursion() {
    List<Map<String, dynamic>> result = [];
    
    // Determine start and end dates for the selected week
    final DateTime startDate = _getStartOfWeek(selectedWeek.value);
    final DateTime endDate = startDate.add(const Duration(days: 6));
    
    // Check if we have any activities
    if (_homeController.recentActivities.isEmpty) {
      return _getEmptyWeekData();
    }
    
    // Filter activities that occurred during the selected week
    final weekActivities = _homeController.recentActivities
        .where((activity) {
          if (activity['date'] == null) return false;
          
          final DateTime activityDate = activity['date'] as DateTime;
          
          // Check if activity date is within the selected week
          return activityDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
                 activityDate.isBefore(endDate.add(const Duration(days: 1)));
        })
        .toList();
    
    // Create a map to store emissions by day of week
    final Map<int, Map<String, dynamic>> emissionsByDay = {};
    
    // Initialize all days with zero emissions
    for (int i = 0; i < 7; i++) {
      final DateTime dayDate = startDate.add(Duration(days: i));
      final String dayName = _getDayName(dayDate.weekday);
      
      emissionsByDay[i] = {
        'day': dayName,
        'emissions': 0.0,
        'categories': <String, double>{
          'Transportation': 0.0,
          'Energy': 0.0,
          'Food': 0.0,
          'Waste': 0.0,
          'Other': 0.0,
        }
      };
    }
    
    // Aggregate emissions by day
    for (final activity in weekActivities) {
      if (activity['date'] != null && activity['emissions'] != null) {
        final DateTime date = activity['date'] as DateTime;
        final double emissions = (activity['emissions'] as num).toDouble();
        
        // Calculate day of week (0 = Sunday, 6 = Saturday)
        final int dayOfWeek = date.weekday % 7;
        
        // Add emissions to the corresponding day
        final currentEmissions = emissionsByDay[dayOfWeek]!['emissions'] as double;
        emissionsByDay[dayOfWeek]!['emissions'] = currentEmissions + emissions;
        
        // Determine category for this activity
        String category = 'Other';
        final type = (activity['type'] as String?)?.toLowerCase() ?? '';
        
        if (_isTransportationCategory(activity)) {
          category = 'Transportation';
        } else if (type.contains('energy') || type.contains('electric') || type.contains('power')) {
          category = 'Energy';
        } else if (type.contains('food') || type.contains('meal') || type.contains('eat') || type.contains('vegetable') || type.contains('fruit')) {
          category = 'Food';
        } else if (type.contains('waste') || type.contains('recycl') || type.contains('trash')) {
          category = 'Waste';
        }
        
        // Add to category total
        final Map<String, double> categories = 
            emissionsByDay[dayOfWeek]!['categories'] as Map<String, double>;
        categories[category] = (categories[category] ?? 0) + emissions;
      }
    }
    
    // Convert map to list format for the chart
    emissionsByDay.forEach((day, data) {
      result.add(data);
    });
    
    // Sort by day of week (0 = Sunday, 6 = Saturday)
    result.sort((a, b) {
      const dayOrder = {'Sunday': 0, 'Monday': 1, 'Tuesday': 2, 'Wednesday': 3, 'Thursday': 4, 'Friday': 5, 'Saturday': 6};
      return dayOrder[a['day']]!.compareTo(dayOrder[b['day']]!);
    });
    
    return result;
  }
  
  /// Get empty week data for display when no real data exists
  List<Map<String, dynamic>> _getEmptyWeekData() {
    List<Map<String, dynamic>> emptyData = [];
    const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    
    for (int i = 0; i < 7; i++) {
      emptyData.add({
        'day': dayNames[i],
        'emissions': 0.0,
        'categories': <String, double>{
          'Transportation': 0.0,
          'Energy': 0.0,
          'Food': 0.0,
          'Waste': 0.0,
          'Other': 0.0,
        }
      });
    }
    
    return emptyData;
  }
  
  /// Get day name from weekday number
  String _getDayName(int weekday) {
    const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return dayNames[weekday % 7]; // Adjust to make Sunday (7) map to index 0
  }
  
  /// Generate empty week data for display when no real data exists
  void _generateEmptyWeekData() {
    weeklyEmissions.clear();
    const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    
    for (int i = 0; i < 7; i++) {
      weeklyEmissions.add({
        'day': dayNames[i],
        'emissions': 0.0,
        'categories': <String, double>{
          'Transportation': 0.0,
          'Energy': 0.0,
          'Food': 0.0,
          'Waste': 0.0,
          'Other': 0.0,
        }
      });
    }
    
    // Reset max weekly emission to default
    maxWeeklyEmission.value = 10.0;
    
    // Reset weekly change percentage
    weeklyChangePercentage.value = 0.0;
  }
  
  /// Generate carbon footprint breakdown by category
  void _generateCarbonBreakdown() {
    // Reset breakdown data
    carbonBreakdown.clear();
    
    // Early return if no activities
    if (_homeController.recentActivities.isEmpty) {
      totalCarbon.value = 0;
      return;
    }
    
    // Temporary map to store category totals
    final Map<String, double> categoryTotals = {};
    double totalEmissions = 0;
    
    // Calculate totals by category
    for (final activity in _homeController.recentActivities) {
      final category = _determineCategoryFromActivity(activity);
      final emissions = activity['emissions'] as double?;
      
      if (emissions != null && emissions > 0) {
        categoryTotals[category] = (categoryTotals[category] ?? 0) + emissions;
        totalEmissions += emissions;
      }
    }
    
    // Update total carbon value
    totalCarbon.value = totalEmissions;
    
    // If no emissions data, return early
    if (totalEmissions <= 0) return;
    
    // Convert to array format with percentages
    categoryTotals.forEach((category, value) {
      final percentage = (value / totalEmissions) * 100;
      carbonBreakdown.add({
        'label': category,
        'value': value,
        'percentage': percentage,
      });
    });
    
    // Sort by value (highest to lowest)
    carbonBreakdown.sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));
  }
  
  /// Determine the category from an activity
  String _determineCategoryFromActivity(Map<String, dynamic> activity) {
    final type = activity['type']?.toLowerCase() ?? '';
    
    // Transportation categories
    if (type.contains('car') || 
        type.contains('drive') || 
        type.contains('vehicle')) {
      return 'Car Travel';
    }
    
    if (type.contains('flight') || 
        type.contains('air') || 
        type.contains('plane')) {
      return 'Air Travel';
    }
    
    if (type.contains('public') || 
        type.contains('transit') || 
        type.contains('bus') || 
        type.contains('train') || 
        type.contains('subway')) {
      return 'Public Transit';
    }
    
    if (type.contains('bike') || 
        type.contains('walk') || 
        type.contains('scoot')) {
      return 'Zero-Emission Travel';
    }
    
    // Energy categories
    if (type.contains('electricity') || 
        type.contains('power') || 
        type.contains('electric')) {
      return 'Electricity';
    }
    
    if (type.contains('heat') || 
        type.contains('gas') || 
        type.contains('oil') || 
        type.contains('fuel')) {
      return 'Heating';
    }
    
    if (type.contains('appliance') || 
        type.contains('device') || 
        type.contains('electronics')) {
      return 'Appliances';
    }
    
    // Food categories
    if (type.contains('meat') || 
        type.contains('beef') || 
        type.contains('pork') || 
        type.contains('chicken')) {
      return 'Meat Consumption';
    }
    
    if (type.contains('dairy') || 
        type.contains('milk') || 
        type.contains('cheese')) {
      return 'Dairy Products';
    }
    
    if (type.contains('food') || 
        type.contains('meal') || 
        type.contains('eat') || 
        type.contains('vegetable') || 
        type.contains('fruit')) {
      return 'Food';
    }
    
    // Other categories
    if (type.contains('waste') || 
        type.contains('recycl') || 
        type.contains('trash')) {
      return 'Waste';
    }
    
    if (type.contains('water') || 
        type.contains('shower')) {
      return 'Water Usage';
    }
    
    // Generic categories based on input type
    if (activity['emissions'] != null && activity['emissions'] > 0) {
      if (type.contains('transport')) {
        return 'Transportation';
      } else if (type.contains('energy')) {
        return 'Energy';
      } else {
        return 'Other';
      }
    }
    
    // Default category
    return 'Uncategorized';
  }
  
  /// Generate miles by transportation mode data
  void _generateMilesByMode() {
    // Reset miles data
    milesByMode.clear();
    
    // Early return if no activities
    if (_homeController.recentActivities.isEmpty) {
      totalMiles.value = 0;
      return;
    }
    
    // Temporary map to store miles by mode
    final Map<String, double> modeToMiles = {};
    double totalMilesValue = 0;
    
    // Calculate miles for transportation activities
    for (final activity in _homeController.recentActivities) {
      final type = (activity['type'] as String?)?.toLowerCase() ?? '';
      
      // Only process transportation-related activities
      if (!_isTransportationCategory(activity)) {
        continue;
      }
      
      // Determine transportation mode
      final mode = _determineTransportMode(activity);
      
      // Check for actual miles data first
      double miles = 0;
      if (activity.containsKey('miles')) {
        // Use actual miles from activity data
        miles = (activity['miles'] as num).toDouble();
      } else {
        // Fall back to estimation if miles not available
        final emissions = (activity['emissions'] as num?)?.toDouble() ?? 0.0;
        miles = _calculateMilesFromEmissions(emissions, mode);
      }
      
      // Skip if no miles
      if (miles <= 0) continue;
      
      // Add to miles totals
      modeToMiles[mode] = (modeToMiles[mode] ?? 0.0) + miles;
      totalMilesValue += miles;
    }
    
    // Update total miles
    totalMiles.value = totalMilesValue;
    
    // If no data, return early
    if (totalMilesValue <= 0) return;
    
    // Convert to array format with percentages
    modeToMiles.forEach((mode, miles) {
      final percentage = (miles / totalMilesValue) * 100;
      milesByMode.add({
        'mode': mode,
        'miles': miles,
        'percentage': percentage,
      });
    });
    
    // Sort by value (highest to lowest)
    milesByMode.sort((a, b) => (b['miles'] as double).compareTo(a['miles'] as double));
  }
  
  /// Check if activity is a transportation category
  bool _isTransportationCategory(Map<String, dynamic> activity) {
    final type = (activity['type'] as String?)?.toLowerCase() ?? '';
    final subType = (activity['subType'] as String?)?.toLowerCase() ?? '';
    final description = (activity['description'] as String?)?.toLowerCase() ?? '';
    final transportMode = (activity['transportMode'] as String?)?.toLowerCase() ?? '';
    final title = (activity['title'] as String?)?.toLowerCase() ?? '';
    
    // Debug information
    print('Checking if transportation: $activity');
    
    return type.contains('car') || 
           type.contains('bus') || 
           type.contains('train') || 
           type.contains('walk') || 
           type.contains('foot') ||
           type.contains('running') ||
           type.contains('bike') || 
           type.contains('flight') || 
           type.contains('scooter') ||
           type.contains('transport') ||
           subType.contains('car') || 
           subType.contains('bus') || 
           subType.contains('train') || 
           subType.contains('walk') ||
           subType.contains('foot') ||
           subType.contains('running') ||
           subType.contains('bike') || 
           subType.contains('flight') || 
           subType.contains('scooter') ||
           subType.contains('transport') ||
           description.contains('walk') ||
           description.contains('foot') ||
           description.contains('running') ||
           description.contains('bike') ||
           description.contains('car') ||
           description.contains('drive') ||
           description.contains('transport') ||
           transportMode.contains('walk') ||
           transportMode.contains('car') ||
           transportMode.contains('drive') ||
           transportMode.contains('bike') ||
           transportMode.contains('train') ||
           transportMode.contains('bus') ||
           transportMode.contains('flight') ||
           title.contains('walk') ||
           title.contains('bike') ||
           title.contains('car') ||
           title.contains('drive') ||
           title.contains('train') ||
           title.contains('bus');
  }
  
  /// Determine transportation mode from activity
  String _determineTransportMode(Map<String, dynamic> activity) {
    final type = (activity['type'] as String?)?.toLowerCase() ?? '';
    final subType = (activity['subType'] as String?)?.toLowerCase() ?? '';
    final description = (activity['description'] as String?)?.toLowerCase() ?? '';
    final transportMode = (activity['transportMode'] as String?)?.toLowerCase() ?? '';
    final title = (activity['title'] as String?)?.toLowerCase() ?? '';
    
    print('Determining mode for: $activity');
    print('type: $type, subType: $subType, description: $description, transportMode: $transportMode, title: $title');
    
    // Check for specific transportation types
    if (type.contains('car') || 
        type.contains('drive') || 
        subType.contains('car') || 
        subType.contains('drive') ||
        transportMode.contains('car') ||
        transportMode.contains('drive')) {
      return 'Car';
    }
    
    if (type.contains('bus') || 
        type.contains('train') || 
        type.contains('subway') || 
        type.contains('public') || 
        type.contains('transit') ||
        subType.contains('bus') || 
        subType.contains('train') || 
        subType.contains('subway') || 
        subType.contains('public') || 
        subType.contains('transit') ||
        transportMode.contains('bus') ||
        transportMode.contains('train') ||
        transportMode.contains('transit')) {
      return 'Public Transit';
    }
    
    if (type.contains('walk') || 
        subType.contains('walk') ||
        description.contains('walk') ||
        type.contains('foot') ||
        subType.contains('foot') ||
        description.contains('foot') ||
        type.contains('running') ||
        subType.contains('running') ||
        description.contains('running') ||
        transportMode.contains('walk') ||
        title.contains('walk')) {
      return 'Walking';
    }
    
    if (type.contains('bike') || 
        type.contains('bicycle') || 
        subType.contains('bike') || 
        subType.contains('bicycle') ||
        description.contains('bike') ||
        description.contains('bicycle') ||
        transportMode.contains('bike') ||
        transportMode.contains('bicycle')) {
      return 'Bicycle';
    }
    
    if (type.contains('flight') || 
        type.contains('plane') || 
        type.contains('air') || 
        subType.contains('flight') || 
        subType.contains('plane') || 
        subType.contains('air') ||
        transportMode.contains('flight') ||
        transportMode.contains('plane') ||
        transportMode.contains('air')) {
      return 'Air Travel';
    }
    
    // Default category
    return 'Other';
  }
  
  /// Calculate estimated miles from emissions based on transportation mode
  double _calculateMilesFromEmissions(double emissions, String mode) {
    // Debug information
    print('Calculating miles for mode: $mode with emissions: $emissions');
    
    // Handle zero-emission modes specially
    if (mode == 'Walking') {
      // For walking, use a default value based on average walking speed
      // If we have emissions data, still use it, but ensure we return at least 1 mile
      if (emissions > 0) {
        return max(1.0, emissions / 0.1); // Very low emissions per mile for walking
      } else {
        return 2.0; // Default assumption: 2 miles of walking
      }
    }
    
    if (mode == 'Bicycle') {
      // For bicycling, use a default value based on average cycling distance
      // If we have emissions data, still use it, but ensure we return at least 2 miles
      if (emissions > 0) {
        return max(2.0, emissions / 0.1); // Very low emissions per mile for cycling
      } else {
        return 5.0; // Default assumption: 5 miles of cycling
      }
    }
    
    // If emissions are 0 and it's not a zero-emission mode, return 0
    if (emissions <= 0) return 0;
    
    // Calculate miles based on mode-specific emission factors
    switch (mode) {
      case 'Car':
        // Emissions (lbs) / 0.9 lbs per mile (average car)
        return emissions / 0.9;
      case 'Public Transit':
        // Emissions (lbs) / 0.3 lbs per mile (average bus/train)
        return emissions / 0.3;
      case 'Air Travel':
        // Emissions (lbs) / 1.5 lbs per mile (average flight)
        return emissions / 1.5;
      default:
        // Default: Emissions (lbs) / 0.7 lbs per mile
        return emissions / 0.7;
    }
  }
}
