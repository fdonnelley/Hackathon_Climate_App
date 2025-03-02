/// Usage Category enum
enum UsageCategory {
  /// Transportation category
  transportation,
  
  /// Energy category
  energy,
}

/// Energy Type enum
enum EnergyType {
  /// Electricity
  electricity,
  
  /// Gas (natural gas, LPG, etc.)
  gas,
}

/// Transport Mode enum for different transportation methods
enum TransportMode {
  /// Walking
  walking,
  
  /// Bicycle
  bicycle,
  
  /// Regular Car (includes sub-types)
  car,
  
  /// Electric Vehicle 
  electricVehicle,
  
  /// Bus
  bus,
  
  /// Train
  train,
  
  /// Airplane
  airplane,
}

/// Car Type enum for different types of cars
enum CarType {
  /// Sedan/Compact car (25-30 MPG average)
  sedan,
  
  /// SUV (15-20 MPG average)
  suv,
  
  /// Van/Minivan (18-24 MPG average)
  van,
  
  /// Truck (12-18 MPG average)
  truck,
  
  /// Hybrid (40-50 MPG average)
  hybrid,
}

/// Extension for TransportMode with helper methods
extension TransportModeExtension on TransportMode {
  /// Get the name of the transport mode
  String get name {
    switch (this) {
      case TransportMode.walking:
        return 'Walking';
      case TransportMode.bicycle:
        return 'Bicycle';
      case TransportMode.car:
        return 'Car';
      case TransportMode.electricVehicle:
        return 'Electric Vehicle';
      case TransportMode.bus:
        return 'Bus';
      case TransportMode.train:
        return 'Train';
      case TransportMode.airplane:
        return 'Airplane';
    }
  }
  
  /// Get default emissions factor per mile (lb CO2)
  double get emissionsPerMile {
    switch (this) {
      case TransportMode.walking:
      case TransportMode.bicycle:
        return 0.0;
      case TransportMode.car:
        return 0.786; // Average car (25 MPG) emits about 19.64 lb CO2 per gallon / 25 miles = 0.786 lb/mile
      case TransportMode.electricVehicle:
        return 0.22; // Average EV based on US grid mix
      case TransportMode.bus:
        return 0.236; // Per passenger mile
      case TransportMode.train:
        return 0.09; // Per passenger mile
      case TransportMode.airplane:
        return 0.55; // Per passenger mile, average for domestic flights
    }
  }
  
  /// Convert from string to TransportMode
  static TransportMode fromString(String value) {
    switch (value.toLowerCase()) {
      case 'walking':
      case 'walk':
        return TransportMode.walking;
      case 'bicycle':
      case 'bike':
      case 'cycling':
        return TransportMode.bicycle;
      case 'car':
      case 'driving':
      case 'drove':
      case 'vehicle':
        return TransportMode.car;
      case 'electric vehicle':
      case 'ev':
      case 'electric car':
        return TransportMode.electricVehicle;
      case 'bus':
      case 'transit':
        return TransportMode.bus;
      case 'train':
      case 'rail':
      case 'subway':
      case 'metro':
        return TransportMode.train;
      case 'airplane':
      case 'plane':
      case 'flight':
      case 'flying':
        return TransportMode.airplane;
      default:
        throw ArgumentError('Invalid transport mode: $value');
    }
  }
}

/// Extension for CarType with helper methods
extension CarTypeExtension on CarType {
  /// Get the name of the car type
  String get name {
    switch (this) {
      case CarType.sedan:
        return 'Sedan/Compact';
      case CarType.suv:
        return 'SUV';
      case CarType.van:
        return 'Van/Minivan';
      case CarType.truck:
        return 'Truck';
      case CarType.hybrid:
        return 'Hybrid';
    }
  }
  
  /// Get default MPG for this car type
  double get defaultMpg {
    switch (this) {
      case CarType.sedan:
        return 28.0;
      case CarType.suv:
        return 18.0;
      case CarType.van:
        return 22.0;
      case CarType.truck:
        return 15.0;
      case CarType.hybrid:
        return 45.0;
    }
  }
  
  /// Convert from string to CarType
  static CarType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'sedan':
      case 'compact':
      case 'car':
      case 'hatchback':
        return CarType.sedan;
      case 'suv':
      case 'crossover':
        return CarType.suv;
      case 'van':
      case 'minivan':
        return CarType.van;
      case 'truck':
      case 'pickup':
        return CarType.truck;
      case 'hybrid':
      case 'phev':
        return CarType.hybrid;
      default:
        return CarType.sedan; // Default to sedan
    }
  }
}

/// Extension for UsageCategory with helper methods
extension UsageCategoryExtension on UsageCategory {
  /// Get the name of the usage category
  String get name {
    switch (this) {
      case UsageCategory.transportation:
        return 'Transportation';
      case UsageCategory.energy:
        return 'Energy';
    }
  }
  
  /// Get the icon name for the usage category
  String get iconName {
    switch (this) {
      case UsageCategory.transportation:
        return 'commute';
      case UsageCategory.energy:
        return 'power';
    }
  }
  
  /// Convert from string to UsageCategory
  static UsageCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'transportation':
      case 'transport':
        return UsageCategory.transportation;
      case 'energy':
        return UsageCategory.energy;
      default:
        throw ArgumentError('Invalid usage category: $value');
    }
  }
}

/// Extension for EnergyType with helper methods
extension EnergyTypeExtension on EnergyType {
  /// Get the name of the energy type
  String get name {
    switch (this) {
      case EnergyType.electricity:
        return 'Electricity';
      case EnergyType.gas:
        return 'Gas';
    }
  }
  
  /// Get the icon name for the energy type
  String get iconName {
    switch (this) {
      case EnergyType.electricity:
        return 'electric_bolt';
      case EnergyType.gas:
        return 'gas_meter';
    }
  }
  
  /// Convert from string to EnergyType
  static EnergyType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'electricity':
      case 'electric':
        return EnergyType.electricity;
      case 'gas':
      case 'natural gas':
      case 'lpg':
      case 'propane':
        return EnergyType.gas;
      default:
        throw ArgumentError('Invalid energy type: $value');
    }
  }
  
  /// Map to EnergySource (from energy_model.dart)
  EnergySource toEnergySource() {
    switch (this) {
      case EnergyType.electricity:
        return EnergySource.electricity;
      case EnergyType.gas:
        return EnergySource.naturalGas; // Default to natural gas
    }
  }
}

/// Energy source enum from energy_model.dart (simplified reference)
enum EnergySource {
  electricity,
  naturalGas,
  lpg,
  heatingOil,
  renewable,
  other,
}

/// Helper class for mapping between usage categories and specific models
class UsageCategoryMapper {
  /// Private constructor to prevent instantiation
  UsageCategoryMapper._();
  
  /// Map an EnergySource to the appropriate EnergyType
  static EnergyType energySourceToEnergyType(EnergySource source) {
    switch (source) {
      case EnergySource.electricity:
      case EnergySource.renewable:
        return EnergyType.electricity;
      case EnergySource.naturalGas:
      case EnergySource.lpg:
      case EnergySource.heatingOil:
      case EnergySource.other:
        return EnergyType.gas;
    }
  }
  
  /// Determine the UsageCategory from a activity/trip type string
  static UsageCategory getUsageCategoryFromType(String type) {
    switch (type.toLowerCase()) {
      case 'transport':
      case 'transportation':
      case 'travel':
      case 'trip':
        return UsageCategory.transportation;
      case 'energy':
      case 'electricity':
      case 'gas':
      case 'power':
      case 'utility':
        return UsageCategory.energy;
      default:
        throw ArgumentError('Unknown usage type: $type');
    }
  }
  
  /// Get the appropriate EnergyType from an activity title or description
  static EnergyType? getEnergyTypeFromDescription(String description) {
    final lowerDesc = description.toLowerCase();
    
    if (lowerDesc.contains('electric') || 
        lowerDesc.contains('power') || 
        lowerDesc.contains('plug')) {
      return EnergyType.electricity;
    } else if (lowerDesc.contains('gas') || 
               lowerDesc.contains('heat') || 
               lowerDesc.contains('propane') ||
               lowerDesc.contains('lpg')) {
      return EnergyType.gas;
    }
    
    return null; // Could not determine
  }
}
