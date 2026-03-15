enum ContestStatus { live, upcoming, finished }

class Contest {
  final String id;
  final String title;
  final String subject;
  final String description;
  final int durationMinutes;
  final ContestStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<String> participantAvatars;
  final int totalParticipants;

  Contest({
    required this.id,
    required this.title,
    required this.subject,
    required this.description,
    required this.durationMinutes,
    required this.status,
    this.startTime,
    this.endTime,
    this.participantAvatars = const [],
    this.totalParticipants = 0,
  });

  factory Contest.fromJson(Map<String, dynamic> json) {
    final startAtStr = json['startAt'] ?? json['startTime'];
    final endAtStr = json['endAt'] ?? json['endTime'];
    
    final startTime = startAtStr != null ? DateTime.parse(startAtStr) : null;
    final endTime = endAtStr != null ? DateTime.parse(endAtStr) : null;

    return Contest(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['name'] ?? json['title'] ?? 'Không có tên').toString(), 
      subject: (json['subjectId'] ?? json['subjectName'] ?? '').toString(), 
      description: (json['description'] ?? '').toString(),
      durationMinutes: json['durationMinutes'] ?? 0,
      startTime: startTime,
      endTime: endTime,
      // Tính toán trạng thái dựa trên thời gian thực tế vì BE không trả về field status
      status: _calculateStatus(startTime, endTime),
      participantAvatars: (json['participantAvatars'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      totalParticipants: json['totalParticipants'] ?? 0,
    );
  }

  static ContestStatus _calculateStatus(DateTime? start, DateTime? end) {
    final now = DateTime.now();
    if (start == null) return ContestStatus.live; // Mặc định nếu không có thời gian
    
    if (now.isBefore(start)) {
      return ContestStatus.upcoming;
    } else if (end != null && now.isAfter(end)) {
      return ContestStatus.finished;
    } else {
      return ContestStatus.live;
    }
  }
}
