class DashboardStats {
  final int totalSubjects;
  final int totalClassrooms;
  final int totalStudents;
  final int totalQuestions;
  final int easyQuestions;
  final int mediumQuestions;
  final int hardQuestions;
  final int liveContests;
  final int inProgressSubmissions;

  DashboardStats({
    required this.totalSubjects,
    required this.totalClassrooms,
    required this.totalStudents,
    required this.totalQuestions,
    required this.easyQuestions,
    required this.mediumQuestions,
    required this.hardQuestions,
    required this.liveContests,
    required this.inProgressSubmissions,
  });

  factory DashboardStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DashboardStats.empty();
    
    int parse(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return DashboardStats(
      totalSubjects: parse(json['totalSubjects']),
      totalClassrooms: parse(json['totalClassrooms']),
      totalStudents: parse(json['totalStudents']),
      totalQuestions: parse(json['totalQuestions']),
      easyQuestions: parse(json['easyQuestions']),
      mediumQuestions: parse(json['mediumQuestions']),
      hardQuestions: parse(json['hardQuestions']),
      liveContests: parse(json['liveContests']),
      inProgressSubmissions: parse(json['inProgressSubmissions']),
    );
  }

  static DashboardStats empty() => DashboardStats(
    totalSubjects: 0,
    totalClassrooms: 0,
    totalStudents: 0,
    totalQuestions: 0,
    easyQuestions: 0,
    mediumQuestions: 0,
    hardQuestions: 0,
    liveContests: 0,
    inProgressSubmissions: 0,
  );
}
