class QuizResult {
  final double score;
  final int totalQuestions;
  final int correctCount;
  final int elapsedSeconds;
  final DateTime completedAt;

  QuizResult({
    required this.score,
    required this.totalQuestions,
    required this.correctCount,
    required this.elapsedSeconds,
    required this.completedAt,
  });

  // Ánh xạ dữ liệu từ Response 'finish' của Backend
  factory QuizResult.fromSubmission({
    required Map<String, dynamic> submissionData,
    required double totalPossibleScore,
    required int elapsedSeconds,
  }) {
    return QuizResult(
      // BE thường trả về 'score' hoặc 'totalScore'
      score: (submissionData['score'] ?? submissionData['totalScore'] ?? 0).toDouble(),
      // BE trả về 'correctCount' hoặc tính từ 'correctAnswers'
      correctCount: submissionData['correctCount'] ?? submissionData['correctAnswers'] ?? 0,
      totalQuestions: submissionData['totalQuestions'] ?? 0,
      elapsedSeconds: elapsedSeconds,
      completedAt: DateTime.now(),
    );
  }
}
