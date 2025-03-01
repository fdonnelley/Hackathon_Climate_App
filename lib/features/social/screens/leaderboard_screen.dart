import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../controllers/social_controller.dart';
import '../models/leaderboard_entry_model.dart';

/// Screen for displaying the leaderboard
class LeaderboardScreen extends StatelessWidget {
  /// Route name for the leaderboard screen
  static String get routeName => AppRoutes.getRouteName(AppRoute.leaderboard);
  
  /// Creates a leaderboard screen
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Initialize controller if not already registered
    if (!Get.isRegistered<SocialController>()) {
      Get.put(SocialController());
    }
    final socialController = Get.find<SocialController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () {
              Get.toNamed(AppRoutes.getRouteName(AppRoute.friends));
            },
            tooltip: 'Manage Friends',
          ),
        ],
      ),
      body: Column(
        children: [
          // Leaderboard filters
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                // Global/Friends toggle
                Row(
                  children: [
                    Expanded(
                      child: Obx(() {
                        return SegmentedButton<LeaderboardFilter>(
                          segments: const [
                            ButtonSegment<LeaderboardFilter>(
                              value: LeaderboardFilter.global,
                              label: Text('Global'),
                              icon: Icon(Icons.public),
                            ),
                            ButtonSegment<LeaderboardFilter>(
                              value: LeaderboardFilter.friends,
                              label: Text('Friends'),
                              icon: Icon(Icons.people),
                            ),
                          ],
                          selected: {socialController.leaderboardFilter.value},
                          onSelectionChanged: (Set<LeaderboardFilter> newSelection) {
                            socialController.changeLeaderboardFilter(newSelection.first);
                          },
                        );
                      }),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Time period selector
                Row(
                  children: [
                    Expanded(
                      child: Obx(() {
                        return SegmentedButton<LeaderboardPeriod>(
                          segments: const [
                            ButtonSegment<LeaderboardPeriod>(
                              value: LeaderboardPeriod.daily,
                              label: Text('Daily'),
                            ),
                            ButtonSegment<LeaderboardPeriod>(
                              value: LeaderboardPeriod.weekly,
                              label: Text('Weekly'),
                            ),
                            ButtonSegment<LeaderboardPeriod>(
                              value: LeaderboardPeriod.monthly,
                              label: Text('Monthly'),
                            ),
                            ButtonSegment<LeaderboardPeriod>(
                              value: LeaderboardPeriod.allTime,
                              label: Text('All Time'),
                            ),
                          ],
                          selected: {socialController.leaderboardPeriod.value},
                          onSelectionChanged: (Set<LeaderboardPeriod> newSelection) {
                            socialController.changeLeaderboardPeriod(newSelection.first);
                          },
                          showSelectedIcon: false,
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Leaderboard header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                const SizedBox(width: 32),
                Expanded(
                  flex: 3,
                  child: Text(
                    'User',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Emissions',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Streak',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          
          // Leaderboard entries
          Expanded(
            child: Obx(() {
              final entries = socialController.leaderboardEntries;
              final currentUserEntry = entries.firstWhereOrNull((entry) => entry.isCurrentUser);
              
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: entries.length + (currentUserEntry != null ? 1 : 0),
                itemBuilder: (context, index) {
                  // If we have a current user entry and it's not in the top entries,
                  // add a divider and show it at the bottom
                  if (currentUserEntry != null && 
                      !entries.take(5).contains(currentUserEntry) && 
                      index == 5) {
                    return Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(),
                        ),
                        _buildLeaderboardEntry(context, currentUserEntry),
                      ],
                    );
                  }
                  
                  // Show regular entries (top 5)
                  if (index < entries.length) {
                    return _buildLeaderboardEntry(context, entries[index]);
                  }
                  
                  return null;
                },
              );
            }),
          ),
        ],
      ),
    );
  }
  
  /// Build a single leaderboard entry widget
  Widget _buildLeaderboardEntry(BuildContext context, LeaderboardEntry entry) {
    final theme = Theme.of(context);
    final backgroundColor = entry.isCurrentUser
        ? theme.colorScheme.primary.withOpacity(0.1)
        : Colors.transparent;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 32,
            child: Text(
              '#${entry.rank}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: entry.rank <= 3 
                    ? _getMedalColor(entry.rank, theme)
                    : theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // User info
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: entry.profilePicture != null
                      ? NetworkImage(entry.profilePicture!)
                      : null,
                  child: entry.profilePicture == null
                      ? Icon(Icons.person, color: theme.colorScheme.onPrimary)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: entry.isCurrentUser ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // Carbon emissions
          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${entry.emissions.toStringAsFixed(1)} kg',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_down,
                      color: AppColors.success,
                      size: 16,
                    ),
                    Text(
                      ' ${entry.reductionPercentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Streak
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${entry.streak} days',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
        ],
      ),
    );
  }
  
  /// Get the medal color based on rank
  Color _getMedalColor(int rank, ThemeData theme) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown.shade300;
      default:
        return theme.colorScheme.onSurface;
    }
  }
}
