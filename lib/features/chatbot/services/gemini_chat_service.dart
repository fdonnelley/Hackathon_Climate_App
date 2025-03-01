// import '../models/chat_message.dart';
// import 'chat_service.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// /// Google Gemini implementation of ChatService
// class GeminiChatService implements ChatService {
//   @override
//   String get providerName => 'Google Gemini';
  
//   /// API key for Gemini
//   final String apiKey;
  
//   /// Model to use (e.g. 'gemini-pro')
//   final String model;
  
//   /// Creates a Gemini chat service
//   GeminiChatService({
//     required this.apiKey,
//     this.model = 'gemini-pro',
//   });
  
//   @override
//   Future<String> generateResponse(String message, List<ChatMessage> conversationHistory) async {
//     if (apiKey.isEmpty) {
//       await Future.delayed(const Duration(seconds: 1));
//       return "Gemini API key not set. Please add your key to the .env file.";
//     }
    
//     try {
//       // Add a system message to encourage brevity as first message in history
//       final systemContent = "Please provide very brief and concise answers. Limit responses to 1-2 short sentences when possible.";
      
//       final contents = [];
      
//       // Add system content as first message
//       contents.add({
//         'role': 'user',
//         'parts': [{'text': systemContent}]
//       });
      
//       contents.add({
//         'role': 'model',
//         'parts': [{'text': "I'll keep my responses brief and to the point."}]
//       });
      
//       // Add conversation history
//       bool isUserTurn = true;
//       for (final msg in conversationHistory) {
//         if (msg.sender == MessageSender.user) {
//           contents.add({
//             'role': 'user',
//             'parts': [{'text': msg.text}]
//           });
//           isUserTurn = false;
//         } else if (msg.sender == MessageSender.assistant) {
//           contents.add({
//             'role': 'model',
//             'parts': [{'text': msg.text}]
//           });
//           isUserTurn = true;
//         }
//         // Skip system messages for Gemini
//       }
      
//       // Add the current message if not already added
//       if (isUserTurn) {
//         contents.add({
//           'role': 'user',
//           'parts': [{'text': message}]
//         });
//       }
      
//       // Make the API call
//       final response = await http.post(
//         Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'contents': contents,
//           'generationConfig': {
//             'maxOutputTokens': 100,
//             'temperature': 0.7,
//           }
//         }),
//       );
      
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data['candidates'][0]['content']['parts'][0]['text'];
//       } else {
//         throw Exception('Gemini API error: ${response.statusCode}, ${response.body}');
//       }
//     } catch (e) {
//       return "Error: $e";
//     }
//   }
  
//   @override
//   Future<void> initialize() async {
//     // Validate API key
//     if (apiKey.isEmpty) {
//       throw Exception('Gemini API key is not set. Please update your .env file.');
//     }
//   }
  
//   @override
//   Future<void> dispose() async {
//     // Clean up resources
//   }
// }
