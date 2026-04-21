import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/app_router.dart';
import '../../../student/home/repositories/contest_repository.dart';
import '../../questions/repositories/question_repository.dart';
import '../models/contest_analytics.dart';
import '../models/item_analysis.dart';
import '../models/scoreboard.dart';

// Providers
final contestAnalyticsProvider = FutureProvider.family<ContestAnalytics, ({String id, bool isQuiz})>((ref, arg) async {
  final repo = ref.watch(contestRepositoryProvider);
  return arg.isQuiz ? repo.getQuizAnalytics(arg.id) : repo.getContestAnalytics(arg.id);
});

final scoreboardProvider = FutureProvider.family<Scoreboard, ({String id, bool isQuiz})>((ref, arg) async {
  final repo = ref.watch(contestRepositoryProvider);
  return arg.isQuiz ? repo.getQuizScoreboard(arg.id) : repo.getScoreboard(arg.id);
});

final itemAnalysisProvider = FutureProvider.family<ItemAnalysis, String>((ref, contestId) async {
  return ref.watch(contestRepositoryProvider).getItemAnalysis(contestId);
});

final classroomFilterProvider = StateProvider<String?>((ref) => null);

class ContestAnalyticsScreen extends ConsumerWidget {
  final String contestId;
  const ContestAnalyticsScreen({super.key, required this.contestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = GoRouterState.of(context);
    final isQuiz = state.uri.queryParameters['isQuiz'] == 'true';
    final sourceContestId = state.uri.queryParameters['sourceContestId'] ?? contestId;

    final primaryColor = isQuiz ? const Color(0xFF14B8A6) : const Color(0xFF3B82F6); 

    return DefaultTabController(
      length: isQuiz ? 3 : 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          title: Text(
            isQuiz ? 'Thống kê Quiz' : 'Phân tích bộ đề',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: Colors.transparent,
          foregroundColor: primaryColor,
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: primaryColor,
            indicatorWeight: 3,
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: isQuiz 
              ? [const Tab(text: 'Vận hành'), const Tab(text: 'Kết quả'), const Tab(text: 'Bảng điểm')]
              : [const Tab(text: 'Chất lượng'), const Tab(text: 'Câu hỏi')],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: isQuiz 
            ? _buildQuizView(ref, isQuiz, primaryColor, theme) 
            : _buildContestView(ref, sourceContestId, primaryColor, theme),
        ),
      ),
    );
  }

  Widget _buildQuizView(WidgetRef ref, bool isQuiz, Color themeColor, ThemeData theme) {
    final scoreboardAsync = ref.watch(scoreboardProvider((id: contestId, isQuiz: isQuiz)));
    final analyticsAsync = ref.watch(contestAnalyticsProvider((id: contestId, isQuiz: isQuiz)));

    return TabBarView(
      children: [
        scoreboardAsync.when(
          data: (s) => _buildParticipationTab(s, themeColor, theme),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Lỗi: $e')),
        ),
        analyticsAsync.when(
          data: (a) => _buildPerformanceTab(a, themeColor, theme),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Lỗi: $e')),
        ),
        scoreboardAsync.when(
          data: (s) => _buildScoreboardTab(ref, s, themeColor, theme),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Lỗi: $e')),
        ),
      ],
    );
  }

  Widget _buildParticipationTab(Scoreboard s, Color color, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildModernStatCard('Tổng học sinh', '${s.totalStudents}', Icons.people_alt_rounded, color, theme),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildModernStatCard('Đã nộp', '${s.completedCount}', Icons.task_alt_rounded, Colors.green, theme)),
            const SizedBox(width: 12),
            Expanded(child: _buildModernStatCard('Vắng', '${s.absentCount}', Icons.block, Colors.red, theme)),
          ],
        ),
        const SizedBox(height: 32),
        Text('TỶ LỆ HOÀN THÀNH', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: s.totalStudents > 0 ? s.completedCount / s.totalStudents : 0,
                  minHeight: 12,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${((s.completedCount / (s.totalStudents > 0 ? s.totalStudents : 1)) * 100).toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceTab(ContestAnalytics a, Color color, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text('ĐIỂM TRUNG BÌNH LỚP', style: TextStyle(color: color, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              const SizedBox(height: 8),
              Text(a.averageScore.toStringAsFixed(2), style: TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: color)),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildInfoRow('Điểm cao nhất', '${a.highestScore.score}', Colors.green, theme),
        _buildInfoRow('Thời gian làm bài TB', '${a.averageCompletionMinutes.toStringAsFixed(1)} phút', Colors.orange, theme),
        _buildInfoRow('Điểm thấp nhất', '${a.lowestScore.score}', Colors.red, theme),
      ],
    );
  }

  Widget _buildScoreboardTab(WidgetRef ref, Scoreboard s, Color color, ThemeData theme) {
    final selectedClass = ref.watch(classroomFilterProvider);
    final classes = s.rows.map((r) => r.classroomName).toSet().toList();
    final filteredRows = selectedClass == null ? s.rows : s.rows.where((r) => r.classroomName == selectedClass).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: DropdownButtonFormField<String?>(
            value: selectedClass,
            dropdownColor: theme.cardColor,
            decoration: InputDecoration(
              labelText: 'Lọc theo lớp học',
              filled: true,
              fillColor: theme.cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Tất cả lớp')),
              ...classes.map((c) => DropdownMenuItem(value: c, child: Text(c))),
            ],
            onChanged: (val) => ref.read(classroomFilterProvider.notifier).state = val,
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredRows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final row = filteredRows[index];
              return Container(
                decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(row.status).withOpacity(0.1),
                    child: Text(row.studentName[0], style: TextStyle(color: _getStatusColor(row.status), fontWeight: FontWeight.bold)),
                  ),
                  title: Text(row.studentName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  subtitle: Text('${row.classroomName} • ${row.status}', style: const TextStyle(fontSize: 12)),
                  trailing: Text(row.score?.toStringAsFixed(1) ?? '-', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
                  onTap: () {
                    context.pushNamed(AppRouteNames.teacherStudentSubmission, pathParameters: {'contestId': contestId, 'studentId': row.studentId});
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContestView(WidgetRef ref, String sourceContestId, Color themeColor, ThemeData theme) {
    final analyticsAsync = ref.watch(contestAnalyticsProvider((id: contestId, isQuiz: false)));
    final itemAnalysisAsync = ref.watch(itemAnalysisProvider(sourceContestId));

    return TabBarView(
      children: [
        analyticsAsync.when(
          data: (a) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildModernStatCard('Độ khó đề', a.averageScore.toStringAsFixed(2), Icons.psychology_rounded, themeColor, theme),
              const SizedBox(height: 12),
              _buildModernStatCard('Tổng lượt thi', '${a.participation.participantCount}', Icons.auto_graph_rounded, themeColor, theme),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Lỗi: $e')),
        ),
        itemAnalysisAsync.when(
          data: (i) => _buildQuestionAnalysisList(ref, i, themeColor, theme),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Lỗi: $e')),
        ),
      ],
    );
  }

  Widget _buildQuestionAnalysisList(WidgetRef ref, ItemAnalysis itemAnalysis, Color themeColor, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemAnalysis.optionAnalysis.length,
      itemBuilder: (context, index) {
        final oa = itemAnalysis.optionAnalysis[index];
        final qa = itemAnalysis.hardestQuestions.firstWhere((q) => q.questionId == oa.questionId, orElse: () => 
                   itemAnalysis.easiestQuestions.firstWhere((q) => q.questionId == oa.questionId, orElse: () =>
                   QuestionAnalysis(questionId: '', questionNo: 0, content: '', attempts: 0, correctCount: 0, wrongCount: 0, correctRate: 0, wrongRate: 0)));

        // FIX LỖI SỐ CÂU: Nếu questionNo = 0 thì dùng index + 1
        final displayNo = oa.questionNo == 0 ? index + 1 : oa.questionNo;
        final difficulty = oa.difficulty ?? qa.difficulty ?? 'MEDIUM';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: theme.cardColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: themeColor.withOpacity(0.1))),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // HIỂN THỊ SỐ CÂU + ĐỘ KHÓ
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: themeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        'CÂU $displayNo [$difficulty]', 
                        style: TextStyle(color: themeColor, fontWeight: FontWeight.w900, fontSize: 12)
                      ),
                    ),
                    IconButton(icon: Icon(Icons.tune_rounded, color: themeColor), onPressed: () => _showDifficultyDialog(context, ref, oa)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(oa.content, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4)),
                const Divider(height: 32),
                Row(
                  children: [
                    _percentCircle('Đúng', qa.correctRate, Colors.green),
                    const SizedBox(width: 24),
                    _percentCircle('Sai', qa.wrongRate, Colors.red),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernStatCard(String label, String value, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            Text(value, style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _percentCircle(String label, double val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        Text('${val.toStringAsFixed(1)}%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'COMPLETED') return Colors.green;
    if (status == 'IN_PROGRESS') return Colors.orange;
    return Colors.red;
  }

  void _showDifficultyDialog(BuildContext context, WidgetRef ref, OptionAnalysis oa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cập nhật độ khó'),
        actions: [
          TextButton(onPressed: () => _updateLevel(context, ref, oa, 'EASY'), child: const Text('EASY', style: TextStyle(color: Colors.green))),
          TextButton(onPressed: () => _updateLevel(context, ref, oa, 'MEDIUM'), child: const Text('MEDIUM', style: TextStyle(color: Colors.orange))),
          TextButton(onPressed: () => _updateLevel(context, ref, oa, 'HARD'), child: const Text('HARD', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _updateLevel(BuildContext context, WidgetRef ref, OptionAnalysis oa, String level) async {
    try {
      await ref.read(questionRepositoryProvider).updateQuestion(oa.questionId, {'level': level});
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã cập nhật câu thành $level')));
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }
}
