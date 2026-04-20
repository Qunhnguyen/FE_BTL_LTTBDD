import '../../../../core/network/api_client.dart';
import '../../../../features/auth/models/user.dart';
import '../../domain/repositories/classroom_repository.dart';
import '../models/classroom_models.dart';

class ClassroomRepositoryImpl implements ClassroomRepository {
  final ApiClient _apiClient;

  ClassroomRepositoryImpl(this._apiClient);

  @override
  Future<List<ClassroomResponse>> getTeacherClassrooms(String subjectId) async {
    final response = await _apiClient.get('/api/admin/subjects/$subjectId/classrooms');
    return (response.data as List).map((e) => ClassroomResponse.fromJson(e)).toList();
  }

  @override
  Future<ClassroomResponse> getClassroomById(String subjectId, String classroomId) async {
    final response = await _apiClient.get('/api/admin/subjects/$subjectId/classrooms/$classroomId');
    return ClassroomResponse.fromJson(response.data);
  }

  @override
  Future<ClassroomResponse> createClassroom(String subjectId, String name, List<String> studentIds) async {
    final response = await _apiClient.post(
      '/api/admin/subjects/$subjectId/classrooms',
      data: {'name': name, 'studentIds': studentIds},
    );
    return ClassroomResponse.fromJson(response.data);
  }

  @override
  Future<ClassroomResponse> updateClassroom(String subjectId, String classroomId, {String? name, List<String>? studentIds}) async {
    final response = await _apiClient.put(
      '/api/admin/subjects/$subjectId/classrooms/$classroomId',
      data: {
        if (name != null) 'name': name,
        if (studentIds != null) 'studentIds': studentIds,
      },
    );
    return ClassroomResponse.fromJson(response.data);
  }

  @override
  Future<ClassroomResponse> addStudents(String subjectId, String classroomId, List<String> studentIds) async {
    final response = await _apiClient.post(
      '/api/admin/subjects/$subjectId/classrooms/$classroomId/students',
      data: {'studentIds': studentIds},
    );
    return ClassroomResponse.fromJson(response.data);
  }

  @override
  Future<ClassroomResponse> removeStudent(String subjectId, String classroomId, String studentId) async {
    final response = await _apiClient.delete(
      '/api/admin/subjects/$subjectId/classrooms/$classroomId/students/$studentId',
    );
    return ClassroomResponse.fromJson(response.data);
  }

  @override
  Future<ClassroomResponse> regenerateInviteCode(String subjectId, String classroomId) async {
    final response = await _apiClient.post(
      '/api/admin/subjects/$subjectId/classrooms/$classroomId/invite-code/regenerate',
    );
    return ClassroomResponse.fromJson(response.data);
  }

  @override
  Future<void> sendInvites(String subjectId, String classroomId, List<String> studentIds) async {
    await _apiClient.post(
      '/api/admin/subjects/$subjectId/classrooms/$classroomId/invites',
      data: {'studentIds': studentIds},
    );
  }

  @override
  Future<void> deleteClassroom(String subjectId, String classroomId) async {
    await _apiClient.delete('/api/admin/subjects/$subjectId/classrooms/$classroomId');
  }

  @override
  Future<List<User>> getAllStudents() async {
    final response = await _apiClient.get('/api/admin/students');
    final List<dynamic> data = response.data;
    return data.map((json) => User.fromJson(json)).toList();
  }

  @override
  Future<List<ClassroomResponse>> getStudentClassrooms() async {
    final response = await _apiClient.get('/api/student/classrooms');
    return (response.data as List).map((e) => ClassroomResponse.fromJson(e)).toList();
  }

  @override
  Future<ClassroomResponse> joinByCode(String inviteCode) async {
    final response = await _apiClient.post(
      '/api/student/classrooms/join-by-code',
      data: {'inviteCode': inviteCode},
    );
    return ClassroomResponse.fromJson(response.data);
  }

  @override
  Future<ClassroomResponse> acceptInvite(String notificationId) async {
    final response = await _apiClient.post(
      '/api/student/classrooms/notifications/$notificationId/accept',
    );
    return ClassroomResponse.fromJson(response.data);
  }

  @override
  Future<void> declineInvite(String notificationId) async {
    await _apiClient.post(
      '/api/student/classrooms/notifications/$notificationId/decline',
    );
  }

  @override
  Future<NotificationListResponse> getStudentNotifications() async {
    final response = await _apiClient.get('/api/student/notifications');
    return NotificationListResponse.fromJson(response.data);
  }
}
