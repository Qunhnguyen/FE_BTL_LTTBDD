import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_entry.dart';
import '../repositories/leaderboard_repository.dart';
import '../../../auth/providers/auth_provider.dart';

// Provider quản lý contestId đang được xem bảng xếp hạng
final selectedLeaderboardContestIdProvider = StateProvider<String?>((ref) => null);

// Provider lấy dữ liệu bảng xếp hạng thật từ API và lọc trùng
final leaderboardEntriesProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final contestId = ref.watch(selectedLeaderboardContestIdProvider);
  if (contestId == null) return [];

  final repository = ref.watch(leaderboardRepositoryProvider);
  final authState = ref.watch(authProvider);
  
  // 1. Lấy toàn bộ danh sách từ API, truyền ID để Repo đánh dấu 'isCurrentUser'
  final allEntries = await repository.getLeaderboard(
    contestId,
    currentUserId: authState.user?.id,
  );

  // 2. Logic Lọc trùng: Chỉ giữ lại kết quả cao nhất của mỗi sinh viên (dựa trên studentId)
  final Map<String, LeaderboardEntry> uniqueStudents = {};
  
  for (var entry in allEntries) {
    if (!uniqueStudents.containsKey(entry.studentId)) {
      uniqueStudents[entry.studentId] = entry;
    }
  }

  // 3. Chuyển về List và đánh lại số thứ hạng (Rank)
  final List<LeaderboardEntry> filteredList = uniqueStudents.values.toList();
  // Sắp xếp lại điểm cao nhất lên đầu
  filteredList.sort((a, b) => b.score.compareTo(a.score));

  return List.generate(filteredList.length, (index) {
    final e = filteredList[index];
    final isMe = e.studentId == authState.user?.id;
    
    return LeaderboardEntry(
      studentId: e.studentId,
      // HIỂN THỊ TÊN THẬT: Nếu là dòng của bạn, lấy tên từ Profile đè lên ID
      name: isMe ? (authState.user?.name ?? e.name) : e.name,
      avatarUrl: e.avatarUrl,
      score: e.score,
      rank: index + 1, // Thứ hạng mới sau khi lọc trùng
      submittedAt: e.submittedAt,
      isCurrentUser: isMe,
    );
  });
});
