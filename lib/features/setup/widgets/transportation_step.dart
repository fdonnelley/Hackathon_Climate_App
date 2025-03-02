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

  void _addTransportationMethod(BuildContext context) {
    // Create a local step index to track the current step
    final RxInt currentStep = 0.obs;
    // Add a new step for car usage type selection
    final RxBool showingCarUsageStep = false.obs;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Get the next relevant step based on the current step and selected mode
            int getNextRelevantStep(int step) {
              // Going forward
              if (step > currentStep.value) {
                // If moving from step 0 (Transport Mode) to step 1 and selected car
                if (currentStep.value == 0 && step == 1 && controller.selectedTransportMode.value == TransportMode.car) {
                  // First show car usage step
                  showingCarUsageStep.value = true;
                  return 1;
                }
                
                // If moving from car usage step (step 1) to car type step
                if (showingCarUsageStep.value && currentStep.value == 1 && step == 2) {
                  // If taxi was selected, set car type to sedan and skip to miles per week
                  if (controller.selectedCarUsageType.value == CarUsageType.taxi) {
                    controller.setCarType(CarType.sedan);
                    showingCarUsageStep.value = false;
                    return 3;
                  }
                  // Otherwise, show car type selection
                  showingCarUsageStep.value = false;
                  return 1;
                }
                
                // If moving to step 1 (Car Details) but not using a car, skip to step 3 (Miles Per Week)
                if (step == 1 && controller.selectedTransportMode.value != TransportMode.car) {
                  // If also not using public transportation, skip to step 3 (Miles Per Week)
                  if (controller.selectedTransportMode.value != TransportMode.publicTransportation) {
                    return 3;
                  }
                  // Otherwise go to step 2 (Public Transportation)
                  return 2;
                }
                
                // If moving to step 2 (Public Transportation) but not using public transportation, skip to step 3
                if (step == 2 && controller.selectedTransportMode.value != TransportMode.publicTransportation) {
                  return 3;
                }
              } 
              // Going backward
              else if (step < currentStep.value) {
                // If at car type step and going back to car usage step
                if (!showingCarUsageStep.value && currentStep.value == 1 && 
                    controller.selectedTransportMode.value == TransportMode.car) {
                  showingCarUsageStep.value = true;
                  return 1;
                }
                
                // If at car usage step and going back to transport mode
                if (showingCarUsageStep.value && currentStep.value == 1 && step == 0) {
                  showingCarUsageStep.value = false;
                  return 0;
                }
                
                // If at step 3 (Miles Per Week) and going back
                if (currentStep.value == 3) {
                  // If using public transportation, go to step 2
                  if (controller.selectedTransportMode.value == TransportMode.publicTransportation) {
                    return 2;
                  }
                  // If using car, go to step 1 (car type)
                  else if (controller.selectedTransportMode.value == TransportMode.car) {
                    return 1;
                  }
                  // Otherwise go to step 0
                  else {
                    return 0;
                  }
                }
                
                // If at step 2 (Public Transportation) and going back, go to step 0 if not using car
                if (currentStep.value == 2 && controller.selectedTransportMode.value != TransportMode.car) {
                  return 0;
                }
              }
              
              // Default: return the requested step
              return step;
            }
            
            // Function to handle step changes
            void onStepChanged(int step) {
              // Skip irrelevant steps
              int nextStep = getNextRelevantStep(step);
              setState(() {
                currentStep.value = nextStep;
              });
            }
            
            // Function to handle completion
            void onComplete() {
              if (controller.mileageController.text.isNotEmpty) {
                controller.addTransportationMethod();
                Navigator.pop(context);
              } else {
                // Show error if miles per week is empty
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter miles per week'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
            
            // Get the title for the current step
            String getStepTitle() {
              switch (currentStep.value) {
                case 0:
                  return 'Select Transportation Mode';
                case 1:
                  if (controller.selectedTransportMode.value == TransportMode.car) {
                    return showingCarUsageStep.value ? 'How do you use this car?' : 'Car Type';
                  } else {
                    return 'Additional Details';
                  }
                case 2:
                  return controller.selectedTransportMode.value == TransportMode.publicTransportation
                      ? 'Public Transportation Details'
                      : 'Usage Details';
                case 3:
                  return 'Miles Per Week';
                default:
                  return 'Add Transportation';
              }
            }
            
            // Get the content for the current step
            Widget getStepContent() {
              switch (currentStep.value) {
                case 0:
                  return Obx(() => DropdownButtonFormField<TransportMode>(
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
                  ));
                
                case 1:
                  if (controller.selectedTransportMode.value == TransportMode.car && showingCarUsageStep.value) {
                    // Car usage type selection (personal, taxi, carpool)
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Minus button
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: controller.carpoolSize.value > 2 
                                          ? () => controller.setCarpoolSize(controller.carpoolSize.value - 1)
                                          : null,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        iconSize: 24,
                                      ),
                                      // Number display
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: Text(
                                          '${controller.carpoolSize.value}',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      // Plus button
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: controller.carpoolSize.value < 8
                                          ? () => controller.setCarpoolSize(controller.carpoolSize.value + 1)
                                          : null,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        iconSize: 24,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8.0),
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
                      ],
                    );
                  } else if (controller.selectedTransportMode.value == TransportMode.car) {
                    // Car type selection
                    return Column(
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
                      ],
                    );
                  } else {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('You can proceed to the next step.'),
                      ),
                    );
                  }
                
                case 2:
                  return Obx(() => Visibility(
                    visible: controller.selectedTransportMode.value == TransportMode.publicTransportation,
                    replacement: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('You can proceed to the next step.'),
                      ),
                    ),
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
                      ],
                    ),
                  ));
                
                case 3:
                  return Column(
                    children: [
                      Obx(() => TextField(
                        controller: controller.mileageController,
                        decoration: InputDecoration(
                          labelText: _getMileageLabel(controller.selectedTransportMode.value, 
                                                     controller.selectedPublicTransportType.value),
                          hintText: _getAverageMileageHint(controller.selectedTransportMode.value, 
                                                          controller.selectedPublicTransportType.value),
                          suffixText: 'miles',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      )),
                      const SizedBox(height: 8.0),
                      Obx(() => Text(
                        _getMileageHelpText(controller.selectedTransportMode.value, 
                                           controller.selectedPublicTransportType.value),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      )),
                      
                      // MPG input (only for car)
                      Obx(() => Visibility(
                        visible: controller.selectedTransportMode.value == TransportMode.car && 
                                controller.selectedCarType.value != CarType.electric,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Column(
                            children: [
                              TextField(
                                controller: controller.mpgController,
                                decoration: InputDecoration(
                                  labelText: 'Miles Per Gallon (MPG)',
                                  hintText: controller.selectedCarType.value.defaultMpg.toStringAsFixed(0),
                                  suffixText: 'MPG',
                                  border: const OutlineInputBorder(),
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
                            ],
                          ),
                        ),
                      )),
                      
                      // Zero emission indicator for walking, biking, electric car
                      Obx(() => Visibility(
                        visible: controller.selectedTransportMode.value == TransportMode.walking || 
                                controller.selectedTransportMode.value == TransportMode.bicycle ||
                                (controller.selectedTransportMode.value == TransportMode.car && 
                                 controller.selectedCarType.value == CarType.electric),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Row(
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
                        ),
                      )),
                    ],
                  );
                
                default:
                  return const SizedBox();
              }
            }
            
            return MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add Transportation Method',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Obx(() => Text(
                          getStepTitle(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Obx(() => getStepContent()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Obx(() => Row(
                          children: [
                            if (currentStep.value > 0)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    onStepChanged(currentStep.value - 1);
                                  },
                                  child: const Text('Back'),
                                ),
                              ),
                            if (currentStep.value > 0)
                              const SizedBox(width: 12.0),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (currentStep.value < 3) {
                                    onStepChanged(currentStep.value + 1);
                                  } else {
                                    onComplete();
                                  }
                                },
                                child: Text(
                                  currentStep.value < 3 ? 'Next' : 'Add',
                                ),
                              ),
                            ),
                          ],
                        )),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Create a scroll controller to enable automatic scrolling
    final ScrollController scrollController = ScrollController();
    
    // Function to scroll to the bottom
    void scrollToBottom() {
      if (scrollController.hasClients) {
        Future.delayed(const Duration(milliseconds: 300), () {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    }
    
    // Listen to changes in transportation methods to trigger scrolling
    controller.transportationMethods.listen((_) {
      scrollToBottom();
    });
    
    return SingleChildScrollView(
      controller: scrollController,
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
            'Add each type of transportation you regularly use.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          
          const SizedBox(height: 32.0),
          
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
                  'Transportation Methods',
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
          
          const SizedBox(height: 24.0),
          
          // Add transportation method button (now below the list)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ElevatedButton.icon(
                onPressed: () => _addTransportationMethod(context),
                icon: const Icon(Icons.add, size: 18.0),
                label: const Text('Add Method', style: TextStyle(fontSize: 16.0)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  foregroundColor: Theme.of(context).primaryColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24.0)),
                  ),
                ),
              ),
            ),
          ),
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
            Text('${method.milesPerWeek.toStringAsFixed(0)} miles per week${_getOriginalMileageText(method)}'),
            if (method.mode == TransportMode.car && method.carType != null && method.carType != CarType.electric)
              Text('${method.carType!.displayName} - ${method.mpg?.toStringAsFixed(0) ?? method.carType!.defaultMpg.toStringAsFixed(0)} MPG'),
            if (method.mode == TransportMode.car && method.carUsageType == CarUsageType.carpool && method.carpoolSize != null)
              Text('Carpool with ${method.carpoolSize} people'),
            if (method.mode == TransportMode.publicTransportation && method.publicTransportType != null)
              Text(method.publicTransportType!.displayName),
            if (method.calculateWeeklyEmissions() > 0)
              Text(
                '${method.calculateWeeklyEmissions().toStringAsFixed(1)} lb CO₂ per week',
                style: TextStyle(color: _getEmissionColor(method.calculateWeeklyEmissions())),
              )
            else
              Text(
                '0 lb CO₂ emissions (Zero emission mode)', 
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
  
  // Helper method to get the appropriate mileage label based on transportation mode
  String _getMileageLabel(TransportMode mode, PublicTransportType? publicType) {
    if (mode == TransportMode.airplane) {
      return 'Miles Per Year';
    } else if (mode == TransportMode.publicTransportation && publicType == PublicTransportType.train) {
      return 'Miles Per Month';
    } else {
      return 'Miles Per Week';
    }
  }
  
  // Helper method to get the appropriate mileage help text
  String _getMileageHelpText(TransportMode mode, PublicTransportType? publicType) {
    if (mode == TransportMode.airplane) {
      return 'Enter your estimated yearly air travel mileage (average is ${controller.averageAirplaneMileagePerYear.toStringAsFixed(0)} miles)';
    } else if (mode == TransportMode.publicTransportation && publicType == PublicTransportType.train) {
      return 'Enter your estimated monthly train travel mileage (average is ${controller.averageTrainMileagePerMonth.toStringAsFixed(0)} miles)';
    } else if (mode == TransportMode.publicTransportation && publicType == PublicTransportType.bus) {
      return 'Enter your average weekly bus travel mileage (average is ${controller.averageBusMileage.toStringAsFixed(0)} miles)';
    } else if (mode == TransportMode.car) {
      return 'Enter your average weekly car travel mileage (average is ${controller.averageCarMileage.toStringAsFixed(0)} miles)';
    } else if (mode == TransportMode.bicycle) {
      return 'Enter your average weekly bicycle travel mileage (average is ${controller.averageBicycleMileage.toStringAsFixed(0)} miles)';
    } else if (mode == TransportMode.walking) {
      return 'Enter your average weekly walking mileage (average is ${controller.averageWalkingMileage.toStringAsFixed(0)} miles)';
    } else {
      return 'Enter your average weekly travel mileage';
    }
  }
  
  // Helper method to get the appropriate average mileage hint based on transportation mode
  String _getAverageMileageHint(TransportMode mode, PublicTransportType? publicType) {
    if (mode == TransportMode.airplane) {
      return controller.averageAirplaneMileagePerYear.toStringAsFixed(0);
    } else if (mode == TransportMode.publicTransportation && publicType == PublicTransportType.train) {
      return controller.averageTrainMileagePerMonth.toStringAsFixed(0);
    } else if (mode == TransportMode.publicTransportation && publicType == PublicTransportType.bus) {
      return controller.averageBusMileage.toStringAsFixed(0);
    } else if (mode == TransportMode.car) {
      return controller.averageCarMileage.toStringAsFixed(0);
    } else if (mode == TransportMode.bicycle) {
      return controller.averageBicycleMileage.toStringAsFixed(0);
    } else if (mode == TransportMode.walking) {
      return controller.averageWalkingMileage.toStringAsFixed(0);
    } else {
      return "0";
    }
  }
  
  // Get original mileage text for display in the transportation method card
  String _getOriginalMileageText(TransportationMethod method) {
    if (method.mode == TransportMode.airplane) {
      // Show original yearly value
      return ' (${(method.milesPerWeek * 52.0).toStringAsFixed(0)} miles per year)';
    } else if (method.mode == TransportMode.publicTransportation && 
               method.publicTransportType == PublicTransportType.train) {
      // Show original monthly value
      return ' (${(method.milesPerWeek * 4.33).toStringAsFixed(0)} miles per month)';
    }
    return '';
  }
}
