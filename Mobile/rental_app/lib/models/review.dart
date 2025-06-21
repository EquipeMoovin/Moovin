class Review {
  final int id; 
  final int authorId; 
  final int rating;
  final String comment;
  final String type; // 'TENANT', 'OWNER', 'PROPERTY'
  final DateTime createdAt;
  final int targetObjectId;
  final String targetContentType; // Para identificar o tipo do objeto alvo
  final String authorUsername;

  Review({
    required this.id,
    required this.authorId,
    required this.rating,
    required this.comment,
    required this.type,
    required this.createdAt,
    required this.targetObjectId,
    required this.targetContentType,
    required this.authorUsername,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
  return Review(
    id: json['id'] as int? ?? 0,
    authorId: json['author'] as int? ?? 0,
    rating: json['rating'] as int? ?? 0,
    comment: json['comment'] as String? ?? '',
    type: json['type'] as String? ?? '',
    createdAt: DateTime.parse(json['created_at'] as String),
    targetObjectId: json['object_id'] as int? ?? 0,
    targetContentType: json['content_type_str'] as String? ?? '',
    authorUsername: json['author_username'] as String? ?? '',
  );
}

 
  Map<String, dynamic> toJson() {
    return {
      'author': authorId,
      'rating': rating,
      'comment': comment,
      'type': type,
      'object_id': targetObjectId,
      'content_type': targetContentType,
      'author_username': authorUsername,
      // 'created_at': createdAt.toIso8601String(), // If you need to send this back
    };
  }
}
