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
                
                // const SizedBox(height: 12),
                
                // // Time period selector
                // Row(
                //   children: [
                //     Expanded(
                //       child: Obx(() {
                //         return SegmentedButton<LeaderboardPeriod>(
                //           segments: const [
                //             ButtonSegment<LeaderboardPeriod>(
                //               value: LeaderboardPeriod.daily,
                //               label: Text('Daily'),
                //             ),
                //             ButtonSegment<LeaderboardPeriod>(
                //               value: LeaderboardPeriod.weekly,
                //               label: Text('Weekly'),
                //             ),
                //             ButtonSegment<LeaderboardPeriod>(
                //               value: LeaderboardPeriod.monthly,
                //               label: Text('Monthly'),
                //             ),
                //             ButtonSegment<LeaderboardPeriod>(
                //               value: LeaderboardPeriod.allTime,
                //               label: Text('All Time'),
                //             ),
                //           ],
                //           selected: {socialController.leaderboardPeriod.value},
                //           onSelectionChanged: (Set<LeaderboardPeriod> newSelection) {
                //             socialController.changeLeaderboardPeriod(newSelection.first);
                //           },
                //           showSelectedIcon: false,
                //         );
                //       }),
                //     ),
                //   ],
                // ),
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
                        _buildLeaderboardEntry(currentUserEntry, theme),
                      ],
                    );
                  }
                  
                  // Show regular entries (top 5)
                  if (index < entries.length) {
                    return _buildLeaderboardEntry(entries[index], theme);
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
  Widget _buildLeaderboardEntry(LeaderboardEntry entry, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: entry.isCurrentUser 
            ? theme.colorScheme.primaryContainer.withOpacity(0.5)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: entry.isCurrentUser
            ? Border.all(color: theme.colorScheme.primary, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                // Rank indicator instead of avatar
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: entry.rank <= 3 
                        ? _getMedalColor(entry.rank, theme).withOpacity(0.2)
                        : theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${entry.rank}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: entry.rank <= 3 
                            ? _getMedalColor(entry.rank, theme)
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ),
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
                if (entry.rank <= 3)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.emoji_events,
                      color: _getMedalColor(entry.rank, theme),
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
          
          // Emissions
          Expanded(
            flex: 2,
            child: Text(
              '${entry.emissions.toStringAsFixed(1)} lbs',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
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
                  '1 day',
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
  
  /// Returns the appropriate medal color based on rank
  Color _getMedalColor(int rank, ThemeData theme) {
    switch (rank) {
      case 1:
        return Colors.amber; // Gold
      case 2:
        return Colors.grey.shade400; // Silver
      case 3:
        return Colors.brown.shade300; // Bronze
      default:
        return theme.colorScheme.primary;
    }
  }
}
