import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/contest.dart';

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

  // Admin endpoints
  Future<List<Contest>> getContestsBySubject(String subjectId) async {
    final response = await _apiClient.get('/api/admin/subjects/$subjectId/contests');
    final List<dynamic> data = response.data;
    return data.map((json) => Contest.fromJson(json)).toList();
  }

  Future<Contest> createContest(String subjectId, Contest contest) async {
    // Note: You might need a specialized toJson for creation
    final response = await _apiClient.post('/api/admin/subjects/$subjectId/contests', data: {
      'title': contest.title,
      'description': contest.description,
      'durationMinutes': contest.durationMinutes,
      'startTime': contest.startTime?.toIso8601String(),
    });
    return Contest.fromJson(response.data);
  }

  Future<void> importQuestions(String subjectId, String contestId, String fileId) async {
    await _apiClient.post('/api/admin/subjects/$subjectId/contests/$contestId/import-questions', queryParameters: {
      'fileId': fileId,
    });
  }
}
