import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/challenges_controller.dart';

/// Screen for displaying challenges
class ChallengesScreen extends StatelessWidget {
  /// Create a new challenges screen
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('DEBUG: ChallengesScreen build method called');
    
    ChallengesController? controller;
    
    try {
      // Try to find the controller
      if (Get.isRegistered<ChallengesController>()) {
        controller = Get.find<ChallengesController>();
        print('DEBUG: Found ChallengesController: ${controller != null}');
      } else {
        // Create controller if it doesn't exist
        print('DEBUG: ChallengesController not registered, creating now');
        controller = Get.put(ChallengesController(), permanent: true);
        print('DEBUG: Created new ChallengesController');
      }
      
      if (controller == null) {
        throw Exception('Could not find or create ChallengesController');
      }
      
      // Force refresh the challenges to ensure we only see transportation and energy ones
      controller.resetChallenges();
      
      final theme = Theme.of(context);
      
      return Scaffold(
        appBar: AppBar(
          title: const Text('Challenges'),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Daily challenge card
              _buildDailyChallengeCard(context, controller),
              
              const SizedBox(height: 24),
              
              // Active challenges
              Text(
                'Active Challenges',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => controller!.activeChallenges.isEmpty
                  ? _buildEmptyState('No active challenges', 'Try getting a new challenge')
                  : Column(
                      children: controller!.activeChallenges
                          .map((challenge) => _buildChallengeCard(context, challenge, controller!))
                          .toList(),
                    )),
              
              const SizedBox(height: 16),
              
              // Get new challenge button
              Center(
                child: ElevatedButton.icon(
                  onPressed: controller!.getNewChallenge,
                  icon: const Icon(Icons.add),
                  label: const Text('Get New Challenge'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Completed challenges
              Text(
                'Completed Challenges',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => controller!.completedChallenges.isEmpty
                  ? _buildEmptyState('No completed challenges yet', 'Complete challenges to see them here')
                  : Column(
                      children: controller!.completedChallenges
                          .map((challenge) => _buildCompletedChallengeCard(context, challenge))
                          .toList(),
                    )),
            ],
          ),
        ),
      );
    } catch (e) {
      print('DEBUG: Error in ChallengesScreen build: $e');
      print('DEBUG: Stack trace: ${StackTrace.current}');
      
      return Scaffold(
        appBar: AppBar(
          title: const Text('Challenges'),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading challenges',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Try to re-create the controller
                  try {
                    ChallengesController.getInstance();
                    Get.forceAppUpdate();
                  } catch (e) {
                    print('DEBUG: Error re-creating controller: $e');
                  }
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
  }
  
  Widget _buildDailyChallengeCard(BuildContext context, ChallengesController? controller) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Challenge',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Today',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Challenge content
          // try {
            Obx(() {
              if (controller!.dailyChallenge.value.isEmpty) {
                return _buildEmptyState(
                  'No daily challenge yet',
                  'Get a new challenge to start',
                );
              }
              
              try {
                final challenge = controller!.dailyChallenge.value;
                final bool isCarFreeChallenge = challenge['id']?.toString().contains('car-free') ?? false;
                final color = isCarFreeChallenge ? Colors.green.shade700 : (challenge['color'] as Color? ?? AppColors.primary);
                
                return Column(
                  children: [
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isCarFreeChallenge ? Icons.no_crash : (challenge['icon'] as IconData? ?? Icons.emoji_events),
                              color: color,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Title and description
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  challenge['title'] as String? ?? 'Challenge',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  challenge['description'] as String? ?? '',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.eco,
                                      size: 16,
                                      color: Colors.green[700],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${challenge['carbonSaved']} kg CO₂ saved',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isCarFreeChallenge) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 14,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'High Impact',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber[800],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Complete button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Obx(() => ElevatedButton(
                        onPressed: controller!.isDailyCompleted.value
                            ? null
                            : () => controller!.completeChallenge(challenge),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(double.infinity, 48),
                          disabledBackgroundColor: Colors.grey[300],
                          disabledForegroundColor: Colors.grey[600],
                        ),
                        child: Text(
                          controller!.isDailyCompleted.value ? 'Completed' : 'Complete Challenge',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )),
                    ),
                  ],
                );
              } catch (e) {
                return _buildEmptyState(
                  'Error loading daily challenge',
                  'Please try again later',
                );
              }
            }),
          // } catch (e) {
          //   return _buildEmptyState(
          //     'Error loading daily challenge',
          //     'Please try again later',
          //   );
          // }
        ],
      ),
    );
  }
  
  Widget _buildChallengeCard(BuildContext context, Map<String, dynamic> challenge, ChallengesController? controller) {
    final theme = Theme.of(context);
    final color = challenge['color'] as Color? ?? AppColors.primary;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  challenge['icon'] as IconData? ?? Icons.emoji_events,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  challenge['category'] as String? ?? 'Challenge',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${challenge['points']} pts',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge['title'] as String? ?? 'Challenge',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        challenge['description'] as String? ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => controller!.completeChallenge(challenge),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: const Size(90, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Complete'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompletedChallengeCard(BuildContext context, Map<String, dynamic> challenge) {
    final theme = Theme.of(context);
    final color = Colors.grey;
    final completedDate = challenge['completedAt'] as DateTime?;
    final dateStr = completedDate != null ? DateFormat('MMM dd, yyyy').format(completedDate) : 'Completed';
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.task_alt,
            color: Colors.green[700],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge['title'] as String? ?? 'Challenge',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+${challenge['points']} pts',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(
            Icons.info_outline,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
