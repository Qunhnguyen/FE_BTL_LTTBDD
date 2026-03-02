enum QuestionDifficulty { easy, medium, hard, draft }

enum QuestionType { multipleChoice, essay, image }

class ManagedQuestion {
  final String id;
  final String text;
  final QuestionDifficulty difficulty;
  final int points;
  final int? answerCount;
  final int durationSeconds;
  final QuestionType type;
  final String? imageUrl;

  ManagedQuestion({
    required this.id,
    required this.text,
    required this.difficulty,
    required this.points,
    this.answerCount,
    required this.durationSeconds,
    required this.type,
    this.imageUrl,
  });
}
