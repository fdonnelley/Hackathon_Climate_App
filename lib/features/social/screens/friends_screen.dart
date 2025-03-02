import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../controllers/social_controller.dart';
import '../models/friend_model.dart';
import '../../../core/widgets/debouncer.dart' as custom_debounce;

/// Screen for managing friends
class FriendsScreen extends StatelessWidget {
  /// Route name for the friends screen
  static String get routeName => AppRoutes.getRouteName(AppRoute.friends);
  
  /// Creates a friends screen
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Initialize controller if not already registered
    if (!Get.isRegistered<SocialController>()) {
      Get.put(SocialController());
    }
    final socialController = Get.find<SocialController>();
    
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Friends'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Friends'),
              Tab(text: 'Requests'),
              Tab(text: 'Find Friends'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFriendsTab(theme, socialController),
            _buildRequestsTab(theme, socialController),
            _buildFindTab(theme, socialController),
          ],
        ),
      ),
    );
  }
  
  /// Build the friends tab content
  Widget _buildFriendsTab(ThemeData theme, SocialController socialController) {
    return Obx(() {
      final friends = socialController.friends;
      
      if (friends.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No friends yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find friends to compete with on the leaderboard',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Switch to Find tab
                  DefaultTabController.of(Get.context!).animateTo(2);
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Find Friends'),
              ),
            ],
          ),
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return _buildFriendItem(theme, friend, socialController);
        },
      );
    });
  }
  
  /// Build a single friend item
  Widget _buildFriendItem(ThemeData theme, Friend friend, SocialController socialController) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: friend.profilePicture != null
            ? NetworkImage(friend.profilePicture!)
            : null,
        child: friend.profilePicture == null
            ? Icon(Icons.person, color: theme.colorScheme.onPrimary)
            : null,
      ),
      title: Text(friend.name),
      subtitle: Text(friend.email),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.eco,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  Text(
                    ' ${friend.reductionPercentage.toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 16,
                  ),
                  Text(
                    ' ${friend.streak} day streak',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              Get.bottomSheet(
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.bar_chart),
                        title: const Text('View Stats'),
                        onTap: () {
                          Get.back();
                          // Navigate to friend's stats (to be implemented)
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.message_outlined),
                        title: const Text('Message'),
                        onTap: () {
                          Get.back();
                          // Navigate to messaging (to be implemented)
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.person_remove_outlined),
                        title: const Text('Remove Friend'),
                        onTap: () {
                          Get.back();
                          _showRemoveFriendDialog(friend, socialController);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      onTap: () {
        // Navigate to friend detail screen (to be implemented)
      },
    );
  }
  
  /// Show dialog to confirm friend removal
  void _showRemoveFriendDialog(Friend friend, SocialController socialController) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove Friend'),
        content: Text('Are you sure you want to remove ${friend.name} from your friends?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              socialController.removeFriend(friend.id);
              Get.back();
              Get.snackbar(
                'Friend Removed',
                '${friend.name} has been removed from your friends',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
  
  /// Build the requests tab content
  Widget _buildRequestsTab(ThemeData theme, SocialController socialController) {
    return Obx(() {
      final requests = socialController.friendRequests;
      
      if (requests.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_add_disabled,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No friend requests',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'When someone sends you a friend request or you send one, it will appear here',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return _buildRequestItem(theme, request, socialController);
        },
      );
    });
  }
  
  /// Build a friend request item
  Widget _buildRequestItem(ThemeData theme, Friend request, SocialController socialController) {
    final isReceived = request.status == FriendStatus.received;
    
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: request.profilePicture != null
            ? NetworkImage(request.profilePicture!)
            : null,
        child: request.profilePicture == null
            ? Icon(Icons.person, color: theme.colorScheme.onPrimary)
            : null,
      ),
      title: Text(request.name),
      subtitle: Text(
        isReceived ? 'Sent you a friend request' : 'Request sent',
      ),
      trailing: isReceived
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => socialController.rejectFriendRequest(request.id),
                  child: const Text('Decline'),
                ),
                ElevatedButton(
                  onPressed: () => socialController.acceptFriendRequest(request.id),
                  child: const Text('Accept'),
                ),
              ],
            )
          : OutlinedButton(
              onPressed: () => socialController.rejectFriendRequest(request.id),
              child: const Text('Cancel'),
            ),
    );
  }
  
  /// Build the find friends tab content
  Widget _buildFindTab(ThemeData theme, SocialController socialController) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search input
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by name or email',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onChanged: (value) {
              // Delay search for better UX
              custom_debounce.debounce.run(() {
                socialController.searchUsers(value);
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Search results
          Expanded(
            child: Obx(() {
              final results = socialController.searchResults;
              final isSearching = socialController.isSearching.value;
              final query = socialController.searchQuery.value;
              
              if (isSearching) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (query.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Search for friends',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          'Find people by name or email to add as friends',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              if (results.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_search,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No results found',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          'Try a different search term or invite your friends to join',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final user = results[index];
                  final bool requestSent = user.status == FriendStatus.pending;
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.profilePicture != null
                          ? NetworkImage(user.profilePicture!)
                          : null,
                      child: user.profilePicture == null
                          ? Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: requestSent
                        ? TextButton(
                            onPressed: null,
                            child: Text('Pending'),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              socialController.sendFriendRequest(user.id);
                            },
                            child: Text('Add'),
                          ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
