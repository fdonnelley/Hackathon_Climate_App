import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:math';

/// Controller for challenges feature
class ChallengesController extends GetxController {
  static bool _debugInstanceCreated = false;

  /// The current daily challenge
  final Rx<Map<String, dynamic>> dailyChallenge = Rx<Map<String, dynamic>>({});
  
  /// Whether the daily challenge is completed
  final RxBool isDailyCompleted = false.obs;
  
  /// List of challenge categories
  final List<String> challengeCategories = [
    'Transportation',
    'Energy',
  ];
  
  /// Current active challenges
  final RxList<Map<String, dynamic>> activeChallenges = <Map<String, dynamic>>[].obs;
  
  /// Completed challenges
  final RxList<Map<String, dynamic>> completedChallenges = <Map<String, dynamic>>[].obs;
  
  /// Available pool of challenges
  final List<Map<String, dynamic>> allChallenges = [
    {
      'id': 'car-free-1',
      'title': 'Car-Free Day',
      'description': 'Go an entire day without using a car - try walking, biking, or public transit',
      'category': 'Transportation',
      'points': 100,
      'carbonSaved': 6.5,
      'difficulty': 'Medium',
      'icon': Icons.no_crash,
      'color': Colors.green,
    },
    {
      'id': 'walk-1',
      'title': 'Take a Walk',
      'description': 'Walk instead of driving for a short trip today',
      'category': 'Transportation',
      'points': 50,
      'carbonSaved': 2.5,
      'difficulty': 'Easy',
      'icon': Icons.directions_walk,
      'color': Colors.green,
    },
    {
      'id': 'energy-1',
      'title': 'Turn Down the Heat',
      'description': 'Lower your thermostat by 2 degrees for a day',
      'category': 'Energy',
      'points': 30,
      'carbonSaved': 1.8,
      'difficulty': 'Easy',
      'icon': Icons.thermostat,
      'color': Colors.orange,
    },
    {
      'id': 'bike-1',
      'title': 'Bike to Work/School',
      'description': 'Use a bike instead of a car for commuting today',
      'category': 'Transportation',
      'points': 80,
      'carbonSaved': 5.0,
      'difficulty': 'Medium',
      'icon': Icons.pedal_bike,
      'color': Colors.green,
    },
    {
      'id': 'energy-2',
      'title': 'Air Dry Laundry',
      'description': 'Skip the dryer and hang-dry your clothes',
      'category': 'Energy',
      'points': 40,
      'carbonSaved': 2.0,
      'difficulty': 'Easy',
      'icon': Icons.dry_cleaning,
      'color': Colors.amber,
    },
    {
      'id': 'transit-1',
      'title': 'Use Public Transit',
      'description': 'Take a bus or train instead of driving',
      'category': 'Transportation',
      'points': 70,
      'carbonSaved': 4.0,
      'difficulty': 'Medium',
      'icon': Icons.directions_bus,
      'color': Colors.green,
    },
    {
      'id': 'energy-3',
      'title': 'LED Light Switch',
      'description': 'Replace one incandescent bulb with an LED bulb',
      'category': 'Energy',
      'points': 35,
      'carbonSaved': 1.5,
      'difficulty': 'Easy',
      'icon': Icons.lightbulb,
      'color': Colors.yellow,
    },
    {
      'id': 'carpool-1',
      'title': 'Carpool Day',
      'description': 'Share a ride with a friend or colleague instead of driving separately',
      'category': 'Transportation',
      'points': 60,
      'carbonSaved': 3.2,
      'difficulty': 'Medium',
      'icon': Icons.people,
      'color': Colors.blue,
    },
    {
      'id': 'energy-4',
      'title': 'Unplug Electronics',
      'description': 'Unplug unused electronics and chargers to reduce phantom energy use',
      'category': 'Energy',
      'points': 25,
      'carbonSaved': 0.8,
      'difficulty': 'Easy',
      'icon': Icons.power,
      'color': Colors.purple,
    },
    {
      'id': 'evs-1',
      'title': 'EV Test Drive',
      'description': 'Schedule a test drive of an electric vehicle to learn more about them',
      'category': 'Transportation',
      'points': 40,
      'carbonSaved': 0.5,
      'difficulty': 'Hard',
      'icon': Icons.electric_car,
      'color': Colors.teal,
    },
    {
      'id': 'energy-5',
      'title': 'Cold Water Wash',
      'description': 'Wash one load of laundry with cold water instead of hot',
      'category': 'Energy',
      'points': 30,
      'carbonSaved': 1.0,
      'difficulty': 'Easy',
      'icon': Icons.local_laundry_service,
      'color': Colors.indigo,
    },
  ];
  
  /// Constructor with debug logging
  ChallengesController() {
    print('DEBUG: ChallengesController constructor called');
    _debugInstanceCreated = true;
  }

  /// For debugging - check if controller exists
  static bool get debugInstanceExists => _debugInstanceCreated;

  /// Static method to get instance, creating it if needed
  static ChallengesController getInstance() {
    print('DEBUG: ChallengesController.getInstance called');
    
    if (Get.isRegistered<ChallengesController>()) {
      print('DEBUG: Returning existing ChallengesController instance');
      return Get.find<ChallengesController>();
    } else {
      print('DEBUG: Creating new permanent ChallengesController instance');
      return Get.put(ChallengesController(), permanent: true);
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Reset all challenges to ensure we only have transportation and energy ones
    resetChallenges();
  }

  /// Reset all challenges to start fresh
  void resetChallenges() {
    print('DEBUG: Resetting all challenges');
    // Clear existing challenges
    dailyChallenge.value = {};
    activeChallenges.clear();
    completedChallenges.clear();
    isDailyCompleted.value = false;
    
    try {
      // Force the car-free day challenge as the daily challenge
      Map<String, dynamic>? carFreeChallenge;
      
      try {
        carFreeChallenge = allChallenges.firstWhere((challenge) => challenge['id'] == 'car-free-1');
        print('DEBUG: Found car-free challenge successfully');
      } catch (e) {
        print('DEBUG: Could not find car-free challenge: $e');
        // Fallback - check if allChallenges has any transportation challenges
        final transportationChallenges = allChallenges.where(
          (challenge) => challenge['category'] == 'Transportation'
        ).toList();
        
        if (transportationChallenges.isNotEmpty) {
          print('DEBUG: Using fallback transportation challenge');
          carFreeChallenge = transportationChallenges.first;
        } else {
          // Last resort - use the first challenge in the list
          print('DEBUG: Using first available challenge as fallback');
          carFreeChallenge = allChallenges.isNotEmpty ? allChallenges.first : null;
        }
      }
      
      // Set the daily challenge
      if (carFreeChallenge != null) {
        dailyChallenge.value = {
          ...carFreeChallenge,
          'isDaily': true,
        };
        print('DEBUG: Set daily challenge to: ${dailyChallenge.value['title']}');
      } else {
        // Create a default challenge if all else fails
        print('DEBUG: Creating default car-free challenge');
        dailyChallenge.value = {
          'id': 'car-free-default',
          'title': 'Car-Free Day',
          'description': 'Go an entire day without using a car - try walking, biking, or public transit',
          'category': 'Transportation',
          'points': 100,
          'carbonSaved': 6.5,
          'difficulty': 'Medium',
          'icon': Icons.no_crash,
          'color': Colors.green,
          'isDaily': true,
        };
      }
    } catch (e) {
      print('DEBUG: Error in resetChallenges: $e');
      // Create a failsafe daily challenge
      _generateDailyChallenge();
    }
    
    // Load other sample challenges (skipping the daily one)
    _loadSampleActiveChallenges();
  }
  
  /// Generates a new daily challenge
  void _generateDailyChallenge() {
    final random = Random();
    final index = random.nextInt(allChallenges.length);
    dailyChallenge.value = {
      ...allChallenges[index],
      'isDaily': true,
    };
  }
  
  /// Load some sample active challenges
  void _loadSampleActiveChallenges() {
    // Add 2-3 random challenges as active
    final random = Random();
    final numChallenges = random.nextInt(2) + 2; // 2-3 challenges
    
    final List<int> selectedIndices = [];
    while (selectedIndices.length < numChallenges && selectedIndices.length < allChallenges.length) {
      final index = random.nextInt(allChallenges.length);
      if (!selectedIndices.contains(index) && 
          allChallenges[index]['id'] != dailyChallenge.value['id'] &&
          (allChallenges[index]['category'] == 'Transportation' || allChallenges[index]['category'] == 'Energy')) {
        selectedIndices.add(index);
        activeChallenges.add(allChallenges[index]);
      }
    }
  }
  
  /// Complete a challenge
  void completeChallenge(Map<String, dynamic> challenge) {
    // Check if it's the daily challenge
    if (challenge['isDaily'] == true) {
      isDailyCompleted.value = true;
      // Add points, etc.
      return;
    }
    
    // Otherwise it's a regular challenge
    final index = activeChallenges.indexWhere((c) => c['id'] == challenge['id']);
    if (index != -1) {
      final completedChallenge = {...activeChallenges[index], 'completedAt': DateTime.now()};
      activeChallenges.removeAt(index);
      completedChallenges.add(completedChallenge);
    }
  }
  
  /// Get a new challenge
  void getNewChallenge() {
    // Find challenges not in active or completed
    final availableChallenges = allChallenges.where((challenge) {
      final bool isActive = activeChallenges.any((c) => c['id'] == challenge['id']);
      final bool isCompleted = completedChallenges.any((c) => c['id'] == challenge['id']);
      final bool isDaily = challenge['id'] == dailyChallenge.value['id'];
      return !isActive && !isCompleted && !isDaily && (challenge['category'] == 'Transportation' || challenge['category'] == 'Energy');
    }).toList();
    
    if (availableChallenges.isNotEmpty) {
      final random = Random();
      final index = random.nextInt(availableChallenges.length);
      activeChallenges.add(availableChallenges[index]);
    }
  }
}
