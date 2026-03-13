import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/contest.dart';
import '../repositories/contest_repository.dart';

// Provider để lấy danh sách tất cả cuộc thi từ API
final contestsProvider = FutureProvider<List<Contest>>((ref) async {
  final repository = ref.watch(contestRepositoryProvider);
  
  // Giả định backend có endpoint lấy danh sách cuộc thi cho sinh viên
  // Nếu chưa có, bạn có thể thay thế bằng logic lấy theo subjectId
  try {
    // Tạm thời gọi API lấy cuộc thi (bạn có thể điều chỉnh endpoint trong repository nếu cần)
    return await repository.getContestsBySubject("all"); 
  } catch (e) {
    // Trả về danh sách rỗng hoặc ném lỗi để UI xử lý
    rethrow;
  }
});

// Provider quản lý tab hiện tại (Đang diễn ra, Sắp tới, Đã kết thúc)
final contestStatusFilterProvider = StateProvider<ContestStatus>((ref) => ContestStatus.live);

// Provider để lọc danh sách cuộc thi dựa trên tab đang chọn
final filteredContestsProvider = Provider<AsyncValue<List<Contest>>>((ref) {
  final filter = ref.watch(contestStatusFilterProvider);
  final contestsAsync = ref.watch(contestsProvider);

  return contestsAsync.whenData((contests) {
    return contests.where((c) => c.status == filter).toList();
  });
});
