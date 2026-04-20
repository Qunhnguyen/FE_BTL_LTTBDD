import 'package:json_annotation/json_annotation.dart';

part 'classroom_models.g.dart';

@JsonSerializable()
class StudentResponse {
  final String id;
  final String email;
  final String name;
  final bool active;

  StudentResponse({required this.id, required this.email, required this.name, required this.active});
  factory StudentResponse.fromJson(Map<String, dynamic> json) => _$StudentResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StudentResponseToJson(this);
}

@JsonSerializable()
class AssignedContestResponse {
  final String id;
  final String? subjectId;
  final String name;
  final String? description;
  final int durationMinutes;
  final String startAt;
  final String endAt;
  final String computedStatus;
  final List<String>? classroomIds;
  final bool? isPublic;

  AssignedContestResponse({
    required this.id,
    this.subjectId,
    required this.name,
    this.description,
    required this.durationMinutes,
    required this.startAt,
    required this.endAt,
    required this.computedStatus,
    this.classroomIds,
    this.isPublic,
  });

  factory AssignedContestResponse.fromJson(Map<String, dynamic> json) => _$AssignedContestResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AssignedContestResponseToJson(this);
}

@JsonSerializable()
class ClassroomResponse {
  final String id;
  final String subjectId;
  final String teacherId;
  final String name;
  final String inviteCode;
  final List<String> studentIds;
  final int studentCount;
  final List<StudentResponse> students;
  final List<AssignedContestResponse> assignedContests;

  ClassroomResponse({
    required this.id,
    required this.subjectId,
    required this.teacherId,
    required this.name,
    required this.inviteCode,
    required this.studentIds,
    required this.studentCount,
    required this.students,
    required this.assignedContests,
  });

  factory ClassroomResponse.fromJson(Map<String, dynamic> json) => _$ClassroomResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ClassroomResponseToJson(this);
}

@JsonSerializable()
class NotificationItem {
  final String id;
  final String subjectId;
  final String subjectName;
  final String? contestId;
  final String? contestName;
  final String? classroomId;
  final String? classroomName;
  final String? inviteCode;
  final String type;
  final String title;
  final String message;
  final bool read;
  final String? readAt;
  final String createdAt;

  NotificationItem({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    this.contestId,
    this.contestName,
    this.classroomId,
    this.classroomName,
    this.inviteCode,
    required this.type,
    required this.title,
    required this.message,
    required this.read,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) => _$NotificationItemFromJson(json);
}

@JsonSerializable()
class NotificationListResponse {
  final List<NotificationItem> items;
  final int unreadCount;

  NotificationListResponse({required this.items, required this.unreadCount});
  factory NotificationListResponse.fromJson(Map<String, dynamic> json) => _$NotificationListResponseFromJson(json);
}
