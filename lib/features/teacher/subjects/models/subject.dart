class Subject {
  final String id;
  final String name;
  final String? description;

  Subject({
    required this.id,
    required this.name,
    this.description,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}
