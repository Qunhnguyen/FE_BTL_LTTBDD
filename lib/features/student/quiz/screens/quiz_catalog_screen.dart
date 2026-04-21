import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../providers/quiz_provider.dart';

class QuizCatalogScreen extends ConsumerWidget {
  final String subjectId;
  final String subjectName;

  const QuizCatalogScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesAsync = ref.watch(studentQuizListProvider(subjectId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách Quiz: $subjectName'),
      ),
      body: quizzesAsync.when(
        data: (quizzes) {
          if (quizzes.isEmpty) {
            return const Center(child: Text('Chưa có quiz nào được phát hành.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              final remaining = quiz['remainingAttempts'] ?? 0;
              final canStart = remaining > 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(quiz['description'] ?? 'Không có mô tả'),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Thời gian: ${quiz['durationMinutes']} phút'),
                              Text('Số câu: ${quiz['questionCount']}'),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Lượt còn lại: $remaining',
                                style: TextStyle(
                                  color: canStart ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Độ khó: ${quiz['difficulty']}'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: canStart
                              ? () {
                                  context.pushNamed(
                                    AppRouteNames.studentQuiz,
                                    pathParameters: {'contestId': quiz['id'].toString()},
                                  );
                                }
                              : null,
                          child: Text(canStart ? 'Bắt đầu làm bài' : 'Hết lượt làm bài'),
                        ),
                      ),
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
}
