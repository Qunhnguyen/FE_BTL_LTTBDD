import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_models.dart';
import '../repositories/ai_repository.dart';
import '../../subjects/screens/teacher_classroom_list_screen.dart';

class KnowledgeManagementScreen extends ConsumerStatefulWidget {
  final String subjectId;
  const KnowledgeManagementScreen({super.key, required this.subjectId});

  @override
  ConsumerState<KnowledgeManagementScreen> createState() => _KnowledgeManagementScreenState();
}

class _KnowledgeManagementScreenState extends ConsumerState<KnowledgeManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _textFormKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedClassroomId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _ingestText() async {
    if (!_textFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final request = KnowledgeIngestRequest(
        title: _titleController.text,
        content: _contentController.text,
        classroomId: _selectedClassroomId,
        sourceType: 'TEXT',
      );
      await ref.read(aiRepositoryProvider).ingestKnowledgeText(widget.subjectId, request);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nạp tri thức văn bản thành công!')),
        );
        _titleController.clear();
        _contentController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _ingestFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'csv', 'md', 'json', 'log', 'pdf', 'docx'],
    );

    if (result == null || result.files.single.path == null) return;

    final file = result.files.single;
    
    // Show dialog to enter title
    final titleController = TextEditingController(text: file.name);
    final String? title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nhập tiêu đề tài liệu'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Tiêu đề'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, titleController.text), child: const Text('OK')),
        ],
      ),
    );

    if (title == null || title.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(aiRepositoryProvider).ingestKnowledgeFile(
            subjectId: widget.subjectId,
            title: title,
            filePath: file.path!,
            fileName: file.name,
            classroomId: _selectedClassroomId,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nạp tri thức file thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final classroomsAsync = ref.watch(classroomsProvider(widget.subjectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Tri thức (RAG)'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.text_fields), text: 'Văn bản'),
            Tab(icon: Icon(Icons.upload_file), text: 'Tập tin'),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: classroomsAsync.when(
                  data: (classrooms) => DropdownButtonFormField<String>(
                    value: _selectedClassroomId,
                    decoration: const InputDecoration(
                      labelText: 'Áp dụng cho lớp học (Tùy chọn)',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Tất cả lớp học')),
                      ...classrooms.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                    ],
                    onChanged: (val) => setState(() => _selectedClassroomId = val),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Không thể tải danh sách lớp học'),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTextTab(),
                    _buildFileTab(),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildTextTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _textFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề tri thức',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Nội dung tri thức',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 10,
              validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập nội dung' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _ingestText,
              icon: const Icon(Icons.save),
              label: const Text('Lưu Tri thức'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_upload_outlined, size: 100, color: Colors.blueGrey),
          const SizedBox(height: 16),
          const Text(
            'Hỗ trợ: txt, csv, md, json, pdf, docx',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _ingestFile,
            icon: const Icon(Icons.add_to_drive),
            label: const Text('Chọn tập tin để nạp'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }
}
