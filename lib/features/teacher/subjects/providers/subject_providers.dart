import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subject.dart';
import '../repositories/subject_repository.dart';

// Provider lấy danh sách môn học chung cho cả Teacher và Student
final subjectsProvider = FutureProvider<List<Subject>>((ref) async {
  final repository = ref.watch(subjectRepositoryProvider);
  return repository.getSubjects();
});
