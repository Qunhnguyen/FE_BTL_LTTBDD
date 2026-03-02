import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_result.dart';

final quizResultProvider = Provider<QuizResult>((ref) {
  // This is mock data. In a real app, you would calculate this based on the user's answers.
  return QuizResult(
    score: 85,
    totalPossibleScore: 100,
    correctAnswers: 17,
    totalQuestions: 20,
    timeTaken: '12:45',
    message: 'Làm tốt lắm! Bạn đã nắm vững kiến thức của bài học này.',
  );
});
