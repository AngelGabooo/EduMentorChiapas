import 'package:flutter/material.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';import 'package:proyectoedumentor/features/chat/domain/models/chat_history.dart';

class ChatHistoryDrawer extends StatelessWidget {
  final List<ChatHistory> chatHistory;
  final Function(String) onChatSelected;
  final VoidCallback onNewChat;

  const ChatHistoryDrawer({
    super.key,
    required this.chatHistory,
    required this.onChatSelected,
    required this.onNewChat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: theme.cardColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Historial de Chat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNewChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 18),
                    SizedBox(width: 8),
                    Text('Nueva Conversación'),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: chatHistory.isEmpty
                ? _buildEmptyHistory(context, isDarkMode)
                : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: chatHistory.length,
              itemBuilder: (context, index) {
                final chat = chatHistory[index];
                return _buildChatItem(chat, context, isDarkMode);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(ChatHistory chat, BuildContext context, bool isDarkMode) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: isDarkMode ? theme.cardColor : Colors.white,
      elevation: isDarkMode ? 0 : 1,
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
            size: 18,
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
            Text(
              chat.lastMessage,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${chat.messageCount} mensajes • ${_formatTime(chat.timestamp)}',
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
        onTap: () => onChatSelected(chat.id),
      ),
    );
  }

  Widget _buildEmptyHistory(BuildContext context, bool isDarkMode) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay conversaciones anteriores',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Comienza una nueva conversación con tu asistente educativo',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
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

    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}