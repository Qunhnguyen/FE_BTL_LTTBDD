class LeaderboardEntry {
  final String studentId;
  final String name;
  final String avatarUrl;
  final double score;
  final int rank;
  final DateTime? submittedAt;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.studentId,
    required this.name,
    required this.avatarUrl,
    required this.score,
    required this.rank,
    this.submittedAt,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntry.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final studentId = (json['studentId'] ?? json['id'] ?? '').toString();
    final studentName =
        (json['studentName'] ?? json['name'] ?? 'Người dùng').toString();
    final avatarUrl =
        (json['avatarUrl'] ?? json['studentAvatarUrl'] ?? '').toString();
    final submittedAtStr = json['submittedAt']?.toString();

    return LeaderboardEntry(
      studentId: studentId,
      name: studentName,
      avatarUrl: avatarUrl,
      score: (json['score'] ?? 0.0).toDouble(),
      rank: json['rank'] ?? 0,
      submittedAt: submittedAtStr != null
          ? DateTime.parse(submittedAtStr).toLocal()
          : null,
      isCurrentUser: studentId == currentUserId,
    );
  }
}
