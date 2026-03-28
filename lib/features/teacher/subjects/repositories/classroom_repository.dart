import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/models/user.dart';
import '../models/classroom.dart';

final classroomRepositoryProvider = Provider<ClassroomRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ClassroomRepository(apiClient);
});

class ClassroomRepository {
  final ApiClient _apiClient;
  ClassroomRepository(this._apiClient);

  // Lấy danh sách toàn bộ sinh viên (để add vào lớp)
  Future<List<User>> getAllStudents() async {
    final response = await _apiClient.get('/api/admin/students');
    final List<dynamic> data = response.data;
    return data.map((json) => User.fromJson(json)).toList();
  }

  // Lấy danh sách lớp theo môn học
  Future<List<Classroom>> getClassroomsBySubject(String subjectId) async {
    final response = await _apiClient.get('/api/admin/subjects/$subjectId/classrooms');
    final List<dynamic> data = response.data;
    return data.map((json) => Classroom.fromJson(json)).toList();
  }

  // Tạo lớp mới
  Future<Classroom> createClassroom(String subjectId, String name, List<String> studentIds) async {
    final response = await _apiClient.post(
      '/api/admin/subjects/$subjectId/classrooms',
      data: {
        'name': name,
        'studentIds': studentIds,
      },
    );
    return Classroom.fromJson(response.data);
  }

  // Cập nhật lớp
  Future<Classroom> updateClassroom(String subjectId, String classroomId, String name, List<String> studentIds) async {
    final response = await _apiClient.put(
      '/api/admin/subjects/$subjectId/classrooms/$classroomId',
      data: {
        'name': name,
        'studentIds': studentIds,
      },
    );
    return Classroom.fromJson(response.data);
  }

  // Xóa lớp
  Future<void> deleteClassroom(String subjectId, String classroomId) async {
    await _apiClient.delete('/api/admin/subjects/$subjectId/classrooms/$classroomId');
  }
}
