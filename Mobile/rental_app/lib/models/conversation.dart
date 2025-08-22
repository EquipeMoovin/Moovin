import 'tenant.dart';
import 'owner.dart';
import 'immobile.dart';
import 'message.dart';

class Conversation {
  final int id;
  final Tenant tenant;
  final Owner owner;
  final Immobile immobile;
  final String createdAt;
  final String updatedAt;
  final List<Message> messages;
  final Message? lastMessage;

  Conversation({
    required this.id,
    required this.tenant,
    required this.owner,
    required this.immobile,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
    this.lastMessage,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      tenant: Tenant.fromJson(json['tenant']),
      owner: Owner.fromJson(json['owner']),
      immobile: Immobile.fromJson(json['immobile']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      messages: (json['messages'] as List<dynamic>)
          .map((m) => Message.fromJson(m))
          .toList(),
      lastMessage: json['last_message'] != null
          ? Message.fromJson(json['last_message'])
          : null,
    );
  }
}