import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/quiz_result_provider.dart';
import '../../../../core/router/app_router.dart';

class QuizResultScreen extends ConsumerWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final result = ref.watch(quizResultProvider);

    // Nếu chưa có kết quả (lỗi hoặc chưa nộp bài)
    if (result == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Không tìm thấy kết quả bài thi.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.goNamed(AppRouteNames.studentHome),
                child: const Text('Quay lại Trang chủ'),
              ),
            ],
          ),
        ),
      );
    }

    final minutes = (result.elapsedSeconds / 60).floor();
    final seconds = result.elapsedSeconds % 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả Bài thi', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false, // Không cho quay lại bài thi
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Trophy Icon
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.emoji_events, size: 80, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Hoàn thành!',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bài thi của bạn đã được ghi nhận trên hệ thống.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // Score Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  const Text('TỔNG ĐIỂM', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text(
                    '${result.score.toStringAsFixed(1)}',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        icon: Icons.check_circle_outline,
                        color: Colors.green,
                        label: 'ĐÚNG',
                        value: '${result.correctCount}/${result.totalQuestions}',
                      ),
                      _buildStatItem(
                        icon: Icons.timer_outlined,
                        color: Colors.orange,
                        label: 'THỜI GIAN',
                        value: '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Actions
            ElevatedButton(
              onPressed: () {
                // TODO: Chuyển sang màn hình Bảng xếp hạng thật
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Xem bảng xếp hạng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.goNamed(AppRouteNames.studentHistory),
                    icon: const Icon(Icons.history),
                    label: const Text('Lịch sử'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 50)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => context.goNamed(AppRouteNames.studentHome),
                    icon: const Icon(Icons.home),
                    label: const Text('Trang chủ'),
                    style: FilledButton.styleFrom(minimumSize: const Size(0, 50)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
