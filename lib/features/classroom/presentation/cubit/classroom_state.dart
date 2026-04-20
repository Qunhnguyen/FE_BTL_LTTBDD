import '../../data/models/classroom_models.dart';

abstract class ClassroomState {}

class ClassroomInitial extends ClassroomState {}

class ClassroomLoading extends ClassroomState {}

class ClassroomLoaded extends ClassroomState {
  final List<ClassroomResponse> classrooms;
  ClassroomLoaded(this.classrooms);
}

class ClassroomDetailLoaded extends ClassroomState {
  final ClassroomResponse classroom;
  ClassroomDetailLoaded(this.classroom);
}

class ClassroomError extends ClassroomState {
  final String message;
  ClassroomError(this.message);
}

class ClassroomOperationSuccess extends ClassroomState {
  final String message;
  final ClassroomResponse? classroom;
  ClassroomOperationSuccess(this.message, {this.classroom});
}
