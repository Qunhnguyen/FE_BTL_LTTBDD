import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: $subjectName', style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: quizzesAsync.when(
        data: (quizzes) {
          if (quizzes.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              
              // LOGIC KIỂM TRA HẾT HẠN
              final DateTime? endAt = quiz['endAt'] != null ? DateTime.parse(quiz['endAt']) : null;
              final bool isExpired = endAt != null && DateTime.now().isAfter(endAt);
              
              final remaining = quiz['remainingAttempts'] ?? 0;
              final bool hasAttempts = remaining > 0;
              final bool canStart = !isExpired && hasAttempts;

              String buttonText = 'Bắt đầu làm bài';
              if (isExpired) {
                buttonText = 'Đã hết hạn';
              } else if (!hasAttempts) {
                buttonText = 'Hết lượt làm bài';
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              quiz['name'] ?? 'Không tên',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          _buildStatusTag(isExpired, hasAttempts),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        quiz['description'] ?? 'Không có mô tả bài thi.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildInfoItem(Icons.timer_outlined, '${quiz['durationMinutes']} phút'),
                          const SizedBox(width: 16),
                          _buildInfoItem(Icons.help_outline_rounded, '${quiz['questionCount']} câu hỏi'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildInfoItem(Icons.refresh_rounded, 'Lượt còn lại: $remaining'),
                          const SizedBox(width: 16),
                          if (endAt != null)
                            _buildInfoItem(Icons.event_available_outlined, 'Hết hạn: ${DateFormat('dd/MM').format(endAt.toLocal())}'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: canStart
                              ? () {
                                  context.pushNamed(
                                    AppRouteNames.studentQuiz,
                                    pathParameters: {'contestId': quiz['id'].toString()},
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canStart ? theme.colorScheme.primary : Colors.grey[300],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text(
                            buttonText,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
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

  Widget _buildStatusTag(bool isExpired, bool hasAttempts) {
    String label = 'Đang mở';
    Color color = Colors.green;
    
    if (isExpired) {
      label = 'Kết thúc';
      color = Colors.grey;
    } else if (!hasAttempts) {
      label = 'Đã hoàn thành';
      color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Chưa có bài thi nào được phát hành cho môn này.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
