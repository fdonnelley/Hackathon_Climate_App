import '../models/chat_message.dart';

/// Abstract class for different LLM chat implementations
abstract class ChatService {
  /// Name of the LLM provider
  String get providerName;
  
  /// Generate a response to a user message
  Future<String> generateResponse(String message, List<ChatMessage> conversationHistory);
  
  /// Initialize the chat service
  Future<void> initialize();
  
  /// Cleanup resources
  Future<void> dispose();
}
