import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/app_failure.dart';
import '../../domain/repositories/classroom_repository.dart';
import 'classroom_state.dart';

class ClassroomNotifier extends StateNotifier<ClassroomState> {
  final ClassroomRepository _repository;

  ClassroomNotifier(this._repository) : super(ClassroomInitial());

  // --- Teacher Actions ---

  Future<void> fetchTeacherClassrooms(String subjectId) async {
    state = ClassroomLoading();
    try {
      final classrooms = await _repository.getTeacherClassrooms(subjectId);
      state = ClassroomLoaded(classrooms);
    } on AppFailure catch (e) {
      state = ClassroomError(e.message);
    }
  }

  Future<void> fetchClassroomDetail(String subjectId, String classroomId) async {
    state = ClassroomLoading();
    try {
      final classroom = await _repository.getClassroomById(subjectId, classroomId);
      state = ClassroomDetailLoaded(classroom);
    } on AppFailure catch (e) {
      state = ClassroomError(e.message);
    }
  }

  Future<void> createClassroom(String subjectId, String name, List<String> studentIds) async {
    state = ClassroomLoading();
    try {
      // Bước 1: Tạo lớp học mới với danh sách sinh viên rỗng để đảm bảo không add trực tiếp
      final classroom = await _repository.createClassroom(subjectId, name, []);
      
      // Bước 2: Nếu có sinh viên được chọn, thực hiện gửi lời mời
      if (studentIds.isNotEmpty) {
        await _repository.sendInvites(subjectId, classroom.id, studentIds);
      }
      
      state = ClassroomOperationSuccess('Lớp học đã được tạo và lời mời đã được gửi đi', classroom: classroom);
      fetchTeacherClassrooms(subjectId);
    } on AppFailure catch (e) {
      state = ClassroomError(e.message);
    }
  }

  Future<void> updateClassroom(String subjectId, String classroomId, {String? name, List<String>? studentIds}) async {
    state = ClassroomLoading();
    try {
      final classroom = await _repository.updateClassroom(subjectId, classroomId, name: name, studentIds: studentIds);
      state = ClassroomOperationSuccess('Classroom updated successfully', classroom: classroom);
      state = ClassroomDetailLoaded(classroom);
    } on AppFailure catch (e) {
      state = ClassroomError(e.message);
    }
  }

  Future<void> sendInvites(String subjectId, String classroomId, List<String> studentIds) async {
    state = ClassroomLoading();
    try {
      await _repository.sendInvites(subjectId, classroomId, studentIds);
      state = ClassroomOperationSuccess('Đã gửi lời mời tới ${studentIds.length} sinh viên');
      fetchClassroomDetail(subjectId, classroomId);
    } on AppFailure catch (e) {
      state = ClassroomError(e.message);
    }
  }

  Future<void> removeStudent(String subjectId, String classroomId, String studentId) async {
    state = ClassroomLoading();
    try {
      final classroom = await _repository.removeStudent(subjectId, classroomId, studentId);
      state = ClassroomOperationSuccess('Đã xóa sinh viên khỏi lớp', classroom: classroom);
      state = ClassroomDetailLoaded(classroom);
    } on AppFailure catch (e) {
      state = ClassroomError(e.message);
    }
  }

  Future<void> deleteClassroom(String subjectId, String classroomId) async {
    state = ClassroomLoading();
    try {
      await _repository.deleteClassroom(subjectId, classroomId);
      state = ClassroomOperationSuccess('Classroom deleted successfully');
      fetchTeacherClassrooms(subjectId);
    } on AppFailure catch (e) {
      state = ClassroomError(e.message);
    }
  }

  Future<void> regenerateInviteCode(String subjectId, String classroomId) async {
    try {
      final classroom = await _repository.regenerateInviteCode(subjectId, classroomId);
      state = ClassroomOperationSuccess('Invite code regenerated', classroom: classroom);
      state = ClassroomDetailLoaded(classroom);
    } on AppFailure catch (e) {
      state = ClassroomError(e.message);
    }
  }

  // --- Student Actions ---

  Future<void> fetchStudentClassrooms() async {
    state = ClassroomLoading();
    try {
      final classrooms = await _repository.getStudentClassrooms();
      state = ClassroomLoaded(classrooms);
    } on AppFailure catch (e) {
      state = ClassroomError(e.message);
    }
  }

  Future<void> joinByCode(String inviteCode) async {
    state = ClassroomLoading();
    try {
      final classroom = await _repository.joinByCode(inviteCode);
      state = ClassroomOperationSuccess('Joined classroom successfully', classroom: classroom);
      fetchStudentClassrooms();
    } on AppFailure catch (e) {
      state = ClassroomError(e.message);
    }
  }

  Future<void> acceptInvite(String notificationId) async {
    state = ClassroomLoading();
    try {
      final classroom = await _repository.acceptInvite(notificationId);
      state = ClassroomOperationSuccess('Invite accepted', classroom: classroom);
      fetchStudentClassrooms();
    } on AppFailure catch (e) {
      state = ClassroomError(e.message);
    }
  }
}
