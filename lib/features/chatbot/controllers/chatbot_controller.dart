import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

import '../../../core/config/env_config.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../services/gemini_chat_service.dart';
import '../services/groq_chat_service.dart';
import '../services/openai_chat_service.dart';

/// Controller for chatbot functionality
class ChatbotController extends GetxController {
  /// Loading state
  final isLoading = false.obs;
  
  /// Chat messages
  final messages = <ChatMessage>[].obs;
  
  /// Current LLM provider
  final currentLlmProvider = 'Groq'.obs;
  
  /// Available LLM providers
  final availableLlmProviders = <String>['Groq', 'OpenAI', 'Google Gemini'].obs;
  
  /// Map of provider names to services
  final Map<String, ChatService> _serviceMap = {};
  
  /// Current active chat service
  ChatService? _currentService;
  
  /// Environment config for API keys
  final EnvConfig _envConfig = EnvConfig();
  
  @override
  void onInit() {
    super.onInit();
    _initializeChatServices();
    
    // Add welcome message
    messages.add(ChatMessage.system(
      'Welcome! Choose your AI model from the settings menu ⚙️'
    ));
  }
  
  @override
  void onClose() {
    // Clean up all services
    for (final service in _serviceMap.values) {
      service.dispose();
    }
    super.onClose();
  }
  
  /// Initialize chat services
  Future<void> _initializeChatServices() async {
    // Debugging: Print available providers
    debugPrint('Available LLM providers: $availableLlmProviders');
    
    // Get API keys from environment configuration
    final openAiApiKey = await _envConfig.openAiApiKey;
    final geminiApiKey = await _envConfig.geminiApiKey;
    final groqApiKey = await _envConfig.groqApiKey;
    
    // Debugging: Print API keys (redacted)
    debugPrint('OpenAI API key available: ${openAiApiKey?.isNotEmpty}');
    debugPrint('Gemini API key available: ${geminiApiKey?.isNotEmpty}');
    debugPrint('Groq API key available: ${groqApiKey?.isNotEmpty}');
    
    // Create OpenAI service if key is available
    if (openAiApiKey?.isNotEmpty ?? false) {
      _serviceMap['OpenAI'] = OpenAIChatService(
        apiKey: openAiApiKey ?? '',
      );
    } else {
      availableLlmProviders.remove('OpenAI');
    }
    
    // Create Gemini service if key is available
    if (geminiApiKey?.isNotEmpty ?? false) {
      _serviceMap['Google Gemini'] = GeminiChatService(
        apiKey: geminiApiKey ?? '',
      );
    } else {
      availableLlmProviders.remove('Google Gemini');
    }
    
    // Create Groq service - we'll use this as the default
    _serviceMap['Groq'] = GroqChatService(
      apiKey: groqApiKey ?? '', // Will be empty string if not set
    );
    
    // Get the default provider from environment config or use Groq if not set
    final savedProvider = await _envConfig.defaultLlmProvider;
    if (availableLlmProviders.contains(savedProvider) && _serviceMap.containsKey(savedProvider)) {
      currentLlmProvider.value = savedProvider;
    } else {
      currentLlmProvider.value = 'Groq';
    }
    
    // Debugging: Print service map and current provider
    debugPrint('Service map contains: ${_serviceMap.keys.toList()}');
    debugPrint('Current LLM provider: ${currentLlmProvider.value}');
    
    // Set default service
    _currentService = _serviceMap[currentLlmProvider.value];
    
    // Initialize default service
    try {
      await _currentService?.initialize();
      
      // Add message if provider was successfully initialized
      messages.add(ChatMessage.system(
        'Using ${currentLlmProvider.value} as your AI provider'
      ));
    } catch (e) {
      debugPrint('Error initializing default service: $e');
      
      // Try to find a service that will initialize
      bool foundWorking = false;
      for (final provider in availableLlmProviders) {
        if (provider != currentLlmProvider.value && _serviceMap.containsKey(provider)) {
          try {
            currentLlmProvider.value = provider;
            _currentService = _serviceMap[provider];
            await _currentService?.initialize();
            messages.add(ChatMessage.system(
              'Switched to ${currentLlmProvider.value} due to initialization error'
            ));
            foundWorking = true;
            break;
          } catch (e) {
            debugPrint('Error initializing alternative service $provider: $e');
          }
        }
      }
      
      if (!foundWorking) {
        messages.add(ChatMessage.system(
          'Warning: Could not initialize any LLM service. Please check your API keys.'
        ));
      }
    }
  }
  
  /// Set the LLM provider to use
  Future<void> setLlmProvider(String providerName) async {
    if (!_serviceMap.containsKey(providerName)) {
      messages.add(ChatMessage.system(
        'Provider $providerName is not available'
      ));
      return;
    }
    
    isLoading.value = true;
    
    try {
      // Initialize the new service if it hasn't been already
      await _serviceMap[providerName]?.initialize();
      
      // Update current service
      _currentService = _serviceMap[providerName];
      currentLlmProvider.value = providerName;
      
      // Try to save preference, but don't fail if it doesn't work
      try {
        await _envConfig.setDefaultLlmProvider(providerName);
      } catch (e) {
        debugPrint('Failed to save provider preference: $e');
        // Continue anyway, it's not critical
      }
      
      // Add system message about the change
      messages.add(ChatMessage.system(
        'Switched to ${_currentService?.providerName} model'
      ));
    } catch (e) {
      // Add error message
      messages.add(ChatMessage.system(
        'Failed to switch to $providerName: $e'
      ));
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Clear all chat messages and add a welcome message
  void clearChat() {
    messages.clear();
    messages.add(ChatMessage.system(
      'Chat cleared! What would you like to talk about?'
    ));
  }
  
  /// Send a message to the chatbot
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    // Add user message
    final userMessage = ChatMessage.fromUser(text);
    messages.add(userMessage);
    
    isLoading.value = true;
    
    try {
      // Get response from current service
      final response = await _currentService?.generateResponse(
        text, 
        messages.toList(),
      );
      
      if (response != null) {
        // Add assistant message
        messages.add(ChatMessage.fromAssistant(response));
      }
    } catch (e) {
      // Add error message
      messages.add(ChatMessage.system(
        'Error: Failed to get response from ${_currentService?.providerName}. $e'
      ));
    } finally {
      isLoading.value = false;
    }
  }
}
