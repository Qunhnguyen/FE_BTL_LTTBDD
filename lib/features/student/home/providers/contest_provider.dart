import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/contest.dart';
import '../repositories/contest_repository.dart';
import '../../../teacher/subjects/repositories/subject_repository.dart';

// Provider để lấy danh sách tất cả cuộc thi
final contestsProvider = FutureProvider<List<Contest>>((ref) async {
  final contestRepo = ref.watch(contestRepositoryProvider);
  final subjectRepo = ref.watch(subjectRepositoryProvider);
  
  // 1. Lấy danh sách môn học thật
  final subjects = await subjectRepo.getSubjects();
  List<Contest> allContests = [];
  
  for (var subject in subjects) {
    // 2. Lấy cuộc thi của từng môn và truyền kèm TÊN môn học
    final contests = await contestRepo.getContestsBySubject(subject.id);
    final mappedContests = contests.map((c) => Contest.fromJson(
      // Giả định contest data gốc, truyền thêm tên môn học thật để hiển thị
      {'id': c.id, 'name': c.title, 'description': c.description, 'durationMinutes': c.durationMinutes},
      sName: subject.name, 
    )).toList();
    
    allContests.addAll(mappedContests);
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
