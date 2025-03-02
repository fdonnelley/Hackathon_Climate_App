import '../models/chat_message.dart';

/// Interface for chat services
abstract class ChatService {
  /// Get the name of the provider
  String get providerName;

  /// Initialize the service
  Future<void> initialize();

  /// Generate a response to a message
  /// 
  /// [message] is the user's message
  /// [conversationHistory] is the history of the conversation
  /// [systemPrompt] is an optional system prompt to override the default
  Future<String> generateResponse(
    String message, 
    List<Map<String, dynamic>> conversationHistory, {
    String? systemPrompt,
  });

  /// Clean up resources
  Future<void> dispose();
}

/// Default implementation using Groq
class DefaultChatService implements ChatService {
  /// Get the name of the provider
  @override
  String get providerName => 'Groq';

  /// Initialize the service
  @override
  Future<void> initialize() async {}

  /// Generate a response to a message
  @override
  Future<String> generateResponse(
    String message, 
    List<Map<String, dynamic>> conversationHistory, {
    String? systemPrompt,
  }) async {
    // Use a default response if no implementation is provided
    return "I'm sorry, I couldn't process your request at this time.";
  }
  
  /// Release resources
  @override
  Future<void> dispose() async {}
}
