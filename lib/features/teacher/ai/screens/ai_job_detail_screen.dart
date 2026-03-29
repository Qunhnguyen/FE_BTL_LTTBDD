import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/ai_models.dart';
import '../repositories/ai_repository.dart';
import '../../subjects/repositories/classroom_repository.dart';

class AiJobDetailScreen extends ConsumerStatefulWidget {
  final String subjectId;
  final String jobId;
  const AiJobDetailScreen({super.key, required this.subjectId, required this.jobId});

  @override
  ConsumerState<AiJobDetailScreen> createState() => _AiJobDetailScreenState();
}

class _AiJobDetailScreenState extends ConsumerState<AiJobDetailScreen> {
  Timer? _timer;
  AiExamJobResponse? _job;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchJob();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_job?.status != 'COMPLETED' && _job?.status != 'FAILED' && _job?.status != 'ALREADY_APPROVED') {
        _fetchJob();
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchJob() async {
    try {
      final job = await ref.read(aiRepositoryProvider).getAiJobDetail(widget.subjectId, widget.jobId);
      if (mounted) {
        setState(() {
          _job = job;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _approveJob() async {
    if (_job?.examDraft == null) return;

    final nameController = TextEditingController(text: _job!.examDraft!.title);
    final descController = TextEditingController(text: _job!.examDraft!.description);
    final durationController = TextEditingController(text: _job!.examDraft!.durationMinutes.toString());
    
    DateTime startAt = DateTime.now().add(const Duration(hours: 1));
    DateTime endAt = startAt.add(Duration(minutes: _job!.examDraft!.durationMinutes));
    List<String> selectedClassrooms = [];

    final result = await showDialog<AiExamApproveRequest>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Phê duyệt đề thi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên kỳ thi')),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Mô tả')),
                TextField(controller: durationController, decoration: const InputDecoration(labelText: 'Thời gian (phút)'), keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Bắt đầu'),
                  subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(startAt)),
                  onTap: () async {
                    final date = await showDatePicker(context: context, initialDate: startAt, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                    if (date != null) {
                      final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(startAt));
                      if (time != null) {
                        setDialogState(() {
                          startAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                          endAt = startAt.add(Duration(minutes: int.tryParse(durationController.text) ?? 0));
                        });
                      }
                    }
                  },
                ),
                ListTile(
                  title: const Text('Kết thúc'),
                  subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(endAt)),
                  onTap: () async {
                    final date = await showDatePicker(context: context, initialDate: endAt, firstDate: startAt, lastDate: DateTime.now().add(const Duration(days: 365)));
                    if (date != null) {
                      final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(endAt));
                      if (time != null) {
                        setDialogState(() => endAt = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, AiExamApproveRequest(
                contestName: nameController.text,
                contestDescription: descController.text,
                durationMinutes: int.parse(durationController.text),
                startAt: startAt.toIso8601String(),
                endAt: endAt.toIso8601String(),
                classroomIds: selectedClassrooms,
              )),
              child: const Text('Phê duyệt'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        await ref.read(aiRepositoryProvider).approveAiJob(widget.subjectId, widget.jobId, result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã phê duyệt đề thi thành công!')));
          _fetchJob(); // Refresh to see ALREADY_APPROVED or updated status
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _job == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null && _job == null) return Scaffold(body: Center(child: Text(_error!)));

    final job = _job!;
    final isCompleted = job.status == 'COMPLETED';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả AI'),
        actions: [
          IconButton(onPressed: _fetchJob, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(job),
            const SizedBox(height: 16),
            if (job.examDraft != null) ...[
              Text('DỰ THẢO ĐỀ THI', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.examDraft!.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      if (job.examDraft!.description != null) Text(job.examDraft!.description!),
                      const Divider(),
                      Text('Thời lượng: ${job.examDraft!.durationMinutes} phút'),
                      Text('Số câu hỏi: ${job.examDraft!.questions.length}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...job.examDraft!.questions.map((q) => _buildQuestionCard(q)),
            ],
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: isCompleted
          ? FloatingActionButton.extended(
              onPressed: _approveJob,
              label: const Text('PHÊ DUYỆT ĐỀ THI'),
              icon: const Icon(Icons.check_circle),
            )
          : null,
    );
  }

  Widget _buildStatusCard(AiExamJobResponse job) {
    Color statusColor = Colors.orange;
    if (job.status == 'COMPLETED') statusColor = Colors.green;
    if (job.status == 'FAILED') statusColor = Colors.red;
    if (job.status == 'ALREADY_APPROVED') statusColor = Colors.blue;

    return Card(
      color: statusColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: statusColor),
                const SizedBox(width: 8),
                Text('Trạng thái: ${job.status}', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
              ],
            ),
            if (job.mode != null) Text('Chế độ: ${job.mode}'),
            if (job.fallbackReason != null) 
              Text('Lưu ý: ${job.fallbackReason}', style: const TextStyle(color: Colors.brown, fontStyle: FontStyle.italic)),
            if (job.warnings != null && job.warnings!.isNotEmpty)
              ...job.warnings!.map((w) => Text('⚠️ $w', style: const TextStyle(color: Colors.orange, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(AiQuestionDraft q) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Câu ${q.questionNo}: ${q.content}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildOption('A', q.optionA, q.correctOption == 'A'),
            _buildOption('B', q.optionB, q.correctOption == 'B'),
            _buildOption('C', q.optionC, q.correctOption == 'C'),
            _buildOption('D', q.optionD, q.correctOption == 'D'),
            if (q.explanation != null) ...[
              const Divider(),
              Text('Giải thích: ${q.explanation}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text(q.difficulty), visualDensity: VisualDensity.compact),
                ...q.tags.map((t) => Chip(label: Text(t), visualDensity: VisualDensity.compact)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String label, String text, bool isCorrect) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(4),
        border: isCorrect ? Border.all(color: Colors.green) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label. ', style: TextStyle(fontWeight: isCorrect ? FontWeight.bold : null)),
          Expanded(child: Text(text, style: TextStyle(fontWeight: isCorrect ? FontWeight.bold : null))),
        ],
      ),
    );
  }
}
