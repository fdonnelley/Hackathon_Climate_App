import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MessagesScreen extends StatefulWidget {
  static const String routeName = '/messages';
  
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  // Mock data for chats
  final List<ChatModel> _chats = [
    ChatModel(
      id: '1',
      name: 'Sarah Johnson',
      lastMessage: 'Thanks for the update!',
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      avatar: 'https://i.pravatar.cc/150?img=1',
      unreadCount: 2,
    ),
    ChatModel(
      id: '2',
      name: 'Tech Team',
      lastMessage: 'Let\'s discuss the new feature',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      avatar: 'https://i.pravatar.cc/150?img=2',
      isGroup: true,
      unreadCount: 5,
    ),
    ChatModel(
      id: '3',
      name: 'Alex Wilson',
      lastMessage: 'I\'ll send you the documents',
      time: DateTime.now().subtract(const Duration(hours: 5)),
      avatar: 'https://i.pravatar.cc/150?img=3',
    ),
    ChatModel(
      id: '4',
      name: 'Project Planning',
      lastMessage: 'Meeting scheduled for tomorrow',
      time: DateTime.now().subtract(const Duration(days: 1)),
      avatar: 'https://i.pravatar.cc/150?img=4',
      isGroup: true,
    ),
    ChatModel(
      id: '5',
      name: 'Emma Davis',
      lastMessage: 'Yes, I got it working!',
      time: DateTime.now().subtract(const Duration(days: 2)),
      avatar: 'https://i.pravatar.cc/150?img=5',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show menu
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Online users horizontal list
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: theme.colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Online',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    scrollDirection: Axis.horizontal,
                    itemCount: _chats.length,
                    itemBuilder: (context, index) {
                      final chat = _chats[index];
                      return Container(
                        width: 70,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(chat.avatar),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: theme.colorScheme.surface,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              chat.name.split(' ')[0],
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Chat list
          Expanded(
            child: ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                final chat = _chats[index];
                return _buildChatTile(context, chat);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // New chat
        },
        child: const Icon(Icons.message),
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, ChatModel chat) {
    final theme = Theme.of(context);
    final time = DateFormat.jm().format(chat.time);
    final isToday = chat.time.day == DateTime.now().day;
    final isYesterday = chat.time.day == DateTime.now().subtract(const Duration(days: 1)).day;
    
    String timeText;
    if (isToday) {
      timeText = time;
    } else if (isYesterday) {
      timeText = 'Yesterday';
    } else {
      timeText = DateFormat('MMM d').format(chat.time);
    }
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(chat.avatar),
            child: chat.isGroup 
                ? Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: const Icon(
                        Icons.group,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              chat.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: chat.unreadCount > 0 ? FontWeight.bold : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            timeText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: chat.unreadCount > 0 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: chat.unreadCount > 0 ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              chat.lastMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: chat.unreadCount > 0 
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: chat.unreadCount > 0 ? FontWeight.bold : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (chat.unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                chat.unreadCount.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        // Navigate to chat
        Get.toNamed('/messages/chat', arguments: chat);
      },
    );
  }
}

class ChatModel {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime time;
  final String avatar;
  final bool isGroup;
  final int unreadCount;
  
  ChatModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.avatar,
    this.isGroup = false,
    this.unreadCount = 0,
  });
}
