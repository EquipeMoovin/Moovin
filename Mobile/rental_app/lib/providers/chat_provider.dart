import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  List<Conversation> _conversations = [];
  bool _isLoading = false;
  String? _error;
  final ApiService _apiService = ApiService();

  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await _apiService.fetchConversations();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Conversation> createConversation(
      int tenantId, int ownerId, int immobileId) async {
    try {
      final conversation = await _apiService.createConversation(
        tenantId: tenantId,
        ownerId: ownerId,
        immobileId: immobileId,
      );
      _conversations.insert(0, conversation);
      notifyListeners();
      return conversation;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> sendMessage(int conversationId, String content) async {
    try {
      final message = await _apiService.sendMessage(
        conversationId: conversationId,
        content: content,
      );
      final index = _conversations
          .indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        _conversations[index] = Conversation(
          id: _conversations[index].id,
          tenant: _conversations[index].tenant,
          owner: _conversations[index].owner,
          immobile: _conversations[index].immobile,
          createdAt: _conversations[index].createdAt,
          updatedAt: message.sentAt,
          messages: [..._conversations[index].messages, message],
          lastMessage: message,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> markMessageAsRead(int messageId) async {
    try {
      await _apiService.markMessageAsRead(messageId);
      for (var conversation in _conversations) {
        final messages = conversation.messages.map((m) {
          if (m.id == messageId) {
            return Message(
              id: m.id,
              sender: m.sender,
              content: m.content,
              sentAt: m.sentAt,
              isRead: true,
            );
          }
          return m;
        }).toList();
        if (messages.any((m) => m.id == messageId)) {
          final index = _conversations.indexOf(conversation);
          _conversations[index] = Conversation(
            id: conversation.id,
            tenant: conversation.tenant,
            owner: conversation.owner,
            immobile: conversation.immobile,
            createdAt: conversation.createdAt,
            updatedAt: conversation.updatedAt,
            messages: messages,
            lastMessage: messages.last,
          );
        }
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}