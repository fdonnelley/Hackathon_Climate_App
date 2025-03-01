import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/setup_controller.dart';
import '../widgets/welcome_step.dart';
import '../widgets/energy_step.dart';
import '../widgets/transportation_step.dart';
import '../widgets/goal_selection_step.dart';

class SetupScreen extends StatelessWidget {
  final SetupController controller = Get.find<SetupController>();

  SetupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Started'),
        centerTitle: true,
        // Hide back button on the first page
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Obx(() {
          return Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (controller.currentStep.value + 1) / 4,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              ),
              
              // Step number indicator
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Step ${controller.currentStep.value + 1} of 4',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              
              // Current step content
              Expanded(
                child: _buildCurrentStep(context),
              ),
              
              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button (hidden on first page)
                    if (controller.currentStep.value > 0)
                      ElevatedButton(
                        onPressed: controller.previousPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black87,
                        ),
                        child: const Text('Back'),
                      )
                    else
                      const SizedBox(width: 80), // Placeholder for spacing
                    
                    // Next/Finish button
                    ElevatedButton(
                      onPressed: _canProceed() ? controller.nextPage : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: Text(
                        controller.currentStep.value == 3 
                            ? 'Finish' 
                            : 'Next'
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
  
  // Build the current step based on page index
  Widget _buildCurrentStep(BuildContext context) {
    switch (controller.currentStep.value) {
      case 0:
        return WelcomeStep(controller: controller);
      case 1:
        return EnergyStep(controller: controller);
      case 2:
        return TransportationStep(controller: controller);
      case 3:
        return GoalSelectionStep(controller: controller);
      default:
        return const Center(child: Text('Error: Unknown step'));
    }
  }
  
  // Check if user can proceed to next step
  bool _canProceed() {
    switch (controller.currentStep.value) {
      case 0: // Welcome page
        return controller.nameController.text.isNotEmpty;
      case 1: // Energy bills
        // Allow proceed even with empty fields (just means zero usage)
        return true;
      case 2: // Transportation
        // Can proceed if at least one transportation method is added
        return controller.transportationMethods.isNotEmpty;
      case 3: // Goal selection
        // Can always proceed from goal selection
        return true;
      default:
        return false;
    }
  }
}
