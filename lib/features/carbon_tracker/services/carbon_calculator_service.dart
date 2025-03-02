import '../../setup/models/setup_data_model.dart';

/// Service for calculating carbon emissions from various sources
class CarbonCalculatorService {
  // Constants for emissions calculations
  
  // Energy emissions factors

  static const double _electricityEmissionFactor = SetupDataModel.electricityEmissionFactor; // lb CO2 per kWh
  static const double _averageElectricityPrice = SetupDataModel.averageElectricityPrice; // $ per kWh
  static const double _gasEmissionFactor = SetupDataModel.gasEmissionFactor; // lb CO2 per therm
  static const double _averageGasPrice = SetupDataModel.averageGasPrice; // $ per therm
  
  // Transportation emissions factors
  static const double _gasolineEmissionFactor = SetupDataModel.gasolineEmissionFactor; // lb CO2 per gallon
  static const double _airplaneEmissionFactor = SetupDataModel.airplaneEmissionFactor; // lb CO2 per passenger-mile
  static const double _busEmissionFactor = SetupDataModel.busEmissionFactor; // lb CO2 per passenger-mile
  static const double _trainEmissionFactor = SetupDataModel.trainEmissionFactor; // lb CO2 per passenger-mile

  
  // Weeks in a month for conversion
  static const double weeksPerMonth = 4.33;
  
  /// Calculate total carbon footprint from all sources (monthly in lbs CO2)
  static double calculateTotalFootprint(SetupDataModel data) {
    double transportationEmissions = calculateTransportationEmissions(data.transportationMethods);
    double electricityEmissions = calculateElectricityEmissions(data.monthlyElectricBill);
    double gasEmissions = calculateGasEmissions(data.monthlyGasBill);
    
    return transportationEmissions + electricityEmissions + gasEmissions;
  }
  
  /// Calculate transportation emissions (monthly in lbs CO2)

  static double calculateTransportationEmissions(List<TransportationMethod> methods) {
    double weeklyEmissions = 0;
    
    // Sum up emissions from all transportation methods
    for (var method in methods) {
      weeklyEmissions += calculateSingleTransportEmissions(method);
    }
    
    // Convert to monthly
    return weeklyEmissions * weeksPerMonth;
  }
  

  /// Calculate emissions for a single transportation method (weekly in lbs CO2)
  static double calculateSingleTransportEmissions(TransportationMethod method) {
    switch (method.mode) {
      case TransportMode.walking:
      case TransportMode.bicycle:
        // Zero emissions for these modes
        return 0.0;
        
      case TransportMode.publicTransportation:
        double emissionsFactor = 1.0;
        if (method.publicTransportType == PublicTransportType.bus) {
          emissionsFactor = _busEmissionFactor;
        } else if (method.publicTransportType == PublicTransportType.train) {
          emissionsFactor = _trainEmissionFactor;
        }
        return method.milesPerWeek * emissionsFactor;
      
      case TransportMode.car:
        // For electric cars, emissions are minimal (we simplify to 0 here)
        if (method.carType == CarType.electric) {
          return 0.0;
        }
        
        // Calculate effective MPG, factoring in carpool if applicable
        double effectiveMpg = method.mpg ?? (method.carType?.defaultMpg ?? 25.0);
        
        // If it's a carpool, divide emissions by number of people (multiply MPG)
        if (method.carUsageType == CarUsageType.carpool && 
            method.carpoolSize != null && 
            method.carpoolSize! > 1) {
          effectiveMpg *= method.carpoolSize!.toDouble();
        }

        // lbs CO2 = (miles / mpg) * emission factor per gallon
        return (method.milesPerWeek / effectiveMpg) * _gasolineEmissionFactor;
      
      case TransportMode.airplane:
        // Airplanes emit per passenger-mile
        return method.milesPerWeek * _airplaneEmissionFactor;
    }
  }

  /// Calculate electricity emissions (monthly in lbs CO2)
  static double calculateElectricityEmissions(double monthlyBill, [double? averageBill]) {
    // If bill is 0 or not provided, use average if provided
    if (monthlyBill <= 0 && averageBill != null) {
      monthlyBill = averageBill;
    }
    
    // Convert from cost to kWh, then multiply by emissions factor
    return monthlyBill / _averageElectricityPrice * _electricityEmissionFactor;
  }
  
  /// Calculate natural gas emissions (monthly in lbs CO2)
  static double calculateGasEmissions(double monthlyBill, [double? averageBill]) {
    // If bill is 0 or not provided, use average if provided
    if (monthlyBill <= 0 && averageBill != null) {
      monthlyBill = averageBill;
    }
    
    // Convert from cost to therms, then multiply by emissions factor
    return monthlyBill / _averageGasPrice * _gasEmissionFactor;
  }
  
  /// Calculate average monthly carbon footprint for a typical household (in lbs CO2)
  static double calculateAverageFootprint() {
    // Average monthly electric bill: $120
    double avgElectricityEmissions = calculateElectricityEmissions(120);
    
    // Average monthly gas bill: $80
    double avgGasEmissions = calculateGasEmissions(80);
    
    // Average weekly car mileage: 250 miles with 25 MPG
    double avgTransportationEmissions = (250 / 25) * _gasolineEmissionFactor * weeksPerMonth;
    
    return avgElectricityEmissions + avgGasEmissions + avgTransportationEmissions;
  }
  
  /// Convert monthly carbon footprint to weekly
  static double monthlyToWeekly(double monthlyEmissions) {
    return monthlyEmissions / weeksPerMonth;
  }
  
  /// Convert weekly carbon footprint to monthly
  static double weeklyToMonthly(double weeklyEmissions) {
    return weeklyEmissions * weeksPerMonth;
  }
  
  /// Calculate carbon savings from a specific action (in lbs CO2)
  static double calculateActionSavings(CarbonSavingAction action) {
    switch (action) {
      case CarbonSavingAction.reduceDriving:
        // Reducing driving by 20 miles per week
        return (20 / 25) * _gasolineEmissionFactor * weeksPerMonth;
        
      case CarbonSavingAction.improveHomeInsulation:
        // Save 10% on heating bill (average gas bill $80)
        return calculateGasEmissions(80) * 0.1;
        
      case CarbonSavingAction.switchToLEDs:
        // Save 5% on electricity bill (average electric bill $120)
        return calculateElectricityEmissions(120) * 0.05;
        
      case CarbonSavingAction.usePublicTransport:
        // Replace 50 car miles with public transit
        double carEmissions = (50 / 25) * _gasolineEmissionFactor;
        double transitEmissions = 50 * _busEmissionFactor;
        return (carEmissions - transitEmissions) * weeksPerMonth;
    }
  }
}

/// Enum representing carbon-saving actions
enum CarbonSavingAction {
  reduceDriving,
  improveHomeInsulation,
  switchToLEDs,
  usePublicTransport,
}
