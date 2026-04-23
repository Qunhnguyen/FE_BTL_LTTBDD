import '../../../auth/models/user.dart';
import '../../data/models/classroom_models.dart';

abstract class ClassroomRepository {
  // Teacher APIs
  Future<List<ClassroomResponse>> getTeacherClassrooms(String subjectId);
  Future<ClassroomResponse> getClassroomById(String subjectId, String classroomId);
  Future<ClassroomResponse> createClassroom(String subjectId, String name, List<String> studentIds);
  Future<ClassroomResponse> updateClassroom(String subjectId, String classroomId, {String? name, List<String>? studentIds});
  Future<ClassroomResponse> addStudents(String subjectId, String classroomId, List<String> studentIds);
  Future<ClassroomResponse> removeStudent(String subjectId, String classroomId, String studentId);
  Future<ClassroomResponse> regenerateInviteCode(String subjectId, String classroomId);
  Future<void> sendInvites(String subjectId, String classroomId, List<String> studentIds);
  Future<void> deleteClassroom(String subjectId, String classroomId);
  Future<List<User>> getAllStudents(); // Thêm hàm này

  // Student APIs
  Future<List<ClassroomResponse>> getStudentClassrooms();
  Future<List<Map<String, dynamic>>> getStudentClassroomQuizzes(String classroomId);
  Future<ClassroomResponse> joinByCode(String inviteCode);
  Future<ClassroomResponse> acceptInvite(String notificationId);
  Future<void> declineInvite(String notificationId);
  
  // Notifications
  Future<NotificationListResponse> getStudentNotifications();
}
