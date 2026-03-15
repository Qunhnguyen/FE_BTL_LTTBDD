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

// Provider trả về danh sách đã được lọc
final filteredManagedQuestionsProvider = Provider<AsyncValue<List<ManagedQuestion>>>((ref) {
  final questionsAsync = ref.watch(managedQuestionsProvider);
  final filter = ref.watch(questionFilterProvider);

  return questionsAsync.whenData((questions) {
    if (filter == null) return questions;
    return questions.where((q) => q.difficulty == filter).toList();
  });
});
