import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_history_entry.dart';

enum HistoryFilter { all, completed, inProgress }

final historyFilterProvider = StateProvider<HistoryFilter>((ref) => HistoryFilter.all);

final quizHistoryProvider = Provider<List<QuizHistoryEntry>>((ref) {
  final mockHistory = [
    QuizHistoryEntry(
      id: '1',
      title: 'Toán Học Kỳ 1',
      category: 'Đại số & Giải tích',
      score: 9.5,
      status: QuizHistoryStatus.completed,
      dateTime: DateTime(2023, 10, 12, 14, 30),
      icon: Icons.calculate,
      color: Colors.green,
    ),
    QuizHistoryEntry(
      id: '2',
      title: 'Vật Lý Đại Cương',
      category: 'Cơ học & Nhiệt học',
      status: QuizHistoryStatus.inProgress,
      dateTime: DateTime.now(),
      icon: Icons.science,
      color: Colors.orange,
      remainingTime: 'Còn 15 phút',
    ),
    QuizHistoryEntry(
      id: '3',
      title: 'Tiếng Anh B1',
      category: 'Grammar & Vocabulary',
      score: 8.0,
      status: QuizHistoryStatus.completed,
      dateTime: DateTime(2023, 10, 10, 9, 0),
      icon: Icons.language,
      color: Colors.blue,
    ),
    QuizHistoryEntry(
      id: '4',
      title: 'Lịch sử 12',
      category: 'Chiến tranh thế giới',
      score: 4.5,
      status: QuizHistoryStatus.completed,
      dateTime: DateTime(2023, 9, 28, 10, 15),
      icon: Icons.history_edu,
      color: Colors.red,
    ),
  ];

  final filter = ref.watch(historyFilterProvider);
  switch (filter) {
    case HistoryFilter.completed:
      return mockHistory.where((e) => e.status == QuizHistoryStatus.completed).toList();
    case HistoryFilter.inProgress:
      return mockHistory.where((e) => e.status == QuizHistoryStatus.inProgress).toList();
    case HistoryFilter.all:
    default:
      return mockHistory;
  }
});

final groupedHistoryProvider = Provider<Map<String, List<QuizHistoryEntry>>>((ref) {
  final history = ref.watch(quizHistoryProvider);
  final grouped = <String, List<QuizHistoryEntry>>{};
  for (var entry in history) {
    final monthYear = 'Tháng ${entry.dateTime.month}, ${entry.dateTime.year}';
    if (grouped[monthYear] == null) {
      grouped[monthYear] = [];
    }
    grouped[monthYear]!.add(entry);
  }
  return grouped;
});
