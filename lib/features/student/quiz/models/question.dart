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
  final String content;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String? correctOption; // Chỉ Admin mới thấy
  final int points;
  final String? level;

  Question({
    required this.id,
    required this.content,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    this.correctOption,
    this.points = 10,
    this.level,
  });

  // Chuyển đổi từ phẳng (optionA..D) sang danh sách Answer để dễ hiển thị UI
  List<Answer> get answers => [
    Answer(id: 'A', text: optionA, label: 'A'),
    Answer(id: 'B', text: optionB, label: 'B'),
    Answer(id: 'C', text: optionC, label: 'C'),
    Answer(id: 'D', text: optionD, label: 'D'),
  ];

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      content: json['content'] ?? '',
      optionA: json['optionA'] ?? '',
      optionB: json['optionB'] ?? '',
      optionC: json['optionC'] ?? '',
      optionD: json['optionD'] ?? '',
      correctOption: json['correctOption'],
      points: json['score'] ?? json['points'] ?? 10,
      level: json['level'],
    );
  }
}
