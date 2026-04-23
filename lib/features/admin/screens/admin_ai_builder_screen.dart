import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../repositories/admin_repository.dart';

class AdminAiBuilderScreen extends ConsumerStatefulWidget {
  final String subjectId;

  const AdminAiBuilderScreen({super.key, required this.subjectId});

  @override
  ConsumerState<AdminAiBuilderScreen> createState() => _AdminAiBuilderScreenState();
}

class _AdminAiBuilderScreenState extends ConsumerState<AdminAiBuilderScreen> {
  final _topicController = TextEditingController();
  int _numQuestions = 10;
  String _level = 'MEDIUM';
  String? _selectedContestId;
  bool _isGenerating = false;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Exam Builder'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ref.watch(adminRepositoryProvider).getContestsBySubject(widget.subjectId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final contests = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                  ),
                  child: const Text('Thiết lập nhanh tham số để AI sinh bộ câu hỏi cho kỳ thi mục tiêu.'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedContestId,
                  decoration: const InputDecoration(labelText: 'Chọn kỳ thi mục tiêu'),
                  items: contests.map((c) => DropdownMenuItem(value: c['id'].toString(), child: Text(c['name']))).toList(),
                  onChanged: (val) => setState(() => _selectedContestId = val),
                ),
                const SizedBox(height: 16),
                TextField(controller: _topicController, decoration: const InputDecoration(labelText: 'Chủ đề/Phạm vi kiến thức')),
                const SizedBox(height: 16),
                const Text('Số lượng câu hỏi'),
                Slider(
                  value: _numQuestions.toDouble(),
                  min: 5, max: 50, divisions: 9,
                  label: _numQuestions.toString(),
                  onChanged: (val) => setState(() => _numQuestions = val.round()),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _level,
                  decoration: const InputDecoration(labelText: 'Độ khó'),
                  items: ['EASY', 'MEDIUM', 'HARD'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                  onChanged: (val) => setState(() => _level = val!),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _selectedContestId == null || _isGenerating ? null : () async {
                    setState(() => _isGenerating = true);
                    try {
                      final result = await ref.read(adminRepositoryProvider).generateAiExam(widget.subjectId, {
                        'contestId': _selectedContestId,
                        'numberOfQuestions': _numQuestions,
                        'topic': _topicController.text.trim(),
                        'level': _level,
                      });
                      if (!context.mounted || result['jobId'] == null) return;
                      context.pushNamed(
                        AppRouteNames.adminAiJobDetail,
                        pathParameters: {
                          'subjectId': widget.subjectId,
                          'jobId': result['jobId'].toString(),
                        },
                      );
                    } finally {
                      if (mounted) {
                        setState(() => _isGenerating = false);
                      }
                    }
                  },
                  child: Text(_isGenerating ? 'Đang tạo đề...' : 'BẮT ĐẦU TẠO ĐỀ'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
