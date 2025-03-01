import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../models/setup_data_model.dart';
import '../../carbon_tracker/models/usage_category_model.dart' as carbon_tracker;
import '../../carbon_tracker/services/carbon_calculator_service.dart';
import '../../home/controllers/home_controller.dart';
import '../../../routes/app_routes.dart';

class SetupController extends GetxController {
  // Controllers for text input fields
  final nameController = TextEditingController();
  final electricBillController = TextEditingController();
  final gasBillController = TextEditingController();
  final mileageController = TextEditingController();
  final mpgController = TextEditingController();
  
  // Current step in the setup process
  final currentStep = 0.obs;
  
  // Observable setup data
  final setupData = SetupDataModel.empty().obs;
  
  // Transportation methods being added
  final transportationMethods = <TransportationMethod>[].obs;
  
  // Currently selected transport mode
  final selectedTransportMode = TransportMode.car.obs; 
  
  // Currently selected car type (when car is selected)
  final selectedCarType = CarType.sedan.obs;
  
  // Currently selected car usage type (for car mode)
  final selectedCarUsageType = CarUsageType.personal.obs;
  
  // Currently selected public transport type (for public transportation mode)
  final selectedPublicTransportType = PublicTransportType.bus.obs;
  
  // Number of people in carpool (for carpool car usage)
  final carpoolSize = 2.obs;
  
  // Average transportation mileage per week value
  final double averageMileage = 200.0;

  // Selected goal level for carbon reduction
  final Rx<CarbonGoalLevel> selectedGoalLevel = CarbonGoalLevel.moderate.obs;
  
  // Flag to track calculation in progress
  final RxBool isCalculating = false.obs;
  
  // Reference to home controller
  late final HomeController _homeController;
  
  // Average values for user reference
  final averageElectricBill = 120.0; // Average monthly electric bill in $
  final averageGasBill = 80.0; // Average monthly gas bill in $
  final averageMpg = {
    CarType.sedan: 25.0,
    CarType.suv: 20.0,
    CarType.truck: 18.0,
    CarType.hybrid: 45.0,
    CarType.electric: 100.0, // Equivalent MPG for electric
  };
  
  @override
  void onInit() {
    super.onInit();
    _homeController = Get.find<HomeController>();
    
    // Pre-populate name from auth if available
    if (Get.arguments != null && Get.arguments['userName'] != null) {
      nameController.text = Get.arguments['userName'];
      setupData.value = setupData.value.copyWith(userName: nameController.text);
    }
  }
  
  @override
  void onClose() {
    // Dispose of text controllers
    nameController.dispose();
    electricBillController.dispose();
    gasBillController.dispose();
    mileageController.dispose();
    mpgController.dispose();
    super.onClose();
  }
  
  // Move to next setup page
  void nextPage() {
    // Save data from the current page
    switch (currentStep.value) {
      case 0: // Welcome page
        setupData.value = setupData.value.copyWith(
          userName: nameController.text,
        );
        break;
        
      case 1: // Energy bills page
        final electric = double.tryParse(electricBillController.text) ?? 0;
        final gas = double.tryParse(gasBillController.text) ?? 0;
        
        setupData.value = setupData.value.copyWith(
          monthlyElectricBill: electric,
          monthlyGasBill: gas,
        );
        break;
        
      case 2: // Transportation methods page
        // Transportation methods are added incrementally via addTransportationMethod
        setupData.value = setupData.value.copyWith(
          transportationMethods: List.from(transportationMethods),
        );
        
        // Calculate carbon footprint if moving to results page
        if (currentStep.value == 2) {
          calculateCarbonFootprint();
        }
        break;
        
      case 3: // Goal selection page
        setupData.value = setupData.value.copyWith(
          selectedGoalLevel: selectedGoalLevel.value,
        );
        
        // Apply setup data to home controller and complete setup
        _applySetupDataToHomeController();
        
        // Navigate to home screen after completing setup
        Get.offAllNamed(AppRoutes.getRouteName(AppRoute.home));
        return; // Exit the function early since we're navigating
    }
    
    // Move to next page
    currentStep.value++;
  }
  
  // Go back to previous page
  void previousPage() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }
  
  // Add a transportation method
  void addTransportationMethod() {
    double milesPerWeek = double.tryParse(mileageController.text) ?? 0;
    
    double? mpg;
    CarType? carType;
    
    // If car mode is selected, handle MPG and car type
    if (selectedTransportMode.value == TransportMode.car) {
      carType = selectedCarType.value;
      
      // Only need MPG for non-electric cars
      if (carType != CarType.electric) {
        mpg = double.tryParse(mpgController.text);
        
        if (mpg == null || mpg <= 0) {
          // If no MPG provided, use the default for the selected car type
          mpg = carType.defaultMpg;
        }
      }
    }
    
    // Create the transportation method and add it to the list
    final method = TransportationMethod(
      mode: selectedTransportMode.value,
      milesPerWeek: milesPerWeek,
      mpg: mpg,
      carType: carType,
      carUsageType: selectedTransportMode.value == TransportMode.car ? selectedCarUsageType.value : null,
      carpoolSize: selectedTransportMode.value == TransportMode.car && selectedCarUsageType.value == CarUsageType.carpool ? carpoolSize.value : null,
      publicTransportType: selectedTransportMode.value == TransportMode.publicTransportation ? selectedPublicTransportType.value : null,
    );
    
    transportationMethods.add(method);
    
    // Reset input fields
    mileageController.clear();
    mpgController.clear();
    
    // Show a quick confirmation
    Get.snackbar(
      'Transportation Added',
      '${method.mode.displayName} - ${milesPerWeek.toStringAsFixed(0)} miles per week',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  // Remove a transportation method
  void removeTransportationMethod(int index) {
    if (index >= 0 && index < transportationMethods.length) {
      transportationMethods.removeAt(index);
    }
  }
  
  // Update car type
  void setCarType(CarType type) {
    selectedCarType.value = type;
  }
  
  // Update car usage type
  void setCarUsageType(CarUsageType type) {
    selectedCarUsageType.value = type;
  }
  
  // Update public transport type
  void setPublicTransportType(PublicTransportType type) {
    selectedPublicTransportType.value = type;
  }
  
  // Update carpool size
  void setCarpoolSize(int size) {
    if (size >= 2) {
      carpoolSize.value = size;
    }
  }
  
  // Calculate the user's carbon footprint based on inputs
  void calculateCarbonFootprint() {
    isCalculating.value = true;
    
    // Short delay to show loading indicator
    Future.delayed(const Duration(milliseconds: 500), () {
      // Update the setupData with current transportation methods
      setupData.update((data) {
        if (data != null) {
          data.transportationMethods = List.from(transportationMethods);
        }
      });
      
      // Use the calculator service to calculate total emissions
      double totalEmissions = CarbonCalculatorService.calculateTotalFootprint(setupData.value);
      
      // Update the setupData with calculated value
      setupData.update((data) {
        if (data != null) {
          data.calculatedCarbonFootprint = totalEmissions;
        }
      });
      
      // Set a default goal level based on current emissions
      _setDefaultGoalLevel(totalEmissions);
      
      isCalculating.value = false;
    });
  }
  
  // Set a default goal level based on current emissions
  void _setDefaultGoalLevel(double totalEmissions) {
    double averageFootprint = CarbonCalculatorService.calculateAverageFootprint();
    
    if (totalEmissions > averageFootprint * 1.3) {
      // If emissions are much higher than average, suggest a more ambitious goal
      selectedGoalLevel.value = CarbonGoalLevel.climateSaver;
    } else if (totalEmissions > averageFootprint) {
      // If emissions are higher than average, suggest a moderate goal
      selectedGoalLevel.value = CarbonGoalLevel.moderate;
    } else {
      // If emissions are already below average, suggest a minimal goal
      selectedGoalLevel.value = CarbonGoalLevel.minimal;
    }
  }

  // Get average utility bills as a string for display
  String getAverageUtilityBillsText() {
    return 'Average electric bill: \$${averageElectricBill.toStringAsFixed(0)}/month\n'
           'Average gas bill: \$${averageGasBill.toStringAsFixed(0)}/month';
  }

  // Get average transportation info text for displaying in the UI
  String getAverageTransportationText() {
    return '''
• Average American drives about 200 miles per week
• Sedans average 25 MPG, SUVs average 20 MPG, trucks average 18 MPG
• Electric vehicles produce zero direct emissions
• Public transportation averages 0.25 kg CO₂/mile (much lower than cars)
• Walking and biking produce zero emissions
''';
  }

  // Calculate electricity emissions from the SetupDataModel
  double calculateElectricityEmissions() {
    return CarbonCalculatorService.calculateElectricityEmissions(
        setupData.value.monthlyElectricBill ?? 0);
  }

  // Calculate gas emissions from the SetupDataModel
  double calculateGasEmissions() {
    return CarbonCalculatorService.calculateGasEmissions(
        setupData.value.monthlyGasBill ?? 0);
  }

  // Calculate transportation emissions from the SetupDataModel
  double calculateTransportationEmissions() {
    return CarbonCalculatorService.calculateTransportationEmissions(
        setupData.value.transportationMethods);
  }

  // Apply the setup data to the home controller
  void _applySetupDataToHomeController() {
    final setupDataValue = setupData.value;
    // final currentFootprint = setupDataValue.estimateFootprint();
    // final targetFootprint = setupDataValue.selectedGoalLevel.weeklyBudgetGoal;
    
    _homeController.setUserData(
      name: setupDataValue.userName,
      goalLevel: setupDataValue.selectedGoalLevel,
      setupData: setupDataValue,
    );
    
    // Navigation is handled by the calling method
  }
}
