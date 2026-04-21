class Scoreboard {
  final String contestId;
  final String contestName;
  final int totalStudents;
  final int completedCount;
  final int inProgressCount;
  final int absentCount;
  final List<ScoreboardRow> rows;

  Scoreboard({
    required this.contestId,
    required this.contestName,
    required this.totalStudents,
    required this.completedCount,
    required this.inProgressCount,
    required this.absentCount,
    required this.rows,
  });

  factory Scoreboard.fromJson(Map<String, dynamic> json) {
    return Scoreboard(
      contestId: json['contestId'] ?? '',
      contestName: json['contestName'] ?? '',
      totalStudents: json['totalStudents'] ?? 0,
      completedCount: json['completedCount'] ?? 0,
      inProgressCount: json['inProgressCount'] ?? 0,
      absentCount: json['absentCount'] ?? 0,
      rows: (json['rows'] as List? ?? [])
          .map((i) => ScoreboardRow.fromJson(i))
          .toList(),
    );
  }
}

class ScoreboardRow {
  final String studentId;
  final String studentName;
  final String classroomName;
  final double? score;
  final DateTime? submittedAt;
  final String status;

  ScoreboardRow({
    required this.studentId,
    required this.studentName,
    required this.classroomName,
    this.score,
    this.submittedAt,
    required this.status,
  });

  factory ScoreboardRow.fromJson(Map<String, dynamic> json) {
    return ScoreboardRow(
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      classroomName: json['classroomName'] ?? '',
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      submittedAt: json['submittedAt'] != null 
          ? DateTime.tryParse(json['submittedAt']) 
          : null,
      status: json['status'] ?? '',
    );
  }
}
