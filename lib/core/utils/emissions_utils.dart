/// Utilities for handling carbon emissions
class EmissionsUtils {
  /// Conversion factor from kg to lb: 1 kg = 2.20462 lb
  static const double kgToLbFactor = 2.20462;
  
  /// Convert kilograms of CO2 to pounds
  static double kgToPounds(double kg) {
    return kg * kgToLbFactor;
  }
  
  /// Convert pounds of CO2 to kilograms
  static double poundsToKg(double lb) {
    return lb / kgToLbFactor;
  }
  
  /// Format pounds for display with appropriate precision
  static String formatPounds(double pounds, {int precision = 1}) {
    return pounds.toStringAsFixed(precision);
  }
  
  /// Format kilograms for display with appropriate precision
  static String formatKg(double kg, {int precision = 1}) {
    return kg.toStringAsFixed(precision);
  }
}
