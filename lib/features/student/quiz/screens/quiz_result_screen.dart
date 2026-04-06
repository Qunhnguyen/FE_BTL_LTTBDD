import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/quiz_result_provider.dart';
import '../providers/quiz_provider.dart';
import '../../leaderboard/providers/leaderboard_provider.dart';
import '../../../../core/router/app_router.dart';

class QuizResultScreen extends ConsumerWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final result = ref.watch(quizResultProvider);
    final quizState = ref.watch(quizProvider);

    if (result == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Không tìm thấy kết quả bài thi.'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => context.goNamed(AppRouteNames.studentHome), child: const Text('Quay lại Trang chủ')),
            ],
          ),
        ),
      );
    }

    final minutes = (result.elapsedSeconds / 60).floor();
    final seconds = result.elapsedSeconds % 60;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Kết quả Bài thi'), centerTitle: true, automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.emoji_events, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            const Text('Hoàn thành!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  const Text('TỔNG ĐIỂM', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  Text('${result.score.toStringAsFixed(1)}', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('ĐÚNG', '${result.correctCount}/${result.totalQuestions}', Colors.green),
                      _buildStat('THỜI GIAN', '${minutes}:${seconds.toString().padLeft(2, '0')}', Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // NÚT BẤM XEM BẢNG XẾP HẠNG THẬT
            ElevatedButton(
              onPressed: () {
                if (quizState.submission != null) {
                  // 1. Cập nhật quizId vào Leaderboard Provider
                  ref.read(selectedLeaderboardContestIdProvider.notifier).state = quizState.submission!.quizId;
                  // 2. Chuyển sang Tab Xếp hạng (index 2)
                  context.goNamed(AppRouteNames.studentLeaderboard);
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
              child: const Text('XEM BẢNG XẾP HẠNG', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => context.goNamed(AppRouteNames.studentHistory), child: const Text('Lịch sử'))),
                const SizedBox(width: 16),
                Expanded(child: FilledButton(onPressed: () => context.goNamed(AppRouteNames.studentHome), child: const Text('Trang chủ'))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(children: [Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)), Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]);
  }
}
