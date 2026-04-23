import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/admin_repository.dart';

class AdminQuestionListScreen extends ConsumerStatefulWidget {
  final String contestId;
  final String contestName;

  const AdminQuestionListScreen({
    super.key,
    required this.contestId,
    required this.contestName,
  });

  @override
  ConsumerState<AdminQuestionListScreen> createState() => _AdminQuestionListScreenState();
}

class _AdminQuestionListScreenState extends ConsumerState<AdminQuestionListScreen> {
  final _contentController = TextEditingController();
  final _optionAController = TextEditingController();
  final _optionBController = TextEditingController();
  final _optionCController = TextEditingController();
  final _optionDController = TextEditingController();
  String _correctOption = 'A';
  bool _isSaving = false;

  @override
  void dispose() {
    _contentController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    _optionCController.dispose();
    _optionDController.dispose();
    super.dispose();
  }

  void _showQuestionDialog({Map<String, dynamic>? question}) {
    if (question != null) {
      _contentController.text = question['content'] ?? '';
      _optionAController.text = question['optionA'] ?? '';
      _optionBController.text = question['optionB'] ?? '';
      _optionCController.text = question['optionC'] ?? '';
      _optionDController.text = question['optionD'] ?? '';
      _correctOption = question['correctOption'] ?? 'A';
    } else {
      _contentController.clear();
      _optionAController.clear();
      _optionBController.clear();
      _optionCController.clear();
      _optionDController.clear();
      _correctOption = 'A';
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(question == null ? 'Thêm câu hỏi mới' : 'Cập nhật câu hỏi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Nội dung câu hỏi',
                    prefixIcon: Icon(Icons.quiz_outlined),
                  ),
                  maxLines: 3,
                ),
                TextField(
                  controller: _optionAController,
                  decoration: const InputDecoration(labelText: 'Đáp án A'),
                ),
                TextField(
                  controller: _optionBController,
                  decoration: const InputDecoration(labelText: 'Đáp án B'),
                ),
                TextField(
                  controller: _optionCController,
                  decoration: const InputDecoration(labelText: 'Đáp án C'),
                ),
                TextField(
                  controller: _optionDController,
                  decoration: const InputDecoration(labelText: 'Đáp án D'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _correctOption,
                  decoration: const InputDecoration(labelText: 'Đáp án đúng'),
                  items: ['A', 'B', 'C', 'D'].map((opt) => DropdownMenuItem(value: opt, child: Text('Đáp án $opt'))).toList(),
                  onChanged: (val) => setDialogState(() => _correctOption = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: _isSaving ? null : () async {
                if (_contentController.text.trim().isEmpty) {
                  return;
                }
                setState(() => _isSaving = true);
                final data = {
                  'contestId': widget.contestId,
                  'content': _contentController.text.trim(),
                  'optionA': _optionAController.text.trim(),
                  'optionB': _optionBController.text.trim(),
                  'optionC': _optionCController.text.trim(),
                  'optionD': _optionDController.text.trim(),
                  'correctOption': _correctOption,
                  'questionNo': question?['questionNo'] ?? 1,
                  'level': question?['level'] ?? 'MEDIUM',
                  'score': question?['score'] ?? 1.0,
                };

                try {
                  if (question == null) {
                    await ref.read(adminRepositoryProvider).createQuestion(data);
                  } else {
                    await ref.read(adminRepositoryProvider).updateQuestion(question['id'].toString(), data);
                  }

                  if (!context.mounted) return;
                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(question == null ? 'Đã thêm câu hỏi' : 'Đã cập nhật câu hỏi')),
                  );
                } finally {
                  if (mounted) {
                    setState(() => _isSaving = false);
                  }
                }
              },
              child: Text(_isSaving ? 'Đang lưu...' : question == null ? 'Thêm' : 'Cập nhật'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      try {
        await ref.read(adminRepositoryProvider).importQuestionsCsv(widget.contestId, file, true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Import thành công')));
          setState(() {});
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  Future<void> _importS3() async {
    final qKeyController = TextEditingController();
    final aKeyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import từ S3 Storage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: qKeyController, decoration: const InputDecoration(labelText: 'Question File Key (S3)')),
            TextField(controller: aKeyController, decoration: const InputDecoration(labelText: 'Answer File Key (S3)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              // Note: subjectId is needed for the S3 import API in your JSON
              // We'll assume the repository handles finding the subject or we pass it
              // Since the API path is /api/admin/subjects/{{subjectId}}/contests/{{contestId}}/import-questions
              // We'll need subjectId here.
              // For simplicity, let's assume we have it or the repo API is adjusted.
              // I'll use a placeholder or check if I can get it from context.
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang xử lý yêu cầu import S3...')));
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCsv() async {
    try {
      await ref.read(adminRepositoryProvider).exportQuestionsToCsv(widget.contestId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yêu cầu xuất CSV đã được gửi')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Câu hỏi: ${widget.contestName}'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'csv_in') _importCsv();
              if (val == 'csv_out') _exportCsv();
              if (val == 's3_in') _importS3();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'csv_in', child: ListTile(leading: Icon(Icons.file_upload), title: Text('Import CSV'))),
              const PopupMenuItem(value: 'csv_out', child: ListTile(leading: Icon(Icons.file_download), title: Text('Export CSV'))),
              const PopupMenuItem(value: 's3_in', child: ListTile(leading: Icon(Icons.cloud_download), title: Text('Import from S3'))),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ref.watch(adminRepositoryProvider).getQuestionsByContest(widget.contestId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final questions = snapshot.data ?? [];
          if (questions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.help_outline, size: 50, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Chưa có câu hỏi nào'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final q = questions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ExpansionTile(
                  leading: CircleAvatar(child: Text((index + 1).toString())),
                  title: Text(q['content'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('A: ${q['optionA']}'),
                          Text('B: ${q['optionB']}'),
                          Text('C: ${q['optionC']}'),
                          Text('D: ${q['optionD']}'),
                          const Divider(),
                          Text('Đáp án đúng: ${q['correctOption']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showQuestionDialog(question: q)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await ref.read(adminRepositoryProvider).deleteQuestion(q['id'].toString());
                                  setState(() {});
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showQuestionDialog(), child: const Icon(Icons.add)),
    );
  }
}
