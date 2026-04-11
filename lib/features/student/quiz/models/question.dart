class QuizOption {
  final String key;
  final String content;

  QuizOption({required this.key, required this.content});

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      key: json['key'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

class Question {
  final String id;
  final int questionNo;
  final String content;
  final String? level;
  final String? topic;
  final double score;
  final List<QuizOption> options;

  Question({
    required this.id,
    required this.questionNo,
    required this.content,
    this.level,
    this.topic,
    required this.score,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id']?.toString() ?? '',
      questionNo: json['questionNo'] ?? 0,
      content: json['content'] ?? '',
      level: json['level'],
      topic: json['topic'],
      score: (json['score'] ?? 0).toDouble(),
      options: (json['options'] as List? ?? [])
          .map((opt) => QuizOption.fromJson(opt))
          .toList(),
    );
  }
}
