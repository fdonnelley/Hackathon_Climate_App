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
    
    // Define colors for specific carbon categories (accessible to all widgets in this method)
    final Map<String, Color> categoryColors = {
      'Car': const Color(0xFF5CC971), // Green
      'Bus': const Color(0xFF4D8FEA), // Blue
      'Train': const Color(0xFFFEBD12), // Yellow
      'Bicycle': const Color(0xFF32ADE6), // Light blue
      'Walking': const Color(0xFF9E43D9), // Purple
      'Air Travel': const Color(0xFFFF6150), // Red
      'Electricity': const Color(0xFFFF9F40), // Orange
      'Natural Gas': const Color(0xFFBF6836), // Brown
      'Heating': const Color(0xFFE74856), // Red
      'Cooling': const Color(0xFF3B78FF), // Blue
      'Food': const Color(0xFF86B300), // Light green
      'Consumer Goods': const Color(0xFFD15700), // Orange
    };
    
    // Default colors array for other categories
    final List<Color> defaultColors = [
      const Color(0xFF5CC971), // Green
      const Color(0xFF4D8FEA), // Blue
      const Color(0xFFFEBD12), // Yellow
      const Color(0xFFFF6150), // Red
      const Color(0xFF9E43D9), // Purple
      const Color(0xFF32ADE6), // Light blue
      const Color(0xFFFF9F40), // Orange
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
                        : PieChart(
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
                          );
                  }),
                ),
                
                // Legend
                Expanded(
                  flex: 2,
                  child: Obx(() {
                    int colorIndex = 0;
                    
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...controller.carbonBreakdown.map((item) {
                          final label = item['label'] as String;
                          
                          // Use predefined color if available, otherwise use from color array
                          final Color color;
                          if (categoryColors.containsKey(label)) {
                            color = categoryColors[label]!;
                          } else {
                            color = defaultColors[colorIndex % defaultColors.length];
                            colorIndex++;
                          }
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    label,
                                    style: theme.textTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
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
    
    // Define colors for specific transportation modes (accessible to all widgets in this method)
    final Map<String, Color> modeColors = {
      'Car': const Color(0xFF5CC971), // Green
      'Bus': const Color(0xFF4D8FEA), // Blue
      'Train': const Color(0xFFFEBD12), // Yellow
      'Bicycle': const Color(0xFF32ADE6), // Light blue
      'Walking': const Color(0xFF9E43D9), // Purple
      'Air Travel': const Color(0xFFFF6150), // Red
      'Zero-Emission': const Color(0xFF86B300), // Light green
      'Other Transport': const Color(0xFFAAAAAA), // Gray
    };
    
    // Default colors array for other categories
    final List<Color> defaultColors = [
      const Color(0xFF5CC971), // Green
      const Color(0xFF4D8FEA), // Blue
      const Color(0xFFFEBD12), // Yellow
      const Color(0xFFFF6150), // Red
      const Color(0xFF9E43D9), // Purple
      const Color(0xFF32ADE6), // Light blue
      const Color(0xFFFF9F40), // Orange
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
            'Miles Traveled by Mode',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How you get around (includes zero-emission vehicles)',
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
                    
                    return controller.milesByMode.isEmpty
                        ? const Center(child: Text('No data available'))
                        : PieChart(
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
                          );
                  }),
                ),
                
                // Legend
                Expanded(
                  flex: 2,
                  child: Obx(() {
                    int colorIndex = 0;
                    
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...controller.milesByMode.map((item) {
                          final label = item['label'] as String;
                          
                          // Use predefined color if available, otherwise use from color array
                          final Color color;
                          if (modeColors.containsKey(label)) {
                            color = modeColors[label]!;
                          } else {
                            color = defaultColors[colorIndex % defaultColors.length];
                            colorIndex++;
                          }
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    label,
                                    style: theme.textTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Total Miles
          Center(
            child: Obx(() => Column(
              children: [
                Text(
                  '${controller.totalMiles.value.toStringAsFixed(1)} miles',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                Text(
                  'Total Miles Traveled',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            )),
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
