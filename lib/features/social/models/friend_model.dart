/// Friend model to represent users in the social network
class Friend {
  /// Unique identifier for the friend
  final String id;
  
  /// Name of the friend
  final String name;
  
  /// Email of the friend
  final String email;
  
  /// Profile picture URL
  final String? profilePicture;
  
  /// Carbon footprint reduction percentage compared to previous month
  final double reductionPercentage;
  
  /// Current streak of days below carbon budget
  final int streak;
  
  /// Overall carbon emissions ranking
  final int rank;
  
  /// Status of the friend relationship (pending, accepted, etc.)
  final FriendStatus status;
  
  /// Creates a friend model
  Friend({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.reductionPercentage = 0.0,
    this.streak = 0,
    this.rank = 0,
    this.status = FriendStatus.accepted,
  });
  
  /// Create a Friend object from a map
  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      profilePicture: map['profilePicture'] as String?,
      reductionPercentage: (map['reductionPercentage'] as num?)?.toDouble() ?? 0.0,
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      rank: (map['rank'] as num?)?.toInt() ?? 0,
      status: FriendStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => FriendStatus.pending,
      ),
    );
  }
  
  /// Convert this Friend object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'reductionPercentage': reductionPercentage,
      'streak': streak,
      'rank': rank,
      'status': status.name,
    };
  }
}

/// Enum representing the status of a friendship
enum FriendStatus {
  /// Request sent but not accepted yet
  pending,
  
  /// Friendship accepted
  accepted,
  
  /// Request received from another user
  received
}
