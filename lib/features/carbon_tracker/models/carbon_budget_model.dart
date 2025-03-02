import 'dart:convert';

/// Model for user's carbon budget settings
class CarbonBudgetModel {
  /// Unique identifier
  final String id;
  
  /// User ID this budget belongs to
  final String userId;
  
  /// Daily carbon budget in grams CO2
  final double dailyBudget;
  
  /// Weekly carbon budget in grams CO2
  final double weeklyBudget;
  
  /// Monthly carbon budget in grams CO2
  final double monthlyBudget;
  
  /// Current budget period start date
  final DateTime periodStart;
  
  /// Current budget period end date
  final DateTime? periodEnd;
  
  /// Whether to receive notifications about budget
  final bool notificationsEnabled;
  
  /// Whether the budget is active
  final bool isActive;
  
  /// Creates a carbon budget model
  CarbonBudgetModel({
    required this.id,
    required this.userId,
    required this.dailyBudget,
    required this.weeklyBudget,
    required this.monthlyBudget,
    required this.periodStart,
    this.periodEnd,
    this.notificationsEnabled = true,
    this.isActive = true,
  });
  
  /// Create a copy with updated fields
  CarbonBudgetModel copyWith({
    String? id,
    String? userId,
    double? dailyBudget,
    double? weeklyBudget,
    double? monthlyBudget,
    DateTime? periodStart,
    DateTime? periodEnd,
    bool? notificationsEnabled,
    bool? isActive,
  }) {
    return CarbonBudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dailyBudget: dailyBudget ?? this.dailyBudget,
      weeklyBudget: weeklyBudget ?? this.weeklyBudget,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isActive: isActive ?? this.isActive,
    );
  }
  
  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'dailyBudget': dailyBudget,
      'weeklyBudget': weeklyBudget,
      'monthlyBudget': monthlyBudget,
      'periodStart': periodStart.millisecondsSinceEpoch,
      'periodEnd': periodEnd?.millisecondsSinceEpoch,
      'notificationsEnabled': notificationsEnabled,
      'isActive': isActive,
    };
  }
  
  /// Create from map
  factory CarbonBudgetModel.fromMap(Map<String, dynamic> map) {
    return CarbonBudgetModel(
      id: map['id'],
      userId: map['userId'],
      dailyBudget: map['dailyBudget']?.toDouble() ?? 0.0,
      weeklyBudget: map['weeklyBudget']?.toDouble() ?? 0.0,
      monthlyBudget: map['monthlyBudget']?.toDouble() ?? 0.0,
      periodStart: DateTime.fromMillisecondsSinceEpoch(map['periodStart']),
      periodEnd: map['periodEnd'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['periodEnd']) 
          : null,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      isActive: map['isActive'] ?? true,
    );
  }
  
  /// Convert to JSON
  String toJson() => json.encode(toMap());
  
  /// Create from JSON
  factory CarbonBudgetModel.fromJson(String source) => 
      CarbonBudgetModel.fromMap(json.decode(source));
      
  /// Create a default budget model for a new user
  factory CarbonBudgetModel.createDefault(String userId) {
    // Default: 500 lb CO2 per day, calculated for week and month
    const double defaultDailyBudget = 500;
    
    return CarbonBudgetModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      dailyBudget: defaultDailyBudget,
      weeklyBudget: defaultDailyBudget * 7,
      monthlyBudget: defaultDailyBudget * 30,
      periodStart: DateTime.now().subtract(const Duration(days: 1)),
      notificationsEnabled: true,
      isActive: true,
    );
  }
  
  @override
  String toString() {
    return 'CarbonBudgetModel(id: $id, userId: $userId, dailyBudget: $dailyBudget, '
        'weeklyBudget: $weeklyBudget, monthlyBudget: $monthlyBudget, '
        'periodStart: $periodStart, periodEnd: $periodEnd, '
        'notificationsEnabled: $notificationsEnabled, isActive: $isActive)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is CarbonBudgetModel &&
        other.id == id &&
        other.userId == userId &&
        other.dailyBudget == dailyBudget &&
        other.weeklyBudget == weeklyBudget &&
        other.monthlyBudget == monthlyBudget &&
        other.periodStart == periodStart &&
        other.periodEnd == periodEnd &&
        other.notificationsEnabled == notificationsEnabled &&
        other.isActive == isActive;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        dailyBudget.hashCode ^
        weeklyBudget.hashCode ^
        monthlyBudget.hashCode ^
        periodStart.hashCode ^
        periodEnd.hashCode ^
        notificationsEnabled.hashCode ^
        isActive.hashCode;
  }
}
