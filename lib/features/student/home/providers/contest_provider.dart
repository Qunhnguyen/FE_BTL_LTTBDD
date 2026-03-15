import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/contest.dart';
import '../repositories/contest_repository.dart';
import '../../../teacher/subjects/repositories/subject_repository.dart';

// Provider để lấy danh sách tất cả cuộc thi
final contestsProvider = FutureProvider<List<Contest>>((ref) async {
  final contestRepo = ref.watch(contestRepositoryProvider);
  final subjectRepo = ref.watch(subjectRepositoryProvider);
  
  // Lưu ý: Nếu bị lỗi 403, nghĩa là Backend chặn Role Student truy cập link /api/admin
  // Bạn cần kiểm tra cấu hình Security ở Backend cho các link này
  final subjects = await subjectRepo.getSubjects();
  List<Contest> allContests = [];
  
  for (var subject in subjects) {
    final contests = await contestRepo.getContestsBySubject(subject.id);
    allContests.addAll(contests);
  }
  
  return allContests;
});

final contestStatusFilterProvider = StateProvider<ContestStatus>((ref) => ContestStatus.live);

final filteredContestsProvider = Provider<AsyncValue<List<Contest>>>((ref) {
  final filter = ref.watch(contestStatusFilterProvider);
  final contestsAsync = ref.watch(contestsProvider);

  return contestsAsync.whenData((contests) {
    return contests.where((c) => c.status == filter).toList();
  });
});
