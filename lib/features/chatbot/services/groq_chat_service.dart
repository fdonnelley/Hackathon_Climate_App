import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/chat_message.dart';
import 'chat_service.dart';

/// Chat service that uses Groq API
class GroqChatService implements ChatService {
  /// Groq API key
  final String apiKey;
  
  /// Groq model to use
  final String model;
  
  /// Create a new Groq chat service
  GroqChatService({
    required this.apiKey,
    this.model = 'llama3-70b-8192',
  });
  
  @override
  String get providerName => 'Groq';
  
  @override
  Future<void> initialize() async {
    // Check if API key is valid
    if (apiKey.isEmpty) {
      throw Exception('Groq API key is not set. Please update your .env file.');
    }
  }
  
  @override
  Future<String> generateResponse(String message, List<ChatMessage> conversationHistory) async {
    try {
      // Create a copy of the conversation history and add the new user message
      final messages = [...conversationHistory];
      messages.add(ChatMessage.fromUser(message));
      
      // Convert ChatMessage to Groq message format
      final groqMessages = messages.map((message) {
        String role;
        switch (message.sender) {
          case MessageSender.user:
            role = 'user';
            break;
          case MessageSender.assistant:
            role = 'assistant';
            break;
          case MessageSender.system:
            role = 'system';
            break;
        }
        
        return {
          'role': role,
          'content': message.text,
        };
      }).toList();
      
      // Prepare the request body
      final body = jsonEncode({
        'model': model,
        'messages': [
          {
            'role': 'system',
            'content': 'You are a helpful assistant that provides very brief, concise answers. Keep responses under 2 sentences when possible. Be friendly but extremely direct.'
          },
          ...groqMessages
        ],
        'temperature': 0.7,
        'max_tokens': 100,
      });
      
      // Debug information
      print('Using Groq model: $model');
      print('API Key First 5 chars: ${apiKey.substring(0, 5)}...');
      
      // Make the API request - using the exact endpoint from Groq docs
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: body,
      );
      
      // Debug information for response
      print('Response status code: ${response.statusCode}');
      if (response.body.isNotEmpty) {
        print('Response body preview: ${response.body.length > 100 ? response.body.substring(0, 100) + "..." : response.body}');
      }
      
      // Handle the response
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data.containsKey('choices') && 
            data['choices'] is List && 
            data['choices'].isNotEmpty &&
            data['choices'][0].containsKey('message') &&
            data['choices'][0]['message'].containsKey('content')) {
          return data['choices'][0]['message']['content'] as String;
        } else {
          throw Exception('Unexpected response format from Groq API');
        }
      } else {
        throw Exception('Failed to get response from Groq API: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
  
  @override
  Future<void> dispose() async {
    // Nothing to dispose
  }
}
