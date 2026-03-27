import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_history_entry.dart';
import '../repositories/quiz_history_repository.dart';
import '../../../auth/providers/auth_provider.dart';

enum HistoryFilter { all, completed, inProgress }

final historyFilterProvider = StateProvider<HistoryFilter>((ref) => HistoryFilter.all);

final quizHistoryProvider = FutureProvider<List<QuizHistoryEntry>>((ref) async {
  final repository = ref.watch(quizHistoryRepositoryProvider);
  // Lấy ID từ authState đã có sẵn, không gọi hàm async gây loop layout
  final authState = ref.watch(authProvider);
  
  if (authState.user == null) return [];
  
  return repository.getHistory();
});

final filteredQuizHistoryProvider = Provider<AsyncValue<List<QuizHistoryEntry>>>((ref) {
  final filter = ref.watch(historyFilterProvider);
  final historyAsync = ref.watch(quizHistoryProvider);

  return historyAsync.whenData((history) {
    switch (filter) {
      case HistoryFilter.completed:
        return history.where((entry) => entry.status == QuizHistoryStatus.completed).toList();
      case HistoryFilter.inProgress:
        return history.where((entry) => entry.status == QuizHistoryStatus.inProgress).toList();
      case HistoryFilter.all:
        return history;
    }
  });
});

final groupedHistoryProvider = Provider<AsyncValue<Map<String, List<QuizHistoryEntry>>>>((ref) {
  final historyAsync = ref.watch(filteredQuizHistoryProvider);

  return historyAsync.whenData((history) {
    final grouped = <String, List<QuizHistoryEntry>>{};
    for (final entry in history) {
      final monthYear = 'Tháng ${entry.dateTime.month}, ${entry.dateTime.year}';
      grouped.putIfAbsent(monthYear, () => []);
      grouped[monthYear]!.add(entry);
    }
    return grouped;
  });
});
