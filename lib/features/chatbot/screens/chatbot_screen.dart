import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../controllers/chatbot_controller.dart';
import '../models/chat_message.dart';
import '../widgets/chat_bubble.dart';

/// Chatbot screen for carbon footprint assistance
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
    if (Get.isRegistered<ChatbotController>()) {
      // Remove any existing controller to ensure we get a fresh instance
      Get.delete<ChatbotController>();
    }
    
    // Create a new instance of the controller
    Get.put(ChatbotController(), permanent: true);
    _chatbotController = Get.find<ChatbotController>();
    
    // Add a system message with carbon info
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatbotController.messages.length <= 1) {
        _addCarbonInfoMessage();
      }
    });
  }
  
  void _addCarbonInfoMessage() async {
    await _chatbotController.addSystemMessage(
      'I can help you understand your carbon emissions and suggest ways to reduce your footprint. Try asking about your current carbon usage or for specific tips to reduce emissions from transportation, home energy, and more.'
    );
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
  
  Future<void> _handleSubmitted(String text) async {
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
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Carbon Footprint Assistant'),
        actions: [
          // Clear chat button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear conversation',
            onPressed: () async {
              await _chatbotController.clearChat();
              // Add carbon info message after clearing
              _addCarbonInfoMessage();
            },
          ),
          // Show carbon data
          IconButton(
            icon: const Icon(Icons.insert_chart_outlined),
            onPressed: () {
              _showCarbonDataDialog(context);
            },
            tooltip: 'View Carbon Data',
          ),
        ],
      ),
      body: Column(
        children: [
          // Carbon status card
          // Obx(() => _buildCarbonStatusCard()),
          
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
                    isCurrentUser: message['isUser'],
                    isSystemMessage: !message['isUser'],
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
                  // Chat examples button
                  IconButton(
                    icon: const Icon(Icons.lightbulb_outline),
                    tooltip: 'Suggested questions',
                    onPressed: () {
                      _showSuggestedQuestions();
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: 'Ask about your carbon footprint...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: theme.hintColor),
                      ),
                      onSubmitted: (text) async => await _handleSubmitted(text),
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: AppColors.primary,
                    onPressed: () async => await _handleSubmitted(_textController.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build a card showing the current carbon status
  Widget _buildCarbonStatusCard() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.eco, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Current Carbon Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBudgetColumn(
                  'Daily',
                  _chatbotController.homeController.dailyEmissions.value,
                  _chatbotController.homeController.dailyBudget.value,
                  'g',
                ),
                _buildBudgetColumn(
                  'Weekly', 
                  _chatbotController.homeController.weeklyEmissions.value,
                  _chatbotController.homeController.weeklyBudget.value,
                  'kg',
                ),
                _buildBudgetColumn(
                  'Monthly',
                  _chatbotController.homeController.monthlyEmissions.value,
                  _chatbotController.homeController.monthlyBudget.value,
                  'kg',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build a column showing budget usage
  Widget _buildBudgetColumn(String label, double used, double total, String unit) {
    final percentage = (used / total * 100).clamp(0, 100);
    final Color statusColor = percentage < 60 ? 
                             Colors.green : 
                             (percentage < 90 ? Colors.orange : Colors.red);
    
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: 60,
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: used / total,
                backgroundColor: Colors.grey[200],
                color: statusColor,
                strokeWidth: 8,
              ),
              Center(
                child: Text(
                  '${percentage.toInt()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${used.toStringAsFixed(1)}/${total.toStringAsFixed(0)} $unit',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
  
  /// Show carbon data dialog
  void _showCarbonDataDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.eco, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Your Carbon Data'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Carbon Context Analysis', 
                    style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _chatbotController.carbonContext.value,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Recent Activities', 
                    style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ..._chatbotController.homeController.recentActivities.map((activity) {
                    return ListTile(
                      leading: Icon(_getActivityIcon(activity['icon'] as String)),
                      title: Text(activity['title'] as String),
                      subtitle: Text('${activity['emissions']} lb CO2'),
                      dense: true,
                    );
                  }),
                ],
              ),
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  /// Get icon for activity type
  IconData _getActivityIcon(String iconName) {
    switch (iconName) {
      case 'directions_bus':
        return Icons.directions_bus;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'directions_bike':
        return Icons.directions_bike;
      default:
        return Icons.eco;
    }
  }
  
  /// Show suggested questions
  void _showSuggestedQuestions() {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Suggested Questions',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Try asking about:'),
              const SizedBox(height: 8),
              _buildSuggestionCard('How can I reduce my carbon footprint?'),
              _buildSuggestionCard('What\'s my biggest source of emissions?'),
              _buildSuggestionCard('How do I compare to average emissions?'),
              _buildSuggestionCard('Tips for reducing transportation emissions?'),
              _buildSuggestionCard('How can I save energy at home?'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
  
  /// Build a suggestion card
  Widget _buildSuggestionCard(String question) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () async {
          Navigator.pop(context);
          _textController.text = question;
          await _handleSubmitted(question);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(Icons.question_answer, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(question),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
