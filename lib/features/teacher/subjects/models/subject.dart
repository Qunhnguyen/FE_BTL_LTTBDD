class Subject {
  final String id;
  final String name;
  final String? description;
  final bool? isPublic;

  Subject({
    required this.id,
    required this.name,
    this.description,
    this.isPublic,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      // Thử lấy 'id', nếu không có thì lấy '_id' (phổ biến trong MongoDB)
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      isPublic: json['isPublic'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'isPublic': isPublic,
    };
  }
}
