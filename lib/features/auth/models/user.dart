class User {
  final String id;
  final String email;
  final String name;
  final String role; // 'STUDENT' or 'TEACHER'
  final String? token;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      token: token,
    );
  }
}
