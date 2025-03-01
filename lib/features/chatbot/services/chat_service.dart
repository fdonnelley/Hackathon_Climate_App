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
    List<ChatMessage> conversationHistory, {
    String? systemPrompt,
  });

  /// Clean up resources
  Future<void> dispose();
}
