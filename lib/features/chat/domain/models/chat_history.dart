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