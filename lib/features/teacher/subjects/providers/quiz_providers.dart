import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz.dart';
import '../repositories/quiz_repository.dart';

final quizListProvider = FutureProvider.family<List<Quiz>, String>((ref, subjectId) async {
  final repository = ref.watch(quizRepositoryProvider);
  return repository.getQuizzes(subjectId);
});

final quizDetailProvider = FutureProvider.family<Quiz, ({String subjectId, String quizId})>((ref, arg) async {
  final repository = ref.watch(quizRepositoryProvider);
  return repository.getQuizById(arg.subjectId, arg.quizId);
});

class QuizActionsController extends StateNotifier<AsyncValue<void>> {
  final QuizRepository _repository;
  final Ref _ref;

  QuizActionsController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> createQuiz(String subjectId, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.createQuiz(subjectId, data));
    _ref.invalidate(quizListProvider(subjectId));
  }

  Future<void> updateQuiz(String subjectId, String quizId, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.updateQuiz(subjectId, quizId, data));
    _ref.invalidate(quizListProvider(subjectId));
    _ref.invalidate(quizDetailProvider((subjectId: subjectId, quizId: quizId)));
  }

  Future<void> publishQuiz(String subjectId, String quizId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.publishQuiz(subjectId, quizId));
    _ref.invalidate(quizListProvider(subjectId));
    _ref.invalidate(quizDetailProvider((subjectId: subjectId, quizId: quizId)));
  }

  Future<void> closeQuiz(String subjectId, String quizId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.closeQuiz(subjectId, quizId));
    _ref.invalidate(quizListProvider(subjectId));
    _ref.invalidate(quizDetailProvider((subjectId: subjectId, quizId: quizId)));
  }

  Future<void> deleteQuiz(String subjectId, String quizId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.deleteQuiz(subjectId, quizId));
    _ref.invalidate(quizListProvider(subjectId));
  }
}

final quizActionsControllerProvider = StateNotifierProvider<QuizActionsController, AsyncValue<void>>((ref) {
  final repository = ref.watch(quizRepositoryProvider);
  return QuizActionsController(repository, ref);
});
