// import '../models/chat_message.dart';
// import 'chat_service.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// /// OpenAI implementation of ChatService
// class OpenAIChatService implements ChatService {
//   @override
//   String get providerName => 'OpenAI';
  
//   /// API key for OpenAI
//   final String apiKey;
  
//   /// Model to use (e.g. 'gpt-3.5-turbo', 'gpt-4')
//   final String model;
  
//   /// Creates an OpenAI chat service
//   OpenAIChatService({
//     required this.apiKey,
//     this.model = 'gpt-3.5-turbo',
//   });
  
//   @override
//   Future<String> generateResponse(String message, List<ChatMessage> conversationHistory) async {
//     if (apiKey.isEmpty) {
//       await Future.delayed(const Duration(seconds: 1));
//       return "OpenAI API key not set. Please add your key to the .env file.";
//     }
    
//     try {
//       final messages = conversationHistory.map((msg) {
//         String role;
//         switch (msg.sender) {
//           case MessageSender.user:
//             role = 'user';
//             break;
//           case MessageSender.assistant:
//             role = 'assistant';
//             break;
//           case MessageSender.system:
//             role = 'system';
//             break;
//         }
        
//         return {
//           'role': role,
//           'content': msg.text,
//         };
//       }).toList();
      
//       // Add system message for brevity
//       messages.insert(0, {
//         'role': 'system',
//         'content': 'You are a helpful assistant that provides very brief, concise answers. Keep responses under 2 sentences when possible. Be friendly but extremely direct.'
//       });
      
//       // Add the new user message
//       messages.add({
//         'role': 'user',
//         'content': message,
//       });
      
//       final response = await http.post(
//         Uri.parse('https://api.openai.com/v1/chat/completions'),
//         headers: {
//           'Authorization': 'Bearer $apiKey',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'model': model,
//           'messages': messages,
//           'max_tokens': 100,
//           'temperature': 0.7,
//         }),
//       );
      
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data['choices'][0]['message']['content'];
//       } else {
//         throw Exception('OpenAI API error: ${response.statusCode}, ${response.body}');
//       }
//     } catch (e) {
//       return "Error: $e";
//     }
//   }
  
//   @override
//   Future<void> initialize() async {
//     // Validate API key
//     if (apiKey.isEmpty) {
//       throw Exception('OpenAI API key is not set. Please update your .env file.');
//     }
//   }
  
//   @override
//   Future<void> dispose() async {
//     // Clean up resources
//   }
// }
