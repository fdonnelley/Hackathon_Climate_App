import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/env_config.dart';
import '../services/chat_service.dart';
import '../services/groq_chat_service.dart';
import '../../home/controllers/home_controller.dart';
import '../../carbon_tracker/models/carbon_budget_model.dart';
import '../../carbon_tracker/models/trip_model.dart';
import '../../carbon_tracker/models/usage_category_model.dart';

/// Controller for chatbot functionality
class ChatbotController extends GetxController {
  /// Loading state
  final RxBool isLoading = false.obs;
  
  /// Chat messages
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  
  /// Current LLM provider - fixed to Groq
  final currentLlmProvider = 'Groq'.obs;
  
  /// Chat service
  ChatService? _chatService;
  
  /// Environment config for API keys
  final EnvConfig _envConfig = EnvConfig();
  
  /// Home controller for accessing carbon data
  late HomeController _homeController;
  
  /// Carbon context string
  final carbonContext = ''.obs;
  
  /// Public getter for the home controller
  HomeController get homeController => _homeController;
  
  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    
    // Load saved messages first
    _loadMessages();
    
    // Only add welcome message if no messages were loaded
    if (messages.isEmpty) {
      messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': 'Welcome to your Carbon Budget Tracker Assistant! I can help you understand your carbon emissions and offer personalized advice to reduce your footprint.',
        'isUser': false,
        'timestamp': DateTime.now(),
      });
    }
  }
  
  @override
  void onClose() {
    // Clean up service
    _chatService?.dispose();
    super.onClose();
  }
  
  /// Initialize required services
  Future<void> _initializeServices() async {
    try {
      // Get Home controller for carbon data
      if (!Get.isRegistered<HomeController>()) {
        Get.put(HomeController());
      }
      _homeController = Get.find<HomeController>();
      
      // Get Groq API key
      final groqApiKey = await _envConfig.groqApiKey;
      
      if (groqApiKey?.isEmpty ?? true) {
        debugPrint('Warning: Groq API key is not set');
        messages.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': 'Warning: Groq API key is not configured. Chatbot functionality may be limited.',
          'isUser': false,
          'timestamp': DateTime.now(),
        });
      }
      
      // Initialize Groq service
      _chatService = GroqChatService(
        apiKey: groqApiKey ?? '',
      );
      
      await _chatService?.initialize();
      
      // Generate carbon context
      updateCarbonContext();
      
    } catch (e) {
      debugPrint('Error initializing chatbot services: $e');
      messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': 'Error initializing chatbot: $e',
        'isUser': false,
        'timestamp': DateTime.now(),
      });
    }
  }
  
  /// Update carbon context string with latest user data
  void updateCarbonContext() {
    try {
      final dailyBudget = _homeController.dailyBudget.value;
      final dailyEmissions = _homeController.dailyEmissions.value;
      final dailyPercentage = (dailyEmissions / dailyBudget * 100).toStringAsFixed(1);
      
      final weeklyBudget = _homeController.weeklyBudget.value;
      final weeklyEmissions = _homeController.weeklyEmissions.value;
      final weeklyPercentage = (weeklyEmissions / weeklyBudget * 100).toStringAsFixed(1);
      
      final monthlyBudget = _homeController.monthlyBudget.value;
      final monthlyEmissions = _homeController.monthlyEmissions.value;
      final monthlyPercentage = (monthlyEmissions / monthlyBudget * 100).toStringAsFixed(1);
      
      // Calculate total miles traveled
      double totalMiles = 0;
      Map<String, double> milesByMode = {};
      
      // Get activities summary
      final activities = _homeController.recentActivities;
      String activitySummary = '';
      
      if (activities.isNotEmpty) {
        // Group by category and subcategory
        final Map<String, Map<String?, double>> categoryEmissions = {};
        
        for (final activity in activities) {
          final type = activity['type'] as String;
          final subType = activity['subType'] as String?;
          final emissions = activity['emissions'] as double;
          
          // Track miles for transportation
          if (type == 'transportation' && activity['miles'] != null) {
            final miles = (activity['miles'] as num).toDouble();
            totalMiles += miles;
            
            // Determine transport mode
            final String mode;
            if (activity['transportMode'] != null) {
              mode = activity['transportMode'] as String;
            } else if (activity['title'] != null) {
              mode = activity['title'] as String;
            } else {
              mode = 'Other';
            }
            
            milesByMode[mode] = (milesByMode[mode] ?? 0) + miles;
          }
          
          // Initialize category if not exists
          if (!categoryEmissions.containsKey(type)) {
            categoryEmissions[type] = {};
          }
          
          // Add emissions to the appropriate category/subcategory
          categoryEmissions[type]![subType] = 
              (categoryEmissions[type]![subType] ?? 0) + emissions;
        }
        
        // Convert to summary
        categoryEmissions.forEach((category, subCategories) {
          // For transportation, show total and miles
          if (category == 'transportation') {
            final total = subCategories.values.fold<double>(0, (sum, val) => sum + val);
            activitySummary += '$category: ${total.toStringAsFixed(1)} lbs CO2, ${totalMiles.toStringAsFixed(1)} miles, ';
          } 
          // For energy, break down by electricity/gas
          else if (category == 'energy') {
            // Total for the category
            final total = subCategories.values.fold<double>(0, (sum, val) => sum + val);
            activitySummary += '$category: ${total.toStringAsFixed(1)} lbs CO2 (';
            
            // Add subcategories
            subCategories.forEach((subType, emissions) {
              if (subType != null) {
                activitySummary += '$subType: ${emissions.toStringAsFixed(1)} lbs, ';
              } else {
                activitySummary += 'other: ${emissions.toStringAsFixed(1)} lbs, ';
              }
            });
            
            // Replace last comma with closing parenthesis
            if (activitySummary.endsWith(', ')) {
              activitySummary = activitySummary.substring(0, activitySummary.length - 2) + '), ';
            } else {
              activitySummary += '), ';
            }
          }
          // Any other categories
          else {
            final total = subCategories.values.fold<double>(0, (sum, val) => sum + val);
            activitySummary += '$category: ${total.toStringAsFixed(1)} lbs CO2, ';
          }
        });
        
        // Remove trailing comma
        if (activitySummary.isNotEmpty) {
          activitySummary = activitySummary.substring(0, activitySummary.length - 2);
        }
      }
      
      // Format miles by mode
      String milesSummary = '';
      if (milesByMode.isNotEmpty) {
        milesByMode.forEach((mode, miles) {
          milesSummary += '$mode: ${miles.toStringAsFixed(1)} miles, ';
        });
        
        // Remove trailing comma
        if (milesSummary.isNotEmpty) {
          milesSummary = milesSummary.substring(0, milesSummary.length - 2);
        }
      }
      
      // Build context
      carbonContext.value = '''
Carbon budget status:
- Daily: ${dailyEmissions.toStringAsFixed(1)} lbs / ${dailyBudget.toStringAsFixed(1)} lbs ($dailyPercentage%)
- Weekly: ${weeklyEmissions.toStringAsFixed(1)} lbs / ${weeklyBudget.toStringAsFixed(1)} lbs ($weeklyPercentage%)
- Monthly: ${monthlyEmissions.toStringAsFixed(1)} lbs / ${monthlyBudget.toStringAsFixed(1)} lbs ($monthlyPercentage%)

Recent activity emissions by category: $activitySummary

Total distance traveled: ${totalMiles.toStringAsFixed(1)} miles
Distance by mode: $milesSummary

User carbon trend: ${_getCarbonTrend()}
      ''';
      
    } catch (e) {
      debugPrint('Error updating carbon context: $e');
      carbonContext.value = 'Error retrieving carbon data: $e';
    }
  }
  
  /// Get trend description based on emissions data
  String _getCarbonTrend() {
    try {
      final dailyBudget = _homeController.dailyBudget.value;
      final dailyEmissions = _homeController.dailyEmissions.value;
      final dailyPercentage = dailyEmissions / dailyBudget * 100;
      
      if (dailyPercentage < 50) {
        return 'Excellent progress! Well below budget';
      } else if (dailyPercentage < 75) {
        return 'Good progress, on track to meet goals';
      } else if (dailyPercentage < 90) {
        return 'Close to budget limit, minor adjustments needed';
      } else if (dailyPercentage < 100) {
        return 'Almost at budget limit, consider reducing emissions';
      } else {
        return 'Exceeding budget, immediate action recommended';
      }
    } catch (e) {
      return 'Unable to determine trend';
    }
  }
  
  /// Clear all chat messages and add a welcome message
  void clearChat() {
    messages.clear();
    messages.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': 'Welcome to your Carbon Budget Tracker Assistant! I can help you understand your carbon emissions and offer personalized advice to reduce your footprint.',
      'isUser': false,
      'timestamp': DateTime.now(),
    });
    
    // Update carbon context
    updateCarbonContext();
  }
  
  /// Send a message to the chatbot
  void sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final userMessage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': message,
      'isUser': true,
      'timestamp': DateTime.now(),
    };

    messages.add(userMessage);
    update();

    // Add a loading message
    final loadingId = DateTime.now().millisecondsSinceEpoch.toString();
    final loadingMessage = {
      'id': loadingId,
      'text': 'Thinking...',
      'isUser': false,
      'timestamp': DateTime.now(),
      'isLoading': true,
    };

    messages.add(loadingMessage);
    update();

    try {
      String response = '';
      
      // Check if this is a request for improvement suggestions
      final lowerMessage = message.toLowerCase();
      final isAskingForImprovements = 
          lowerMessage.contains('how can i improve') || 
          lowerMessage.contains('how to improve') ||
          lowerMessage.contains('reduce my footprint') ||
          lowerMessage.contains('reduce my carbon') ||
          lowerMessage.contains('suggestions') ||
          lowerMessage.contains('tips') ||
          (lowerMessage.contains('help') && lowerMessage.contains('better')) ||
          (lowerMessage.contains('what') && lowerMessage.contains('change'));
      
      if (isAskingForImprovements) {
        // Provide personalized recommendations
        response = getPersonalizedRecommendations();
      } else {
        // Use LLM for general responses
        response = await _generateBotResponse(message);
      }

      // Replace the loading message with the actual response
      messages.removeWhere((msg) => msg['id'] == loadingId);
      
      final botMessage = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': response,
        'isUser': false,
        'timestamp': DateTime.now(),
      };

      messages.add(botMessage);
      update();
      
      // Save the conversation
      _saveMessages();
    } catch (e) {
      debugPrint('Error generating response: $e');
      
      // Replace loading with error
      messages.removeWhere((msg) => msg['id'] == loadingId);
      
      final errorMessage = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': 'Sorry, I encountered an error. Please try again later.',
        'isUser': false,
        'timestamp': DateTime.now(),
      };

      messages.add(errorMessage);
      update();
    }
  }
  
  /// Get personalized recommendations based on user's carbon usage patterns
  String getPersonalizedRecommendations() {
    try {
      // Get major emission categories and their totals
      final categoryEmissions = _getCategoryEmissionsBreakdown();
      
      if (categoryEmissions.isEmpty) {
        return "I don't have enough data about your carbon usage yet. Try adding some activities first!";
      }
      
      // Find the category with the highest emissions
      String highestCategory = '';
      double highestEmissions = 0;
      
      categoryEmissions.forEach((category, emissions) {
        if (emissions > highestEmissions) {
          highestCategory = category;
          highestEmissions = emissions;
        }
      });
      
      // Calculate percentage of total for the highest category
      final totalEmissions = categoryEmissions.values.fold<double>(0, (sum, val) => sum + val);
      final highestPercentage = (highestEmissions / totalEmissions * 100).toStringAsFixed(0);
      
      // Build recommendations based on highest category
      final buffer = StringBuffer();
      buffer.writeln("Based on your usage patterns, ${highestPercentage}% of your carbon footprint comes from $highestCategory.");
      
      // Create category-specific recommendations
      if (highestCategory.toLowerCase().contains('transport')) {
        final transportRecommendations = _getTransportationRecommendations();
        buffer.write(transportRecommendations);
      } 
      else if (highestCategory.toLowerCase().contains('electric')) {
        final electricityRecommendations = _getElectricityRecommendations();
        buffer.write(electricityRecommendations);
      }
      else if (highestCategory.toLowerCase().contains('gas') || 
               highestCategory.toLowerCase().contains('heat')) {
        final gasRecommendations = _getGasHeatingRecommendations();
        buffer.write(gasRecommendations);
      }
      else if (highestCategory.toLowerCase().contains('food')) {
        final foodRecommendations = _getFoodRecommendations();
        buffer.write(foodRecommendations);
      }
      else {
        // Generic recommendations
        buffer.write("Consider tracking more specific activities to get personalized recommendations.");
      }
      
      return buffer.toString();
    } catch (e) {
      debugPrint('Error generating personalized recommendations: $e');
      return "I couldn't analyze your usage patterns right now. Please try again later.";
    }
  }
  
  /// Get transportation-specific recommendations
  String _getTransportationRecommendations() {
    final milesByMode = _getMilesByMode();
    double totalMiles = milesByMode.values.fold<double>(0, (sum, val) => sum + val);
    
    // Check if user has car usage
    bool hasCar = false;
    double carMiles = 0;
    milesByMode.forEach((mode, miles) {
      if (mode.toLowerCase().contains('car')) {
        hasCar = true;
        carMiles += miles;
      }
    });
    
    final buffer = StringBuffer();
    
    if (hasCar && carMiles / totalMiles > 0.5) {
      // Heavy car usage
      buffer.writeln("\n\nRecommendations to reduce your transportation emissions:");
      buffer.writeln("1. Consider walking or biking for trips under 2 miles");
      buffer.writeln("2. Use public transportation when available");
      buffer.writeln("3. Organize carpools for commuting");
      buffer.writeln("4. Combine multiple errands into a single trip");
      buffer.writeln("5. Research electric or hybrid vehicle options for your next car purchase");
    } else if (milesByMode.containsKey('Air Travel') && 
               milesByMode['Air Travel']! / totalMiles > 0.3) {
      // Significant air travel
      buffer.writeln("\n\nRecommendations to reduce your air travel emissions:");
      buffer.writeln("1. Consider video conferencing instead of business travel when possible");
      buffer.writeln("2. Take direct flights rather than connecting flights");
      buffer.writeln("3. Consider train travel for shorter trips");
      buffer.writeln("4. Offset your flight emissions through verified carbon offset programs");
    } else {
      // General transportation recommendations
      buffer.writeln("\n\nGeneral transportation recommendations:");
      buffer.writeln("1. Increase your use of zero-emission transportation (walking, biking)");
      buffer.writeln("2. Consider public transit for longer trips");
      buffer.writeln("3. Maintain your vehicles properly for optimal fuel efficiency");
      buffer.writeln("4. Plan routes efficiently to minimize distance traveled");
    }
    
    return buffer.toString();
  }
  
  /// Get electricity-specific recommendations
  String _getElectricityRecommendations() {
    return '''

Recommendations to reduce your electricity emissions:
1. Switch to LED light bulbs throughout your home
2. Unplug devices or use smart power strips to eliminate phantom power usage
3. Adjust your thermostat by a few degrees (higher in summer, lower in winter)
4. Upgrade to ENERGY STAR certified appliances when replacements are needed
5. Consider renewable energy options like rooftop solar or green power plans
6. Wash clothes in cold water and air dry when possible
7. Run dishwashers and washing machines only when full
''';
  }
  
  /// Get gas/heating-specific recommendations
  String _getGasHeatingRecommendations() {
    return '''

Recommendations to reduce your heating emissions:
1. Improve insulation in your walls, attic, and around doors/windows
2. Lower your thermostat setting in winter and use extra blankets
3. Service your heating system regularly for maximum efficiency
4. Use a programmable thermostat to reduce heating when away or sleeping
5. Consider upgrading to a high-efficiency heating system
6. Take shorter, cooler showers to reduce hot water usage
7. Install low-flow showerheads to reduce hot water consumption
''';
  }
  
  /// Get food-specific recommendations
  String _getFoodRecommendations() {
    return '''

Recommendations to reduce your food-related emissions:
1. Incorporate more plant-based meals into your diet
2. Reduce food waste by planning meals and properly storing leftovers
3. Buy local, seasonal produce when possible to reduce transportation emissions
4. Compost food scraps rather than sending them to landfill
5. Choose foods with minimal packaging
6. Grow some of your own herbs or vegetables if space allows
''';
  }
  
  /// Get breakdown of emissions by major category
  Map<String, double> _getCategoryEmissionsBreakdown() {
    final Map<String, double> categoryEmissions = {};
    
    // Process activities to group by major category
    for (final activity in _homeController.recentActivities) {
      final type = activity['type'] as String;
      final subType = activity['subType'] as String?;
      final emissions = activity['emissions'] as double;
      
      // Determine major category
      String category = type;
      
      // For energy, use subtypes
      if (type == 'energy' && subType != null) {
        category = subType;
      }
      
      // Add emissions to category
      categoryEmissions[category] = (categoryEmissions[category] ?? 0) + emissions;
    }
    
    return categoryEmissions;
  }
  
  Future<String> _generateBotResponse(String message) async {
    try {
      // Make sure carbon context is up to date
      updateCarbonContext();
      
      // Get the system prompt with user's carbon data
      final personalizedSystemPrompt = _getSystemPrompt();
      
      // Generate response using the selected LLM (Groq)
      final response = await _chatService?.generateResponse(
        message,
        messages.toList(),
        systemPrompt: personalizedSystemPrompt,
      );
      
      if (response != null) {
        return response;
      } else {
        return 'Sorry, I was unable to generate a response. Please try again.';
      }
    } catch (e) {
      debugPrint('Error generating response: $e');
      return 'Sorry, an error occurred: $e';
    }
  }
  
  /// Get recent activities formatted as text for the system prompt
  String _getRecentActivitiesText() {
    if (_homeController.recentActivities.isEmpty) {
      return "No recent activities recorded.";
    }
    
    final Map<String, Map<String?, List<Map<String, dynamic>>>> categorizedActivities = {};
    
    // Group activities by category and subcategory
    for (final activity in _homeController.recentActivities) {
      final type = activity['type'] as String;
      final subType = activity['subType'] as String?;
      
      // Initialize category if not exists
      if (!categorizedActivities.containsKey(type)) {
        categorizedActivities[type] = {};
      }
      
      // Initialize subcategory if not exists
      if (!categorizedActivities[type]!.containsKey(subType)) {
        categorizedActivities[type]![subType] = [];
      }
      
      // Add activity to the appropriate category/subcategory
      categorizedActivities[type]![subType]!.add(activity);
    }
    
    final buffer = StringBuffer();
    
    // Transportation activities
    if (categorizedActivities.containsKey('transportation')) {
      buffer.writeln("Transportation Activities:");
      final transportActivities = categorizedActivities['transportation']?[null] ?? [];
      for (final activity in transportActivities) {
        String mileageInfo = "";
        if (activity.containsKey('miles')) {
          mileageInfo = " (${(activity['miles'] as num).toStringAsFixed(1)} miles)";
        }
        buffer.writeln("- ${activity['title']}$mileageInfo: ${activity['emissions']} lbs CO2");
      }
      buffer.writeln();
    }
    
    // Energy activities (electricity + gas)
    if (categorizedActivities.containsKey('energy')) {
      buffer.writeln("Energy Usage:");
      
      // Electricity
      if (categorizedActivities['energy']!.containsKey('electricity')) {
        buffer.writeln("  Electricity:");
        for (final activity in categorizedActivities['energy']!['electricity']!) {
          String billInfo = "";
          if (activity.containsKey('billAmount')) {
            billInfo = " (${(activity['billAmount'] as num).toStringAsFixed(0)} bill)";
          }
          buffer.writeln("  - ${activity['title']}$billInfo: ${activity['emissions']} lbs CO2");
        }
      }
      
      // Gas
      if (categorizedActivities['energy']!.containsKey('gas')) {
        buffer.writeln("  Gas:");
        for (final activity in categorizedActivities['energy']!['gas']!) {
          String billInfo = "";
          if (activity.containsKey('billAmount')) {
            billInfo = " (${(activity['billAmount'] as num).toStringAsFixed(0)} bill)";
          }
          buffer.writeln("  - ${activity['title']}$billInfo: ${activity['emissions']} lbs CO2");
        }
      }
      
      // Other energy
      if (categorizedActivities['energy']!.containsKey(null)) {
        buffer.writeln("  Other Energy:");
        for (final activity in categorizedActivities['energy']![null]!) {
          buffer.writeln("  - ${activity['title']}: ${activity['emissions']} lbs CO2");
        }
      }
      
      buffer.writeln();
    }
    
    // Any other categories
    categorizedActivities.forEach((category, subcategories) {
      if (category != 'transportation' && category != 'energy') {
        buffer.writeln("$category Activities:");
        subcategories.forEach((subcategory, activities) {
          for (final activity in activities) {
            buffer.writeln("- ${activity['title']}: ${activity['emissions']} lbs CO2");
          }
        });
        buffer.writeln();
      }
    });
    
    // Add carbon budget information
    buffer.writeln("Carbon Budget Goals:");
    buffer.writeln("- Daily: ${_homeController.dailyBudget.value.toStringAsFixed(1)} lbs");
    buffer.writeln("- Weekly: ${_homeController.weeklyBudget.value.toStringAsFixed(1)} lbs");
    buffer.writeln("- Monthly: ${_homeController.monthlyBudget.value.toStringAsFixed(1)} lbs");
    
    return buffer.toString();
  }

  String _getTransportationDataText() {
    final milesByMode = _getMilesByMode();
    final buffer = StringBuffer();
    milesByMode.forEach((mode, miles) {
      buffer.writeln("$mode: ${miles.toStringAsFixed(1)} miles");
    });
    return buffer.toString();
  }

  Map<String, double> _getMilesByMode() {
    final milesByMode = <String, double>{};
    final activities = _homeController.recentActivities;
    for (final activity in activities) {
      if (activity['type'] == 'transportation' && activity['miles'] != null) {
        final miles = (activity['miles'] as num).toDouble();
        final mode = activity['transportMode'] as String?;
        if (mode != null) {
          milesByMode[mode] = (milesByMode[mode] ?? 0) + miles;
        } else {
          milesByMode['Other'] = (milesByMode['Other'] ?? 0) + miles;
        }
      }
    }
    return milesByMode;
  }

  String _getSystemPrompt() {
    final personalizedSystemPrompt = '''
You're a carbon advisor for the Carbon Budget Tracker app. Give VERY CONCISE advice using 1-3 sentences maximum unless the user specifically asks for detailed information.

USER DATA (reference briefly when relevant):
- Daily: ${_homeController.dailyEmissions.value} lbs (${(_homeController.dailyEmissions.value / _homeController.dailyBudget.value * 100).toStringAsFixed(0)}% of budget)
- Weekly: ${_homeController.weeklyEmissions.value} lbs (${(_homeController.weeklyEmissions.value / _homeController.weeklyBudget.value * 100).toStringAsFixed(0)}% of budget)
- Monthly: ${_homeController.monthlyEmissions.value} lbs (${(_homeController.monthlyEmissions.value / _homeController.monthlyBudget.value * 100).toStringAsFixed(0)}% of budget)

TRANSPORTATION DATA:
${_getTransportationDataText()}

RECENT ACTIVITIES:
${_getRecentActivitiesText().replaceAll('\n', ' ')}

USAGE CATEGORIES:
The app tracks three main types of carbon usage:
1. Transportation (car trips, flights, public transit, etc.)
2. Energy - Electricity (home appliances, lighting, etc.)
3. Energy - Gas (heating, cooking, etc.)

When the user wants to add usage, guide them to specify one of these three categories.

KEY REQUIREMENTS:
1. Be extremely brief (1-3 sentences)
2. Focus on one actionable suggestion at a time
3. Only provide detailed information if explicitly requested
4. Use simple, direct language
5. Provide personalized recommendations based on user's highest emission categories.
''';
    return personalizedSystemPrompt;
  }
  
  /// Save messages to local storage
  void _saveMessages() {
    try {
      // Convert messages to a format that can be stored
      final List<Map<String, dynamic>> serializableMessages = messages.map((message) {
        return {
          'id': message['id'],
          'text': message['text'],
          'isUser': message['isUser'],
          'timestamp': (message['timestamp'] as DateTime).toIso8601String(),
        };
      }).toList();
      
      // Convert to JSON string
      final String messagesJson = jsonEncode(serializableMessages);
      
      // Save to shared preferences
      final prefs = Get.find<SharedPreferences>();
      prefs.setString('chat_messages', messagesJson);
      
      debugPrint('Chat messages saved successfully');
    } catch (e) {
      debugPrint('Error saving chat messages: $e');
    }
  }
  
  /// Load saved messages from local storage
  void _loadMessages() {
    try {
      final prefs = Get.find<SharedPreferences>();
      final String? messagesJson = prefs.getString('chat_messages');
      
      if (messagesJson != null) {
        final List<dynamic> decodedMessages = jsonDecode(messagesJson);
        
        messages.clear();
        
        // Convert stored messages back to the expected format
        for (final item in decodedMessages) {
          messages.add({
            'id': item['id'],
            'text': item['text'],
            'isUser': item['isUser'],
            'timestamp': DateTime.parse(item['timestamp']),
          });
        }
        
        debugPrint('Loaded ${messages.length} chat messages');
        update();
      }
    } catch (e) {
      debugPrint('Error loading chat messages: $e');
    }
  }
}
