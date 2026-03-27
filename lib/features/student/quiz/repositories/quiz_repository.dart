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

  // API lấy chi tiết cuộc thi kèm danh sách câu hỏi dành cho Student
  Future<Map<String, dynamic>> getStudentContestDetail(String contestId) async {
    final response = await _apiClient.get('/api/student/contests/$contestId');
    return response.data;
  }

  // API lấy danh sách câu hỏi (dùng endpoint admin nếu cần hoặc contest detail)
  Future<List<Question>> getQuestionsForContest(String contestId) async {
    // Ưu tiên dùng endpoint detail của contest vì nó trả về questions mảng phẳng
    final data = await getStudentContestDetail(contestId);
    final List<dynamic> questionsRaw = data['questions'] ?? [];
    return questionsRaw.map((q) => Question.fromJson(q)).toList();
  }

  // API bắt đầu làm bài
  Future<Map<String, dynamic>> startSubmission(
      String contestId, String studentId) async {
    final response =
        await _apiClient.post('/api/student/submissions/$contestId/start');
    return response.data;
  }

  // API nộp đáp án từng câu
  Future<void> submitAnswer(
      String submissionId, String questionId, String answer) async {
    await _apiClient.post(
      '/api/student/submissions/$submissionId/answer',
      data: {
        'questionId': questionId,
        'selectedOption': answer,
      },
    );
  }

  // API kết thúc bài thi (Chốt điểm)
  Future<Map<String, dynamic>> finishSubmission(String submissionId) async {
    final response =
        await _apiClient.post('/api/student/submissions/$submissionId/finish');
    return response.data; // Trả về kết quả: score, correctCount, time, v.v.
  }

  // API sử dụng quyền trợ giúp
  Future<Map<String, dynamic>> usePowerUp(
      String submissionId, String questionId, String type) async {
    final response = await _apiClient.post(
      '/api/student/submissions/$submissionId/power-up',
      data: {
        'type': type, // "50_50", "SKIP", "ASK_AUDIENCE"
        'questionId': questionId,
      },
    );
    return response.data;
  }
}
