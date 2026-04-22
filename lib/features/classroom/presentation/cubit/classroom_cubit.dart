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
    } catch (e) {
      state = ClassroomError(e is AppFailure ? e.message : e.toString());
    }
  }

  Future<void> fetchClassroomDetail(String subjectId, String classroomId) async {
    state = ClassroomLoading();
    try {
      final classroom = await _repository.getClassroomById(subjectId, classroomId);
      state = ClassroomDetailLoaded(classroom);
    } catch (e) {
      state = ClassroomError(e is AppFailure ? e.message : e.toString());
    }
  }

  Future<void> createClassroom(String subjectId, String name, List<String> studentIds) async {
    state = ClassroomLoading();
    try {
      final classroom = await _repository.createClassroom(subjectId, name, []);
      if (studentIds.isNotEmpty) {
        await _repository.sendInvites(subjectId, classroom.id, studentIds);
      }
      state = ClassroomOperationSuccess('Lớp học đã được tạo và lời mời đã được gửi đi', classroom: classroom);
      fetchTeacherClassrooms(subjectId);
    } catch (e) {
      state = ClassroomError(e is AppFailure ? e.message : e.toString());
    }
  }

  Future<void> updateClassroom(String subjectId, String classroomId, {String? name, List<String>? studentIds}) async {
    state = ClassroomLoading();
    try {
      final classroom = await _repository.updateClassroom(subjectId, classroomId, name: name, studentIds: studentIds);
      state = ClassroomOperationSuccess('Cập nhật lớp học thành công', classroom: classroom);
      state = ClassroomDetailLoaded(classroom);
    } catch (e) {
      state = ClassroomError(e is AppFailure ? e.message : e.toString());
    }
  }

  Future<void> sendInvites(String subjectId, String classroomId, List<String> studentIds) async {
    state = ClassroomLoading();
    try {
      await _repository.sendInvites(subjectId, classroomId, studentIds);
      state = ClassroomOperationSuccess('Đã gửi lời mời tới ${studentIds.length} sinh viên');
      fetchClassroomDetail(subjectId, classroomId);
    } catch (e) {
      state = ClassroomError(e is AppFailure ? e.message : e.toString());
    }
  }

  Future<void> removeStudent(String subjectId, String classroomId, String studentId) async {
    state = ClassroomLoading();
    try {
      final classroom = await _repository.removeStudent(subjectId, classroomId, studentId);
      state = ClassroomOperationSuccess('Đã xóa sinh viên khỏi lớp', classroom: classroom);
      state = ClassroomDetailLoaded(classroom);
    } catch (e) {
      state = ClassroomError(e is AppFailure ? e.message : e.toString());
    }
  }

  Future<void> deleteClassroom(String subjectId, String classroomId) async {
    state = ClassroomLoading();
    try {
      await _repository.deleteClassroom(subjectId, classroomId);
      state = ClassroomOperationSuccess('Xóa lớp học thành công');
      fetchTeacherClassrooms(subjectId);
    } catch (e) {
      state = ClassroomError(e is AppFailure ? e.message : e.toString());
    }
  }

  Future<void> regenerateInviteCode(String subjectId, String classroomId) async {
    try {
      final classroom = await _repository.regenerateInviteCode(subjectId, classroomId);
      state = ClassroomOperationSuccess('Mã mời đã được tạo mới', classroom: classroom);
      state = ClassroomDetailLoaded(classroom);
    } catch (e) {
      state = ClassroomError(e is AppFailure ? e.message : e.toString());
    }
  }

  // --- Student Actions ---

  Future<void> fetchStudentClassrooms() async {
    state = ClassroomLoading();
    try {
      final classrooms = await _repository.getStudentClassrooms();
      state = ClassroomLoaded(classrooms);
    } catch (e) {
      // Sửa lỗi: Bắt mọi exception để không bị kẹt spinner
      state = ClassroomError(e is AppFailure ? e.message : e.toString());
    }
  }

  Future<void> joinByCode(String inviteCode) async {
    state = ClassroomLoading();
    try {
      final classroom = await _repository.joinByCode(inviteCode);
      state = ClassroomOperationSuccess('Tham gia lớp học thành công', classroom: classroom);
      fetchStudentClassrooms();
    } catch (e) {
      state = ClassroomError(e is AppFailure ? e.message : e.toString());
    }
  }

  Future<void> acceptInvite(String notificationId) async {
    state = ClassroomLoading();
    try {
      final classroom = await _repository.acceptInvite(notificationId);
      state = ClassroomOperationSuccess('Đã chấp nhận lời mời', classroom: classroom);
      fetchStudentClassrooms();
    } catch (e) {
      state = ClassroomError(e is AppFailure ? e.message : e.toString());
    }
  }
}
