import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/providers/auth_provider.dart';
import '../models/subject.dart';
import '../../../../features/student/home/models/contest.dart';
import '../../../../features/student/home/repositories/contest_repository.dart';
import '../../../../features/teacher/questions/providers/question_management_provider.dart';
import '../repositories/classroom_repository.dart';
import 'teacher_classroom_list_screen.dart';
import 'quiz_management_screen.dart';

final contestsBySubjectProvider = FutureProvider.family<List<Contest>, String>((ref, subjectId) async {
  return ref.watch(contestRepositoryProvider).getContestsBySubject(subjectId);
});

class TeacherContestListScreen extends ConsumerWidget {
  final Subject subject;
  const TeacherContestListScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(authProvider).user?.role;
    final isAdmin = userRole == 'ADMIN';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(subject.name),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                final routeName = isAdmin ? _getAdminRoute(value) : _getTeacherRoute(value);
                context.pushNamed(routeName, pathParameters: {'subjectId': subject.id});
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'knowledge',
                  child: Row(children: [Icon(Icons.auto_stories, color: Colors.blue), SizedBox(width: 8), Text('Quản lý Tri thức (RAG)')]),
                ),
                const PopupMenuItem(
                  value: 'ai_builder',
                  child: Row(children: [Icon(Icons.psychology, color: Colors.purple), SizedBox(width: 8), Text('Tạo đề thi bằng AI')]),
                ),
              ],
              icon: const Icon(Icons.auto_fix_high),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.assignment_outlined), text: 'Cuộc thi'),
              Tab(icon: Icon(Icons.play_lesson_outlined), text: 'Quiz'),
              Tab(icon: Icon(Icons.groups_outlined), text: 'Lớp học'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ContestsTab(subject: subject),
            QuizManagementScreen(subject: subject),
            TeacherClassroomListScreen(subject: subject),
          ],
        ),
      ),
    );
  }

  String _getAdminRoute(String value) {
    if (value == 'knowledge') return AppRouteNames.adminKnowledge;
    return AppRouteNames.adminAiBuilder;
  }

  String _getTeacherRoute(String value) {
    if (value == 'knowledge') return AppRouteNames.teacherKnowledge;
    return AppRouteNames.teacherAiBuilder;
  }
}

class _ContestsTab extends ConsumerWidget {
  final Subject subject;
  const _ContestsTab({required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contestsAsync = ref.watch(contestsBySubjectProvider(subject.id));
    final userRole = ref.watch(authProvider).user?.role;
    final isAdmin = userRole == 'ADMIN';

    return contestsAsync.when(
      data: (contests) => Scaffold(
        body: contests.isEmpty
            ? const Center(child: Text('Chưa có cuộc thi nào.'))
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
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Set active contest ID before navigating
                                  ref.read(activeContestIdProvider.notifier).state = contest.id;
                                  context.pushNamed(
                                    isAdmin ? AppRouteNames.adminQuestions : AppRouteNames.teacherQuestions,
                                    pathParameters: {'subjectId': subject.id},
                                  );
                                },
                                icon: const Icon(Icons.quiz_outlined, size: 18),
                                label: const Text('Câu hỏi'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade50,
                                  foregroundColor: Colors.blue.shade700,
                                  elevation: 0,
                                ),
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
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
             FloatingActionButton.extended(
              heroTag: 'quiz_fab',
              onPressed: () => context.pushNamed(
                isAdmin ? AppRouteNames.adminCreateQuiz : AppRouteNames.teacherCreateQuiz,
                pathParameters: {'subjectId': subject.id},
              ),
              label: Text(isAdmin ? 'Tạo Quiz Public' : 'Tạo Quiz lớp'),
              icon: const Icon(Icons.add_task),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            const SizedBox(height: 12),
            FloatingActionButton.extended(
              heroTag: 'ai_fab',
              onPressed: () => context.pushNamed(
                isAdmin ? AppRouteNames.adminAiBuilder : AppRouteNames.teacherAiBuilder,
                pathParameters: {'subjectId': subject.id},
              ),
              label: const Text('Tạo đề AI'),
              icon: const Icon(Icons.psychology),
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            const SizedBox(height: 12),
            FloatingActionButton.extended(
              heroTag: 'standard_fab',
              onPressed: () => _showAddContestDialog(context, ref, subject.id),
              label: const Text('Tạo bộ đề gốc'),
              icon: const Icon(Icons.add),
            ),
          ],
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
        title: const Text('Xác nhận xóa?'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo bộ đề mới (Contest)'),
        content: TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Tên bộ đề')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await ref.read(contestRepositoryProvider).createContest(subjectId, {
                  'name': titleController.text,
                  'durationMinutes': 45,
                  'status': 'UPCOMING',
                  'classroomIds': [],
                });
                ref.invalidate(contestsBySubjectProvider(subjectId));
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }
}
