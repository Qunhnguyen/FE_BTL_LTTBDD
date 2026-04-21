import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AdminRepository(apiClient);
});

class AdminRepository {
  final ApiClient _apiClient;

  AdminRepository(this._apiClient);

  // --- 1. Admin Profile ---
  Future<dynamic> getMyProfile() async {
    final response = await _apiClient.get('/api/admin/profile');
    return response.data;
  }

  Future<dynamic> updateMyProfile(String name) async {
    final response = await _apiClient.put('/api/admin/profile', data: {'name': name});
    return response.data;
  }

  Future<dynamic> uploadAvatar(File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });
    final response = await _apiClient.post('/api/admin/profile/avatar', data: formData);
    return response.data;
  }

  // --- 2. Auth (Me) ---
  Future<dynamic> getMe() async {
    final response = await _apiClient.get('/api/auth/me');
    return response.data;
  }

  // --- 3. Subject ---
  Future<List<dynamic>> getAllSubjects() async {
    final response = await _apiClient.get('/api/admin/subject');
    return response.data as List<dynamic>;
  }

  Future<dynamic> createSubject(String name, String description) async {
    final response = await _apiClient.post('/api/admin/subject', data: {
      'name': name,
      'description': description,
    });
    return response.data;
  }

  Future<dynamic> updateSubject(String id, String name, String description) async {
    final response = await _apiClient.put('/api/admin/subject/$id', data: {
      'name': name,
      'description': description,
    });
    return response.data;
  }

  Future<void> deleteSubject(String id) async {
    await _apiClient.delete('/api/admin/subject/$id');
  }

  // --- 4. Contest ---
  Future<List<dynamic>> getContestsBySubject(String subjectId) async {
    final response = await _apiClient.get('/api/admin/subjects/$subjectId/contests');
    return response.data as List<dynamic>;
  }

  Future<dynamic> createContest(String subjectId, Map<String, dynamic> data) async {
    final response = await _apiClient.post('/api/admin/subjects/$subjectId/contests', data: data);
    return response.data;
  }

  Future<dynamic> updateContest(String subjectId, String contestId, Map<String, dynamic> data) async {
    final response = await _apiClient.put('/api/admin/subjects/$subjectId/contests/$contestId', data: data);
    return response.data;
  }

  Future<void> deleteContest(String subjectId, String contestId) async {
    await _apiClient.delete('/api/admin/subjects/$subjectId/contests/$contestId');
  }

  // --- 5. Question ---
  Future<List<dynamic>> getQuestionsByContest(String contestId) async {
    final response = await _apiClient.get('/api/admin/questions/contest/$contestId');
    return response.data as List<dynamic>;
  }

  Future<dynamic> createQuestion(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/api/admin/questions', data: data);
    return response.data;
  }

  Future<dynamic> updateQuestion(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('/api/admin/questions/$id', data: data);
    return response.data;
  }

  Future<void> deleteQuestion(String id) async {
    await _apiClient.delete('/api/admin/questions/$id');
  }

  // --- 6. Import/Export CSV ---
  Future<dynamic> importQuestionsCsv(String contestId, File file, bool replaceExisting) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
      'replaceExisting': replaceExisting.toString(),
    });
    final response = await _apiClient.post('/api/admin/import-export/contests/$contestId/questions', data: formData);
    return response.data;
  }

  Future<String> exportQuestionsToCsv(String contestId) async {
    final response = await _apiClient.get('/api/admin/import-export/contests/$contestId/questions/export');
    return response.data.toString();
  }

  // --- 7. File Storage ---
  Future<dynamic> uploadFile(File file, String? subjectId, String? contestId) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
      if (subjectId != null) 'subjectId': subjectId,
      if (contestId != null) 'contestId': contestId,
    });
    final response = await _apiClient.post('/api/admin/files/upload', data: formData);
    return response.data;
  }

  Future<dynamic> getFileMetadata(String fileId) async {
    final response = await _apiClient.get('/api/admin/files/$fileId');
    return response.data;
  }

  Future<void> deleteFile(String fileId) async {
    await _apiClient.delete('/api/admin/files/$fileId');
  }

  // --- 8. Teachers ---
  Future<List<dynamic>> getAllTeachers() async {
    final response = await _apiClient.get('/api/admin/teachers');
    return response.data as List<dynamic>;
  }

  Future<dynamic> createTeacher(String email, String name, String password) async {
    final response = await _apiClient.post('/api/admin/teachers', data: {
      'email': email,
      'name': name,
      'password': password,
    });
    return response.data;
  }

  Future<dynamic> updateTeacher(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('/api/admin/teachers/$id', data: data);
    return response.data;
  }

  Future<void> deactivateTeacher(String id) async {
    await _apiClient.delete('/api/admin/teachers/$id');
  }

  // --- 9. Students ---
  Future<List<dynamic>> getAllStudents() async {
    final response = await _apiClient.get('/api/admin/students');
    return response.data as List<dynamic>;
  }

  Future<dynamic> createStudent(String email, String name, String password) async {
    final response = await _apiClient.post('/api/admin/students', data: {
      'email': email,
      'name': name,
      'password': password,
    });
    return response.data;
  }

  Future<dynamic> updateStudent(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('/api/admin/students/$id', data: data);
    return response.data;
  }

  Future<void> deactivateStudent(String id) async {
    await _apiClient.delete('/api/admin/students/$id');
  }

  // --- 10. AI ---
  Future<dynamic> generateAiExam(String subjectId, Map<String, dynamic> data) async {
    final response = await _apiClient.post('/api/admin/subjects/$subjectId/ai/exams/generate', data: data);
    return response.data;
  }

  Future<dynamic> getAiJobDetail(String subjectId, String jobId) async {
    final response = await _apiClient.get('/api/admin/subjects/$subjectId/ai/exams/jobs/$jobId');
    return response.data;
  }

  Future<dynamic> approveAiExam(String subjectId, String jobId) async {
    final response = await _apiClient.post('/api/admin/subjects/$subjectId/ai/exams/jobs/$jobId/approve');
    return response.data;
  }

  Future<dynamic> ingestKnowledgeText(String subjectId, Map<String, dynamic> data) async {
    final response = await _apiClient.post('/api/admin/subjects/$subjectId/ai/knowledge/ingest', data: data);
    return response.data;
  }

  Future<dynamic> ingestKnowledgeFile(String subjectId, File file, String title, String sourceType, String? classroomId) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
      'title': title,
      'sourceType': sourceType,
      if (classroomId != null) 'classroomId': classroomId,
    });
    final response = await _apiClient.post('/api/admin/subjects/$subjectId/ai/knowledge/ingest-file', data: formData);
    return response.data;
  }

  // Dashboard Stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final subjects = await getAllSubjects();
      final teachers = await getAllTeachers();
      final students = await getAllStudents();
      return {
        'subjectCount': subjects.length,
        'teacherCount': teachers.length,
        'studentCount': students.length,
      };
    } catch (e) {
      return {'subjectCount': 0, 'teacherCount': 0, 'studentCount': 0};
    }
  }
}
