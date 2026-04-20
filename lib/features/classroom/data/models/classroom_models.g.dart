// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classroom_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentResponse _$StudentResponseFromJson(Map<String, dynamic> json) =>
    StudentResponse(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      active: json['active'] as bool,
    );

Map<String, dynamic> _$StudentResponseToJson(StudentResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'active': instance.active,
    };

AssignedContestResponse _$AssignedContestResponseFromJson(
        Map<String, dynamic> json) =>
    AssignedContestResponse(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      startAt: json['startAt'] as String,
      endAt: json['endAt'] as String,
      computedStatus: json['computedStatus'] as String,
      classroomIds: (json['classroomIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isPublic: json['isPublic'] as bool?,
    );

Map<String, dynamic> _$AssignedContestResponseToJson(
        AssignedContestResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subjectId': instance.subjectId,
      'name': instance.name,
      'description': instance.description,
      'durationMinutes': instance.durationMinutes,
      'startAt': instance.startAt,
      'endAt': instance.endAt,
      'computedStatus': instance.computedStatus,
      'classroomIds': instance.classroomIds,
      'isPublic': instance.isPublic,
    };

ClassroomResponse _$ClassroomResponseFromJson(Map<String, dynamic> json) =>
    ClassroomResponse(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      teacherId: json['teacherId'] as String,
      name: json['name'] as String,
      inviteCode: json['inviteCode'] as String,
      studentIds: (json['studentIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      studentCount: (json['studentCount'] as num).toInt(),
      students: (json['students'] as List<dynamic>)
          .map((e) => StudentResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      assignedContests: (json['assignedContests'] as List<dynamic>)
          .map((e) =>
              AssignedContestResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ClassroomResponseToJson(ClassroomResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subjectId': instance.subjectId,
      'teacherId': instance.teacherId,
      'name': instance.name,
      'inviteCode': instance.inviteCode,
      'studentIds': instance.studentIds,
      'studentCount': instance.studentCount,
      'students': instance.students,
      'assignedContests': instance.assignedContests,
    };

NotificationItem _$NotificationItemFromJson(Map<String, dynamic> json) =>
    NotificationItem(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      subjectName: json['subjectName'] as String,
      contestId: json['contestId'] as String?,
      contestName: json['contestName'] as String?,
      classroomId: json['classroomId'] as String?,
      classroomName: json['classroomName'] as String?,
      inviteCode: json['inviteCode'] as String?,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      read: json['read'] as bool,
      readAt: json['readAt'] as String?,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$NotificationItemToJson(NotificationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subjectId': instance.subjectId,
      'subjectName': instance.subjectName,
      'contestId': instance.contestId,
      'contestName': instance.contestName,
      'classroomId': instance.classroomId,
      'classroomName': instance.classroomName,
      'inviteCode': instance.inviteCode,
      'type': instance.type,
      'title': instance.title,
      'message': instance.message,
      'read': instance.read,
      'readAt': instance.readAt,
      'createdAt': instance.createdAt,
    };

NotificationListResponse _$NotificationListResponseFromJson(
        Map<String, dynamic> json) =>
    NotificationListResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      unreadCount: (json['unreadCount'] as num).toInt(),
    );

Map<String, dynamic> _$NotificationListResponseToJson(
        NotificationListResponse instance) =>
    <String, dynamic>{
      'items': instance.items,
      'unreadCount': instance.unreadCount,
    };
