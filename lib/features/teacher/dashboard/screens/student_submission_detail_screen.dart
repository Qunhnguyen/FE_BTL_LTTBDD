import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../student/home/repositories/contest_repository.dart';
import '../models/student_submission_detail.dart';

final studentSubmissionDetailProvider = FutureProvider.family<StudentSubmissionDetail, ({String id, String studentId, bool isQuiz})>((ref, arg) async {
  return ref.watch(contestRepositoryProvider).getStudentSubmissionDetail(arg.id, arg.studentId, isQuiz: arg.isQuiz);
});

class StudentSubmissionDetailScreen extends ConsumerWidget {
  final String contestId; // ID này có thể là quizId hoặc contestId
  final String studentId;

  const StudentSubmissionDetailScreen({
    super.key,
    required this.contestId,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = GoRouterState.of(context);
    final isQuiz = state.uri.queryParameters['isQuiz'] == 'true';

    final detailAsync = ref.watch(studentSubmissionDetailProvider((id: contestId, studentId: studentId, isQuiz: isQuiz)));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isQuiz ? 'Chi tiết bài Quiz' : 'Chi tiết bài Contest'),
        elevation: 0,
      ),
      body: detailAsync.when(
        data: (detail) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(detail, theme),
              const SizedBox(height: 24),
              Text('DANH SÁCH CÂU TRẢ LỜI', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: detail.answers.length,
                itemBuilder: (context, index) {
                  final answer = detail.answers[index];
                  return _buildAnswerCard(answer, theme);
                },
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }

  Widget _buildInfoCard(StudentSubmissionDetail detail, ThemeData theme) {
    final dateFormat = DateFormat('HH:mm dd/MM/yyyy');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: theme.colorScheme.primary.withOpacity(0.1), child: Text(detail.studentName[0])),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(detail.studentName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Mã sinh viên: ${detail.studentId}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              _StatusBadge(status: detail.status),
            ],
          ),
          const Divider(height: 32),
          _infoRow('Bài thi:', detail.contestName, theme),
          _infoRow('Tổng điểm:', '${detail.totalScore}', theme, valueColor: theme.colorScheme.primary, isBold: true),
          _infoRow('Số câu đúng:', '${detail.correctCount}/${detail.totalQuestions}', theme),
          if (detail.submittedAt != null)
            _infoRow('Thời gian nộp:', dateFormat.format(detail.submittedAt!), theme),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, ThemeData theme, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: TextStyle(color: valueColor, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildAnswerCard(AnswerDetail answer, ThemeData theme) {
    final isCorrect = answer.correct;
    final color = isCorrect ? Colors.green : Colors.red;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Text('${answer.questionNo}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(answer.content, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
              Icon(isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded, color: color, size: 20),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              _optionLabel('Đã chọn:', answer.selectedOption ?? 'N/A', color),
              const SizedBox(width: 20),
              _optionLabel('Đáp án đúng:', answer.correctOption ?? 'N/A', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _optionLabel(String label, String val, Color color) {
    return Row(
      children: [
        Text('$label ', style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
          child: Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    String text = status;
    if (status == 'COMPLETED') { color = Colors.green; text = 'Đã nộp'; }
    else if (status == 'IN_PROGRESS') { color = Colors.orange; text = 'Đang làm'; }
    else if (status == 'ABSENT') { color = Colors.red; text = 'Vắng'; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
