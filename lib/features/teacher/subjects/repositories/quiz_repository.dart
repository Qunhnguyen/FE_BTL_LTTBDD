import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/quiz.dart';

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return QuizRepository(apiClient);
});

class QuizRepository {
  final ApiClient _apiClient;

  QuizRepository(this._apiClient);

  Future<List<Quiz>> getQuizzes(String subjectId, {Map<String, dynamic>? filters}) async {
    final response = await _apiClient.get(
      '/api/admin/subjects/$subjectId/quizzes',
      queryParameters: filters,
    );
    final List<dynamic> data = response.data;
    return data.map((json) => Quiz.fromJson(json)).toList();
  }

  Future<Quiz> getQuizById(String subjectId, String quizId) async {
    final response = await _apiClient.get('/api/admin/subjects/$subjectId/quizzes/$quizId');
    return Quiz.fromJson(response.data);
  }

  Future<Quiz> createQuiz(String subjectId, Map<String, dynamic> quizRequest) async {
    final response = await _apiClient.post(
      '/api/admin/subjects/$subjectId/quizzes',
      data: quizRequest,
    );
    return Quiz.fromJson(response.data);
  }

  Future<Quiz> updateQuiz(String subjectId, String quizId, Map<String, dynamic> quizRequest) async {
    final response = await _apiClient.put(
      '/api/admin/subjects/$subjectId/quizzes/$quizId',
      data: quizRequest,
    );
    return Quiz.fromJson(response.data);
  }

  Future<void> publishQuiz(String subjectId, String quizId) async {
    await _apiClient.post('/api/admin/subjects/$subjectId/quizzes/$quizId/publish');
  }

  Future<void> closeQuiz(String subjectId, String quizId) async {
    await _apiClient.post('/api/admin/subjects/$subjectId/quizzes/$quizId/close');
  }

  Future<void> deleteQuiz(String subjectId, String quizId) async {
    await _apiClient.delete('/api/admin/subjects/$subjectId/quizzes/$quizId');
  }
}
