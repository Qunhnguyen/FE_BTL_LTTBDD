import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../providers/dashboard_provider.dart';
import '../models/recent_exam.dart';

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final recentExams = ref.watch(recentExamsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header xịn hơn
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      child: Icon(Icons.dashboard_rounded, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bảng điều khiển', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          Text('Xin chào, Giảng viên!', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
                  ],
                ),
              ),

              // Thống kê nhanh
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildTotalCard(theme, isDark),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _SmallStatCard(icon: Icons.book_rounded, label: 'Môn học', value: '12', color: Colors.blue)),
                        const SizedBox(width: 16),
                        Expanded(child: _SmallStatCard(icon: Icons.assignment_rounded, label: 'Bài thi', value: '45', color: Colors.purple)),
                      ],
                    ),
                  ],
                ),
              ),

              // Thao tác nhanh (Fix lỗi infinite width bằng cách dùng Container có height)
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Text('Thao tác nhanh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _ActionButton(
                      icon: Icons.add_task_rounded, 
                      label: 'Tạo Quiz', 
                      isPrimary: true, 
                      onTap: () => context.goNamed(AppRouteNames.teacherSubjects)
                    ),
                    const SizedBox(width: 12),
                    _ActionButton(
                      icon: Icons.library_add_rounded, 
                      label: 'Môn học', 
                      onTap: () => context.goNamed(AppRouteNames.teacherSubjects)
                    ),
                    const SizedBox(width: 12),
                    _ActionButton(
                      icon: Icons.person_add_rounded, 
                      label: 'Thêm SV', 
                      onTap: () {}
                    ),
                  ],
                ),
              ),

              // Bài thi gần đây
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Bài thi gần đây', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    TextButton(onPressed: () {}, child: const Text('Xem tất cả')),
                  ],
                ),
              ),
              
              if (recentExams.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Chưa có dữ liệu bài thi.')))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: recentExams.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ExamListItem(exam: recentExams[index]),
                  ),
                ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tổng số câu hỏi', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text('1,248', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.auto_awesome_motion_rounded, color: theme.colorScheme.primary, size: 32),
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, this.isPrimary = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isPrimary ? theme.colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isPrimary ? Colors.black : theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isPrimary ? Colors.black : null)),
          ],
        ),
      ),
    );
  }
}

class _ExamListItem extends StatelessWidget {
  final RecentExam exam;
  const _ExamListItem({required this.exam});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            height: 44, width: 44,
            decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: Text(exam.category, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(exam.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('${exam.durationMinutes} phút • ${exam.questionCount} câu', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade700),
        ],
      ),
    );
  }
}
