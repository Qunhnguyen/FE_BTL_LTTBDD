import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../student/home/repositories/contest_repository.dart';
import '../models/contest_analytics.dart';

final contestAnalyticsProvider = FutureProvider.family<ContestAnalytics, String>((ref, contestId) async {
  return ref.watch(contestRepositoryProvider).getContestAnalytics(contestId);
});

class ContestAnalyticsScreen extends ConsumerWidget {
  final String contestId;
  const ContestAnalyticsScreen({super.key, required this.contestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(contestAnalyticsProvider(contestId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân tích cuộc thi'),
      ),
      body: analyticsAsync.when(
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
