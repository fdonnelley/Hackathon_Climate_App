import 'dart:convert';

/// Model for list items
class ListItemModel {
  /// Unique identifier
  final String id;
  
  /// Item title
  final String title;
  
  /// Item description
  final String description;
  
  /// Timestamp
  final DateTime timestamp;
  
  /// Optional category for grouping items
  final String? category;
  
  /// Boolean to mark items as completed or favorite
  final bool isMarked;
  
  /// Is completed flag
  final bool isCompleted;
  
  /// Item priority
  final ItemPriority priority;
  
  /// Creates a list item model
  const ListItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    this.category,
    this.isMarked = false,
    this.isCompleted = false,
    this.priority = ItemPriority.medium,
  });
  
  /// Create a copy with updated fields
  ListItemModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? timestamp,
    String? category,
    bool? isMarked,
    bool? isCompleted,
    ItemPriority? priority,
  }) {
    return ListItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      isMarked: isMarked ?? this.isMarked,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
    );
  }
  
  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'category': category,
      'isMarked': isMarked,
      'isCompleted': isCompleted,
      'priority': priority.index,
    };
  }
  
  /// Create from map
  factory ListItemModel.fromMap(Map<String, dynamic> map) {
    return ListItemModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      category: map['category'],
      isMarked: map['isMarked'] ?? false,
      isCompleted: map['isCompleted'] ?? false,
      priority: ItemPriority.values[map['priority'] ?? 1],
    );
  }
  
  /// Convert to JSON
  String toJson() => json.encode(toMap());
  
  /// Create from JSON
  factory ListItemModel.fromJson(String source) => 
      ListItemModel.fromMap(json.decode(source));
  
  @override
  String toString() {
    return 'ListItemModel(id: $id, title: $title, description: $description, '
        'timestamp: $timestamp, category: $category, isMarked: $isMarked, '
        'isCompleted: $isCompleted, priority: $priority)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ListItemModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.timestamp == timestamp &&
        other.category == category &&
        other.isMarked == isMarked &&
        other.isCompleted == isCompleted &&
        other.priority == priority;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        timestamp.hashCode ^
        category.hashCode ^
        isMarked.hashCode ^
        isCompleted.hashCode ^
        priority.hashCode;
  }
}

/// Priority levels for items
enum ItemPriority {
  /// Low priority
  low,
  
  /// Medium priority
  medium,
  
  /// High priority
  high,
}

/// Extensions for ItemPriority
extension ItemPriorityX on ItemPriority {
  /// Get the name of the priority
  String get name {
    switch (this) {
      case ItemPriority.low:
        return 'Low';
      case ItemPriority.medium:
        return 'Medium';
      case ItemPriority.high:
        return 'High';
    }
  }
  
  /// Get the color for the priority
  int get color {
    switch (this) {
      case ItemPriority.low:
        return 0xFF4CAF50; // Green
      case ItemPriority.medium:
        return 0xFFFFA000; // Amber
      case ItemPriority.high:
        return 0xFFF44336; // Red
    }
  }
}
