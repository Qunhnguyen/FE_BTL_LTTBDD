class ContestAnalytics {
  final String contestId;
  final String contestName;
  final Participation participation;
  final List<ScoreDistribution> scoreDistribution;
  final double averageScore;
  final ScoreInfo highestScore;
  final ScoreInfo lowestScore;
  final double averageCompletionMinutes;

  ContestAnalytics({
    required this.contestId,
    required this.contestName,
    required this.participation,
    required this.scoreDistribution,
    required this.averageScore,
    required this.highestScore,
    required this.lowestScore,
    required this.averageCompletionMinutes,
  });

  factory ContestAnalytics.fromJson(Map<String, dynamic> json) {
    return ContestAnalytics(
      contestId: json['contestId'] ?? '',
      contestName: json['contestName'] ?? '',
      participation: Participation.fromJson(json['participation'] ?? {}),
      scoreDistribution: (json['scoreDistribution'] as List? ?? [])
          .map((i) => ScoreDistribution.fromJson(i))
          .toList(),
      averageScore: (json['averageScore'] ?? 0).toDouble(),
      highestScore: ScoreInfo.fromJson(json['highestScore'] ?? {}),
      lowestScore: ScoreInfo.fromJson(json['lowestScore'] ?? {}),
      averageCompletionMinutes: (json['averageCompletionMinutes'] ?? 0).toDouble(),
    );
  }
}

class Participation {
  final int participantCount;
  final int totalStudents;
  final double participationRate;

  Participation({
    required this.participantCount,
    required this.totalStudents,
    required this.participationRate,
  });

  factory Participation.fromJson(Map<String, dynamic> json) {
    return Participation(
      participantCount: json['participantCount'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
      participationRate: (json['participationRate'] ?? 0).toDouble(),
    );
  }
}

class ScoreDistribution {
  final String range;
  final int count;

  ScoreDistribution({
    required this.range,
    required this.count,
  });

  factory ScoreDistribution.fromJson(Map<String, dynamic> json) {
    return ScoreDistribution(
      range: json['range'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class ScoreInfo {
  final String studentId;
  final String studentName;
  final double score;

  ScoreInfo({
    required this.studentId,
    required this.studentName,
    required this.score,
  });

  factory ScoreInfo.fromJson(Map<String, dynamic> json) {
    return ScoreInfo(
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
    );
  }
}
