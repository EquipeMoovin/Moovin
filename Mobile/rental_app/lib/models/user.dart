class User {
  final int id;
  final String email;
  final String name;
  final String userType;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.userType,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'],
      name: json['name'],
      userType: json['user_type'],
    );
  }
}