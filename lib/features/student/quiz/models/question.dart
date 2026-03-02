class Answer {
  final String id;
  final String text;
  final String label; // A, B, C, D

  Answer({
    required this.id,
    required this.text,
    required this.label,
  });
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
}
