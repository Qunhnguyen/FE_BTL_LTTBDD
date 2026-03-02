import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.dashboard_outlined,
                          color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dashboard',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Xin chào, Giảng viên',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_none),
                    ),
                  ],
                ),
              ),

              // Quick Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // Total Questions Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.2),
                            isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.white,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Tổng số câu hỏi',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 4),
                                  Text('1,200',
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.quiz_outlined,
                                    color: theme.colorScheme.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.trending_up,
                                        size: 14, color: Colors.green),
                                    SizedBox(width: 4),
                                    Text('+15%',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('so với tháng trước',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Small Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _SmallStatCard(
                            icon: Icons.library_books_outlined,
                            label: 'Môn học',
                            value: '12',
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _SmallStatCard(
                            icon: Icons.assignment_outlined,
                            label: 'Bài thi',
                            value: '45',
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Thao tác nhanh
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 32, 20, 16),
                child: Text('Thao tác nhanh',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _ActionButton(
                      icon: Icons.add_circle_outline,
                      label: 'Tạo bài thi',
                      isPrimary: true,
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    _ActionButton(
                      icon: Icons.library_add_outlined,
                      label: 'Tạo môn học',
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    _ActionButton(
                      icon: Icons.group_add_outlined,
                      label: 'Thêm SV',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              // Bài thi gần đây
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Bài thi gần đây',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    TextButton(
                        onPressed: () {}, child: const Text('Xem tất cả')),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: recentExams.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ExamListItem(exam: recentExams[index]),
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SmallStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(label,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
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

  const _ActionButton({
    required this.icon,
    required this.label,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary
            ? theme.colorScheme.primary
            : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
        foregroundColor: isPrimary
            ? Colors.black
            : (isDark ? Colors.white70 : Colors.black87),
        elevation: isPrimary ? 4 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isPrimary
              ? BorderSide.none
              : BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}

class _ExamListItem extends StatelessWidget {
  final RecentExam exam;

  const _ExamListItem({required this.exam});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color categoryColor;
    switch (exam.category) {
      case 'JAVA':
        categoryColor = Colors.orange;
        break;
      case 'WEB':
        categoryColor = Colors.blue;
        break;
      case 'CSDL':
        categoryColor = Colors.purple;
        break;
      default:
        categoryColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              exam.category,
              style: TextStyle(
                  color: categoryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exam.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${exam.durationMinutes} phút • ${exam.questionCount} câu hỏi',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(width: 6),
                    const Icon(Icons.circle, size: 4, color: Colors.grey),
                    const SizedBox(width: 6),
                    _StatusText(status: exam.status),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              exam.status == ExamStatus.finished
                  ? Icons.visibility_outlined
                  : Icons.edit_outlined,
              color: Colors.grey,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusText extends StatelessWidget {
  final ExamStatus status;
  const _StatusText({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ExamStatus.ongoing:
        return const Text('Đang diễn ra',
            style: TextStyle(
                color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600));
      case ExamStatus.upcoming:
        return const Text('Chưa bắt đầu',
            style: TextStyle(color: Colors.grey, fontSize: 12));
      case ExamStatus.finished:
        return const Text('Đã kết thúc',
            style: TextStyle(color: Colors.grey, fontSize: 12));
    }
  }
}
