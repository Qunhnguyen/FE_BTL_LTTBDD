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
  final String? correctOption;
  final String? optionA;
  final String? optionB;
  final String? optionC;
  final String? optionD;

  ManagedQuestion({
    required this.id,
    required this.text,
    required this.difficulty,
    required this.points,
    this.answerCount,
    required this.durationSeconds,
    required this.type,
    this.imageUrl,
    this.correctOption,
    this.optionA,
    this.optionB,
    this.optionC,
    this.optionD,
  });

  factory ManagedQuestion.fromJson(Map<String, dynamic> json) {
    // Nội dung: thử content → text → question
    final questionText = json['content'] ?? json['text'] ?? json['question'] ?? '';

    // Điểm: thử score → points → point
    final rawPoints = json['score'] ?? json['points'] ?? json['point'] ?? 0;
    final questionPoints = rawPoints is int ? rawPoints : (int.tryParse(rawPoints.toString()) ?? 0);

    // Thời gian: thử durationSeconds → duration → time → timeLimit
    final rawDuration = json['durationSeconds'] ?? json['duration'] ?? json['time'] ?? json['timeLimit'] ?? 0;
    final questionDuration = rawDuration is int ? rawDuration : (int.tryParse(rawDuration.toString()) ?? 0);

    // Đếm số đáp án
    int answerCount = 0;
    if (json['answers'] != null) {
      answerCount = (json['answers'] as List).length;
    } else {
      if (json['optionA'] != null) answerCount++;
      if (json['optionB'] != null) answerCount++;
      if (json['optionC'] != null) answerCount++;
      if (json['optionD'] != null) answerCount++;
    }

    return ManagedQuestion(
      id: json['id']?.toString() ?? '',
      text: questionText,
      difficulty: _parseDifficulty(json['difficulty'] ?? json['level']),
      points: questionPoints,
      answerCount: answerCount,
      durationSeconds: questionDuration,
      type: _parseType(json['type']),
      imageUrl: json['imageUrl'],
      correctOption: json['correctOption']?.toString(),
      optionA: json['optionA']?.toString(),
      optionB: json['optionB']?.toString(),
      optionC: json['optionC']?.toString(),
      optionD: json['optionD']?.toString(),
    );
  }

  static QuestionDifficulty _parseDifficulty(dynamic difficultyRaw) {
    final difficulty = (difficultyRaw ?? '').toString().trim().toUpperCase();
    switch (difficulty) {
      case 'EASY': return QuestionDifficulty.easy;
      case 'MEDIUM': return QuestionDifficulty.medium;
      case 'HARD': return QuestionDifficulty.hard;
      case 'DE':
      case 'DỄ':
        return QuestionDifficulty.easy;
      case 'TRUNGBINH':
      case 'TRUNG_BINH':
      case 'TRUNG BÌNH':
        return QuestionDifficulty.medium;
      case 'KHO':
      case 'KHÓ':
        return QuestionDifficulty.hard;
      default: return QuestionDifficulty.draft;
    }
  }

  static QuestionType _parseType(String? type) {
    switch (type?.toUpperCase()) {
      case 'ESSAY': return QuestionType.essay;
      case 'IMAGE': return QuestionType.image;
      default: return QuestionType.multipleChoice;
    }
  }
}
