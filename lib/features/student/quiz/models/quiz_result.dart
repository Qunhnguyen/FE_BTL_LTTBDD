class QuizResult {
  final double score;
  final double totalPossibleScore;
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

  factory QuizResult.fromSubmission({
    required Map<String, dynamic> submissionData,
    required double totalPossibleScore,
    required int elapsedSeconds,
  }) {
    final score = _toDouble(submissionData['totalScore']);
    final totalQuestions = _toInt(submissionData['totalQuestions']);
    final correctAnswers = _toInt(submissionData['correctCount']);
    final accuracy = totalQuestions == 0 ? 0.0 : correctAnswers / totalQuestions;

    return QuizResult(
      score: score,
      totalPossibleScore: totalPossibleScore,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      timeTaken: _formatDuration(elapsedSeconds),
      message: _buildMessage(accuracy),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _formatDuration(int elapsedSeconds) {
    final safeSeconds = elapsedSeconds < 0 ? 0 : elapsedSeconds;
    final minutes = (safeSeconds / 60).floor();
    final seconds = safeSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  static String _buildMessage(double accuracy) {
    if (accuracy >= 0.9) {
      return 'Kết quả rất tốt. Bạn nắm bài rất chắc.';
    }
    if (accuracy >= 0.7) {
      return 'Kết quả tốt. Bạn chỉ cần ôn thêm một vài ý nhỏ.';
    }
    if (accuracy >= 0.5) {
      return 'Bạn đã hoàn thành bài thi. Nên xem lại các câu sai để cải thiện.';
    }
    return 'Bài thi đã hoàn thành. Bạn nên ôn lại kiến thức và thử lại.';
  }
}
