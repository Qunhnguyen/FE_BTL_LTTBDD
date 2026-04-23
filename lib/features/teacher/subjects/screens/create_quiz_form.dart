import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers/auth_provider.dart';
import '../models/quiz.dart';
import '../providers/quiz_providers.dart';
import '../repositories/classroom_repository.dart';
import '../repositories/quiz_repository.dart';
import 'teacher_contest_list_screen.dart';

class CreateQuizForm extends ConsumerStatefulWidget {
  final String subjectId;
  final Quiz? quizToEdit;

  const CreateQuizForm({super.key, required this.subjectId, this.quizToEdit});

  @override
  ConsumerState<CreateQuizForm> createState() => _CreateQuizFormState();
}

class _CreateQuizFormState extends ConsumerState<CreateQuizForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _selectionCountController; // MỚI
  
  String? _selectedContestId;
  late int _duration;
  late int _maxAttempts;
  late bool _randomQuestion;
  late bool _randomAnswer;
  late String _difficulty;
  List<String> _selectedClassIds = [];

  @override
  void initState() {
    super.initState();
    final quiz = widget.quizToEdit;
    _nameController = TextEditingController(text: quiz?.name ?? '');
    _descController = TextEditingController(text: quiz?.description ?? '');
    _selectionCountController = TextEditingController(
      text: quiz?.questionSelectionCount?.toString() ?? ''
    );
    _selectedContestId = quiz?.sourceContestId;
    _duration = quiz?.durationMinutes ?? 30;
    _maxAttempts = quiz?.maxAttempts ?? 1;
    _randomQuestion = quiz?.randomQuestionOrder ?? true;
    _randomAnswer = quiz?.randomAnswerOrder ?? true;
    _difficulty = quiz?.difficulty ?? 'MEDIUM';
    _selectedClassIds = List.from(quiz?.classroomIds ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _selectionCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userRole = ref.watch(authProvider).user?.role;
    final isAdmin = userRole == 'ADMIN';
    final isTeacher = userRole == 'TEACHER';
    final contestsAsync = ref.watch(contestsBySubjectProvider(widget.subjectId));

    return Scaffold(
      appBar: AppBar(title: Text(widget.quizToEdit != null ? 'Sửa Quiz' : 'Tạo Quiz')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên Quiz (VD: Giữa kỳ 1)', border: OutlineInputBorder()),
              validator: (v) => v?.isEmpty == true ? 'Vui lòng nhập tên' : null,
            ),
            const SizedBox(height: 16),
            contestsAsync.when(
              data: (contests) => DropdownButtonFormField<String>(
                value: _selectedContestId,
                decoration: const InputDecoration(labelText: 'Chọn bộ đề nguồn (Contest)', border: OutlineInputBorder()),
                items: contests.map((c) => DropdownMenuItem(value: c.id, child: Text(c.title))).toList(),
                onChanged: (v) => setState(() => _selectedContestId = v),
                validator: (v) => v == null ? 'Bắt buộc chọn bộ đề' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, st) => Text('Lỗi tải đề: $e', style: const TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 16),
            
            // MỚI: Nhập số lượng câu hỏi tuyển chọn
            TextFormField(
              controller: _selectionCountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số lượng câu hỏi (Để trống nếu lấy tất cả)',
                helperText: 'Hệ thống sẽ lấy ngẫu nhiên',
                border: OutlineInputBorder()
              ),
            ),
            const SizedBox(height: 24),
            
            if (isAdmin) 
              _buildScopeInfo('PUBLIC (Mọi sinh viên đều có thể làm)')
            else if (isTeacher) ...[
              const Text('Gán cho lớp học (Bắt buộc)', style: TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              _buildClassroomSelector(),
            ],

            const SizedBox(height: 24),
            const Text('Cấu hình bài thi', style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            Row(
              children: [
                Expanded(child: _buildNumField('Thời gian (phút)', _duration, (v) => _duration = v)),
                const SizedBox(width: 16),
                Expanded(child: _buildNumField('Lượt làm tối đa', _maxAttempts, (v) => _maxAttempts = v)),
              ],
            ),
            SwitchListTile(title: const Text('Trộn thứ tự câu hỏi'), value: _randomQuestion, onChanged: (v) => setState(() => _randomQuestion = v)),
            SwitchListTile(title: const Text('Trộn thứ tự đáp án'), value: _randomAnswer, onChanged: (v) => setState(() => _randomAnswer = v)),
            
            const SizedBox(height: 40),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary, 
                  foregroundColor: Colors.white, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                onPressed: _submit,
                child: Text(
                  widget.quizToEdit != null ? 'CẬP NHẬT QUIZ' : 'TẠO VÀ PUBLISH QUIZ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeInfo(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(children: [const Icon(Icons.public, color: Colors.blue), const SizedBox(width: 12), Expanded(child: Text(text, style: const TextStyle(fontSize: 12)))]),
    );
  }

  Widget _buildClassroomSelector() {
    return FutureBuilder(
      future: ref.read(classroomRepositoryProvider).getClassroomsBySubject(widget.subjectId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final classrooms = snapshot.data!;
        return Column(
          children: classrooms.map((cls) => CheckboxListTile(
            title: Text(cls.name),
            value: _selectedClassIds.contains(cls.id),
            onChanged: (val) => setState(() => val! ? _selectedClassIds.add(cls.id) : _selectedClassIds.remove(cls.id)),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          )).toList(),
        );
      },
    );
  }

  Widget _buildNumField(String label, int initial, Function(int) onUpdate) {
    return TextFormField(
      initialValue: initial.toString(),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      onChanged: (v) => onUpdate(int.tryParse(v) ?? initial),
    );
  }

  void _submit() async {
    final userRole = ref.read(authProvider).user?.role;
    if (_formKey.currentState!.validate()) {
      if (userRole == 'TEACHER' && _selectedClassIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Giáo viên phải chọn ít nhất một lớp!'), backgroundColor: Colors.red));
        return;
      }

      final data = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'sourceContestId': _selectedContestId,
        'questionSelectionCount': int.tryParse(_selectionCountController.text), // Gửi field mới lên BE
        'durationMinutes': _duration,
        'maxAttempts': _maxAttempts,
        'randomQuestionOrder': _randomQuestion,
        'randomAnswerOrder': _randomAnswer,
        'difficulty': _difficulty,
        'accessScope': userRole == 'ADMIN' ? 'PUBLIC' : 'CLASSROOM',
        'classroomIds': userRole == 'ADMIN' ? [] : _selectedClassIds,
        'tags': [],
        'metadata': {},
      };

      try {
        final actions = ref.read(quizActionsControllerProvider.notifier);
        if (widget.quizToEdit != null) {
          await actions.updateQuiz(widget.subjectId, widget.quizToEdit!.id, data);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã cập nhật quiz')),
            );
          }
        } else {
          final createdQuiz = await actions.createQuiz(widget.subjectId, data);
          await actions.publishQuiz(widget.subjectId, createdQuiz.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã tạo và publish quiz, sinh viên có thể thấy ngay')),
            );
          }
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }
}
