import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

import '../../../core/config/env_config.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../services/groq_chat_service.dart';
import '../../home/controllers/home_controller.dart';
import '../../carbon_tracker/models/carbon_budget_model.dart';
import '../../carbon_tracker/models/trip_model.dart';

/// Controller for chatbot functionality
class ChatbotController extends GetxController {
  /// Loading state
  final isLoading = false.obs;
  
  /// Chat messages
  final messages = <ChatMessage>[].obs;
  
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
    
    // Add welcome message
    messages.add(ChatMessage.system(
      'Welcome to your Carbon Budget Tracker Assistant! I can help you understand your carbon emissions and offer personalized advice to reduce your footprint.'
    ));
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
        messages.add(ChatMessage.system(
          'Warning: Groq API key is not configured. Chatbot functionality may be limited.'
        ));
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
      messages.add(ChatMessage.system(
        'Error initializing chatbot: $e'
      ));
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
      
      // Get activities summary
      final activities = _homeController.recentActivities;
      String activitySummary = '';
      
      if (activities.isNotEmpty) {
        // Group by type
        final Map<String, double> typeEmissions = {};
        
        for (final activity in activities) {
          final type = activity['type'] as String;
          final emissions = activity['emissions'] as double;
          
          typeEmissions[type] = (typeEmissions[type] ?? 0) + emissions;
        }
        
        // Convert to summary
        typeEmissions.forEach((type, emissions) {
          activitySummary += '$type: ${emissions.toStringAsFixed(1)} kg CO2, ';
        });
        
        // Remove trailing comma
        if (activitySummary.isNotEmpty) {
          activitySummary = activitySummary.substring(0, activitySummary.length - 2);
        }
      }
      
      // Build context
      carbonContext.value = '''
Carbon budget status:
- Daily: ${dailyEmissions.toStringAsFixed(1)}g / ${dailyBudget.toStringAsFixed(1)}g ($dailyPercentage%)
- Weekly: ${weeklyEmissions.toStringAsFixed(1)}kg / ${weeklyBudget.toStringAsFixed(1)}kg ($weeklyPercentage%)
- Monthly: ${monthlyEmissions.toStringAsFixed(1)}kg / ${monthlyBudget.toStringAsFixed(1)}kg ($monthlyPercentage%)

Recent activity emissions by category: $activitySummary

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
    messages.add(ChatMessage.system(
      'Welcome to your Carbon Budget Tracker Assistant! I can help you understand your carbon emissions and offer personalized advice to reduce your footprint.'
    ));
    
    // Update carbon context
    updateCarbonContext();
  }
  
  /// Send a message to the AI
  Future<void> sendMessage(String messageText) async {
    if (messageText.trim().isEmpty) return;
    
    try {
      // Add user message to the list
      final userMessage = ChatMessage.fromUser(messageText);
      messages.add(userMessage);
      
      // Set loading state
      isLoading.value = true;
      
      // Make sure carbon context is up to date
      updateCarbonContext();
      
      // Create personalized system prompt with user's carbon data
      final personalizedSystemPrompt = '''
You're a carbon advisor for the Carbon Budget Tracker app. Give VERY CONCISE advice using 1-3 sentences maximum unless the user specifically asks for detailed information.

USER DATA (reference briefly when relevant):
- Daily: ${_homeController.dailyEmissions.value}g (${(_homeController.dailyEmissions.value / _homeController.dailyBudget.value * 100).toStringAsFixed(0)}% of budget)
- Weekly: ${_homeController.weeklyEmissions.value}kg (${(_homeController.weeklyEmissions.value / _homeController.weeklyBudget.value * 100).toStringAsFixed(0)}% of budget)
- Monthly: ${_homeController.monthlyEmissions.value}kg (${(_homeController.monthlyEmissions.value / _homeController.monthlyBudget.value * 100).toStringAsFixed(0)}% of budget)
- Recent: ${_getRecentActivitiesText().replaceAll('\n', ' ')}

KEY REQUIREMENTS:
1. Be extremely brief (1-3 sentences)
2. Focus on one actionable suggestion at a time
3. Only provide detailed information if explicitly requested
4. Use simple, direct language
''';
      
      // Generate response using the selected LLM (Groq)
      final response = await _chatService?.generateResponse(
        messageText,
        messages,
        systemPrompt: personalizedSystemPrompt,
      );
      
      if (response != null) {
        messages.add(ChatMessage.fromAssistant(response));
      } else {
        messages.add(ChatMessage.fromAssistant(
          'Sorry, I was unable to generate a response. Please try again.'
        ));
      }
      
    } catch (e) {
      debugPrint('Error sending message: $e');
      messages.add(ChatMessage.fromAssistant(
        'Sorry, an error occurred: $e'
      ));
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Get recent activities formatted as text for the system prompt
  String _getRecentActivitiesText() {
    if (_homeController.recentActivities.isEmpty) {
      return "No recent activities recorded.";
    }
    
    final buffer = StringBuffer();
    for (final activity in _homeController.recentActivities) {
      buffer.writeln("- ${activity['title']}: ${activity['emissions']} kg CO2");
    }
    
    return buffer.toString();
  }
}
