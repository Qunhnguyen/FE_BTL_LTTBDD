class QuizResult {
  final int score;
  final int totalPossibleScore;
  final int correctAnswers;
  final int totalQuestions;
  final String timeTaken; // e.g., "12:45"
  final String message;

  QuizResult({
    required this.score,
    required this.totalPossibleScore,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeTaken,
    required this.message,
  });
}
