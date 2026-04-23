import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/managed_question.dart';
import '../repositories/question_repository.dart';

// Provider quản lý contestId hiện tại đang được quản lý câu hỏi
final activeContestIdProvider = StateProvider<String?>((ref) => null);

// Provider lấy danh sách câu hỏi từ API dựa trên contestId
final managedQuestionsProvider = FutureProvider<List<ManagedQuestion>>((ref) async {
  final contestId = ref.watch(activeContestIdProvider);
  if (contestId == null) return [];
  
  final repository = ref.watch(questionRepositoryProvider);
  return repository.getQuestionsByContest(contestId);
});

// Provider quản lý bộ lọc độ khó
final questionFilterProvider = StateProvider<QuestionDifficulty?>((ref) => null);
final questionSearchQueryProvider = StateProvider<String>((ref) => '');

// Provider trả về danh sách đã được lọc
final filteredManagedQuestionsProvider = Provider<AsyncValue<List<ManagedQuestion>>>((ref) {
  final questionsAsync = ref.watch(managedQuestionsProvider);
  final filter = ref.watch(questionFilterProvider);
  final query = ref.watch(questionSearchQueryProvider).trim().toLowerCase();

  return questionsAsync.whenData((questions) {
    return questions.where((q) {
      final matchesDifficulty = filter == null || q.difficulty == filter;
      if (!matchesDifficulty) return false;

      if (query.isEmpty) return true;

      final text = q.text.toLowerCase();
      final optionA = (q.optionA ?? '').toLowerCase();
      final optionB = (q.optionB ?? '').toLowerCase();
      final optionC = (q.optionC ?? '').toLowerCase();
      final optionD = (q.optionD ?? '').toLowerCase();
      final correctOption = (q.correctOption ?? '').toLowerCase();
      final difficulty = q.difficulty.name.toLowerCase();

      return text.contains(query) ||
          optionA.contains(query) ||
          optionB.contains(query) ||
          optionC.contains(query) ||
          optionD.contains(query) ||
          correctOption.contains(query) ||
          difficulty.contains(query);
    }).toList();
  });
});
