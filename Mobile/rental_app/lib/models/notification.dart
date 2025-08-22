class Notification {
  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String createdAt;
  final int? relatedObjectId;
  final String? relatedObjectType;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.relatedObjectId,
    this.relatedObjectType,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      isRead: json['is_read'],
      createdAt: json['created_at'],
      relatedObjectId: json['related_object_id'],
      relatedObjectType: json['related_object_type'],
    );
  }
}