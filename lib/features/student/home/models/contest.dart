enum ContestStatus { live, upcoming, finished }

class Contest {
  final String id;
  final String title;
  final String subject;
  final String description;
  final int durationMinutes;
  final ContestStatus status;
  final DateTime? startTime;
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
    this.participantAvatars = const [],
    this.totalParticipants = 0,
  });

  factory Contest.fromJson(Map<String, dynamic> json) {
    return Contest(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      subject: json['subjectName'] ?? '',
      description: json['description'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 0,
      status: _parseStatus(json['status']),
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      participantAvatars: (json['participantAvatars'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      totalParticipants: json['totalParticipants'] ?? 0,
    );
  }

  static ContestStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'live':
      case 'ongoing':
        return ContestStatus.live;
      case 'upcoming':
        return ContestStatus.upcoming;
      case 'finished':
      case 'ended':
        return ContestStatus.finished;
      default:
        return ContestStatus.live;
    }
  }
}
