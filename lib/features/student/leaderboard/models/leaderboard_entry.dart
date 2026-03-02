class LeaderboardEntry {
  final String id;
  final String name;
  final String avatarUrl;
  final int points;
  final Duration timeTaken;
  final int rank;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.points,
    required this.timeTaken,
    required this.rank,
    this.isCurrentUser = false,
  });
}
