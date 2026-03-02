enum ExamStatus { ongoing, upcoming, finished }

class RecentExam {
  final String id;
  final String title;
  final String category; // e.g., JAVA, WEB, CSDL
  final int durationMinutes;
  final int questionCount;
  final ExamStatus status;

  RecentExam({
    required this.id,
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.questionCount,
    required this.status,
  });
}
