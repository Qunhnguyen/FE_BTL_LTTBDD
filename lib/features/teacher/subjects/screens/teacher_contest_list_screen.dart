import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../models/subject.dart';
import '../../../../features/student/home/models/contest.dart';
import '../../../../features/student/home/repositories/contest_repository.dart';
import '../../../../features/teacher/questions/providers/question_management_provider.dart';
import '../repositories/classroom_repository.dart';
import 'teacher_classroom_list_screen.dart';

final contestsBySubjectProvider = FutureProvider.family<List<Contest>, String>((ref, subjectId) async {
  return ref.watch(contestRepositoryProvider).getContestsBySubject(subjectId);
});

class TeacherContestListScreen extends ConsumerWidget {
  final Subject subject;
  const TeacherContestListScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(subject.name),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.assignment_outlined), text: 'Cuộc thi'),
              Tab(icon: Icon(Icons.groups_outlined), text: 'Lớp học'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ContestsTab(subject: subject),
            TeacherClassroomListScreen(subject: subject),
          ],
        ),
      ),
    );
  }
}

class _ContestsTab extends ConsumerWidget {
  final Subject subject;
  const _ContestsTab({required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contestsAsync = ref.watch(contestsBySubjectProvider(subject.id));

    return contestsAsync.when(
      data: (contests) => Scaffold(
        body: contests.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_note_outlined, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text('Chưa có cuộc thi nào.'),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: contests.length,
                itemBuilder: (context, index) {
                  final contest = contests[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(contest.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${contest.durationMinutes} phút • ${contest.description}'),
                          if (contest.classroomIds.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('Đã gán cho ${contest.classroomIds.length} lớp', 
                                style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  ref.read(activeContestIdProvider.notifier).state = contest.id;
                                  context.goNamed(AppRouteNames.teacherQuestions);
                                },
                                icon: const Icon(Icons.quiz_outlined, size: 18),
                                label: const Text('Câu hỏi'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  context.pushNamed(
                                    AppRouteNames.teacherContestAnalytics,
                                    pathParameters: {'contestId': contest.id},
                                  );
                                },
                                icon: const Icon(Icons.analytics_outlined, size: 18),
                                label: const Text('Thống kê'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _handleDelete(context, ref, contest.id),
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddContestDialog(context, ref, subject.id),
          label: const Text('Tạo cuộc thi'),
          icon: const Icon(Icons.add),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Lỗi: $err')),
    );
  }

  void _handleDelete(BuildContext context, WidgetRef ref, String contestId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa cuộc thi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(contestRepositoryProvider).deleteContest(subject.id, contestId);
      ref.invalidate(contestsBySubjectProvider(subject.id));
    }
  }

  void _showAddContestDialog(BuildContext context, WidgetRef ref, String subjectId) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final durationController = TextEditingController(text: '45');
    
    // Lấy danh sách lớp thật từ BE
    final classrooms = await ref.read(classroomRepositoryProvider).getClassroomsBySubject(subjectId);
    List<String> selectedClassIds = [];

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tạo cuộc thi mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Tên cuộc thi')),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(labelText: 'Thời gian (phút)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Align(alignment: Alignment.centerLeft, child: Text('Gán cho lớp học (Bắt buộc):', style: TextStyle(fontWeight: FontWeight.bold))),
                const Divider(),
                if (classrooms.isEmpty)
                  const Text('Chưa có lớp học nào. Hãy tạo lớp ở tab Lớp học trước.', style: TextStyle(color: Colors.red, fontSize: 12))
                else
                  ...classrooms.map((cls) => CheckboxListTile(
                    title: Text(cls.name),
                    value: selectedClassIds.contains(cls.id),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) selectedClassIds.add(cls.id);
                        else selectedClassIds.remove(cls.id);
                      });
                    },
                    dense: true,
                  )),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && selectedClassIds.isNotEmpty) {
                  await ref.read(contestRepositoryProvider).createContest(subjectId, {
                    'name': titleController.text,
                    'description': descController.text,
                    'durationMinutes': int.tryParse(durationController.text) ?? 45,
                    'status': 'UPCOMING',
                    'classroomIds': selectedClassIds,
                  });
                  ref.invalidate(contestsBySubjectProvider(subjectId));
                  if (context.mounted) Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên và chọn ít nhất 1 lớp')));
                }
              },
              child: const Text('Tạo'),
            ),
          ],
        ),
      ),
    );
  }
}
