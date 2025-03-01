/// Enum for message sender type
enum MessageSender {
  /// User sent the message
  user,
  
  /// AI assistant sent the message
  assistant,
  
  /// System message
  system,
}

/// Model class for chat messages
class ChatMessage {
  /// The content of the message
  final String text;
  
  /// Who sent the message
  final MessageSender sender;
  
  /// Timestamp when the message was sent
  final DateTime timestamp;
  
  /// ID of the message
  final String id;

  /// Creates a new chat message
  ChatMessage({
    required this.text,
    required this.sender,
    DateTime? timestamp,
    String? id,
  }) : 
    timestamp = timestamp ?? DateTime.now(),
    id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
  
  /// Creates a user message
  factory ChatMessage.fromUser(String text) {
    return ChatMessage(
      text: text,
      sender: MessageSender.user,
    );
  }
  
  /// Creates an assistant message
  factory ChatMessage.fromAssistant(String text) {
    return ChatMessage(
      text: text,
      sender: MessageSender.assistant,
    );
  }
  
  /// Creates a system message
  factory ChatMessage.system(String text) {
    return ChatMessage(
      text: text,
      sender: MessageSender.system,
    );
  }
  
  /// Converts this message to a map
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'sender': sender.toString(),
      'timestamp': timestamp.toIso8601String(),
      'id': id,
    };
  }
  
  /// Creates a message from a map
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      text: map['text'],
      sender: MessageSender.values.firstWhere(
        (e) => e.toString() == map['sender'],
        orElse: () => MessageSender.system,
      ),
      timestamp: DateTime.parse(map['timestamp']),
      id: map['id'],
    );
  }
}
