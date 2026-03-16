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
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.event_note_outlined, size: 64, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)),
                    ),
                    const SizedBox(height: 24),
                    const Text('Chưa có cuộc thi nào', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    const Text(
                      'Tạo cuộc thi đầu tiên cho môn học này\nđể sinh viên có thể tham gia.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showAddContestSheet(context, ref, subject.id),
                      icon: const Icon(Icons.add),
                      label: const Text('Tạo cuộc thi đầu tiên'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
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
                            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
        onPressed: () => _showAddContestSheet(context, ref, subject.id),
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

  void _showAddContestSheet(BuildContext context, WidgetRef ref, String subjectId) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final durationController = TextEditingController(text: '45');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.add_circle_outline, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  const Text('Tạo Cuộc thi Mới', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Tên cuộc thi *',
                  hintText: 'VD: Giữa kỳ lập trình Java',
                  prefixIcon: const Icon(Icons.assignment_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
                validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập tên cuộc thi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Mô tả',
                  hintText: 'Mô tả ngắn về cuộc thi...',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Thời gian (phút)',
                  prefixIcon: const Icon(Icons.timer_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
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
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Tạo cuộc thi'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
