import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/contest.dart';
import '../../../teacher/dashboard/models/contest_analytics.dart';

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

  // Teacher Analytics
  Future<ContestAnalytics> getContestAnalytics(String contestId) async {
    final response = await _apiClient.get('/api/teacher/analytics/contests/$contestId');
    return ContestAnalytics.fromJson(response.data);
  }
}
