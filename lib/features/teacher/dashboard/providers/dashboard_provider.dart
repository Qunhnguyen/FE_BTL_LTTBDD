import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recent_exam.dart';

final recentExamsProvider = Provider<List<RecentExam>>((ref) {
  return [
    RecentExam(
      id: '1',
      title: 'Lập trình Java Căn bản - GK',
      category: 'JAVA',
      durationMinutes: 45,
      questionCount: 30,
      status: ExamStatus.ongoing,
    ),
    RecentExam(
      id: '2',
      title: 'Thiết kế Web Frontend',
      category: 'WEB',
      durationMinutes: 60,
      questionCount: 50,
      status: ExamStatus.upcoming,
    ),
    RecentExam(
      id: '3',
      title: 'Cơ sở dữ liệu nâng cao',
      category: 'CSDL',
      durationMinutes: 90,
      questionCount: 60,
      status: ExamStatus.finished,
    ),
  ];
});
