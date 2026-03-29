class StudentSubmissionDetail {
  final String contestId;
  final String contestName;
  final String studentId;
  final String studentName;
  final String status;
  final double totalScore;
  final int correctCount;
  final int totalQuestions;
  final DateTime? startedAt;
  final DateTime? submittedAt;
  final List<AnswerDetail> answers;

  StudentSubmissionDetail({
    required this.contestId,
    required this.contestName,
    required this.studentId,
    required this.studentName,
    required this.status,
    required this.totalScore,
    required this.correctCount,
    required this.totalQuestions,
    this.startedAt,
    this.submittedAt,
    required this.answers,
  });

  factory StudentSubmissionDetail.fromJson(Map<String, dynamic> json) {
    return StudentSubmissionDetail(
      contestId: json['contestId'] ?? '',
      contestName: json['contestName'] ?? '',
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      status: json['status'] ?? '',
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0.0,
      correctCount: json['correctCount'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      submittedAt: json['submittedAt'] != null ? DateTime.parse(json['submittedAt']) : null,
      answers: (json['answers'] as List<dynamic>?)
              ?.map((e) => AnswerDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class AnswerDetail {
  final String questionId;
  final int questionNo;
  final String content;
  final String? selectedOption;
  final String? correctOption;
  final bool correct;
  final DateTime? answeredAt;

  AnswerDetail({
    required this.questionId,
    required this.questionNo,
    required this.content,
    this.selectedOption,
    this.correctOption,
    required this.correct,
    this.answeredAt,
  });

  factory AnswerDetail.fromJson(Map<String, dynamic> json) {
    return AnswerDetail(
      questionId: json['questionId'] ?? '',
      questionNo: json['questionNo'] ?? 0,
      content: json['content'] ?? '',
      selectedOption: json['selectedOption'],
      correctOption: json['correctOption'],
      correct: json['correct'] ?? false,
      answeredAt: json['answeredAt'] != null ? DateTime.parse(json['answeredAt']) : null,
    );
  }
}
