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

  factory ManagedQuestion.fromJson(Map<String, dynamic> json) {
    return ManagedQuestion(
      id: json['id']?.toString() ?? '',
      text: json['text'] ?? '',
      difficulty: _parseDifficulty(json['difficulty']),
      points: json['points'] ?? 0,
      answerCount: json['answers'] != null ? (json['answers'] as List).length : 0,
      durationSeconds: json['durationSeconds'] ?? 0,
      type: _parseType(json['type']),
      imageUrl: json['imageUrl'],
    );
  }

  static QuestionDifficulty _parseDifficulty(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy': return QuestionDifficulty.easy;
      case 'medium': return QuestionDifficulty.medium;
      case 'hard': return QuestionDifficulty.hard;
      default: return QuestionDifficulty.draft;
    }
  }

  static QuestionType _parseType(String? type) {
    switch (type?.toLowerCase()) {
      case 'essay': return QuestionType.essay;
      case 'image': return QuestionType.image;
      default: return QuestionType.multipleChoice;
    }
  }
}
