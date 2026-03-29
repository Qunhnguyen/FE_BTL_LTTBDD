class ItemAnalysis {
  final String contestId;
  final String contestName;
  final List<QuestionAnalysis> hardestQuestions;
  final List<QuestionAnalysis> easiestQuestions;
  final List<OptionAnalysis> optionAnalysis;

  ItemAnalysis({
    required this.contestId,
    required this.contestName,
    required this.hardestQuestions,
    required this.easiestQuestions,
    required this.optionAnalysis,
  });

  factory ItemAnalysis.fromJson(Map<String, dynamic> json) {
    return ItemAnalysis(
      contestId: json['contestId'] ?? '',
      contestName: json['contestName'] ?? '',
      hardestQuestions: (json['hardestQuestions'] as List? ?? [])
          .map((i) => QuestionAnalysis.fromJson(i))
          .toList(),
      easiestQuestions: (json['easiestQuestions'] as List? ?? [])
          .map((i) => QuestionAnalysis.fromJson(i))
          .toList(),
      optionAnalysis: (json['optionAnalysis'] as List? ?? [])
          .map((i) => OptionAnalysis.fromJson(i))
          .toList(),
    );
  }
}

class QuestionAnalysis {
  final String questionId;
  final int questionNo;
  final String content;
  final int attempts;
  final int correctCount;
  final int wrongCount;
  final double correctRate;
  final double wrongRate;

  QuestionAnalysis({
    required this.questionId,
    required this.questionNo,
    required this.content,
    required this.attempts,
    required this.correctCount,
    required this.wrongCount,
    required this.correctRate,
    required this.wrongRate,
  });

  factory QuestionAnalysis.fromJson(Map<String, dynamic> json) {
    return QuestionAnalysis(
      questionId: json['questionId'] ?? '',
      questionNo: json['questionNo'] ?? 0,
      content: json['content'] ?? '',
      attempts: json['attempts'] ?? 0,
      correctCount: json['correctCount'] ?? 0,
      wrongCount: json['wrongCount'] ?? 0,
      correctRate: (json['correctRate'] ?? 0).toDouble(),
      wrongRate: (json['wrongRate'] ?? 0).toDouble(),
    );
  }
}

class OptionAnalysis {
  final String questionId;
  final int questionNo;
  final String content;
  final int attempts;
  final Map<String, int> optionCounts;

  OptionAnalysis({
    required this.questionId,
    required this.questionNo,
    required this.content,
    required this.attempts,
    required this.optionCounts,
  });

  factory OptionAnalysis.fromJson(Map<String, dynamic> json) {
    return OptionAnalysis(
      questionId: json['questionId'] ?? '',
      questionNo: json['questionNo'] ?? 0,
      content: json['content'] ?? '',
      attempts: json['attempts'] ?? 0,
      optionCounts: Map<String, int>.from(json['optionCounts'] ?? {}),
    );
  }
}
