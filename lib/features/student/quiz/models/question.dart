class Answer {
  final String id;
  final String text;
  final String label; // A, B, C, D

  Answer({
    required this.id,
    required this.text,
    required this.label,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id']?.toString() ?? '',
      text: json['text'] ?? '',
      label: json['label'] ?? '',
    );
  }
}

class Question {
  final String id;
  final String text;
  final List<Answer> answers;
  final String? correctAnswerId;
  final List<String> tags;
  final String difficulty;
  final int points;

  Question({
    required this.id,
    required this.text,
    required this.answers,
    this.correctAnswerId,
    this.tags = const [],
    this.difficulty = 'Trung bình',
    this.points = 5,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id']?.toString() ?? '',
      text: json['text'] ?? '',
      answers: (json['answers'] as List<dynamic>?)
              ?.map((e) => Answer.fromJson(e))
              .toList() ??
          [],
      correctAnswerId: json['correctAnswerId']?.toString(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      difficulty: json['difficulty'] ?? 'Trung bình',
      points: json['points'] ?? 5,
    );
  }
}
