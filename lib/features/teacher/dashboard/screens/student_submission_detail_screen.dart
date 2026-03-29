import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../student/home/repositories/contest_repository.dart';
import '../models/student_submission_detail.dart';

final studentSubmissionDetailProvider = FutureProvider.family<StudentSubmissionDetail, ({String contestId, String studentId})>((ref, arg) async {
  return ref.watch(contestRepositoryProvider).getStudentSubmissionDetail(arg.contestId, arg.studentId);
});

class StudentSubmissionDetailScreen extends ConsumerWidget {
  final String contestId;
  final String studentId;

  const StudentSubmissionDetailScreen({
    super.key,
    required this.contestId,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(studentSubmissionDetailProvider((contestId: contestId, studentId: studentId)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết bài làm'),
      ),
      body: detailAsync.when(
        data: (detail) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(detail),
              const SizedBox(height: 20),
              const Text(
                'Danh sách câu trả lời',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: detail.answers.length,
                itemBuilder: (context, index) {
                  final answer = detail.answers[index];
                  return _buildAnswerCard(answer);
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

  Widget _buildInfoCard(StudentSubmissionDetail detail) {
    final dateFormat = DateFormat('HH:mm:ss dd/MM/yyyy');
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detail.studentName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text('MSSV: ${detail.studentId}', style: TextStyle(color: Colors.grey[600])),
            const Divider(height: 24),
            _buildInfoRow('Cuộc thi:', detail.contestName),
            _buildInfoRow('Trạng thái:', _getStatusText(detail.status), valueColor: _getStatusColor(detail.status)),
            _buildInfoRow('Điểm số:', '${detail.totalScore}', valueColor: Colors.blue, isBold: true),
            _buildInfoRow('Số câu đúng:', '${detail.correctCount}/${detail.totalQuestions}'),
            if (detail.startedAt != null)
              _buildInfoRow('Bắt đầu:', dateFormat.format(detail.startedAt!)),
            if (detail.submittedAt != null)
              _buildInfoRow('Nộp bài:', dateFormat.format(detail.submittedAt!)),
            if (detail.startedAt != null && detail.submittedAt != null)
              _buildInfoRow('Thời gian làm:', '${detail.submittedAt!.difference(detail.startedAt!).inMinutes} phút'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerCard(AnswerDetail answer) {
    final color = answer.correct ? Colors.green : Colors.red;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: color,
                  child: Text(
                    '${answer.questionNo}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    answer.content,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(
                  answer.correct ? Icons.check_circle : Icons.cancel,
                  color: color,
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: _buildOptionLabel('Chọn:', answer.selectedOption ?? 'N/A', 
                      answer.correct ? Colors.green : Colors.red),
                ),
                Expanded(
                  child: _buildOptionLabel('Đáp án:', answer.correctOption ?? 'N/A', Colors.blue),
                ),
              ],
            ),
            if (answer.answeredAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Trả lời lúc: ${DateFormat('HH:mm:ss').format(answer.answeredAt!)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionLabel(String label, String option, Color color) {
    return Row(
      children: [
        Text('$label ', style: const TextStyle(fontSize: 13)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            option,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'COMPLETED': return 'Hoàn thành';
      case 'IN_PROGRESS': return 'Đang làm';
      case 'ABSENT': return 'Vắng mặt';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED': return Colors.green;
      case 'IN_PROGRESS': return Colors.orange;
      case 'ABSENT': return Colors.red;
      default: return Colors.grey;
    }
  }
}
