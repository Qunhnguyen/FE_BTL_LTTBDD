import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/question.dart';
import '../models/quiz_submission.dart';

final studentQuizRepositoryProvider = Provider<StudentQuizRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return StudentQuizRepository(apiClient);
});

class StudentQuizRepository {
  final ApiClient _apiClient;
  StudentQuizRepository(this._apiClient);

  // 1. Lấy danh sách Quiz theo Subject
  Future<List<dynamic>> getQuizzes(String subjectId) async {
    final response = await _apiClient.get('/api/student/quizzes', queryParameters: {'subjectId': subjectId});
    return response.data;
  }

  // 2. Lấy chi tiết Quiz
  Future<Map<String, dynamic>> getQuizDetail(String quizId) async {
    final response = await _apiClient.get('/api/student/quizzes/$quizId');
    return response.data;
  }

  // 3. Start Quiz -> Nhận submissionId và list questions
  Future<StartQuizResponse> startQuiz(String quizId) async {
    final response = await _apiClient.post('/api/student/quizzes/$quizId/start');
    return StartQuizResponse.fromJson(response.data);
  }

  // 4. Submit từng câu -> Trả về kết quả đúng/sai realtime
  Future<Map<String, dynamic>> submitAnswer(String submissionId, String questionId, String selectedOption) async {
    final response = await _apiClient.post(
      '/api/student/submissions/$submissionId/answer',
      data: {
        'questionId': questionId,
        'selectedOption': selectedOption,
      },
    );
    return response.data;
  }

  // 5. Use Power-up
  Future<Map<String, dynamic>> usePowerUp(String submissionId, String questionId, String type) async {
    final response = await _apiClient.post(
      '/api/student/submissions/$submissionId/power-up',
      data: {'type': type, 'questionId': questionId},
    );
    return response.data;
  }

  // 6. Finish
  Future<Map<String, dynamic>> finishQuiz(String submissionId) async {
    final response = await _apiClient.post('/api/student/submissions/$submissionId/finish');
    return response.data;
  }

  // 7. History
  Future<List<dynamic>> getHistory() async {
    final response = await _apiClient.get('/api/student/submissions/history');
    return response.data;
  }
}
