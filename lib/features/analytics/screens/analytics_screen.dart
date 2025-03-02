import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/analytics_controller.dart';

class AnalyticsScreen extends StatelessWidget {
  static const String routeName = '/analytics';
  
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.put(AnalyticsController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carbon Analytics'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Your Carbon Impact',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track and analyze your carbon footprint',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 28),
              
              // Carbon Breakdown Pie Chart
              _buildCarbonBreakdownChart(context, controller),
              
              const SizedBox(height: 32),
              
              // Miles by Mode Pie Chart
              _buildMilesByModeChart(context, controller),
              
              const SizedBox(height: 32),
              
              // Weekly Bar Chart
              _buildWeeklyEmissionsChart(context, controller),
              
              // Add bottom padding
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCarbonBreakdownChart(BuildContext context, AnalyticsController controller) {
    final theme = Theme.of(context);
    
    // Category colors for pie chart
    final Map<String, Color> categoryColors = {
      'Car Travel': const Color(0xFF4285F4),        // Blue
      'Public Transit': const Color(0xFF34A853),    // Green
      'Air Travel': const Color(0xFFFBBC05),        // Yellow
      'Zero-Emission Travel': const Color(0xFF5CC971), // Light Green
      
      'Electricity': const Color(0xFFEA4335),       // Red
      'Heating': const Color(0xFFFF6D01),           // Orange
      'Appliances': const Color(0xFFAB47BC),        // Purple
      
      'Food': const Color(0xFF0097A7),              // Teal
      'Meat Consumption': const Color(0xFFD32F2F),  // Dark Red
      'Dairy Products': const Color(0xFFFFB74D),    // Light Orange
      
      'Waste': const Color(0xFF795548),             // Brown
      'Water Usage': const Color(0xFF42A5F5),       // Light Blue
      
      'Transportation': const Color(0xFF3F51B5),    // Indigo
      'Energy': const Color(0xFFFF5722),            // Deep Orange
      'Other': const Color(0xFF9E9E9E),             // Grey
      'Uncategorized': const Color(0xFF607D8B),     // Blue Grey
    };
    
    // Default colors array for fallback
    final List<Color> defaultColors = [
      const Color(0xFF4285F4),  // Blue
      const Color(0xFF34A853),  // Green
      const Color(0xFFEA4335),  // Red
      const Color(0xFFFBBC05),  // Yellow
      const Color(0xFF673AB7),  // Deep Purple
      const Color(0xFFFF6D01),  // Orange
      const Color(0xFF0097A7),  // Teal
      const Color(0xFFE91E63),  // Pink
    ];
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Carbon Footprint Breakdown',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sources of your carbon emissions',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '${controller.totalCarbon.value.toStringAsFixed(1)} lbs',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 24),
          
          // Pie Chart
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pie Chart
                Expanded(
                  flex: 3,
                  child: Obx(() {
                    int colorIndex = 0;
                    
                    return controller.carbonBreakdown.isEmpty
                        ? const Center(child: Text('No data available'))
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  borderData: FlBorderData(show: false),
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 45,
                                  sections: controller.carbonBreakdown.map((item) {
                                    final label = item['label'] as String;
                                    final value = (item['value'] as double);
                                    final percentage = (item['percentage'] as double).toStringAsFixed(1);
                                    
                                    // Use predefined color if available, otherwise use from color array
                                    final Color color;
                                    if (categoryColors.containsKey(label)) {
                                      color = categoryColors[label]!;
                                    } else {
                                      color = defaultColors[colorIndex % defaultColors.length];
                                      colorIndex++;
                                    }
                                    
                                    return PieChartSectionData(
                                      color: color,
                                      value: value,
                                      title: '$percentage%',
                                      radius: 45,
                                      titleStyle: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      titlePositionPercentageOffset: 0.55,
                                    );
                                  }).toList(),
                                ),
                              ),
                              // Add total emissions label in the center
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 3,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${controller.totalCarbon.value.toStringAsFixed(1)}',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    Text(
                                      'lbs CO₂',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                  }),
                ),
                
                // Legend
                Expanded(
                  flex: 4,
                  child: Container(
                    margin: const EdgeInsets.only(left: 12),
                    child: Obx(() {
                      return controller.carbonBreakdown.isEmpty
                          ? const SizedBox.shrink()
                          : ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: controller.carbonBreakdown.length,
                              itemBuilder: (context, index) {
                                final item = controller.carbonBreakdown[index];
                                final label = item['label'] as String;
                                final value = item['value'] as double;
                                final percentage = item['percentage'] as double;
                                
                                // Determine color
                                final Color color;
                                if (categoryColors.containsKey(label)) {
                                  color = categoryColors[label]!;
                                } else {
                                  color = defaultColors[index % defaultColors.length];
                                }
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          label,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          '${value.toStringAsFixed(1)} lbs',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.primary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      SizedBox(
                                        width: 30,
                                        child: Text(
                                          '${percentage.toStringAsFixed(0)}%',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                                            fontSize: 10,
                                          ),
                                          textAlign: TextAlign.right,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                    }),
                  ),
                ),
              ],
            ),
          ),
          
          // Total CO2 has been moved to badge in the header
        ],
      ),
    );
  }
  
  Widget _buildMilesByModeChart(BuildContext context, AnalyticsController controller) {
    final theme = Theme.of(context);
    
    // Transportation mode colors
    final Map<String, Color> transportColors = {
      'Car': const Color(0xFF4285F4),          // Blue
      'Carpool': const Color(0xFF42A5F5),      // Light Blue
      'Bus': const Color(0xFF34A853),          // Green
      'Train': const Color(0xFF0F9D58),        // Dark Green
      'Subway': const Color(0xFF1DA462),       // Medium Green
      'Walk': const Color(0xFF5CC971),         // Light Green
      'Bike': const Color(0xFF4CAF50),         // Leaf Green
      'E-Bike': const Color(0xFF8BC34A),       // Lime
      'Scooter': const Color(0xFFCDDC39),      // Lime Yellow
      'Electric Car': const Color(0xFF03A9F4), // Light Blue
      'Rideshare': const Color(0xFF9C27B0),    // Purple
      'Motorcycle': const Color(0xFFFF5722),   // Deep Orange
      'Plane': const Color(0xFFFFC107),        // Amber
      'Boat': const Color(0xFF00ACC1),         // Cyan
      'Other': const Color(0xFF9E9E9E),        // Grey
    };
    
    // Default colors array for fallback
    final List<Color> defaultColors = [
      const Color(0xFF4285F4),  // Blue
      const Color(0xFF34A853),  // Green
      const Color(0xFFEA4335),  // Red
      const Color(0xFFFBBC05),  // Yellow
      const Color(0xFF673AB7),  // Deep Purple
      const Color(0xFF00BCD4),  // Cyan
      const Color(0xFF009688),  // Teal
      const Color(0xFFFF5722),  // Deep Orange
    ];
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Miles by Transportation Mode',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your travel habits breakdown',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '${controller.totalMiles.value.toStringAsFixed(1)} mi',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 24),
          
          // Pie Chart
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pie Chart
                Expanded(
                  flex: 3,
                  child: Obx(() {
                    int colorIndex = 0;
                    
                    return controller.milesByMode.isEmpty
                        ? const Center(child: Text('No data available'))
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  borderData: FlBorderData(show: false),
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 45,
                                  sections: controller.milesByMode.map((item) {
                                    final mode = item['mode'] as String;
                                    final miles = item['miles'] as double;
                                    final percentage = item['percentage'] as double;
                                    
                                    // Determine color
                                    final Color color;
                                    if (transportColors.containsKey(mode)) {
                                      color = transportColors[mode]!;
                                    } else {
                                      color = defaultColors[colorIndex % defaultColors.length];
                                      colorIndex++;
                                    }
                                    
                                    return PieChartSectionData(
                                      color: color,
                                      value: miles,
                                      title: '${percentage.toStringAsFixed(1)}%',
                                      radius: 45,
                                      titleStyle: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      titlePositionPercentageOffset: 0.55,
                                    );
                                  }).toList(),
                                ),
                              ),
                              // Add total miles label in the center
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 3,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${controller.totalMiles.value.toStringAsFixed(1)}',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.secondary,
                                      ),
                                    ),
                                    Text(
                                      'miles',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                  }),
                ),
                
                // Legend
                Expanded(
                  flex: 4,
                  child: Container(
                    margin: const EdgeInsets.only(left: 12),
                    child: Obx(() {
                      return controller.milesByMode.isEmpty
                          ? const SizedBox.shrink()
                          : ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: controller.milesByMode.length,
                              itemBuilder: (context, index) {
                                final item = controller.milesByMode[index];
                                final mode = item['mode'] as String;
                                final miles = item['miles'] as double;
                                final percentage = item['percentage'] as double;
                                
                                // Determine color
                                final Color color;
                                if (transportColors.containsKey(mode)) {
                                  color = transportColors[mode]!;
                                } else {
                                  color = defaultColors[index % defaultColors.length];
                                }
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          mode,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          '${miles.toStringAsFixed(1)} mi',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.secondary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      SizedBox(
                                        width: 30,
                                        child: Text(
                                          '${percentage.toStringAsFixed(0)}%',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                                            fontSize: 10,
                                          ),
                                          textAlign: TextAlign.right,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWeeklyEmissionsChart(BuildContext context, AnalyticsController controller) {
    final theme = Theme.of(context);
    
    // Carbon emission category colors
    final Map<String, Color> categoryColors = {
      'Transportation': const Color(0xFF4285F4),  // Blue
      'Energy': const Color(0xFFEA4335),          // Red
      'Food': const Color(0xFF34A853),            // Green
      'Waste': const Color(0xFFFFBB00),           // Yellow
      'Other': const Color(0xFF9E9E9E),           // Grey
    };
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Emissions Trend',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your carbon footprint over time',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Obx(() {
                final weeklyChange = controller.weeklyChangePercentage.value;
                final isPositive = weeklyChange > 0;
                final changeColor = isPositive
                    ? const Color(0xFFEA4335) // Red for increase (negative)
                    : const Color(0xFF34A853); // Green for decrease (positive)
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? const Color(0xFFFEE8E6) // Light red background
                        : const Color(0xFFE6F4EA), // Light green background
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        color: changeColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${weeklyChange.abs().toStringAsFixed(1)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: changeColor,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 24),
          
          // Bar Chart
          SizedBox(
            height: 220,
            child: Obx(() {
              return controller.weeklyEmissions.isEmpty
                  ? const Center(child: Text('No weekly data available'))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: controller.maxWeeklyEmission.value * 1.2, // Add 20% headroom
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final weekDay = controller.weeklyEmissions[value.toInt()]['day'] as String;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    weekDay.substring(0, 3), // First 3 letters of day name
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    value.toInt().toString(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: controller.maxWeeklyEmission.value / 5,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: theme.dividerColor.withOpacity(0.2),
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            );
                          },
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        barGroups: List.generate(
                          controller.weeklyEmissions.length,
                          (index) {
                            final item = controller.weeklyEmissions[index];
                            final emissions = item['emissions'] as double;
                            final categories = item['categories'] as Map<String, double>?;
                            
                            List<BarChartRodStackItem> rodStackItems = [];
                            double currentSum = 0;
                            
                            // If we have category breakdown
                            if (categories != null && categories.isNotEmpty) {
                              categories.forEach((category, value) {
                                final color = categoryColors[category] ?? 
                                    const Color(0xFF9E9E9E); // Default grey
                                
                                rodStackItems.add(
                                  BarChartRodStackItem(
                                    currentSum,
                                    currentSum + value,
                                    color,
                                  ),
                                );
                                currentSum += value;
                              });
                            } else {
                              // If no breakdown, use a default color
                              rodStackItems.add(
                                BarChartRodStackItem(
                                  0,
                                  emissions,
                                  theme.colorScheme.primary,
                                ),
                              );
                            }
                            
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: emissions,
                                  width: 18,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(4),
                                  ),
                                  rodStackItems: rodStackItems,
                                ),
                              ],
                            );
                          },
                        ),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: theme.colorScheme.surface,
                            tooltipPadding: const EdgeInsets.all(8),
                            tooltipMargin: 8,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final item = controller.weeklyEmissions[groupIndex];
                              final day = item['day'] as String;
                              final emissions = item['emissions'] as double;
                              return BarTooltipItem(
                                '$day\n${emissions.toStringAsFixed(1)} lbs',
                                theme.textTheme.bodySmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
            }),
          ),
          
          // Category legend
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: categoryColors.entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: entry.value,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    entry.key,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
