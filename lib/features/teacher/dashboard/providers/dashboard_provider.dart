import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../subjects/repositories/subject_repository.dart';
import '../../subjects/repositories/quiz_repository.dart';
import '../../subjects/models/quiz.dart';

// Provider lấy các con số thống kê tổng quát cho giáo viên
final teacherStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final subjectRepo = ref.watch(subjectRepositoryProvider);
  final subjects = await subjectRepo.getSubjects();
  
  int totalQuizzes = 0;
  final quizRepo = ref.watch(quizRepositoryProvider);
  
  for (var subject in subjects) {
    try {
      final quizzes = await quizRepo.getQuizzes(subject.id);
      totalQuizzes += quizzes.length;
    } catch (_) {}
  }
  
  return {
    'totalSubjects': subjects.length,
    'totalQuizzes': totalQuizzes,
  };
});

// Provider lấy danh sách QUIZ mới nhất cho dashboard
final recentTeacherQuizzesProvider = FutureProvider<List<Quiz>>((ref) async {
  final subjectRepo = ref.watch(subjectRepositoryProvider);
  final quizRepo = ref.watch(quizRepositoryProvider);
  
  final subjects = await subjectRepo.getSubjects();
  List<Quiz> allQuizzes = [];
  
  for (var subject in subjects) {
    try {
      final quizzes = await quizRepo.getQuizzes(subject.id);
      allQuizzes.addAll(quizzes);
    } catch (_) {}
  }
  
  // Sắp xếp theo ID giảm dần (giả định cái sau mới hơn)
  allQuizzes.sort((a, b) => b.id.compareTo(a.id));
  
  return allQuizzes.take(5).toList();
});
