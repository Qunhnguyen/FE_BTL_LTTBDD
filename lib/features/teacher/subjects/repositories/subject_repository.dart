import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/subject.dart';

final subjectRepositoryProvider = Provider<SubjectRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SubjectRepository(apiClient);
});

class SubjectRepository {
  final ApiClient _apiClient;

  SubjectRepository(this._apiClient);

  Future<List<Subject>> getSubjects() async {
    final response = await _apiClient.get('/api/admin/subject');
    final List<dynamic> data = response.data;
    return data.map((json) => Subject.fromJson(json)).toList();
  }

  Future<Subject> getSubjectById(String id) async {
    final response = await _apiClient.get('/api/admin/subject/$id');
    return Subject.fromJson(response.data);
  }

  Future<Subject> createSubject(Subject subject) async {
    final response = await _apiClient.post('/api/admin/subject', data: subject.toJson());
    return Subject.fromJson(response.data);
  }

  Future<Subject> updateSubject(String id, Subject subject) async {
    final response = await _apiClient.put('/api/admin/subject/$id', data: subject.toJson());
    return Subject.fromJson(response.data);
  }

  Future<void> deleteSubject(String id) async {
    await _apiClient.delete('/api/admin/subject/$id');
  }
}
