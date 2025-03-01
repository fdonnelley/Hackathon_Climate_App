import 'package:get/get.dart';
import '../models/friend_model.dart';
import '../models/leaderboard_entry_model.dart';
import '../../auth/controllers/auth_controller.dart';

/// Controller for social features including friends and leaderboard
class SocialController extends GetxController {
  /// List of friends
  final friends = <Friend>[].obs;
  
  /// List of friend requests
  final friendRequests = <Friend>[].obs;
  
  /// List of all leaderboard entries
  final leaderboardEntries = <LeaderboardEntry>[].obs;
  
  /// Global leaderboard period type
  final Rx<LeaderboardPeriod> leaderboardPeriod = LeaderboardPeriod.weekly.obs;
  
  /// Friend leaderboard period type
  final Rx<LeaderboardPeriod> friendLeaderboardPeriod = LeaderboardPeriod.weekly.obs;
  
  /// Current leaderboard filter
  final Rx<LeaderboardFilter> leaderboardFilter = LeaderboardFilter.global.obs;
  
  /// Search query for finding friends
  final searchQuery = ''.obs;
  
  /// Search results when looking for new friends
  final searchResults = <Map<String, dynamic>>[].obs;
  
  /// Whether a search is currently in progress
  final isSearching = false.obs;
  
  /// Reference to the auth controller
  late final AuthController _authController;
  
  /// Get the current user ID
  String? get currentUserId => _authController.currentUser?.id;
  
  /// Initialize the controller
  @override
  void onInit() {
    super.onInit();
    _authController = Get.find<AuthController>();
    
    // Load mock data for demo purposes
    _loadMockData();
    
    // In a real app, we would fetch data from an API or database
    // _fetchFriends();
    // _fetchLeaderboard();
  }
  
  /// Load mock data for demonstration
  void _loadMockData() {
    // Mock friends data
    friends.assignAll([
      Friend(
        id: '1',
        name: 'Emma Johnson',
        email: 'emma.j@example.com',
        profilePicture: 'https://randomuser.me/api/portraits/women/44.jpg',
        reductionPercentage: 12.5,
        streak: 7,
        rank: 3,
      ),
      Friend(
        id: '2',
        name: 'Michael Chen',
        email: 'michael.c@example.com',
        profilePicture: 'https://randomuser.me/api/portraits/men/22.jpg',
        reductionPercentage: 8.2,
        streak: 5,
        rank: 12,
      ),
      Friend(
        id: '3',
        name: 'Sophia Rodriguez',
        email: 'sophia.r@example.com',
        profilePicture: 'https://randomuser.me/api/portraits/women/67.jpg',
        reductionPercentage: 15.0,
        streak: 14,
        rank: 1,
      ),
    ]);
    
    // Mock friend requests
    friendRequests.assignAll([
      Friend(
        id: '4',
        name: 'James Wilson',
        email: 'james.w@example.com',
        profilePicture: 'https://randomuser.me/api/portraits/men/32.jpg',
        status: FriendStatus.received,
      ),
      Friend(
        id: '5',
        name: 'Olivia Smith',
        email: 'olivia.s@example.com',
        profilePicture: 'https://randomuser.me/api/portraits/women/28.jpg',
        status: FriendStatus.pending,
      ),
    ]);
    
    // Mock leaderboard data
    final mockEntries = [
      LeaderboardEntry(
        userId: '3',
        name: 'Sophia Rodriguez',
        profilePicture: 'https://randomuser.me/api/portraits/women/67.jpg',
        rank: 1,
        emissions: 62.3,
        reductionPercentage: 15.0,
        streak: 14,
        score: 128,
      ),
      LeaderboardEntry(
        userId: '6',
        name: 'Alex Kim',
        profilePicture: 'https://randomuser.me/api/portraits/men/79.jpg',
        rank: 2,
        emissions: 64.1,
        reductionPercentage: 13.7,
        streak: 10,
        score: 125,
      ),
      LeaderboardEntry(
        userId: '1',
        name: 'Emma Johnson',
        profilePicture: 'https://randomuser.me/api/portraits/women/44.jpg',
        rank: 3,
        emissions: 65.8,
        reductionPercentage: 12.5,
        streak: 7,
        score: 119,
      ),
      LeaderboardEntry(
        userId: '7',
        name: 'David Lopez',
        profilePicture: 'https://randomuser.me/api/portraits/men/91.jpg',
        rank: 4,
        emissions: 69.2,
        reductionPercentage: 10.3,
        streak: 6,
        score: 112,
      ),
      LeaderboardEntry(
        userId: '8',
        name: 'Sarah Thompson',
        profilePicture: 'https://randomuser.me/api/portraits/women/12.jpg',
        rank: 5,
        emissions: 70.5,
        reductionPercentage: 9.8,
        streak: 4,
        score: 105,
      ),
      LeaderboardEntry(
        userId: '9',
        name: 'Current User',
        profilePicture: null,
        rank: 17,
        emissions: 84.3,
        reductionPercentage: 5.2,
        streak: 3,
        score: 87,
        isCurrentUser: true,
      ),
    ];
    
    leaderboardEntries.assignAll(mockEntries);
  }
  
  /// Change the leaderboard period
  void changeLeaderboardPeriod(LeaderboardPeriod period) {
    leaderboardPeriod.value = period;
    // In a real app, we would fetch new data based on the period
    // _fetchLeaderboard();
  }
  
  /// Change the friend leaderboard period
  void changeFriendLeaderboardPeriod(LeaderboardPeriod period) {
    friendLeaderboardPeriod.value = period;
    // In a real app, we would fetch new data based on the period
    // _fetchFriendLeaderboard();
  }
  
  /// Change the leaderboard filter between global and friends
  void changeLeaderboardFilter(LeaderboardFilter filter) {
    leaderboardFilter.value = filter;
    // In a real app, we would adjust the display based on the filter
  }
  
  /// Search for users to add as friends
  void searchUsers(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }
    
    isSearching.value = true;
    
    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 800), () {
      // Mock search results
      final results = [
        {
          'id': '10',
          'name': 'Taylor Swift',
          'email': 'taylor.s@example.com',
          'profilePicture': 'https://randomuser.me/api/portraits/women/90.jpg',
          'mutualFriends': 2,
        },
        {
          'id': '11',
          'name': 'Chris Taylor',
          'email': 'chris.t@example.com',
          'profilePicture': 'https://randomuser.me/api/portraits/men/45.jpg',
          'mutualFriends': 1,
        },
        {
          'id': '12',
          'name': 'Taylor Jones',
          'email': 'taylor.j@example.com',
          'profilePicture': 'https://randomuser.me/api/portraits/women/22.jpg',
          'mutualFriends': 0,
        },
      ].where((user) => 
        user['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
        user['email'].toString().toLowerCase().contains(query.toLowerCase())
      ).toList();
      
      searchResults.assignAll(results);
      isSearching.value = false;
    });
  }
  
  /// Send a friend request to a user
  void sendFriendRequest(String userId) {
    // In a real app, we would send an API request
    // For now, just update the UI
    final userIndex = searchResults.indexWhere((user) => user['id'] == userId);
    if (userIndex >= 0) {
      final user = searchResults[userIndex];
      friendRequests.add(Friend(
        id: user['id'],
        name: user['name'],
        email: user['email'],
        profilePicture: user['profilePicture'],
        status: FriendStatus.pending,
      ));
      
      // Update the search result to show request sent
      searchResults[userIndex] = {
        ...user,
        'requestSent': true,
      };
      searchResults.refresh();
    }
  }
  
  /// Accept a friend request
  void acceptFriendRequest(String userId) {
    final requestIndex = friendRequests.indexWhere((request) => request.id == userId);
    if (requestIndex >= 0) {
      final request = friendRequests[requestIndex];
      final friend = Friend(
        id: request.id,
        name: request.name,
        email: request.email,
        profilePicture: request.profilePicture,
        status: FriendStatus.accepted,
      );
      
      friends.add(friend);
      friendRequests.removeAt(requestIndex);
    }
  }
  
  /// Reject a friend request
  void rejectFriendRequest(String userId) {
    friendRequests.removeWhere((request) => request.id == userId);
  }
  
  /// Remove a friend
  void removeFriend(String userId) {
    friends.removeWhere((friend) => friend.id == userId);
  }
}

/// Enum representing the leaderboard time period
enum LeaderboardPeriod {
  /// Daily leaderboard
  daily,
  
  /// Weekly leaderboard
  weekly,
  
  /// Monthly leaderboard
  monthly,
  
  /// All-time leaderboard
  allTime
}

/// Enum representing the leaderboard filter type
enum LeaderboardFilter {
  /// Global leaderboard with all users
  global,
  
  /// Friends-only leaderboard
  friends
}
