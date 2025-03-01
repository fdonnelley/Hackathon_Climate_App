import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../models/setup_data_model.dart';
import '../../carbon_tracker/models/usage_category_model.dart' as carbon_tracker;
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
  
  // Observable loading state
  final isCalculating = false.obs;
  
  // Observable goal selection
  final selectedGoalLevel = CarbonGoalLevel.moderate.obs;
  
  // Reference to home controller
  late final HomeController _homeController;
  
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
    
    // Calculate transportation emissions (weekly)
    double transportationEmissions = 0;
    for (var method in transportationMethods) {
      transportationEmissions += method.calculateWeeklyEmissions();
    }
    
    // Convert to monthly (multiply by ~4.33 weeks per month)
    transportationEmissions *= 4.33;
    
    // Calculate energy emissions
    // Average electricity emissions: 0.48 kg CO2 per kWh
    // Average residential price: $0.15 per kWh
    double electricityEmissions = setupData.value.monthlyElectricBill / 0.15 * 0.48;
    
    // Average natural gas emissions: 5.5 kg CO2 per therm
    // Average residential price: $1.5 per therm
    double gasEmissions = setupData.value.monthlyGasBill / 1.5 * 5.5;
    
    // Total monthly carbon footprint
    double totalEmissions = transportationEmissions + electricityEmissions + gasEmissions;
    
    // Update the model
    setupData.value = setupData.value.copyWith(
      calculatedCarbonFootprint: totalEmissions,
    );
    
    isCalculating.value = false;
  }
  
  // Apply the setup data to the home controller
  void _applySetupDataToHomeController() {
    final setupDataValue = setupData.value;
    final currentFootprint = setupDataValue.estimateFootprint();
    final targetFootprint = setupDataValue.selectedGoalLevel.weeklyBudgetGoal;
    
    _homeController.setUserData(
      name: setupDataValue.userName,
      goalLevel: setupDataValue.selectedGoalLevel,
      setupData: setupDataValue,
    );
    
    // Navigation is handled by the calling method
  }
}
