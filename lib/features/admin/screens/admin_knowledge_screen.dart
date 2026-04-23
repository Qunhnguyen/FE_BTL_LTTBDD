import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/admin_repository.dart';

class AdminKnowledgeScreen extends ConsumerStatefulWidget {
  final String subjectId;
  final String subjectName;

  const AdminKnowledgeScreen({super.key, required this.subjectId, required this.subjectName});

  @override
  ConsumerState<AdminKnowledgeScreen> createState() => _AdminKnowledgeScreenState();
}

class _AdminKnowledgeScreenState extends ConsumerState<AdminKnowledgeScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _ingestText() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(adminRepositoryProvider).ingestKnowledgeText(widget.subjectId, {
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'sourceType': 'MANUAL',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nạp kiến thức thành công')));
        _titleController.clear();
        _contentController.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _ingestFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null) {
        final file = File(result.files.single.path!);
        await ref.read(adminRepositoryProvider).ingestKnowledgeFile(
          widget.subjectId, file, 'Tài liệu: ${widget.subjectName}', 'FILE', null
        );
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tải tệp kiến thức thành công')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: Text('Kho kiến thức: ${widget.subjectName}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: primary.withValues(alpha: 0.08),
                border: Border.all(color: primary.withValues(alpha: 0.18)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.psychology_outlined),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Nạp dữ liệu kiến thức để AI sinh đề sát nội dung môn học.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Nạp kiến thức dạng văn bản', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Tiêu đề', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: _contentController, decoration: const InputDecoration(labelText: 'Nội dung kiến thức', border: OutlineInputBorder()), maxLines: 8),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _ingestText,
                        child: Text(_isSubmitting ? 'Đang gửi...' : 'Gửi kiến thức'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Center(child: Text('HOẶC', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: _ingestFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('TẢI LÊN TỆP KIẾN THỨC (PDF, DOCX, CSV)'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
