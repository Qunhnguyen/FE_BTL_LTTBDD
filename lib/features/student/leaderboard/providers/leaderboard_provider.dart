import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_provider.dart';
import '../models/leaderboard_entry.dart';
import '../repositories/leaderboard_repository.dart';

final selectedLeaderboardContestIdProvider =
    StateProvider<String?>((ref) => null);

final leaderboardEntriesProvider =
    FutureProvider<List<LeaderboardEntry>>((ref) async {
  final contestId = ref.watch(selectedLeaderboardContestIdProvider);
  if (contestId == null) {
    return [];
  }

  final repository = ref.watch(leaderboardRepositoryProvider);
  final authState = ref.watch(authProvider);

  final allEntries = await repository.getLeaderboard(
    contestId,
    currentUserId: authState.user?.id,
  );

  final uniqueStudents = <String, LeaderboardEntry>{};
  for (final entry in allEntries) {
    uniqueStudents.putIfAbsent(entry.studentId, () => entry);
  }

  final filteredList = uniqueStudents.values.toList()
    ..sort((a, b) => b.score.compareTo(a.score));

  return List.generate(filteredList.length, (index) {
    final entry = filteredList[index];
    final isCurrentUser = entry.studentId == authState.user?.id;

    return LeaderboardEntry(
      studentId: entry.studentId,
      name: isCurrentUser ? (authState.user?.name ?? entry.name) : entry.name,
      avatarUrl: isCurrentUser
          ? (authState.user?.avatarUrl ?? entry.avatarUrl)
          : entry.avatarUrl,
      score: entry.score,
      rank: index + 1,
      submittedAt: entry.submittedAt,
      isCurrentUser: isCurrentUser,
    );
  });
});
