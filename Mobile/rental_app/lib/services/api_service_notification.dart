import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';

class ApiService {
  final String _notificationBase = '$apiBase/notifications';
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<List<Notification>> fetchNotifications() async {
    final url = Uri.parse('$_notificationBase/');
    final token = await _secureStorage.read(key: 'access_token');

    if (token == null) {
      throw Exception('Token JWT não encontrado.');
    }

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(decodedBody);
      return jsonList.map((json) => Notification.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar notificações: ${response.body}');
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    final url = Uri.parse('$_notificationBase/$notificationId/read/');
    final token = await _secureStorage.read(key: 'access_token');

    if (token == null) {
      throw Exception('Token JWT não encontrado.');
    }

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao marcar notificação como lida: ${response.body}');
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    final url = Uri.parse('$_notificationBase/$notificationId/');
    final token = await _secureStorage.read(key: 'access_token');

    if (token == null) {
      throw Exception('Token JWT não encontrado.');
    }

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Falha ao excluir notificação: ${response.body}');
    }
  }

  Future<void> markAllAsRead() async {
    final url = Uri.parse('$_notificationBase/mark-all-read/');
    final token = await _secureStorage.read(key: 'access_token');

    if (token == null) {
      throw Exception('Token JWT não encontrado.');
    }

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao marcar todas notificações como lidas: ${response.body}');
    }
  }

  Future<void> sendNotification(String title, String message, String email) async {
    final url = Uri.parse('$_notificationBase/send/');
    final token = await _secureStorage.read(key: 'access_token');

    if (token == null) {
      throw Exception('Token JWT não encontrado.');
    }

    final Map<String, dynamic> body = {
      'title': title,
      'message': message,
      'email': email, 
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      throw Exception('Falha ao enviar notificação: ${response.body}');
    }
  }
}