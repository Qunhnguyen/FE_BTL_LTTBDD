import 'question.dart';

class StartQuizResponse {
  final String submissionId;
  final String quizId;
  final String quizName;
  final int durationMinutes;
  final int attemptNumber;
  final int totalQuestions;
  final List<Question> questions;

  StartQuizResponse({
    required this.submissionId,
    required this.quizId,
    required this.quizName,
    required this.durationMinutes,
    required this.attemptNumber,
    required this.totalQuestions,
    required this.questions,
  });

  factory StartQuizResponse.fromJson(Map<String, dynamic> json) {
    return StartQuizResponse(
      submissionId: json['submissionId'] ?? '',
      quizId: json['quizId'] ?? '',
      quizName: json['quizName'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 0,
      attemptNumber: json['attemptNumber'] ?? 1,
      totalQuestions: json['totalQuestions'] ?? 0,
      questions: (json['questions'] as List? ?? [])
          .map((q) => Question.fromJson(q))
          .toList(),
    );
  }
}

class SubmissionResult {
  final double totalScore;
  final int correctCount;
  final int totalQuestions;
  final String status;
  final DateTime submittedAt;

  SubmissionResult({
    required this.totalScore,
    required this.correctCount,
    required this.totalQuestions,
    required this.status,
    required this.submittedAt,
  });

  factory SubmissionResult.fromJson(Map<String, dynamic> json) {
    return SubmissionResult(
      totalScore: (json['totalScore'] ?? 0).toDouble(),
      correctCount: json['correctCount'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      status: json['status'] ?? '',
      submittedAt: json['submittedAt'] != null 
          ? DateTime.parse(json['submittedAt']) 
          : DateTime.now(),
    );
  }
}
