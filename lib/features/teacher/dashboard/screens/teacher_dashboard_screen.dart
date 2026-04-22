import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../providers/dashboard_provider.dart';
import '../../subjects/models/quiz.dart';

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final statsAsync = ref.watch(teacherStatsProvider);
    final recentQuizzesAsync = ref.watch(recentTeacherQuizzesProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(teacherStatsProvider);
            ref.invalidate(recentTeacherQuizzesProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1), 
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: Icon(Icons.dashboard_rounded, color: theme.colorScheme.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bảng điều khiển', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            Text('Xin chào, Giảng viên!', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Stats Cards
                statsAsync.when(
                  data: (stats) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildTotalCard(theme, 'Tổng số môn học', stats['totalSubjects'].toString()),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _SmallStatCard(icon: Icons.menu_book_rounded, label: 'Môn học', value: stats['totalSubjects'].toString(), color: Colors.blue)),
                            const SizedBox(width: 12),
                            Expanded(child: _SmallStatCard(icon: Icons.quiz_outlined, label: 'Bộ đề Quiz', value: stats['totalQuizzes'].toString(), color: Colors.purple)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  loading: () => const Padding(padding: EdgeInsets.all(20), child: LinearProgressIndicator()),
                  error: (err, _) => const Center(child: Text('Lỗi tải thống kê')),
                ),

                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 32, 20, 16),
                  child: Text('Thao tác nhanh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.add_task_rounded, 
                          label: 'Tạo Quiz', 
                          color: Colors.orange,
                          onTap: () => context.goNamed(AppRouteNames.teacherSubjects)
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.library_add_outlined, 
                          label: 'Thêm Môn', 
                          color: Colors.teal,
                          onTap: () => context.goNamed(AppRouteNames.teacherSubjects)
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Bộ đề gần đây', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      TextButton(
                        onPressed: () => context.goNamed(AppRouteNames.teacherSubjects), 
                        child: const Text('Xem tất cả', style: TextStyle(fontSize: 13))
                      ),
                    ],
                  ),
                ),
                
                // DANH SÁCH BỘ ĐỀ (QUIZ) - ĐIỀU HƯỚNG CHUẨN GIỐNG PHẦN MÔN HỌC
                recentQuizzesAsync.when(
                  data: (quizzes) {
                    if (quizzes.isEmpty) {
                      return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Chưa có bộ đề nào.')));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: quizzes.length,
                      itemBuilder: (context, index) => _QuizItem(quiz: quizzes[index]),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Lỗi: $err')),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalCard(ThemeData theme, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: const Icon(Icons.auto_graph_rounded, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _SmallStatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _QuizItem extends StatelessWidget {
  final Quiz quiz;
  const _QuizItem({required this.quiz});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.quiz_outlined, color: Colors.teal, size: 22),
        ),
        title: Text(quiz.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('Trạng thái: ${quiz.status.name} • ${quiz.questionCount} câu', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
        ),
        trailing: Container(
          decoration: BoxDecoration(color: const Color(0xFF14B8A6).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: IconButton(
            icon: const Icon(Icons.analytics_rounded, color: Color(0xFF14B8A6), size: 20),
            onPressed: () {
              // ĐIỀU HƯỚNG CHUẨN: Copy y hệt logic từ Quản lý môn học
              context.pushNamed(
                AppRouteNames.teacherContestAnalytics,
                pathParameters: {'contestId': quiz.id},
                queryParameters: {
                  'sourceContestId': quiz.sourceContestId ?? '',
                  'isQuiz': 'true',
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
