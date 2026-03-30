import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/admin_repository.dart';

class AdminAiJobDetailScreen extends ConsumerStatefulWidget {
  final String subjectId;
  final String jobId;

  const AdminAiJobDetailScreen({super.key, required this.subjectId, required this.jobId});

  @override
  ConsumerState<AdminAiJobDetailScreen> createState() => _AdminAiJobDetailScreenState();
}

class _AdminAiJobDetailScreenState extends ConsumerState<AdminAiJobDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết Job AI')),
      body: FutureBuilder<dynamic>(
        future: ref.watch(adminRepositoryProvider).getAiJobDetail(widget.subjectId, widget.jobId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final job = snapshot.data;
          if (job == null) return const Center(child: Text('Không tìm thấy thông tin Job'));

          final status = job['status'] ?? 'PENDING';
          final questions = job['generatedQuestions'] as List? ?? [];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Trạng thái: $status', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    if (status == 'COMPLETED')
                      ElevatedButton(
                        onPressed: () async {
                          await ref.read(adminRepositoryProvider).approveAiExam(widget.subjectId, widget.jobId);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã phê duyệt và thêm câu hỏi vào kỳ thi')));
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('PHÊ DUYỆT'),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(child: Text((index + 1).toString())),
                        title: Text(q['content'] ?? ''),
                        subtitle: Text('Đáp án đúng: ${q['correctOption']}'),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
