import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/setup_controller.dart';
import '../models/setup_data_model.dart';
import '../../carbon_tracker/models/usage_category_model.dart' as carbon_tracker;

class TransportationStep extends StatelessWidget {
  final SetupController controller;
  
  const TransportationStep({
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
          // Transportation header
          Text(
            'Transportation Habits',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          
          const SizedBox(height: 16.0),
          
          // Introduction
          Text(
            'Add each type of transportation you regularly use and how many miles per week.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          
          const SizedBox(height: 32.0),
          
          // Transportation input form
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Transportation Method',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16.0),
                
                // Transportation mode selection
                Obx(() => DropdownButtonFormField<TransportMode>(
                  decoration: const InputDecoration(
                    labelText: 'Transportation Type',
                    border: OutlineInputBorder(),
                  ),
                  value: controller.selectedTransportMode.value,
                  items: TransportMode.values.map((mode) {
                    return DropdownMenuItem<TransportMode>(
                      value: mode,
                      child: Row(
                        children: [
                          Icon(_getTransportIcon(mode)),
                          const SizedBox(width: 8.0),
                          Text(mode.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectedTransportMode.value = value;
                    }
                  },
                )),
                
                const SizedBox(height: 16.0),
                
                // Car type selection (only for car)
                Obx(() => Visibility(
                  visible: controller.selectedTransportMode.value == TransportMode.car,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Car Type',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      
                      const SizedBox(height: 8.0),
                      
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: CarType.values.map((type) {
                          return Obx(() => ChoiceChip(
                            label: Text(type.displayName),
                            selected: controller.selectedCarType.value == type,
                            onSelected: (selected) {
                              if (selected) {
                                controller.setCarType(type);
                              }
                            },
                          ));
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 16.0),
                      
                      // Car usage type selection (personal, taxi, carpool)
                      Text(
                        'How do you use this car?',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      
                      const SizedBox(height: 8.0),
                      
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: CarUsageType.values.map((type) {
                          return Obx(() => ChoiceChip(
                            label: Text(type.displayName),
                            selected: controller.selectedCarUsageType.value == type,
                            onSelected: (selected) {
                              if (selected) {
                                controller.setCarUsageType(type);
                              }
                            },
                          ));
                        }).toList(),
                      ),
                      
                      // Carpool size input (only for carpool)
                      Obx(() => Visibility(
                        visible: controller.selectedCarUsageType.value == CarUsageType.carpool,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Number of people in carpool:',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  Expanded(
                                    child: Slider(
                                      value: controller.carpoolSize.value.toDouble(),
                                      min: 2,
                                      max: 8,
                                      divisions: 6,
                                      label: controller.carpoolSize.value.toString(),
                                      onChanged: (value) {
                                        controller.setCarpoolSize(value.toInt());
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      '${controller.carpoolSize.value}',
                                      style: Theme.of(context).textTheme.titleMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Your emissions will be divided by the number of people',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                      
                      const SizedBox(height: 16.0),
                    ],
                  ),
                )),
                
                // Public transportation type selection (only for public transportation)
                Obx(() => Visibility(
                  visible: controller.selectedTransportMode.value == TransportMode.publicTransportation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Public Transportation Type',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      
                      const SizedBox(height: 8.0),
                      
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: PublicTransportType.values.map((type) {
                          return Obx(() => ChoiceChip(
                            label: Text(type.displayName),
                            selected: controller.selectedPublicTransportType.value == type,
                            onSelected: (selected) {
                              if (selected) {
                                controller.setPublicTransportType(type);
                              }
                            },
                          ));
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 16.0),
                      
                      Text(
                        'Public transportation has zero emissions in our calculation model',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.green.shade700,
                        ),
                      ),
                      
                      const SizedBox(height: 16.0),
                    ],
                  ),
                )),
                
                // Miles per week input
                TextField(
                  controller: controller.mileageController,
                  decoration: const InputDecoration(
                    labelText: 'Miles Per Week',
                    hintText: 'Enter distance',
                    suffixText: 'miles',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                
                const SizedBox(height: 16.0),
                
                // MPG input (only for car)
                Obx(() => Visibility(
                  visible: controller.selectedTransportMode.value == TransportMode.car && controller.selectedCarType.value != CarType.electric,
                  child: Column(
                    children: [
                      TextField(
                        controller: controller.mpgController,
                        decoration: const InputDecoration(
                          labelText: 'Miles Per Gallon (MPG)',
                          hintText: 'Enter vehicle fuel efficiency',
                          suffixText: 'MPG',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      
                      const SizedBox(height: 8.0),
                      
                      Obx(() => Text(
                        'If you don\'t know your MPG, leave blank for ${controller.selectedCarType.value.displayName} average (${controller.selectedCarType.value.defaultMpg.toStringAsFixed(0)} MPG)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      )),
                      
                      const SizedBox(height: 16.0),
                    ],
                  ),
                )),
                
                // Zero emission indicator for walking, biking, electric car
                Obx(() => Visibility(
                  visible: controller.selectedTransportMode.value == TransportMode.walking || 
                          controller.selectedTransportMode.value == TransportMode.bicycle ||
                          (controller.selectedTransportMode.value == TransportMode.car && 
                           controller.selectedCarType.value == CarType.electric),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.eco, color: Colors.green.shade700),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                'Zero emissions mode of transportation!',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
                
                // Add button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (controller.mileageController.text.isNotEmpty) {
                        controller.addTransportationMethod();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Transportation Method'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24.0),
          
          // List of added transportation methods
          Obx(() {
            final methods = controller.transportationMethods;
            
            if (methods.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Add at least one transportation method to continue',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Transportation Methods',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8.0),
                
                ...List.generate(methods.length, (index) {
                  final method = methods[index];
                  return TransportMethodDisplay(
                    method: method,
                    onRemove: () => controller.removeTransportationMethod(index),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }
  
  Widget TransportMethodDisplay({
    required TransportationMethod method,
    required VoidCallback onRemove,
  }) {
    return Card(
      elevation: 2.0,
      child: ListTile(
        leading: Icon(_getTransportIcon(method.mode)),
        title: Text(
          _buildTransportTitle(method),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${method.milesPerWeek.toStringAsFixed(0)} miles per week'),
            if (method.mode == TransportMode.car && method.carType != null && method.carType != CarType.electric)
              Text('${method.carType!.displayName} - ${method.mpg?.toStringAsFixed(0) ?? method.carType!.defaultMpg.toStringAsFixed(0)} MPG'),
            if (method.mode == TransportMode.car && method.carUsageType == CarUsageType.carpool && method.carpoolSize != null)
              Text('Carpool with ${method.carpoolSize} people'),
            if (method.mode == TransportMode.publicTransportation && method.publicTransportType != null)
              Text(method.publicTransportType!.displayName),
            if (method.calculateWeeklyEmissions() > 0)
              Text(
                '${method.calculateWeeklyEmissions().toStringAsFixed(1)} kg CO₂ per week',
                style: TextStyle(color: _getEmissionColor(method.calculateWeeklyEmissions())),
              )
            else
              Text(
                '0 kg CO₂ emissions (Zero emission mode)', 
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                overflow: TextOverflow.visible,
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onRemove,
        ),
      ),
    );
  }
  
  // Build a more descriptive title based on mode and subtypes
  String _buildTransportTitle(TransportationMethod method) {
    switch (method.mode) {
      case TransportMode.car:
        String carType = method.carType?.displayName ?? 'Car';
        if (method.carUsageType != null) {
          return '$carType (${method.carUsageType!.displayName})';
        }
        return carType;
      
      case TransportMode.publicTransportation:
        if (method.publicTransportType != null) {
          return method.publicTransportType!.displayName;
        }
        return method.mode.displayName;
        
      default:
        return method.mode.displayName;
    }
  }
  
  // Get color based on emission level
  Color _getEmissionColor(double emissions) {
    if (emissions <= 5) return Colors.green;
    if (emissions <= 20) return Colors.orange;
    return Colors.red;
  }
  
  IconData _getTransportIcon(TransportMode mode) {
    switch (mode) {
      case TransportMode.walking:
        return Icons.directions_walk;
      case TransportMode.bicycle:
        return Icons.directions_bike;
      case TransportMode.car:
        return Icons.directions_car;
      case TransportMode.publicTransportation:
        return Icons.directions_bus;
      case TransportMode.airplane:
        return Icons.airplanemode_active;
    }
  }
}
