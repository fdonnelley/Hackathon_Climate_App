import 'package:get/get.dart';
import '../../carbon_tracker/models/usage_category_model.dart';

/// Model to store setup data collected during the initial setup flow
class SetupDataModel {
  // User information
  final String userName;
  
  // Energy usage
  final double monthlyElectricBill; // in currency units
  final double monthlyGasBill; // in currency units
  
  // Transportation methods - Not final so it can be updated
  List<TransportationMethod> transportationMethods;
  
  // Calculated carbon footprint - Not final so it can be updated
  double calculatedCarbonFootprint; // in kg CO2 per month
  
  // Selected goal level
  final CarbonGoalLevel selectedGoalLevel;
  
  SetupDataModel({
    required this.userName,
    required this.monthlyElectricBill,
    required this.monthlyGasBill,
    required this.transportationMethods,
    required this.calculatedCarbonFootprint,
    required this.selectedGoalLevel,
  });
  
  // Create an empty model with default values
  factory SetupDataModel.empty() {
    return SetupDataModel(
      userName: '',
      monthlyElectricBill: 0,
      monthlyGasBill: 0,
      transportationMethods: [],
      calculatedCarbonFootprint: 0,
      selectedGoalLevel: CarbonGoalLevel.moderate,
    );
  }
  
  // Copy with function to create a new instance with some modified values
  SetupDataModel copyWith({
    String? userName,
    double? monthlyElectricBill,
    double? monthlyGasBill,
    List<TransportationMethod>? transportationMethods,
    double? calculatedCarbonFootprint,
    CarbonGoalLevel? selectedGoalLevel,
  }) {
    return SetupDataModel(
      userName: userName ?? this.userName,
      monthlyElectricBill: monthlyElectricBill ?? this.monthlyElectricBill,
      monthlyGasBill: monthlyGasBill ?? this.monthlyGasBill,
      transportationMethods: transportationMethods ?? this.transportationMethods,
      calculatedCarbonFootprint: calculatedCarbonFootprint ?? this.calculatedCarbonFootprint,
      selectedGoalLevel: selectedGoalLevel ?? this.selectedGoalLevel,
    );
  }
  
  /// Estimate weekly carbon footprint based on transportation and energy usage
  double estimateFootprint() {
    // Start with the stored carbon footprint (monthly) and convert to weekly
    double weekly = calculatedCarbonFootprint / 4.33; // Convert monthly to weekly
    
    // If we have transportation methods, use those for more accurate calculation
    if (transportationMethods.isNotEmpty) {
      double transportEmissions = 0.0;
      
      // Sum up emissions from all transportation methods
      for (var transport in transportationMethods) {
        transportEmissions += transport.calculateWeeklyEmissions();
      }
      
      // Add transportation emissions to the total
      weekly = transportEmissions;
    }
    
    // Return the weekly estimate
    return weekly;
  }
}

/// Represents a transportation method with usage details
class TransportationMethod {
  final TransportMode mode;
  final double milesPerWeek;
  final CarType? carType;
  final double? mpg; // Miles per gallon if car
  final CarUsageType? carUsageType; // How the car is used
  final int? carpoolSize; // Number of people in carpool
  final PublicTransportType? publicTransportType; // Bus or train
  
  TransportationMethod({
    required this.mode,
    required this.milesPerWeek,
    this.carType,
    this.mpg,
    this.carUsageType,
    this.carpoolSize,
    this.publicTransportType,
  });
  
  /// Calculate weekly emissions in kg CO2
  double calculateWeeklyEmissions() {
    switch (mode) {
      case TransportMode.walking:
      case TransportMode.bicycle:
      case TransportMode.publicTransportation:
        // Zero emissions for these modes
        return 0.0;
      
      case TransportMode.car:
        // For electric cars, emissions are 0
        if (carType == CarType.electric) {
          return 0.0;
        }
        
        // Calculate effective MPG, factoring in carpool if applicable
        double effectiveMpg = mpg ?? (carType?.defaultMpg ?? 25.0);
        
        // If it's a carpool, divide emissions by number of people (multiply MPG)
        if (carUsageType == CarUsageType.carpool && carpoolSize != null && carpoolSize! > 1) {
          effectiveMpg *= carpoolSize!.toDouble();
        }
        
        // lbs CO2 per gallon of gasoline is 19.16 lbs CO2
        return (milesPerWeek / effectiveMpg) * 19.16;
      
      case TransportMode.airplane:
        // Airplanes emit about 0.2 lbs CO2 per passenger-mile
        return milesPerWeek * 0.2;
    }
  }
}

/// Transportation modes
enum TransportMode {
  walking,
  bicycle,
  car,
  publicTransportation,
  airplane,
}

/// Car usage types
enum CarUsageType {
  personal,
  taxi,
  carpool,
}

/// Public transportation types
enum PublicTransportType {
  bus,
  train,
}

extension TransportModeExt on TransportMode {
  String get displayName {
    switch (this) {
      case TransportMode.walking:
        return 'Walk';
      case TransportMode.bicycle:
        return 'Bike';
      case TransportMode.car:
        return 'Car';
      case TransportMode.publicTransportation:
        return 'Public Transportation';
      case TransportMode.airplane:
        return 'Plane';
    }
  }
}

/// Extension on car usage type
extension CarUsageTypeExt on CarUsageType {
  String get displayName {
    switch (this) {
      case CarUsageType.personal:
        return 'Personal';
      case CarUsageType.taxi:
        return 'Taxi';
      case CarUsageType.carpool:
        return 'Carpool';
    }
  }
}

/// Extension on public transport type
extension PublicTransportTypeExt on PublicTransportType {
  String get displayName {
    switch (this) {
      case PublicTransportType.bus:
        return 'Bus';
      case PublicTransportType.train:
        return 'Train';
    }
  }
}

enum CarType {
  sedan,
  suv,
  truck,
  hybrid,
  electric,
}

extension CarTypeExt on CarType {
  double get defaultMpg {
    switch (this) {
      case CarType.sedan:
        return 25.0;
      case CarType.suv:
        return 20.0;
      case CarType.truck:
        return 18.0;
      case CarType.hybrid:
        return 35.0;
      case CarType.electric:
        return 0.0; // Electric cars do not use gasoline
    }
  }
  
  String get displayName {
    switch (this) {
      case CarType.sedan:
        return 'Sedan';
      case CarType.suv:
        return 'SUV';
      case CarType.truck:
        return 'Truck';
      case CarType.hybrid:
        return 'Hybrid';
      case CarType.electric:
        return 'Electric';
    }
  }
}

/// Enum for carbon reduction goal levels
enum CarbonGoalLevel {
  minimal,    // 10% reduction
  moderate,   // 25% reduction
  climateSaver // 50% reduction
}

/// Extension on CarbonGoalLevel for user-friendly names and reduction percentages
extension CarbonGoalLevelExt on CarbonGoalLevel {
  String get displayName {
    switch (this) {
      case CarbonGoalLevel.minimal:
        return 'Minimal Effort';
      case CarbonGoalLevel.moderate:
        return 'Moderate Reducer';
      case CarbonGoalLevel.climateSaver:
        return 'Climate Saver';
    }
  }

  String get description {
    switch (this) {
      case CarbonGoalLevel.minimal:
        return 'Small changes that fit easily into your lifestyle (10% reduction)';
      case CarbonGoalLevel.moderate:
        return 'Balanced approach to reducing your footprint (25% reduction)';
      case CarbonGoalLevel.climateSaver:
        return 'Maximum impact to help save the planet (50% reduction)';
    }
  }

  double get reductionPercentage {
    switch (this) {
      case CarbonGoalLevel.minimal:
        return 0.1;
      case CarbonGoalLevel.moderate:
        return 0.25;
      case CarbonGoalLevel.climateSaver:
        return 0.5;
    }
  }

  double get weeklyBudgetGoal {
    // Get average weekly carbon budget
    double averageWeekly = 40.0; // Average weekly emissions in kg CO2
    
    switch (this) {
      case CarbonGoalLevel.minimal:
        return averageWeekly * 0.9; // 10% reduction
      case CarbonGoalLevel.moderate:
        return averageWeekly * 0.75; // 25% reduction
      case CarbonGoalLevel.climateSaver:
        return averageWeekly * 0.5; // 50% reduction
    }
  }
}
