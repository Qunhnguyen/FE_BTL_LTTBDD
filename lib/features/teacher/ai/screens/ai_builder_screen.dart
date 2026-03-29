import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../models/ai_models.dart';
import '../repositories/ai_repository.dart';
import '../../subjects/screens/teacher_classroom_list_screen.dart';

class AiBuilderScreen extends ConsumerStatefulWidget {
  final String subjectId;
  const AiBuilderScreen({super.key, required this.subjectId});

  @override
  ConsumerState<AiBuilderScreen> createState() => _AiBuilderScreenState();
}

class _AiBuilderScreenState extends ConsumerState<AiBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _topicController = TextEditingController();
  final _questionCountController = TextEditingController(text: '10');
  final _durationController = TextEditingController(text: '15');
  
  bool _useRag = false;
  final _topKController = TextEditingController(text: '5');
  final _minScoreController = TextEditingController(text: '0.05');
  String? _ragClassroomId;
  
  bool _isGenerating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _topicController.dispose();
    _questionCountController.dispose();
    _durationController.dispose();
    _topKController.dispose();
    _minScoreController.dispose();
    super.dispose();
  }

  Future<void> _generateExam() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isGenerating = true);
    try {
      final request = AiExamGenerateRequest(
        title: _titleController.text,
        topic: _topicController.text,
        questionCount: int.parse(_questionCountController.text),
        durationMinutes: int.parse(_durationController.text),
        useRag: _useRag,
        difficultyDistribution: {
          'easy': 40,
          'medium': 40,
          'hard': 20,
        },
        ragOptions: _useRag ? RagOptions(
          topK: int.parse(_topKController.text),
          minScore: double.parse(_minScoreController.text),
          classroomId: _ragClassroomId,
        ) : null,
      );

      final response = await ref.read(aiRepositoryProvider).generateAiExam(widget.subjectId, request);
      
      if (mounted) {
        context.pushNamed(
          AppRouteNames.teacherAiJobDetail,
          pathParameters: {
            'subjectId': widget.subjectId,
            'jobId': response.jobId,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final classroomsAsync = ref.watch(classroomsProvider(widget.subjectId));

    return Scaffold(
      appBar: AppBar(title: const Text('Tạo đề AI (RAG Dynamic)')),
      body: _isGenerating 
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('AI đang soạn đề, vui lòng đợi...'),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Tên kỳ thi', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập tên' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _topicController,
                    decoration: const InputDecoration(labelText: 'Chủ đề / Yêu cầu chi tiết', border: OutlineInputBorder()),
                    maxLines: 2,
                    validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập chủ đề' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _questionCountController,
                          decoration: const InputDecoration(labelText: 'Số câu hỏi', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Phải > 0' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _durationController,
                          decoration: const InputDecoration(labelText: 'Thời gian (phút)', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: const Text('Sử dụng tri thức đã nạp (RAG)'),
                    subtitle: const Text('AI sẽ dựa trên tài liệu bạn đã nạp để soạn đề'),
                    value: _useRag,
                    onChanged: (val) => setState(() => _useRag = val),
                  ),
                  if (_useRag) ...[
                    const SizedBox(height: 16),
                    classroomsAsync.when(
                      data: (classrooms) => DropdownButtonFormField<String>(
                        value: _ragClassroomId,
                        decoration: const InputDecoration(labelText: 'Lấy tri thức từ lớp học', border: OutlineInputBorder()),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Toàn bộ môn học')),
                          ...classrooms.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                        ],
                        onChanged: (val) => setState(() => _ragClassroomId = val),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const Text('Lỗi tải lớp học'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _topKController,
                            decoration: const InputDecoration(labelText: 'Số lượng context (topK)', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _minScoreController,
                            decoration: const InputDecoration(labelText: 'Min Score', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _generateExam,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('BẮT ĐẦU TẠO ĐỀ AI', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
