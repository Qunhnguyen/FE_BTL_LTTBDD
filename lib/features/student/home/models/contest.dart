enum ContestStatus { live, upcoming, finished }

class Contest {
  final String id;
  final String title;
  final String subjectId;
  final String subjectName; 
  final String description;
  final int durationMinutes;
  final ContestStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<String> classroomIds; // Thêm classroomIds
  final List<String> participantAvatars;
  final int totalParticipants;

  Contest({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.subjectName,
    required this.description,
    required this.durationMinutes,
    required this.status,
    this.startTime,
    this.endTime,
    this.classroomIds = const [],
    this.participantAvatars = const [],
    this.totalParticipants = 0,
  });

  factory Contest.fromJson(Map<String, dynamic> json, {String? sName}) {
    final startAtStr = json['startAt'] ?? json['startTime'];
    final endAtStr = json['endAt'] ?? json['endTime'];
    
    final startTime = startAtStr != null ? DateTime.tryParse(startAtStr.toString()) : null;
    final endTime = endAtStr != null ? DateTime.tryParse(endAtStr.toString()) : null;

    return Contest(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['name'] ?? json['title'] ?? 'Không có tên').toString(), 
      subjectId: (json['subjectId'] ?? '').toString(),
      subjectName: sName ?? json['subjectName'] ?? 'Môn học', 
      description: (json['description'] ?? '').toString(),
      durationMinutes: json['durationMinutes'] ?? 0,
      startTime: startTime,
      endTime: endTime,
      status: _calculateStatus(startTime, endTime),
      classroomIds: List<String>.from(json['classroomIds'] ?? []),
      participantAvatars: (json['participantAvatars'] as List? ?? []).map((e) => e.toString()).toList(),
      totalParticipants: json['totalParticipants'] ?? 0,
    );
  }

  static ContestStatus _calculateStatus(DateTime? start, DateTime? end) {
    final now = DateTime.now();
    if (start == null) return ContestStatus.live;
    if (now.isBefore(start)) return ContestStatus.upcoming;
    if (end != null && now.isAfter(end)) return ContestStatus.finished;
    return ContestStatus.live;
  }
}
