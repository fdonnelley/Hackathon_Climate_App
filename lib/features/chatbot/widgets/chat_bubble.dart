import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../models/chat_message.dart';

/// A chat bubble widget for displaying chat messages
class ChatBubble extends StatelessWidget {
  /// The message to display
  final ChatMessage message;
  
  /// Whether the message is from the current user
  final bool isCurrentUser;
  
  /// Whether the message is a system message
  final bool isSystemMessage;
  
  /// Creates a chat bubble widget
  const ChatBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    this.isSystemMessage = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // System messages have their own style
    if (isSystemMessage) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.eco,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message.text,
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? AppColors.primary
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: isCurrentUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              // We use Markdown to render message text
              MarkdownBody(
                data: message.text,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    color: isCurrentUser
                        ? Colors.white
                        : theme.textTheme.bodyMedium?.color,
                    fontSize: 15,
                  ),
                  h1: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  h2: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  h3: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  blockquote: TextStyle(
                    color: isCurrentUser
                        ? Colors.white.withOpacity(0.9)
                        : theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
                    fontStyle: FontStyle.italic,
                  ),
                  code: TextStyle(
                    backgroundColor: isCurrentUser
                        ? Colors.white.withOpacity(0.2)
                        : theme.colorScheme.onSurface.withOpacity(0.1),
                    color: isCurrentUser
                        ? Colors.white
                        : theme.colorScheme.primary,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: isCurrentUser
                        ? Colors.white.withOpacity(0.1)
                        : theme.colorScheme.onSurface.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  a: TextStyle(
                    color: isCurrentUser
                        ? Colors.white
                        : theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
                onTapLink: (text, href, title) {
                  if (href != null) {
                    _launchUrl(href);
                  }
                },
              ),
              
              // Message timestamp
              const SizedBox(height: 4),
              Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: isCurrentUser
                      ? Colors.white.withOpacity(0.7)
                      : theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Format message timestamp
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);
    
    if (messageDate == today) {
      // Today, show time only
      return '${_padZero(time.hour)}:${_padZero(time.minute)}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return 'Yesterday, ${_padZero(time.hour)}:${_padZero(time.minute)}';
    } else {
      // Other days, show date and time
      return '${_padZero(time.day)}/${_padZero(time.month)}, ${_padZero(time.hour)}:${_padZero(time.minute)}';
    }
  }
  
  /// Pad single digit numbers with leading zero
  String _padZero(int number) {
    return number.toString().padLeft(2, '0');
  }
  
  /// Launch a URL
  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
