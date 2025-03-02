/// Model representing an entry in the leaderboard
class LeaderboardEntry {
  /// User ID
  final String userId;
  
  /// User's name
  final String name;
  
  /// Profile picture URL
  final String? profilePicture;
  
  /// User's rank on the leaderboard
  final int rank;
  
  /// Carbon emissions (kg) this period
  final double emissions;
  
  /// Percentage reduction from previous period
  final double reductionPercentage;
  
  /// Days streak below carbon budget
  final int streak;
  
  /// Score used for ranking (can be based on various factors)
  final int score;
  
  /// Whether this entry represents the current user
  final bool isCurrentUser;
  
  /// Creates a leaderboard entry
  LeaderboardEntry({
    required this.userId,
    required this.name,
    this.profilePicture,
    required this.rank,
    required this.emissions,
    this.reductionPercentage = 0.0,
    this.streak = 0,
    required this.score,
    this.isCurrentUser = false,
  });
  
  /// Create a LeaderboardEntry from a map
  factory LeaderboardEntry.fromMap(Map<String, dynamic> map, {String? currentUserId}) {
    return LeaderboardEntry(
      userId: map['userId'] as String,
      name: map['name'] as String,
      profilePicture: map['profilePicture'] as String?,
      rank: (map['rank'] as num).toInt(),
      emissions: (map['emissions'] as num).toDouble(),
      reductionPercentage: (map['reductionPercentage'] as num?)?.toDouble() ?? 0.0,
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      score: (map['score'] as num).toInt(),
      isCurrentUser: currentUserId != null && map['userId'] as String == currentUserId,
    );
  }
  
  /// Convert this LeaderboardEntry to a map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'profilePicture': profilePicture,
      'rank': rank,
      'emissions': emissions,
      'reductionPercentage': reductionPercentage,
      'streak': streak,
      'score': score,
    };
  }
  
  /// Create a copy of this entry with different values
  LeaderboardEntry copyWith({
    String? userId,
    String? name,
    String? profilePicture,
    int? rank,
    double? emissions,
    double? reductionPercentage,
    int? streak,
    int? score,
    bool? isCurrentUser,
  }) {
    return LeaderboardEntry(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      rank: rank ?? this.rank,
      emissions: emissions ?? this.emissions,
      reductionPercentage: reductionPercentage ?? this.reductionPercentage,
      streak: streak ?? this.streak,
      score: score ?? this.score,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}
