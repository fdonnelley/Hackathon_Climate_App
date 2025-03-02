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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Your Carbon Impact',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track and analyze your carbon footprint',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              
              // Carbon Breakdown Pie Chart
              _buildCarbonBreakdownChart(context, controller),
              
              const SizedBox(height: 32),
              
              // Miles by Mode Pie Chart
              _buildMilesByModeChart(context, controller),
              
              const SizedBox(height: 32),
              
              // Weekly Bar Chart
              _buildWeeklyEmissionsChart(context, controller),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Carbon Footprint Breakdown',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sources of your carbon emissions',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          
          // Pie Chart
          SizedBox(
            height: 220,
            child: Row(
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
                                  centerSpaceRadius: 50,
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
                                      radius: 50,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              // Add total emissions label in the center
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${controller.totalCarbon.value.toStringAsFixed(1)}',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    'lbs CO₂',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                  }),
                ),
                
                // Legend
                Expanded(
                  flex: 4,
                  child: Obx(() {
                    return controller.carbonBreakdown.isEmpty
                        ? const SizedBox.shrink()
                        : ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
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
                              
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        label,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${value.toStringAsFixed(1)} lbs',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${percentage.toStringAsFixed(1)}%',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                  }),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Total CO2
          Center(
            child: Obx(() => Column(
              children: [
                Text(
                  '${controller.totalCarbon.value.toStringAsFixed(1)} lbs',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'Total CO₂ Emissions',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMilesByModeChart(BuildContext context, AnalyticsController controller) {
    final theme = Theme.of(context);
    
    // Mode-specific colors
    final Map<String, Color> modeColors = {
      'Car': const Color(0xFF5CC971),        // Green
      'Public Transit': const Color(0xFF4D8FEA), // Blue
      'Walking': const Color(0xFF32ADE6),    // Light blue 
      'Bicycle': const Color(0xFF9E43D9),    // Purple
      'Air Travel': const Color(0xFFFF6150), // Red
      'Other': const Color(0xFF9E9E9E),      // Grey
    };
    
    // Default colors array
    final List<Color> defaultColors = [
      const Color(0xFF5CC971), // Green
      const Color(0xFF4D8FEA), // Blue
      const Color(0xFFFF6150), // Red
      const Color(0xFFFEBD12), // Yellow
      const Color(0xFF9E43D9), // Purple
    ];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Miles Traveled by Mode',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'How you get around (includes zero-emission vehicles)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            height: 220,
            child: Row(
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
                                  centerSpaceRadius: 50,
                                  sections: controller.milesByMode.map((item) {
                                    final label = item['label'] as String;
                                    final value = (item['value'] as double);
                                    final percentage = (item['percentage'] as double).toStringAsFixed(1);
                                    
                                    // Use predefined color if available, otherwise use from color array
                                    final Color color;
                                    if (modeColors.containsKey(label)) {
                                      color = modeColors[label]!;
                                    } else {
                                      color = defaultColors[colorIndex % defaultColors.length];
                                      colorIndex++;
                                    }
                                    
                                    return PieChartSectionData(
                                      color: color,
                                      value: value,
                                      title: '$percentage%',
                                      radius: 50,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              // Add total miles label in the center
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${controller.totalMiles.value.toStringAsFixed(1)}',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    'miles',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                  }),
                ),
                
                // Legend
                Expanded(
                  flex: 4,
                  child: Obx(() {
                    return controller.milesByMode.isEmpty
                        ? const SizedBox.shrink()
                        : ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.milesByMode.length,
                            itemBuilder: (context, index) {
                              final item = controller.milesByMode[index];
                              final label = item['label'] as String;
                              final value = item['value'] as double;
                              final percentage = item['percentage'] as double;
                              
                              // Determine color
                              final Color color;
                              if (modeColors.containsKey(label)) {
                                color = modeColors[label]!;
                              } else {
                                color = defaultColors[index % defaultColors.length];
                              }
                              
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        label,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${value.toStringAsFixed(1)} mi',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${percentage.toStringAsFixed(1)}%',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                  }),
                ),
              ],
            ),
          ),
          
          // If no miles recorded, show the total at the bottom
          Obx(() => controller.milesByMode.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      '${controller.totalMiles.value.toStringAsFixed(1)} miles',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink()
          ),
        ],
      ),
    );
  }
  
  Widget _buildWeeklyEmissionsChart(BuildContext context, AnalyticsController controller) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Emissions',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                    controller.getWeekDateRange(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  )),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: controller.previousWeek,
                    icon: const Icon(Icons.arrow_back_ios, size: 18),
                    tooltip: 'Previous Week',
                  ),
                  Obx(() => IconButton(
                    onPressed: controller.isNextWeekDisabled() 
                        ? null 
                        : controller.nextWeek,
                    icon: const Icon(Icons.arrow_forward_ios, size: 18),
                    tooltip: 'Next Week',
                    color: controller.isNextWeekDisabled()
                        ? Colors.grey.shade400
                        : null,
                  )),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Bar Chart
          SizedBox(
            height: 250,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 24),
              child: Obx(() => BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: controller.getWeeklyEmissionsMaxValue(), // Dynamic max value based on data
                  barGroups: controller.getWeeklyEmissionsBarData(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      axisNameWidget: Text(
                        'lbs CO₂',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox.shrink();
                          return Text(
                            value.toInt().toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value < 0 || value >= controller.getWeekDays().length) {
                            return const SizedBox.shrink();
                          }
                          
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              controller.getWeekDays()[value.toInt()],
                              style: theme.textTheme.bodySmall,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    horizontalInterval: 10,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    ),
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                ),
              )),
            ),
          ),
          
          // Legend explanation
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5CC971),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Daily Carbon Emissions',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
