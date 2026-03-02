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
}
