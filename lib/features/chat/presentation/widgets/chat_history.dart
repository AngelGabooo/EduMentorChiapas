import 'package:flutter/material.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';
class ChatHistory {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime timestamp;
  final int messageCount;

  ChatHistory({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.timestamp,
    required this.messageCount,
  });
}

class ChatHistoryList extends StatelessWidget {
  final List<ChatHistory> chatHistory;
  final Function(String) onChatSelected;
  final VoidCallback onNewChat;

  const ChatHistoryList({
    super.key,
    required this.chatHistory,
    required this.onChatSelected,
    required this.onNewChat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Conversaciones',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: onNewChat,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
        Expanded(
          child: chatHistory.isEmpty
              ? _buildEmptyState(context, isDarkMode)
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: chatHistory.length,
            itemBuilder: (context, index) {
              final chat = chatHistory[index];
              return _buildChatItem(chat, context, isDarkMode);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatItem(ChatHistory chat, BuildContext context, bool isDarkMode) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: isDarkMode ? 0 : 1,
      color: isDarkMode ? theme.cardColor : Colors.white,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.chat_bubble_outline,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          chat.title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              chat.lastMessage,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${chat.messageCount} mensajes',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '•',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(chat.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurface.withOpacity(0.4),
        ),
        onTap: () => onChatSelected(chat.id),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkMode) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay conversaciones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Inicia una conversación con tu asistente educativo',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onNewChat,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Comenzar Chat'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Ahora';
    if (difference.inHours < 1) return 'Hace ${difference.inMinutes}m';
    if (difference.inDays < 1) return 'Hace ${difference.inHours}h';
    if (difference.inDays < 7) return 'Hace ${difference.inDays}d';
    if (difference.inDays < 30) return 'Hace ${(difference.inDays / 7).floor()}sem';

    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}