import 'package:json_annotation/json_annotation.dart';

part 'classroom_models.g.dart';

@JsonSerializable()
class StudentResponse {
  final String? id;
  final String? email;
  final String? name;
  final bool? active;

  StudentResponse({this.id, this.email, this.name, this.active});
  factory StudentResponse.fromJson(Map<String, dynamic> json) => _$StudentResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StudentResponseToJson(this);
}

@JsonSerializable()
class AssignedContestResponse {
  final String id;
  final String? subjectId;
  final String name;
  final String? description;
  final int? durationMinutes;
  final String? startAt;
  final String? endAt;
  final String? computedStatus;
  final List<String>? classroomIds;
  final bool? isPublic;

  AssignedContestResponse({
    required this.id,
    this.subjectId,
    required this.name,
    this.description,
    this.durationMinutes,
    this.startAt,
    this.endAt,
    this.computedStatus,
    this.classroomIds,
    this.isPublic,
  });

  factory AssignedContestResponse.fromJson(Map<String, dynamic> json) => _$AssignedContestResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AssignedContestResponseToJson(this);
}

@JsonSerializable()
class ClassroomResponse {
  final String id;
  final String? subjectId;
  final String? teacherId;
  final String name;
  final String? inviteCode; // SỬA: Cho phép null vì log báo inviteCode: null
  final List<String>? studentIds;
  final int? studentCount;
  final List<StudentResponse>? students;
  final List<AssignedContestResponse>? assignedContests;

  ClassroomResponse({
    required this.id,
    this.subjectId,
    this.teacherId,
    required this.name,
    this.inviteCode,
    this.studentIds,
    this.studentCount,
    this.students,
    this.assignedContests,
  });

  factory ClassroomResponse.fromJson(Map<String, dynamic> json) => _$ClassroomResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ClassroomResponseToJson(this);
}

@JsonSerializable()
class NotificationItem {
  final String id;
  final String? subjectId;
  final String? subjectName;
  final String? contestId;
  final String? contestName;
  final String? classroomId;
  final String? classroomName;
  final String? inviteCode;
  final String? type;
  final String? title;
  final String? message;
  final bool? read;
  final String? readAt;
  final String? createdAt;

  NotificationItem({
    required this.id,
    this.subjectId,
    this.subjectName,
    this.contestId,
    this.contestName,
    this.classroomId,
    this.classroomName,
    this.inviteCode,
    this.type,
    this.title,
    this.message,
    this.read,
    this.readAt,
    this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) => _$NotificationItemFromJson(json);
}

@JsonSerializable()
class NotificationListResponse {
  final List<NotificationItem>? items;
  final int? unreadCount;

  NotificationListResponse({this.items, this.unreadCount});
  factory NotificationListResponse.fromJson(Map<String, dynamic> json) => _$NotificationListResponseFromJson(json);
}
