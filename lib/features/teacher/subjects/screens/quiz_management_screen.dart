import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../models/quiz.dart';
import '../providers/quiz_providers.dart';
import '../models/subject.dart';
import 'create_quiz_form.dart';

class QuizManagementScreen extends ConsumerWidget {
  final Subject subject;

  const QuizManagementScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizListAsync = ref.watch(quizListProvider(subject.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý Quiz: ${subject.name}'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.pushNamed(
                AppRouteNames.teacherCreateQuiz,
                pathParameters: {'subjectId': subject.id},
              );
            },
          ),
        ],
      ),
      body: quizListAsync.when(
        data: (quizzes) {
          if (quizzes.isEmpty) {
            return const Center(child: Text('Chưa có quiz nào. Nhấn + để tạo.'));
          }
          return ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(quiz.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Trạng thái: ${quiz.status.name} • ${quiz.questionCount} câu'),
                        trailing: _buildPopupMenu(context, ref, quiz),
                      ),
                      const Divider(),
                      // FIX LỖI TRÀN VIỀN: Sử dụng Row với các nút thu gọn
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {
                                  context.pushNamed(
                                    AppRouteNames.teacherContestAnalytics,
                                    pathParameters: {'contestId': quiz.id},
                                    queryParameters: {
                                      'sourceContestId': quiz.sourceContestId ?? '',
                                      'isQuiz': 'true',
                                    },
                                  );
                                },
                                icon: const Icon(Icons.analytics_outlined, size: 18, color: Color(0xFF14B8A6)),
                                label: const Text('Thống kê', overflow: TextOverflow.ellipsis, style: TextStyle(color: Color(0xFF14B8A6))),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: quiz.status == QuizStatus.DRAFT 
                                  ? () => _openEditForm(context, quiz)
                                  : null,
                                icon: const Icon(Icons.edit_note_rounded, size: 18),
                                label: const Text('Chỉnh sửa', overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }

  void _openEditForm(BuildContext context, Quiz quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateQuizForm(
          subjectId: subject.id,
          quizToEdit: quiz,
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, WidgetRef ref, Quiz quiz) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        final controller = ref.read(quizActionsControllerProvider.notifier);
        if (value == 'publish') {
          await controller.publishQuiz(subject.id, quiz.id);
        } else if (value == 'close') {
          await controller.closeQuiz(subject.id, quiz.id);
        } else if (value == 'delete') {
          await controller.deleteQuiz(subject.id, quiz.id);
        }
      },
      itemBuilder: (context) => [
        if (quiz.status == QuizStatus.DRAFT)
          const PopupMenuItem(
            value: 'publish',
            child: Row(children: [Icon(Icons.publish, size: 18), SizedBox(width: 8), Text('Publish')]),
          ),
        if (quiz.status == QuizStatus.PUBLISHED)
          const PopupMenuItem(
            value: 'close',
            child: Row(children: [Icon(Icons.close, size: 18), SizedBox(width: 8), Text('Close')]),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text('Xóa', style: TextStyle(color: Colors.red))]),
        ),
      ],
    );
  }
}
