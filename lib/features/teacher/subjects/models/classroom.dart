import '../../../auth/models/user.dart';
import '../../../student/home/models/contest.dart';

class Classroom {
  final String id;
  final String subjectId;
  final String name;
  final List<String> studentIds;
  final int studentCount;
  final List<User> students;
  final List<Contest> assignedContests;

  Classroom({
    required this.id,
    required this.subjectId,
    required this.name,
    this.studentIds = const [],
    this.studentCount = 0,
    this.students = const [],
    this.assignedContests = const [],
  });

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      subjectId: json['subjectId'] ?? '',
      name: json['name'] ?? '',
      studentIds: List<String>.from(json['studentIds'] ?? []),
      studentCount: json['studentCount'] ?? 0,
      students: (json['students'] as List? ?? [])
          .map((s) => User.fromJson(s))
          .toList(),
      assignedContests: (json['assignedContests'] as List? ?? [])
          .map((c) => Contest.fromJson(c))
          .toList(),
    );
  }
}
