import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../teacher/subjects/models/subject.dart';
import '../../../teacher/subjects/providers/subject_providers.dart';

final subjectSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredStudentSubjectsProvider = Provider<AsyncValue<List<Subject>>>((ref) {
  final subjectsAsync = ref.watch(subjectsProvider);
  final searchQuery = ref.watch(subjectSearchQueryProvider).toLowerCase();

  return subjectsAsync.whenData((subjects) {
    if (searchQuery.isEmpty) return subjects;
    return subjects.where((subject) {
      return subject.name.toLowerCase().contains(searchQuery) ||
             (subject.description?.toLowerCase().contains(searchQuery) ?? false);
    }).toList();
  });
});
