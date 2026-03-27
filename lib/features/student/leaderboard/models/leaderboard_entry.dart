class LeaderboardEntry {
  final String studentId; // Giữ ID để so sánh chuẩn
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

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final sId = (json['studentId'] ?? json['id'] ?? '').toString();
    final sName = json['studentName'] ?? json['name'] ?? 'Người dùng';
    final submittedAtStr = json['submittedAt'];
    
    return LeaderboardEntry(
      studentId: sId,
      name: sName,
      avatarUrl: '', 
      score: (json['score'] ?? 0.0).toDouble(),
      rank: json['rank'] ?? 0,
      submittedAt: submittedAtStr != null ? DateTime.parse(submittedAtStr).toLocal() : null,
      // So sánh theo ID để biết có phải mình không
      isCurrentUser: sId == currentUserId,
    );
  }
}
