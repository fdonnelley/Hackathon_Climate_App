import 'dart:math';

import '../models/chat_message.dart';
import 'chat_service.dart';

/// Mock implementation of ChatService for testing
class MockChatService implements ChatService {
  @override
  String get providerName => 'Mock Bot';
  
  // General mock responses
  final List<String> _responses = [
    "Hi there! I'm a demo bot. Ask me about this app! 😊",
    "I'm your friendly app assistant. How can I help?",
    "Hello! Have a question about the app?",
    "Hey! I can help with app info. What do you need?",
    "I'm here to help! What would you like to know?",
    "Need info about this app? Just ask me!",
    "Quick question? I'm here for you!",
  ];
  
  // App-specific information responses
  final Map<String, String> _appInfoResponses = {
    'feature': 'This app has a multi-provider chatbot supporting OpenAI, Gemini, and Groq! 🚀',
    'api key': 'Set API keys in your .env file: OPENAI_API_KEY, GEMINI_API_KEY, GROQ_API_KEY',
    'setup': 'Create a .env file with your API keys to get started!',
    'provider': 'We support Mock Bot (default), OpenAI, Google Gemini, and Groq.',
    'model': 'Switch AI models using the settings icon in the top-right corner!',
    'openai': 'For OpenAI, just add your OPENAI_API_KEY to the .env file.',
    'gemini': 'For Gemini, add GEMINI_API_KEY to your .env file.',
    'groq': 'Groq uses fast Llama 3 models. Add GROQ_API_KEY to use it.',
    'architecture': 'We use a feature-based architecture with GetX for state management.',
    'security': 'API keys are stored securely using environment variables and secure storage.',
    'config': 'App config is managed through EnvConfig from .env and secure storage.',
    'chat': 'Select different AI providers and chat away!',
    'default': 'Default is Mock Bot (no API key needed). Change in your .env file.',
  };
  
  final Random _random = Random();
  
  @override
  Future<String> generateResponse(String message, List<ChatMessage> conversationHistory) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Check if the message contains keywords about the app
    final lowerMessage = message.toLowerCase();
    
    // Check for app information queries
    for (final entry in _appInfoResponses.entries) {
      if (lowerMessage.contains(entry.key)) {
        return entry.value;
      }
    }
    
    // If the message contains a question about the app but no specific keywords match
    if (lowerMessage.contains('app') || 
        lowerMessage.contains('feature') || 
        lowerMessage.contains('how') ||
        lowerMessage.contains('llm') ||
        lowerMessage.contains('api') ||
        lowerMessage.contains('key')) {
      return "This app has chatbots from OpenAI, Gemini, and Groq! Set up API keys in .env and switch providers with the settings icon.";
    }
    
    // Return random predefined response for other queries
    return _responses[_random.nextInt(_responses.length)];
  }
  
  @override
  Future<void> initialize() async {
    // Nothing to initialize for mock service
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  @override
  Future<void> dispose() async {
    // Nothing to clean up for mock service
  }
}
