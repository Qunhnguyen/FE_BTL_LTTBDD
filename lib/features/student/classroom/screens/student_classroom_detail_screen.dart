import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../classroom/classroom_providers.dart';
import '../../../classroom/data/models/classroom_models.dart';
import '../../../classroom/presentation/cubit/classroom_state.dart';

class StudentClassroomDetailScreen extends ConsumerStatefulWidget {
  final String classroomId;

  const StudentClassroomDetailScreen({super.key, required this.classroomId});

  @override
  ConsumerState<StudentClassroomDetailScreen> createState() => _StudentClassroomDetailScreenState();
}

class _StudentClassroomDetailScreenState extends ConsumerState<StudentClassroomDetailScreen> {
  ClassroomResponse? _classroom;
  late Future<List<Map<String, dynamic>>> _classroomQuizzesFuture;

  void _reloadClassroomQuizzes() {
    setState(() {
      _classroomQuizzesFuture = ref.read(classroomRepositoryProvider).getStudentClassroomQuizzes(widget.classroomId);
    });
  }

  @override
  void initState() {
    super.initState();
    // Tìm dữ liệu lớp học từ state hiện tại của Cubit (đã load ở màn hình danh sách)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(classroomCubitProvider);
      if (state is ClassroomLoaded) {
        try {
          _classroom = state.classrooms.firstWhere((c) => c.id == widget.classroomId);
          setState(() {});
        } catch (_) {
          // Nếu không tìm thấy trong cache, có thể cần fetch riêng (nhưng hiện tại ta tận dụng cache)
        }
      }
    });
    _reloadClassroomQuizzes();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_classroom == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết lớp học')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_classroom!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card - THÔNG TIN THẬT
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                    child: const Icon(Icons.class_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Lớp học của tôi', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          _classroom!.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Mã mời: ${_classroom!.inviteCode ?? "N/A"}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Text('Danh sách bài thi được giao', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),

            // DANH SÁCH BÀI THI THẬT
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _classroomQuizzesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Lỗi tải danh sách quiz: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final quizzes = snapshot.data ?? [];
                if (quizzes.isEmpty) {
                  return _buildEmptyContests(theme);
                }
                return Column(
                  children: quizzes.map((quiz) => _buildQuizTile(quiz, theme, isDark)).toList(),
                );
              },
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.pushNamed(AppRouteNames.studentHistory),
                icon: const Icon(Icons.history_rounded),
                label: const Text('Xem tất cả lịch sử làm bài', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizTile(Map<String, dynamic> quiz, ThemeData theme, bool isDark) {
    final duration = quiz['durationMinutes'] ?? 0;
    final status = (quiz['status'] ?? 'PUBLISHED').toString();
    final attempts = quiz['remainingAttempts'];
    final subtitleAttempts = attempts == null ? 'Không giới hạn lượt' : 'Lượt còn lại: $attempts';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.quiz_rounded, color: Colors.orange),
        ),
        title: Text((quiz['name'] ?? 'Quiz').toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Thời gian: $duration phút'),
            const SizedBox(height: 2),
            Text('Trạng thái: $status', style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(subtitleAttempts, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () {
          // Điều hướng trực tiếp đến bài thi
          context.pushNamed(
            AppRouteNames.studentQuiz,
            pathParameters: {'contestId': (quiz['id'] ?? '').toString()},
          ).then((_) => _reloadClassroomQuizzes());
        },
      ),
    );
  }

  Widget _buildEmptyContests(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1), style: BorderStyle.solid),
      ),
      child: const Column(
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text('Chưa có bài thi nào được giao', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
