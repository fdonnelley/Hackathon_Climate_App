import 'dart:convert';

/// Transportation mode enum
enum TransportMode {
  /// Walk/Run
  walking,
  
  /// Bicycle
  bicycle,
  
  /// Car
  car,
  
  /// Electric Vehicle
  electricVehicle,
  
  /// Bus
  bus,
  
  /// Train
  train,
  
  /// Airplane
  airplane,
  
  /// Other
  other,
}

/// Extension for TransportMode with helper methods
extension TransportModeExtension on TransportMode {
  /// Get the name of the transport mode
  String get name {
    switch (this) {
      case TransportMode.walking:
        return 'Walking/Running';
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
      case TransportMode.other:
        return 'Other';
    }
  }
  
  /// Get the icon data for the transport mode
  String get iconName {
    switch (this) {
      case TransportMode.walking:
        return 'directions_walk';
      case TransportMode.bicycle:
        return 'directions_bike';
      case TransportMode.car:
        return 'directions_car';
      case TransportMode.electricVehicle:
        return 'electric_car';
      case TransportMode.bus:
        return 'directions_bus';
      case TransportMode.train:
        return 'train';
      case TransportMode.airplane:
        return 'flight';
      case TransportMode.other:
        return 'commute';
    }
  }
  
  /// Get the CO2 emissions per kilometer for the transport mode (g CO2/km)
  double get emissionsPerKm {
    switch (this) {
      case TransportMode.walking:
        return 0;
      case TransportMode.bicycle:
        return 0;
      case TransportMode.car:
        return 192; // Average gasoline car
      case TransportMode.electricVehicle:
        return 53; // Average EV (includes emissions from electricity generation)
      case TransportMode.bus:
        return 105; // Average bus occupancy
      case TransportMode.train:
        return 41; // Average train emissions
      case TransportMode.airplane:
        return 255; // Short-haul flight
      case TransportMode.other:
        return 150; // Default mid-range value
    }
  }
}

/// Model for trip entries in the carbon tracker
class TripModel {
  /// Unique identifier
  final String id;
  
  /// Trip title or description
  final String title;
  
  /// Trip distance in kilometers
  final double distance;
  
  /// Transportation mode used
  final TransportMode transportMode;
  
  /// Date and time of the trip
  final DateTime timestamp;
  
  /// CO2 emissions in grams
  final double co2Emissions;
  
  /// Optional notes
  final String? notes;
  
  /// Creates a trip model
  TripModel({
    required this.id,
    required this.title,
    required this.distance,
    required this.transportMode,
    required this.timestamp,
    double? co2Emissions,
    this.notes,
  }) : co2Emissions = co2Emissions ?? (distance * transportMode.emissionsPerKm);
  
  /// Create a copy with updated fields
  TripModel copyWith({
    String? id,
    String? title,
    double? distance,
    TransportMode? transportMode,
    DateTime? timestamp,
    double? co2Emissions,
    String? notes,
  }) {
    return TripModel(
      id: id ?? this.id,
      title: title ?? this.title,
      distance: distance ?? this.distance,
      transportMode: transportMode ?? this.transportMode,
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
      'distance': distance,
      'transportMode': transportMode.index,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'co2Emissions': co2Emissions,
      'notes': notes,
    };
  }
  
  /// Create from map
  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      id: map['id'],
      title: map['title'],
      distance: map['distance']?.toDouble() ?? 0.0,
      transportMode: TransportMode.values[map['transportMode'] ?? 0],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      co2Emissions: map['co2Emissions']?.toDouble() ?? 0.0,
      notes: map['notes'],
    );
  }
  
  /// Convert to JSON
  String toJson() => json.encode(toMap());
  
  /// Create from JSON
  factory TripModel.fromJson(String source) => 
      TripModel.fromMap(json.decode(source));
  
  @override
  String toString() {
    return 'TripModel(id: $id, title: $title, distance: $distance, '
        'transportMode: $transportMode, timestamp: $timestamp, '
        'co2Emissions: $co2Emissions, notes: $notes)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is TripModel &&
        other.id == id &&
        other.title == title &&
        other.distance == distance &&
        other.transportMode == transportMode &&
        other.timestamp == timestamp &&
        other.co2Emissions == co2Emissions &&
        other.notes == notes;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        distance.hashCode ^
        transportMode.hashCode ^
        timestamp.hashCode ^
        co2Emissions.hashCode ^
        notes.hashCode;
  }
}
