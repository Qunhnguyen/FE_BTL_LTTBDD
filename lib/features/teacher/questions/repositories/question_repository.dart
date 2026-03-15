import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/managed_question.dart';

final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return QuestionRepository(apiClient);
});

class QuestionRepository {
  final ApiClient _apiClient;

  QuestionRepository(this._apiClient);

  Future<List<ManagedQuestion>> getQuestionsByContest(String contestId) async {
    final response = await _apiClient.get('/api/admin/questions/contest/$contestId');
    final List<dynamic> data = response.data;
    return data.map((json) => ManagedQuestion.fromJson(json)).toList();
  }

  Future<ManagedQuestion> createQuestion(Map<String, dynamic> questionData) async {
    final response = await _apiClient.post('/api/admin/questions', data: questionData);
    return ManagedQuestion.fromJson(response.data);
  }

  Future<void> deleteQuestion(String id) async {
    await _apiClient.delete('/api/admin/questions/$id');
  }
  
  Future<ManagedQuestion> updateQuestion(String id, Map<String, dynamic> questionData) async {
    final response = await _apiClient.put('/api/admin/questions/$id', data: questionData);
    return ManagedQuestion.fromJson(response.data);
  }
}
