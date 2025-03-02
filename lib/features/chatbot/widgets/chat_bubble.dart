import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../core/theme/app_theme.dart';

/// A chat bubble widget for displaying chat messages
class ChatBubble extends StatelessWidget {
  /// The message to display
  final Map<String, dynamic> message;
  
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
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['text'] as String,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              _formatTime(message['timestamp'] as DateTime),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontSize: 10.0,
              ),
            ),
          ],
        ),
      );
    }
    
    final backgroundColor = isCurrentUser
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceVariant;
    final textColor = isCurrentUser
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurfaceVariant;
    
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Check if the message might contain a URL
            if (message['text'].toString().contains('http') || 
                message['text'].toString().contains('www.'))
              _buildTextWithLinks(message['text'] as String, textColor)
            else
              Text(
                message['text'] as String,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                ),
              ),
            const SizedBox(height: 4.0),
            Text(
              _formatTime(message['timestamp'] as DateTime),
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColor.withOpacity(0.7),
                fontSize: 10.0,
              ),
              textAlign: TextAlign.right,
            ),
          ],
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
  
  /// Build text with links
  Widget _buildTextWithLinks(String text, Color textColor) {
    return MarkdownBody(
      data: text,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          color: textColor,
        ),
        a: TextStyle(
          color: textColor,
          decoration: TextDecoration.underline,
        ),
      ),
      onTapLink: (text, href, title) {
        if (href != null) {
          _launchUrl(href);
        }
      },
    );
  }
  
  /// Launch a URL
  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
