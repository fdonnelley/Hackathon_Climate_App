import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/setup_controller.dart';
import '../models/setup_data_model.dart';

class GoalSelectionStep extends StatelessWidget {
  final SetupController controller;
  
  const GoalSelectionStep({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results header
          Text(
            'Your Carbon Footprint',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          
          const SizedBox(height: 24.0),
          
          // Carbon footprint result
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.co2,
                  size: 48.0,
                  color: Colors.green,
                ),
                
                const SizedBox(height: 16.0),
                
                Text(
                  'Your Weekly Carbon Footprint',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8.0),
                
                Obx(() => Text(
                  '${(controller.setupData.value.calculatedCarbonFootprint / 4.33).toStringAsFixed(1)} kg CO₂',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                )),
                
                const SizedBox(height: 8.0),
                
                Text(
                  'Based on your energy and transportation inputs',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32.0),
          
          // Goal selection header
          Text(
            'Choose Your Carbon Reduction Goal',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8.0),
          
          Text(
            'Select a goal that works for your lifestyle:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          
          const SizedBox(height: 16.0),
          
          // Goal options
          Obx(() => Column(
            children: [
              _buildGoalOption(
                context,
                level: CarbonGoalLevel.minimal,
                icon: Icons.emoji_nature,
                isSelected: controller.selectedGoalLevel.value == CarbonGoalLevel.minimal,
                onTap: () => controller.selectedGoalLevel.value = CarbonGoalLevel.minimal,
                carbonFootprint: controller.setupData.value.calculatedCarbonFootprint,
              ),
              
              const SizedBox(height: 12.0),
              
              _buildGoalOption(
                context,
                level: CarbonGoalLevel.moderate,
                icon: Icons.eco,
                isSelected: controller.selectedGoalLevel.value == CarbonGoalLevel.moderate,
                onTap: () => controller.selectedGoalLevel.value = CarbonGoalLevel.moderate,
                carbonFootprint: controller.setupData.value.calculatedCarbonFootprint,
              ),
              
              const SizedBox(height: 12.0),
              
              _buildGoalOption(
                context,
                level: CarbonGoalLevel.climateSaver,
                icon: Icons.volunteer_activism,
                isSelected: controller.selectedGoalLevel.value == CarbonGoalLevel.climateSaver,
                onTap: () => controller.selectedGoalLevel.value = CarbonGoalLevel.climateSaver,
                carbonFootprint: controller.setupData.value.calculatedCarbonFootprint,
              ),
            ],
          )),
          
          const SizedBox(height: 24.0),
          
          // Information about next steps - now collapsible
          CollapsibleInfoCard(
            title: 'What\'s Next?',
            content: 'After you select your goal, we\'ll create your personalized carbon budget. You\'ll be able to track your emissions, get tailored advice, and see your progress over time.',
            initiallyExpanded: false,
          ),
        ],
      ),
    );
  }
  
  Widget _buildGoalOption(
    BuildContext context, {
    required CarbonGoalLevel level,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required double carbonFootprint,
  }) {
    // Calculate the target based on reduction percentage
    final targetBudget = carbonFootprint * (1 - level.reductionPercentage) / 4.33;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).primaryColor.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected 
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
                size: 24.0,
              ),
            ),
            
            const SizedBox(width: 16.0),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected 
                          ? Theme.of(context).primaryColor
                          : Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 4.0),
                  
                  Text(
                    level.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  
                  const SizedBox(height: 8.0),
                  
                  Text(
                    'Weekly Goal: ${targetBudget.toStringAsFixed(1)} kg CO₂',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected 
                          ? Theme.of(context).primaryColor
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            
            Radio<CarbonGoalLevel>(
              value: level,
              groupValue: controller.selectedGoalLevel.value,
              onChanged: (value) {
                if (value != null) {
                  controller.selectedGoalLevel.value = value;
                }
              },
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

/// A collapsible information card widget
class CollapsibleInfoCard extends StatefulWidget {
  final String title;
  final String content;
  final bool initiallyExpanded;
  
  const CollapsibleInfoCard({
    Key? key,
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
  }) : super(key: key);
  
  @override
  _CollapsibleInfoCardState createState() => _CollapsibleInfoCardState();
}

class _CollapsibleInfoCardState extends State<CollapsibleInfoCard> {
  late bool _isExpanded;
  
  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and title
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.blue[700],
                    ),
                  ],
                ),
                
                // Content that can be collapsed
                AnimatedCrossFade(
                  firstChild: const SizedBox(height: 0),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      widget.content,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  crossFadeState: _isExpanded 
                      ? CrossFadeState.showSecond 
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
