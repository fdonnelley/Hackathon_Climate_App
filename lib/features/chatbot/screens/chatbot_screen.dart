import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../controllers/chatbot_controller.dart';
import '../models/chat_message.dart';
import '../widgets/chat_bubble.dart';

/// Chatbot screen for AI interaction
class ChatbotScreen extends StatefulWidget {
  /// Route name for this screen
  static String get routeName => AppRoutes.getRouteName(AppRoute.chatbot);

  /// Creates a chatbot screen
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  late final ChatbotController _chatbotController;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    // Make sure we have a ChatbotController instance
    if (!Get.isRegistered<ChatbotController>()) {
      Get.put(ChatbotController(), permanent: true);
    }
    _chatbotController = Get.find<ChatbotController>();
    
    // Add a system message with app information
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatbotController.messages.length <= 1) {
        _addAppInfoMessage();
      }
    });
  }
  
  void _addAppInfoMessage() {
    _chatbotController.messages.add(ChatMessage.system(
      'Using Groq as your default AI model. Ask me anything! 😊'
    ));
  }
  
  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    
    _textController.clear();
    _chatbotController.sendMessage(text);
    _scrollToBottom();
    
    // Request focus after sending message
    FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          // Clear chat button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear conversation',
            onPressed: () {
              _chatbotController.clearChat();
              // Add app info message after clearing
              _addAppInfoMessage();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Show LLM selection dialog
              _showLlmSelectionDialog(context);
            },
            tooltip: 'Select LLM Provider',
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: Obx(() {
              _scrollToBottom();
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _chatbotController.messages.length,
                itemBuilder: (context, index) {
                  final message = _chatbotController.messages[index];
                  
                  return ChatBubble(
                    message: message,
                    isCurrentUser: message.sender == MessageSender.user,
                    isSystemMessage: message.sender == MessageSender.system,
                  );
                },
              );
            }),
          ),
          
          // Status indicator
          Obx(() {
            if (_chatbotController.isLoading.value) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          
          // Input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.mic),
                    onPressed: () {
                      // Speech recognition feature (to be implemented)
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: _handleSubmitted,
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _handleSubmitted(_textController.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showLlmSelectionDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    // Model descriptions for each provider
    final Map<String, Map<String, dynamic>> modelInfo = {
      'Mock Bot': {
        'icon': Icons.smart_toy,
        'description': 'Simple rule-based bot (no API key required)',
        'color': Colors.grey,
      },
      'OpenAI': {
        'icon': Icons.psychology,
        'description': 'Powerful GPT models from OpenAI',
        'color': Colors.green,
      },
      'Google Gemini': {
        'icon': Icons.auto_awesome,
        'description': 'Google\'s advanced conversational AI',
        'color': Colors.blue,
      },
      'Groq': {
        'icon': Icons.bolt,
        'description': 'Ultra-fast LLM inference with Llama 3',
        'color': Colors.purple,
      },
    };
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.smart_toy, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Select AI Model'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Instructions
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Choose which AI model to use for your conversation',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              
              // This list will be populated with available LLM providers
              ...(_chatbotController.availableLlmProviders.map((provider) {
                final info = modelInfo[provider] ?? {
                  'icon': Icons.smart_toy,
                  'description': 'AI model',
                  'color': theme.colorScheme.primary,
                };
                
                return Obx(() {
                  final isSelected = _chatbotController.currentLlmProvider.value == provider;
                  
                  return Card(
                    elevation: isSelected ? 2 : 0,
                    color: isSelected 
                        ? theme.colorScheme.primaryContainer 
                        : theme.cardColor,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: isSelected 
                          ? BorderSide(color: theme.colorScheme.primary, width: 2)
                          : BorderSide(color: theme.dividerColor),
                    ),
                    child: InkWell(
                      onTap: () {
                        _chatbotController.setLlmProvider(provider);
                        Get.back();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: info['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                info['icon'],
                                color: info['color'],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    provider,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    info['description'],
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: theme.colorScheme.primary,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
              })),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
