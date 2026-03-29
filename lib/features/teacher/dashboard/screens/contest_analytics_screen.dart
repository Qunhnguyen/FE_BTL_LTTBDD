import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../student/home/repositories/contest_repository.dart';
import '../models/contest_analytics.dart';
import '../models/item_analysis.dart';
import '../models/scoreboard.dart';

final contestAnalyticsProvider = FutureProvider.family<ContestAnalytics, String>((ref, contestId) async {
  return ref.watch(contestRepositoryProvider).getContestAnalytics(contestId);
});

final itemAnalysisProvider = FutureProvider.family<ItemAnalysis, String>((ref, contestId) async {
  return ref.watch(contestRepositoryProvider).getItemAnalysis(contestId);
});

final scoreboardProvider = FutureProvider.family<Scoreboard, String>((ref, contestId) async {
  return ref.watch(contestRepositoryProvider).getScoreboard(contestId);
});

class ContestAnalyticsScreen extends ConsumerWidget {
  final String contestId;
  const ContestAnalyticsScreen({super.key, required this.contestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(contestAnalyticsProvider(contestId));
    final itemAnalysisAsync = ref.watch(itemAnalysisProvider(contestId));
    final scoreboardAsync = ref.watch(scoreboardProvider(contestId));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Phân tích cuộc thi'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Tổng quan'),
              Tab(text: 'Bảng điểm'),
              Tab(text: 'Chi tiết câu hỏi'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            analyticsAsync.when(
              data: (analytics) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewCard(analytics),
                    const SizedBox(height: 20),
                    _buildParticipationCard(analytics.participation),
                    const SizedBox(height: 20),
                    _buildScoreDistributionCard(analytics.scoreDistribution),
                    const SizedBox(height: 20),
                    _buildExtremeScoresCard(analytics),
                  ],
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi: $err')),
            ),
            scoreboardAsync.when(
              data: (scoreboard) => _buildScoreboardView(scoreboard),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi: $err')),
            ),
            itemAnalysisAsync.when(
              data: (itemAnalysis) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Câu hỏi khó nhất'),
                    ...itemAnalysis.hardestQuestions.map((q) => _buildQuestionCard(q, Colors.red[50]!)),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Câu hỏi dễ nhất'),
                    ...itemAnalysis.easiestQuestions.map((q) => _buildQuestionCard(q, Colors.green[50]!)),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Phân tích lựa chọn'),
                    ...itemAnalysis.optionAnalysis.map((oa) => _buildOptionAnalysisCard(oa)),
                  ],
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi: $err')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreboardView(Scoreboard scoreboard) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Tổng', scoreboard.totalStudents.toString()),
              _buildSummaryItem('Hoàn thành', scoreboard.completedCount.toString(), Colors.green),
              _buildSummaryItem('Đang làm', scoreboard.inProgressCount.toString(), Colors.orange),
              _buildSummaryItem('Vắng', scoreboard.absentCount.toString(), Colors.red),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Sinh viên')),
                  DataColumn(label: Text('Lớp')),
                  DataColumn(label: Text('Điểm')),
                  DataColumn(label: Text('Trạng thái')),
                  DataColumn(label: Text('Thời gian nộp')),
                ],
                rows: scoreboard.rows.map((row) {
                  return DataRow(cells: [
                    DataCell(Text(row.studentName)),
                    DataCell(Text(row.classroomName)),
                    DataCell(Text(row.score?.toStringAsFixed(1) ?? '-')),
                    DataCell(_buildStatusBadge(row.status)),
                    DataCell(Text(row.submittedAt != null 
                        ? DateFormat('HH:mm dd/MM/yyyy').format(row.submittedAt!) 
                        : '-')),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, [Color? color]) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case 'COMPLETED':
        color = Colors.green;
        text = 'Đã nộp';
        break;
      case 'IN_PROGRESS':
        color = Colors.orange;
        text = 'Đang làm';
        break;
      case 'ABSENT':
        color = Colors.red;
        text = 'Vắng';
        break;
      default:
        color = Colors.grey;
        text = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildQuestionCard(QuestionAnalysis q, Color bgColor) {
    return Card(
      color: bgColor,
      child: ListTile(
        title: Text('Câu ${q.questionNo}: ${q.content}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text('Đúng: ${q.correctCount} (${q.correctRate}%)', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Text('Sai: ${q.wrongCount} (${q.wrongRate}%)', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
            Text('Số lượt làm: ${q.attempts}'),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionAnalysisCard(OptionAnalysis oa) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Câu ${oa.questionNo}: ${oa.content}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            ...oa.optionCounts.entries.map((entry) {
              final percentage = oa.attempts > 0 ? (entry.value / oa.attempts * 100).toStringAsFixed(1) : '0';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(width: 60, child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500))),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: oa.attempts > 0 ? entry.value / oa.attempts : 0,
                        backgroundColor: Colors.grey[200],
                        color: Colors.blue[300],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${entry.value} ($percentage%)'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(ContestAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              analytics.contestName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Điểm TB', analytics.averageScore.toStringAsFixed(2), Colors.blue),
                _buildStatItem('Thời gian TB', '${analytics.averageCompletionMinutes.toStringAsFixed(1)} ph', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipationCard(Participation p) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tham gia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: p.participationRate / 100,
              backgroundColor: Colors.grey[200],
              color: Colors.green,
              minHeight: 10,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sĩ số: ${p.totalStudents}'),
                Text('Đã thi: ${p.participantCount}'),
                Text('Tỉ lệ: ${p.participationRate.toStringAsFixed(1)}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreDistributionCard(List<ScoreDistribution> distribution) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Phổ điểm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...distribution.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  SizedBox(width: 50, child: Text(d.range)),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: d.count / 20, // Giả sử max là 20 để minh họa
                        minHeight: 12,
                        color: Colors.blue[400],
                        backgroundColor: Colors.grey[100],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${d.count} SV'),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildExtremeScoresCard(ContestAnalytics analytics) {
    return Row(
      children: [
        Expanded(
          child: _buildStudentScoreCard(
            'Cao nhất',
            analytics.highestScore.studentName,
            analytics.highestScore.score,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStudentScoreCard(
            'Thấp nhất',
            analytics.lowestScore.studentName,
            analytics.lowestScore.score,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentScoreCard(String label, String name, double score, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(score.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
