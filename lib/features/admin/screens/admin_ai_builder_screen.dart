import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Exam Builder')),
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
                DropdownButtonFormField<String>(
                  value: _selectedContestId,
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
                  value: _level,
                  decoration: const InputDecoration(labelText: 'Độ khó'),
                  items: ['EASY', 'MEDIUM', 'HARD'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                  onChanged: (val) => setState(() => _level = val!),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _selectedContestId == null ? null : () async {
                    final result = await ref.read(adminRepositoryProvider).generateAiExam(widget.subjectId, {
                      'contestId': _selectedContestId,
                      'numberOfQuestions': _numQuestions,
                      'topic': _topicController.text,
                      'level': _level,
                    });
                    if (mounted && result['jobId'] != null) {
                      context.push('/admin/subjects/${widget.subjectId}/ai-jobs/${result['jobId']}');
                    }
                  },
                  child: const Text('BẮT ĐẦU TẠO ĐỀ'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
