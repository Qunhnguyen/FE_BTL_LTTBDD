import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../models/subject.dart';
import '../../../../features/student/home/models/contest.dart';
import '../../../../features/student/home/repositories/contest_repository.dart';
import '../../../../features/teacher/questions/providers/question_management_provider.dart';

final contestsBySubjectProvider = FutureProvider.family<List<Contest>, String>((ref, subjectId) async {
  return ref.watch(contestRepositoryProvider).getContestsBySubject(subjectId);
});

class TeacherContestListScreen extends ConsumerWidget {
  final Subject subject;
  const TeacherContestListScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contestsAsync = ref.watch(contestsBySubjectProvider(subject.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Cuộc thi - ${subject.name}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: contestsAsync.when(
        data: (contests) {
          if (contests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note_outlined, size: 64, color: (Colors.grey[300] ?? Colors.grey)),
                  const SizedBox(height: 16),
                  const Text('Chưa có cuộc thi nào cho môn học này.'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contests.length,
            itemBuilder: (context, index) {
              final contest = contests[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(contest.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${contest.durationMinutes} phút • ${contest.description}'),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref.read(activeContestIdProvider.notifier).state = contest.id;
                            context.goNamed(AppRouteNames.teacherQuestions);
                          },
                          icon: const Icon(Icons.quiz_outlined, size: 18),
                          label: const Text('Quản lý Câu hỏi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            foregroundColor: Theme.of(context).colorScheme.primary,
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _handleDelete(context, ref, contest.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddContestDialog(context, ref, subject.id),
        label: const Text('Tạo cuộc thi'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _handleDelete(BuildContext context, WidgetRef ref, String contestId) async {
    final success = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa cuộc thi này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (success == true) {
      try {
        await ref.read(contestRepositoryProvider).deleteContest(subject.id, contestId);
        ref.invalidate(contestsBySubjectProvider(subject.id));
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
        }
      }
    }
  }

  void _showAddContestDialog(BuildContext context, WidgetRef ref, String subjectId) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final durationController = TextEditingController(text: '45');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo cuộc thi mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Tên cuộc thi')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Mô tả')),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(labelText: 'Thời gian (phút)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                try {
                  await ref.read(contestRepositoryProvider).createContest(subjectId, {
                    'name': titleController.text,
                    'description': descController.text,
                    'durationMinutes': int.tryParse(durationController.text) ?? 45,
                    'status': 'UPCOMING',
                  });
                  ref.invalidate(contestsBySubjectProvider(subjectId));
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
                  }
                }
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }
}
