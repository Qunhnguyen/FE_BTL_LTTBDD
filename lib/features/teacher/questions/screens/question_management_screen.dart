import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'csv_import_screen.dart';
import '../models/managed_question.dart';
import '../providers/question_management_provider.dart';
import '../repositories/question_repository.dart';
import '../../../../features/student/home/providers/contest_provider.dart';
import '../../../../core/router/app_router.dart';

class QuestionManagementScreen extends ConsumerStatefulWidget {
  final String? subjectId;
  final String? csvImportRouteName;
  final String subjectsRouteName;

  const QuestionManagementScreen({
    super.key,
    this.subjectId,
    this.csvImportRouteName,
    this.subjectsRouteName = AppRouteNames.teacherSubjects,
  });

  @override
  ConsumerState<QuestionManagementScreen> createState() => _QuestionManagementScreenState();
}

class _QuestionManagementScreenState extends ConsumerState<QuestionManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final contestId = ref.watch(activeContestIdProvider);
    final questionsAsync = ref.watch(filteredManagedQuestionsProvider);
    final currentFilter = ref.watch(questionFilterProvider);

    if (contestId == null) {
      return _buildNoContestSelected(theme);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Câu hỏi', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          onPressed: () => ref.read(activeContestIdProvider.notifier).state = null,
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () => _openCsvImport(context),
            icon: const Icon(Icons.upload_file),
            tooltip: 'Import CSV',
          ),
          TextButton.icon(
            onPressed: () => _showAddQuestionDialog(context, ref, contestId),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Thêm'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm câu hỏi...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: isDark ? Colors.white10 : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _FilterChip(
                    label: 'Tất cả',
                    isSelected: currentFilter == null,
                    onTap: () => ref.read(questionFilterProvider.notifier).state = null,
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _DifficultyFilterButton(
                    label: 'Dễ',
                    isSelected: currentFilter == QuestionDifficulty.easy,
                    color: Colors.green,
                    onTap: () => ref.read(questionFilterProvider.notifier).state = QuestionDifficulty.easy,
                  ),
                  const SizedBox(width: 8),
                  _DifficultyFilterButton(
                    label: 'Trung bình',
                    isSelected: currentFilter == QuestionDifficulty.medium,
                    color: Colors.orange,
                    onTap: () => ref.read(questionFilterProvider.notifier).state = QuestionDifficulty.medium,
                  ),
                  const SizedBox(width: 8),
                  _DifficultyFilterButton(
                    label: 'Khó',
                    isSelected: currentFilter == QuestionDifficulty.hard,
                    color: Colors.red,
                    onTap: () => ref.read(questionFilterProvider.notifier).state = QuestionDifficulty.hard,
                  ),
                ],
              ),
            ),
            Expanded(
              child: questionsAsync.when(
                data: (questions) => questions.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.quiz_outlined, size: 56, color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                              ),
                              const SizedBox(height: 20),
                              const Text('Chưa có câu hỏi nào', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                              const SizedBox(height: 8),
                              const Text(
                                'Thêm câu hỏi hoặc import từ CSV\nđể bắt đầu xây dựng đề thi.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _showAddQuestionDialog(context, ref, contestId),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Thêm thủ công'),
                                  ),
                                  const SizedBox(width: 12),
                                  OutlinedButton.icon(
                                    onPressed: () => _openCsvImport(context),
                                    icon: const Icon(Icons.upload_file),
                                    label: const Text('Import CSV'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _QuestionCard(
                              question: questions[index],
                              index: index + 1,
                              onEdit: () => _showEditQuestionDialog(context, ref, contestId, questions[index]),
                              onDelete: () async {
                                await ref.read(questionRepositoryProvider).deleteQuestion(questions[index].id);
                                ref.refresh(managedQuestionsProvider);
                              },
                            ),
                          );
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Lỗi: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoContestSelected(ThemeData theme) {
    final contestsAsync = ref.watch(contestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chọn Cuộc thi')),
      body: contestsAsync.when(
        data: (contests) => contests.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.event_note_outlined, size: 56, color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                      ),
                      const SizedBox(height: 20),
                      const Text('Chưa có cuộc thi nào', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      const SizedBox(height: 8),
                      const Text(
                        'Hãy tạo cuộc thi trước để\ncó thể thêm câu hỏi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: () => context.goNamed(widget.subjectsRouteName),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Đi tới Quản lý Môn học'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: contests.length,
                itemBuilder: (context, index) {
                  final contest = contests[index];
                  return Card(
                    child: ListTile(
                      title: Text(contest.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(contest.description),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => ref.read(activeContestIdProvider.notifier).state = contest.id,
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }

  void _openCsvImport(BuildContext context) {
    final subjectId = widget.subjectId;
    final routeName = widget.csvImportRouteName;
    if (subjectId == null || routeName == null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const CsvImportScreen(),
        ),
      );
      return;
    }

    context.pushNamed(
      routeName,
      pathParameters: {'subjectId': subjectId},
    );
  }

  void _showAddQuestionDialog(BuildContext context, WidgetRef ref, String contestId) {
    final contentController = TextEditingController();
    final pointsController = TextEditingController(text: '10');
    final durationController = TextEditingController(text: '30');
    final List<TextEditingController> answerControllers = List.generate(4, (_) => TextEditingController());
    int correctAnswerIndex = 0;
    QuestionDifficulty difficulty = QuestionDifficulty.medium;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 16),
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.add_circle_outline, color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    const Text('Thêm Câu hỏi Mới', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                // Scrollable content
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      TextFormField(
                        controller: contentController,
                        decoration: InputDecoration(
                          labelText: 'Nội dung câu hỏi *',
                          hintText: 'Nhập nội dung câu hỏi...',
                          prefixIcon: const Icon(Icons.help_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      const Text('Đáp án (Chọn đáp án đúng):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      ...List.generate(4, (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Radio<int>(
                              value: index,
                              groupValue: correctAnswerIndex,
                              onChanged: (val) => setState(() => correctAnswerIndex = val!),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: answerControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Đáp án ${String.fromCharCode(65 + index)}',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: pointsController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Điểm',
                                prefixIcon: const Icon(Icons.star_outline, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: durationController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Thời gian (s)',
                                prefixIcon: const Icon(Icons.timer_outlined, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<QuestionDifficulty>(
                        value: difficulty,
                        decoration: InputDecoration(
                          labelText: 'Độ khó',
                          prefixIcon: const Icon(Icons.speed, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                        ),
                        items: QuestionDifficulty.values
                            .where((d) => d != QuestionDifficulty.draft)
                            .map((d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(d.name.toUpperCase()),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => difficulty = val!),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                // Bottom buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (contentController.text.isNotEmpty && answerControllers.every((c) => c.text.isNotEmpty)) {
                            try {
                              final pts = int.tryParse(pointsController.text) ?? 10;
                              final dur = int.tryParse(durationController.text) ?? 30;
                              await ref.read(questionRepositoryProvider).createQuestion({
                                'contestId': contestId,
                                'content': contentController.text,
                                'optionA': answerControllers[0].text,
                                'optionB': answerControllers[1].text,
                                'optionC': answerControllers[2].text,
                                'optionD': answerControllers[3].text,
                                'correctOption': String.fromCharCode(65 + correctAnswerIndex),
                                'score': pts,
                                'points': pts,
                                'duration': dur,
                                'durationSeconds': dur,
                                'difficulty': difficulty.name.toUpperCase(),
                                'type': 'MULTIPLE_CHOICE',
                              });
                              ref.refresh(managedQuestionsProvider);
                              if (context.mounted) Navigator.pop(context);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
                                );
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập đủ nội dung và 4 đáp án')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Lưu câu hỏi'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditQuestionDialog(BuildContext context, WidgetRef ref, String contestId, ManagedQuestion question) {
    final contentController = TextEditingController(text: question.text);
    final pointsController = TextEditingController(text: question.points.toString());
    final durationController = TextEditingController(text: question.durationSeconds.toString());
    final List<TextEditingController> answerControllers = [
      TextEditingController(text: question.optionA ?? ''),
      TextEditingController(text: question.optionB ?? ''),
      TextEditingController(text: question.optionC ?? ''),
      TextEditingController(text: question.optionD ?? ''),
    ];
    int correctAnswerIndex = 0;
    if (question.correctOption != null) {
      final idx = question.correctOption!.codeUnitAt(0) - 65;
      if (idx >= 0 && idx < 4) correctAnswerIndex = idx;
    }
    QuestionDifficulty difficulty = question.difficulty == QuestionDifficulty.draft ? QuestionDifficulty.medium : question.difficulty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
            child: Column(
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.edit_outlined, color: Colors.orange),
                    ),
                    const SizedBox(width: 12),
                    const Text('Sửa Câu hỏi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      TextFormField(
                        controller: contentController,
                        decoration: InputDecoration(
                          labelText: 'Nội dung câu hỏi *',
                          prefixIcon: const Icon(Icons.help_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      const Text('Đáp án (Chọn đáp án đúng):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      ...List.generate(4, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Radio<int>(
                                value: index,
                                groupValue: correctAnswerIndex,
                                onChanged: (val) => setState(() => correctAnswerIndex = val!),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: answerControllers[index],
                                  decoration: InputDecoration(
                                    labelText: 'Đáp án ${String.fromCharCode(65 + index)}',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    filled: true,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: pointsController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Điểm',
                                prefixIcon: const Icon(Icons.star_outline, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: durationController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Thời gian (s)',
                                prefixIcon: const Icon(Icons.timer_outlined, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<QuestionDifficulty>(
                        value: difficulty,
                        decoration: InputDecoration(
                          labelText: 'Độ khó',
                          prefixIcon: const Icon(Icons.speed, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                        ),
                        items: QuestionDifficulty.values
                            .where((d) => d != QuestionDifficulty.draft)
                            .map((d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(d.name.toUpperCase()),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => difficulty = val!),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (contentController.text.isNotEmpty) {
                            try {
                              final pts = int.tryParse(pointsController.text) ?? 10;
                              final dur = int.tryParse(durationController.text) ?? 30;
                              await ref.read(questionRepositoryProvider).updateQuestion(question.id, {
                                'contestId': contestId,
                                'content': contentController.text,
                                'optionA': answerControllers[0].text,
                                'optionB': answerControllers[1].text,
                                'optionC': answerControllers[2].text,
                                'optionD': answerControllers[3].text,
                                'correctOption': String.fromCharCode(65 + correctAnswerIndex),
                                'score': pts,
                                'points': pts,
                                'duration': dur,
                                'durationSeconds': dur,
                                'difficulty': difficulty.name.toUpperCase(),
                                'type': 'MULTIPLE_CHOICE',
                              });
                              ref.refresh(managedQuestionsProvider);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Đã cập nhật câu hỏi!'), backgroundColor: Colors.green),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cập nhật'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DifficultyFilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _DifficultyFilterButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? theme.colorScheme.primary : (Colors.grey[300] ?? Colors.grey)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final ManagedQuestion question;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _QuestionCard({required this.question, required this.index, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white10 : (Colors.grey[200] ?? Colors.grey)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Badge(label: 'CÂU $index', color: Colors.blue),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_outlined, color: Colors.orange[700], size: 20),
                      onPressed: onEdit,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      tooltip: 'Sửa câu hỏi',
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: onDelete,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      tooltip: 'Xóa câu hỏi',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(question.text, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _DifficultyBadge(difficulty: question.difficulty),
                const Spacer(),
                Text('${question.points} điểm', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(width: 8),
                const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${question.durationSeconds}s', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final QuestionDifficulty difficulty;
  const _DifficultyBadge({required this.difficulty});
  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    if (difficulty == QuestionDifficulty.easy) color = Colors.green;
    if (difficulty == QuestionDifficulty.medium) color = Colors.orange;
    if (difficulty == QuestionDifficulty.hard) color = Colors.red;
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(difficulty.name.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
      ],
    );
  }
}
