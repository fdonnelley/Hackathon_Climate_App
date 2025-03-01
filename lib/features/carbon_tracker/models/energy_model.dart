import 'dart:convert';

/// Energy source enum
enum EnergySource {
  /// Electricity
  electricity,
  
  /// Natural Gas
  naturalGas,
  
  /// LPG/Propane
  lpg,
  
  /// Heating Oil
  heatingOil,
  
  /// Renewable Energy
  renewable,
  
  /// Other energy source
  other,
}

/// Extension for EnergySource with helper methods
extension EnergySourceExtension on EnergySource {
  /// Get the name of the energy source
  String get name {
    switch (this) {
      case EnergySource.electricity:
        return 'Electricity';
      case EnergySource.naturalGas:
        return 'Natural Gas';
      case EnergySource.lpg:
        return 'LPG/Propane';
      case EnergySource.heatingOil:
        return 'Heating Oil';
      case EnergySource.renewable:
        return 'Renewable Energy';
      case EnergySource.other:
        return 'Other';
    }
  }
  
  /// Get the icon name for the energy source
  String get iconName {
    switch (this) {
      case EnergySource.electricity:
        return 'electric_bolt';
      case EnergySource.naturalGas:
        return 'gas_meter';
      case EnergySource.lpg:
        return 'propane';
      case EnergySource.heatingOil:
        return 'local_fire_department';
      case EnergySource.renewable:
        return 'wb_sunny';
      case EnergySource.other:
        return 'power';
    }
  }
  
  /// Get the unit of measurement
  String get unit {
    switch (this) {
      case EnergySource.electricity:
        return 'kWh';
      case EnergySource.naturalGas:
        return 'm³';
      case EnergySource.lpg:
        return 'kg';
      case EnergySource.heatingOil:
        return 'L';
      case EnergySource.renewable:
        return 'kWh';
      case EnergySource.other:
        return 'units';
    }
  }
  
  /// Get the CO2 emissions per unit for the energy source (g CO2/unit)
  double get emissionsPerUnit {
    switch (this) {
      case EnergySource.electricity:
        return 420; // Average grid mix, varies by location
      case EnergySource.naturalGas:
        return 2020; // Per m³
      case EnergySource.lpg:
        return 2983; // Per kg
      case EnergySource.heatingOil:
        return 2518; // Per liter
      case EnergySource.renewable:
        return 0; // Zero emissions for renewable
      case EnergySource.other:
        return 500; // Default value
    }
  }
}

/// Model for energy consumption entries in the carbon tracker
class EnergyModel {
  /// Unique identifier
  final String id;
  
  /// Energy consumption title or description
  final String title;
  
  /// Consumption amount in appropriate units
  final double amount;
  
  /// Energy source type
  final EnergySource energySource;
  
  /// Date and time of the energy consumption entry
  final DateTime timestamp;
  
  /// CO2 emissions in grams
  final double co2Emissions;
  
  /// Optional notes
  final String? notes;
  
  /// Creates an energy consumption model
  EnergyModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.energySource,
    required this.timestamp,
    double? co2Emissions,
    this.notes,
  }) : co2Emissions = co2Emissions ?? (amount * energySource.emissionsPerUnit);
  
  /// Create a copy with updated fields
  EnergyModel copyWith({
    String? id,
    String? title,
    double? amount,
    EnergySource? energySource,
    DateTime? timestamp,
    double? co2Emissions,
    String? notes,
  }) {
    return EnergyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      energySource: energySource ?? this.energySource,
      timestamp: timestamp ?? this.timestamp,
      co2Emissions: co2Emissions ?? this.co2Emissions,
      notes: notes ?? this.notes,
    );
  }
  
  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'energySource': energySource.index,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'co2Emissions': co2Emissions,
      'notes': notes,
    };
  }
  
  /// Create from map
  factory EnergyModel.fromMap(Map<String, dynamic> map) {
    return EnergyModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount']?.toDouble() ?? 0.0,
      energySource: EnergySource.values[map['energySource'] ?? 0],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      co2Emissions: map['co2Emissions']?.toDouble() ?? 0.0,
      notes: map['notes'],
    );
  }
  
  /// Convert to JSON
  String toJson() => json.encode(toMap());
  
  /// Create from JSON
  factory EnergyModel.fromJson(String source) => 
      EnergyModel.fromMap(json.decode(source));
  
  @override
  String toString() {
    return 'EnergyModel(id: $id, title: $title, amount: $amount, '
        'energySource: $energySource, timestamp: $timestamp, '
        'co2Emissions: $co2Emissions, notes: $notes)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is EnergyModel &&
        other.id == id &&
        other.title == title &&
        other.amount == amount &&
        other.energySource == energySource &&
        other.timestamp == timestamp &&
        other.co2Emissions == co2Emissions &&
        other.notes == notes;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        amount.hashCode ^
        energySource.hashCode ^
        timestamp.hashCode ^
        co2Emissions.hashCode ^
        notes.hashCode;
  }
}
