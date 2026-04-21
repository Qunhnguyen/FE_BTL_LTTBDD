import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/contest.dart';
import '../../../teacher/dashboard/models/contest_analytics.dart';
import '../../../teacher/dashboard/models/item_analysis.dart';
import '../../../teacher/dashboard/models/scoreboard.dart';
import '../../../teacher/dashboard/models/student_submission_detail.dart';
import 'package:dio/dio.dart';

final contestRepositoryProvider = Provider<ContestRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ContestRepository(apiClient);
});

class ContestRepository {
  final ApiClient _apiClient;

  ContestRepository(this._apiClient);

  // Student endpoints
  Future<Contest> getContestById(String id) async {
    final response = await _apiClient.get('/api/student/contests/$id');
    return Contest.fromJson(response.data);
  }

  // Admin/Teacher endpoints
  Future<List<Contest>> getContestsBySubject(String subjectId) async {
    final response = await _apiClient.get('/api/admin/subjects/$subjectId/contests');
    final List<dynamic> data = response.data;
    return data.map((json) => Contest.fromJson(json)).toList();
  }

  Future<Contest> createContest(String subjectId, Map<String, dynamic> contestData) async {
    final response = await _apiClient.post(
      '/api/admin/subjects/$subjectId/contests',
      data: contestData,
    );
    return Contest.fromJson(response.data);
  }

  Future<void> deleteContest(String subjectId, String contestId) async {
    await _apiClient.delete('/api/admin/subjects/$subjectId/contests/$contestId');
  }

  Future<void> importQuestions(String subjectId, String contestId, String fileId) async {
    await _apiClient.post(
      '/api/admin/subjects/$subjectId/contests/$contestId/import-questions',
      queryParameters: {'fileId': fileId},
    );
  }

  // --- Teacher Analytics (Contest) ---
  Future<ContestAnalytics> getContestAnalytics(String contestId) async {
    final response = await _apiClient.get('/api/teacher/analytics/contests/$contestId');
    return ContestAnalytics.fromJson(response.data);
  }

  Future<ItemAnalysis> getItemAnalysis(String contestId) async {
    final response = await _apiClient.get('/api/teacher/analytics/contests/$contestId/items');
    return ItemAnalysis.fromJson(response.data);
  }

  Future<Scoreboard> getScoreboard(String contestId) async {
    final response = await _apiClient.get('/api/teacher/analytics/contests/$contestId/scoreboard');
    return Scoreboard.fromJson(response.data);
  }

  Future<Response> exportScoreboard(String contestId) async {
    return await _apiClient.get(
      '/api/teacher/analytics/contests/$contestId/scoreboard/export',
      options: Options(responseType: ResponseType.bytes),
    );
  }

  // --- Teacher Analytics (Quiz) - NEW ENDPOINTS ---
  Future<ContestAnalytics> getQuizAnalytics(String quizId) async {
    final response = await _apiClient.get('/api/teacher/analytics/quizzes/$quizId');
    return ContestAnalytics.fromJson(response.data);
  }

  Future<Scoreboard> getQuizScoreboard(String quizId) async {
    final response = await _apiClient.get('/api/teacher/analytics/quizzes/$quizId/scoreboard');
    return Scoreboard.fromJson(response.data);
  }

  Future<Response> exportQuizScoreboard(String quizId) async {
    return await _apiClient.get(
      '/api/teacher/analytics/quizzes/$quizId/scoreboard/export',
      options: Options(responseType: ResponseType.bytes),
    );
  }

  Future<StudentSubmissionDetail> getQuizStudentSubmissionDetail(String quizId, String studentId) async {
    final response = await _apiClient.get('/api/teacher/analytics/quizzes/$quizId/submissions/$studentId');
    return StudentSubmissionDetail.fromJson(response.data);
  }

  // Shared detail method
  Future<StudentSubmissionDetail> getStudentSubmissionDetail(String id, String studentId, {bool isQuiz = false}) async {
    final path = isQuiz 
      ? '/api/teacher/analytics/quizzes/$id/submissions/$studentId'
      : '/api/teacher/analytics/contests/$id/submissions/$studentId';
    final response = await _apiClient.get(path);
    return StudentSubmissionDetail.fromJson(response.data);
  }
}
