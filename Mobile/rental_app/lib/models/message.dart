import 'user.dart';

class Message {
  final int id;
  final User sender;
  final String content;
  final String sentAt;
  final bool isRead;

  Message({
    required this.id,
    required this.sender,
    required this.content,
    required this.sentAt,
    required this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      sender: User.fromJson(json['sender']),
      content: json['content'],
      sentAt: json['sent_at'],
      isRead: json['is_read'],
    );
  }
}