class User {
  final String id;
  final String email;
  final String name;
  final String role; // 'STUDENT', 'TEACHER', or 'ADMIN'
  final String? avatarFileId;
  final String? avatarUrl;
  final String? token;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.avatarFileId,
    this.avatarUrl,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    return User(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      avatarFileId: json['avatarFileId']?.toString(),
      avatarUrl: json['avatarUrl'],
      token: token,
    );
  }

  User copyWith({
    String? name,
    String? avatarFileId,
    String? avatarUrl,
  }) {
    return User(
      id: id,
      email: email,
      name: name ?? this.name,
      role: role,
      avatarFileId: avatarFileId ?? this.avatarFileId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      token: token,
    );
  }
}
