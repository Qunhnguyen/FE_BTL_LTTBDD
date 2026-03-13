import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/question.dart';

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return QuizRepository(apiClient);
});

class QuizRepository {
  final ApiClient _apiClient;

  QuizRepository(this._apiClient);

  Future<Map<String, dynamic>> startSubmission(String contestId, String studentId) async {
    final response = await _apiClient.post(
      '/api/student/submissions/$contestId/start',
      queryParameters: {'studentId': studentId},
    );
    return response.data;
  }

  Future<void> submitAnswer(String submissionId, String questionId, String answerId) async {
    await _apiClient.post(
      '/api/student/submissions/$submissionId/answer',
      data: {
        'questionId': questionId,
        'answerId': answerId,
      },
    );
  }

  Future<Map<String, dynamic>> finishSubmission(String submissionId) async {
    final response = await _apiClient.post('/api/student/submissions/$submissionId/finish');
    return response.data;
  }

  Future<List<Question>> getQuestionsForContest(String contestId) async {
    final response = await _apiClient.get('/api/admin/questions/contest/$contestId');
    final List<dynamic> data = response.data;
    return data.map((json) => Question.fromJson(json)).toList();
  }
}
