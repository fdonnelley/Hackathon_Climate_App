import 'package:get/get.dart';
import '../models/friend_model.dart';
import '../models/leaderboard_entry_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../home/controllers/home_controller.dart';

/// Controller for social features including friends and leaderboard
class SocialController extends GetxController {
  /// Global leaderboard entries
  final globalLeaderboardEntries = <LeaderboardEntry>[].obs;
  
  /// Friends leaderboard entries
  final friendsLeaderboardEntries = <LeaderboardEntry>[].obs;
  
  /// Currently displayed leaderboard entries
  final leaderboardEntries = <LeaderboardEntry>[].obs;
  
  /// Friends list
  final friends = <Friend>[].obs;
  
  /// Friend requests (received and sent)
  final friendRequests = <Friend>[].obs;
  
  /// Current search query for finding users
  final searchQuery = ''.obs;
  
  /// Search results
  final searchResults = <Friend>[].obs;
  
  /// Selected leaderboard filter (global or friends)
  final leaderboardFilter = Rx<LeaderboardFilter>(LeaderboardFilter.global);
  
  /// Selected leaderboard time period
  final leaderboardPeriod = Rx<LeaderboardPeriod>(LeaderboardPeriod.weekly);
  
  /// Whether to show a loading indicator for search
  final isSearching = false.obs;
  
  /// Whether to show a loading indicator for the leaderboard
  final isLoadingLeaderboard = false.obs;
  
  /// Auth controller for getting current user info
  AuthController get _authController => Get.find<AuthController>();
  
  /// Home controller for getting emissions data
  HomeController? get _homeController => 
      Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;
  
  /// Get the current user ID
  String? get currentUserId => _authController.currentUser?.id;
  
  /// Initialize the controller
  @override
  void onInit() {
    super.onInit();
    
    // Load real data for demo purposes
    _loadMockData();
    
    // Set up listener for emissions changes
    if (_homeController != null) {
      ever(_homeController!.weeklyEmissions, (_) => updateCurrentUserEmissions());
    }
    
    // In a real app, we would fetch data from an API or database
    // _fetchFriends();
    // _fetchLeaderboard();
  }
  
  /// Load real data for demonstration
  void _loadMockData() {
    // Get current user ID
    final userId = currentUserId ?? 'user123';
    
    // Get current user's name
    final userName = _authController.currentUser?.name ?? 'You';
    
    // Get initial emissions data
    double userEmissions = 0.0;
    double userReductionPercentage = 0.0;
    
    // Try to get real emissions data from HomeController if available
    if (_homeController != null) {
      userEmissions = _homeController!.weeklyEmissions.value;
      
      // Calculate reduction percentage based on budget usage
      if (_homeController!.weeklyBudget.value > 0) {
        final usagePercentage = _homeController!.weeklyUsagePercentage.value;
        // Convert usage percentage to reduction percentage
        userReductionPercentage = (100 - usagePercentage).clamp(0.0, 100.0);
      } else {
        userReductionPercentage = 5.2;
      }
    } else {
      // Default values if HomeController is not available
      userEmissions = 125.3;
      userReductionPercentage = 5.2;
    }
    
    // Generate more realistic global leaderboard data
    globalLeaderboardEntries.value = [
      // Top performers
      LeaderboardEntry(
        userId: 'user001',
        name: 'Greta T.',
        rank: 1,
        emissions: 15.8,
        reductionPercentage: 35.2,
        streak: 1,
        score: 3850,
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        userId: 'user002',
        name: 'David A.',
        rank: 2,
        emissions: 22.6,
        reductionPercentage: 28.9,
        streak: 1,
        score: 3540,
        isCurrentUser: false,
      ),
      // Other good performers
      LeaderboardEntry(
        userId: 'user003',
        name: 'Jane G.',
        rank: 3,
        emissions: 34.2,
        reductionPercentage: 18.7,
        streak: 1,
        score: 2980,
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        userId: 'user004',
        name: 'Marcus L.',
        rank: 4,
        emissions: 45.8,
        reductionPercentage: 15.3,
        streak: 1,
        score: 2650,
        isCurrentUser: false,
      ),
      // Mid-range performers
      LeaderboardEntry(
        userId: 'user005',
        name: 'Sarah P.',
        rank: 5,
        emissions: 65.4,
        reductionPercentage: 12.1,
        streak: 1,
        score: 1950,
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        userId: 'user006',
        name: 'John D.',
        rank: 6,
        emissions: 89.7,
        reductionPercentage: 8.5,
        streak: 1,
        score: 1420,
        isCurrentUser: false,
      ),
      // Current user
      LeaderboardEntry(
        userId: userId,
        name: userName,
        rank: 7,
        emissions: userEmissions,
        reductionPercentage: userReductionPercentage,
        streak: 1,
        score: 1250,
        isCurrentUser: true,
      ),
      // Below average performers
      LeaderboardEntry(
        userId: 'user007',
        name: 'Michael B.',
        rank: 8,
        emissions: 148.2,
        reductionPercentage: 2.1,
        streak: 1,
        score: 850,
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        userId: 'user008',
        name: 'Emma W.',
        rank: 9,
        emissions: 175.6,
        reductionPercentage: 0.8,
        streak: 1,
        score: 620,
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        userId: 'user009',
        name: 'Robert C.',
        rank: 10,
        emissions: 210.3,
        reductionPercentage: 0.0,
        streak: 1,
        score: 340,
        isCurrentUser: false,
      ),
    ];
    
    // Create a subset for friends leaderboard
    friendsLeaderboardEntries.value = [
      // Friend with excellent performance
      LeaderboardEntry(
        userId: 'user002',
        name: 'David A.',
        rank: 1,
        emissions: 22.6,
        reductionPercentage: 28.9,
        streak: 1,
        score: 3540,
        isCurrentUser: false,
      ),
      // Current user
      LeaderboardEntry(
        userId: userId,
        name: userName,
        rank: 2,
        emissions: userEmissions,
        reductionPercentage: userReductionPercentage,
        streak: 1,
        score: 1250,
        isCurrentUser: true,
      ),
      // Friends with varying performance
      LeaderboardEntry(
        userId: 'user005',
        name: 'Sarah P.',
        rank: 3,
        emissions: 65.4,
        reductionPercentage: 12.1,
        streak: 1,
        score: 1950,
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        userId: 'user007',
        name: 'Michael B.',
        rank: 4,
        emissions: 148.2,
        reductionPercentage: 2.1,
        streak: 1,
        score: 850,
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        userId: 'user008',
        name: 'Emma W.',
        rank: 5,
        emissions: 175.6,
        reductionPercentage: 0.8,
        streak: 1,
        score: 620,
        isCurrentUser: false,
      ),
    ];
    
    // Sort leaderboards by emissions (lower is better)
    globalLeaderboardEntries.sort((a, b) => a.emissions.compareTo(b.emissions));
    friendsLeaderboardEntries.sort((a, b) => a.emissions.compareTo(b.emissions));
    
    // Update ranks after sorting
    for (int i = 0; i < globalLeaderboardEntries.length; i++) {
      final entry = globalLeaderboardEntries[i];
      globalLeaderboardEntries[i] = entry.copyWith(rank: i + 1);
    }
    
    for (int i = 0; i < friendsLeaderboardEntries.length; i++) {
      final entry = friendsLeaderboardEntries[i];
      friendsLeaderboardEntries[i] = entry.copyWith(rank: i + 1);
    }
    
    // Initialize the displayed leaderboard with global entries
    leaderboardEntries.value = globalLeaderboardEntries;
    
    // Generate mock friends
    _loadMockFriends();
  }
  
  /// Load mock friends data
  void _loadMockFriends() {
    // Mock friends data
    friends.assignAll([
      Friend(
        id: 'user002',
        name: 'David A.',
        email: 'david.a@example.com',
        profilePicture: 'https://randomuser.me/api/portraits/men/22.jpg',
        reductionPercentage: 28.9,
        streak: 1,
        rank: 1,
      ),
      Friend(
        id: 'user005',
        name: 'Sarah P.',
        email: 'sarah.p@example.com',
        profilePicture: 'https://randomuser.me/api/portraits/women/44.jpg',
        reductionPercentage: 12.1,
        streak: 1,
        rank: 3,
      ),
      Friend(
        id: 'user007',
        name: 'Michael B.',
        email: 'michael.b@example.com',
        profilePicture: 'https://randomuser.me/api/portraits/men/32.jpg',
        reductionPercentage: 2.1,
        streak: 1,
        rank: 4,
      ),
      Friend(
        id: 'user008',
        name: 'Emma W.',
        email: 'emma.w@example.com',
        profilePicture: 'https://randomuser.me/api/portraits/women/67.jpg',
        reductionPercentage: 0.8,
        streak: 1,
        rank: 5,
      ),
    ]);
    
    // Mock friend requests
    friendRequests.assignAll([
      Friend(
        id: 'user003',
        name: 'Jane G.',
        email: 'jane.g@example.com',
        profilePicture: 'https://randomuser.me/api/portraits/women/28.jpg',
        status: FriendStatus.received,
      ),
      Friend(
        id: 'user006',
        name: 'John D.',
        email: 'john.d@example.com',
        profilePicture: 'https://randomuser.me/api/portraits/men/45.jpg',
        status: FriendStatus.pending,
      ),
    ]);
  }
  
  /// Change the leaderboard period
  void changeLeaderboardPeriod(LeaderboardPeriod period) {
    leaderboardPeriod.value = period;
    // In a real app, we would fetch new data based on the period
    // _fetchLeaderboard();
  }
  
  /// Change the friend leaderboard period
  void changeFriendLeaderboardPeriod(LeaderboardPeriod period) {
    leaderboardPeriod.value = period;
    // In a real app, we would fetch new data based on the period
    // _fetchFriendLeaderboard();
  }
  
  /// Change the leaderboard filter between global and friends
  void changeLeaderboardFilter(LeaderboardFilter filter) {
    leaderboardFilter.value = filter;
    updateLeaderboardEntries();
  }
  
  /// Update leaderboard entries based on current filter
  void updateLeaderboardEntries() {
    if (leaderboardFilter.value == LeaderboardFilter.global) {
      leaderboardEntries.assignAll(globalLeaderboardEntries);
    } else {
      leaderboardEntries.assignAll(friendsLeaderboardEntries);
    }
  }
  
  /// Update current user's emissions data from HomeController
  void updateCurrentUserEmissions() {
    // If home controller is not available, skip
    if (_homeController == null) return;
    
    // Get current weekly emissions
    final emissions = _homeController!.weeklyEmissions.value;
    
    // Calculate reduction percentage based on budget usage
    // Lower percentage of budget used means higher reduction
    double reductionPercentage;
    if (_homeController!.weeklyBudget.value > 0) {
      final usagePercentage = _homeController!.weeklyUsagePercentage.value;
      // Convert usage percentage to reduction percentage
      // If usage is low (e.g., 50% of budget), reduction is high (50%)
      reductionPercentage = (100 - usagePercentage).clamp(0.0, 100.0);
    } else {
      // Default value if budget is not set
      reductionPercentage = 5.2;
    }
    
    // Update global leaderboard entry
    _updateUserInLeaderboard(globalLeaderboardEntries, emissions, reductionPercentage);
    
    // Update friends leaderboard entry
    _updateUserInLeaderboard(friendsLeaderboardEntries, emissions, reductionPercentage);
    
    // Update current display
    updateLeaderboardEntries();
  }
  
  /// Update user entry in leaderboard and resort
  void _updateUserInLeaderboard(RxList<LeaderboardEntry> leaderboardList, double emissions, double reductionPercentage) {
    // Find current user in leaderboard
    final index = leaderboardList.indexWhere((entry) => entry.isCurrentUser);
    if (index == -1) return;
    
    // Get current user entry
    final currentEntry = leaderboardList[index];
    
    // Create updated entry
    final updatedEntry = currentEntry.copyWith(
      emissions: emissions,
      reductionPercentage: reductionPercentage,
    );
    
    // Remove current entry
    leaderboardList.removeAt(index);
    
    // Add updated entry
    leaderboardList.add(updatedEntry);
    
    // Sort by emissions (lower is better)
    leaderboardList.sort((a, b) => a.emissions.compareTo(b.emissions));
    
    // Update ranks
    for (int i = 0; i < leaderboardList.length; i++) {
      final entry = leaderboardList[i];
      leaderboardList[i] = entry.copyWith(rank: i + 1);
    }
  }
  
  /// Search for users to add as friends
  void searchUsers(String query) {
    searchQuery.value = query;
    
    if (query.isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }
    
    // Show loading indicator
    isSearching.value = true;
    
    // In a real app, we would make an API call here
    _performMockSearch(query);
  }
  
  /// Perform mock search for demonstration
  void _performMockSearch(String query) {
    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 800), () {
      // Mock search results
      final results = [
        Friend(
          id: '10',
          name: 'Taylor Swift',
          email: 'taylor.s@example.com',
          profilePicture: 'https://randomuser.me/api/portraits/women/90.jpg',
          reductionPercentage: 0.0,
          streak: 1,
          rank: 0,
        ),
        Friend(
          id: '11',
          name: 'Chris Taylor',
          email: 'chris.t@example.com',
          profilePicture: 'https://randomuser.me/api/portraits/men/45.jpg',
          reductionPercentage: 0.0,
          streak: 1,
          rank: 0,
        ),
        Friend(
          id: '12',
          name: 'Taylor Jones',
          email: 'taylor.j@example.com',
          profilePicture: 'https://randomuser.me/api/portraits/women/22.jpg',
          reductionPercentage: 0.0,
          streak: 1,
          rank: 0,
        ),
      ].where((user) => 
        user.name.toLowerCase().contains(query.toLowerCase()) ||
        user.email.toLowerCase().contains(query.toLowerCase())
      ).toList();
      
      searchResults.assignAll(results);
      isSearching.value = false;
    });
  }
  
  /// Send a friend request to a user
  void sendFriendRequest(String userId) {
    // In a real app, we would send an API request
    // For now, just update the UI
    final userIndex = searchResults.indexWhere((user) => user.id == userId);
    if (userIndex >= 0) {
      final user = searchResults[userIndex];
      friendRequests.add(Friend(
        id: user.id,
        name: user.name,
        email: user.email,
        profilePicture: user.profilePicture,
        status: FriendStatus.pending,
      ));
      
      // Update the search result to show request sent
      searchResults[userIndex] = user.copyWith(
        status: FriendStatus.pending,
      );
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
