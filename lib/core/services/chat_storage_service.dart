// lib/core/services/chat_storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyectoedumentor/features/chat/domain/models/chat_message.dart';
import 'package:proyectoedumentor/features/chat/domain/models/chat_history.dart';

class ChatStorageService {
  static const String _keyChatList = 'chat_history_list';
  static const String _keyCurrentChatId = 'current_chat_id';

  // Guarda o actualiza un chat en la lista
  Future<void> saveChat(ChatHistory chat, List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();

    // Obtener lista actual
    final List<String> chatListJson = prefs.getStringList(_keyChatList) ?? [];
    final List<Map<String, dynamic>> chatList = chatListJson
        .map((e) => json.decode(e) as Map<String, dynamic>)
        .toList();

    // Actualizar o agregar el chat
    final index = chatList.indexWhere((c) => c['id'] == chat.id);
    final chatData = {
      'id': chat.id,
      'title': chat.title,
      'lastMessage': chat.lastMessage,
      'timestamp': chat.timestamp.millisecondsSinceEpoch,
      'messageCount': chat.messageCount,
    };

    if (index != -1) {
      chatList[index] = chatData;
    } else {
      chatList.add(chatData);
    }

    // Guardar mensajes completos de este chat
    final messagesJson = messages
        .map((m) => {
      'text': m.text,
      'isUser': m.isUser,
      'timestamp': m.timestamp.millisecondsSinceEpoch,
    })
        .toList();
    await prefs.setString('messages_${chat.id}', json.encode(messagesJson));

    // Guardar lista actualizada
    final updatedJson = chatList.map((c) => json.encode(c)).toList();
    await prefs.setStringList(_keyChatList, updatedJson);
    await prefs.setString(_keyCurrentChatId, chat.id);
  }

  // Carga todos los chats del historial
  Future<List<ChatHistory>> loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> chatListJson = prefs.getStringList(_keyChatList) ?? [];

    return chatListJson.map((jsonStr) {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      return ChatHistory(
        id: map['id'],
        title: map['title'],
        lastMessage: map['lastMessage'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
        messageCount: map['messageCount'],
      );
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Más reciente primero
  }

  // Carga los mensajes de un chat específico
  Future<List<ChatMessage>> loadMessages(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('messages_$chatId');
    if (jsonStr == null) return [];

    final List<dynamic> list = json.decode(jsonStr);
    return list.map((m) => ChatMessage(
      text: m['text'],
      isUser: m['isUser'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(m['timestamp']),
    )).toList();
  }

  // Obtiene el ID del chat actual (o null si no hay)
  Future<String?> getCurrentChatId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrentChatId);
  }

  // Limpia todo (para debug)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (var key in keys) {
      if (key.startsWith('messages_') || key == _keyChatList || key == _keyCurrentChatId) {
        await prefs.remove(key);
      }
    }
  }

  Future<void> deleteChat(String chatId) async {}
}