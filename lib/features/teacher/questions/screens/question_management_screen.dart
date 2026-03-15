import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/managed_question.dart';
import '../providers/question_management_provider.dart';
import '../repositories/question_repository.dart';
import '../../../../features/student/home/providers/contest_provider.dart';
import '../../../../core/router/app_router.dart';

class QuestionManagementScreen extends ConsumerStatefulWidget {
  const QuestionManagementScreen({super.key});

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
                    ? const Center(child: Text('Chưa có câu hỏi nào cho cuộc thi này.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _QuestionCard(
                              question: questions[index],
                              index: index + 1,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddQuestionDialog(context, ref, contestId),
        backgroundColor: theme.colorScheme.primary,
        label: const Text('Thêm câu hỏi'),
        icon: const Icon(Icons.add),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Chưa có cuộc thi nào.'),
                    TextButton(
                      onPressed: () => context.goNamed(AppRouteNames.teacherSubjects),
                      child: const Text('Đi tới Quản lý Môn học'),
                    ),
                  ],
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

  void _showAddQuestionDialog(BuildContext context, WidgetRef ref, String contestId) {
    final contentController = TextEditingController();
    final pointsController = TextEditingController(text: '10');
    final durationController = TextEditingController(text: '30');
    final List<TextEditingController> answerControllers = List.generate(4, (_) => TextEditingController());
    int correctAnswerIndex = 0;
    QuestionDifficulty difficulty = QuestionDifficulty.medium;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Thêm Câu hỏi Mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'Nội dung câu hỏi', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                const Text('Đáp án (Tích chọn đáp án đúng):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                ...List.generate(4, (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Radio<int>(
                        value: index,
                        groupValue: correctAnswerIndex,
                        onChanged: (val) => setState(() => correctAnswerIndex = val!),
                      ),
                      Expanded(
                        child: TextField(
                          controller: answerControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Đáp án ${String.fromCharCode(65 + index)}',
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: pointsController,
                        decoration: const InputDecoration(labelText: 'Điểm'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: durationController,
                        decoration: const InputDecoration(labelText: 'Thời gian (s)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<QuestionDifficulty>(
                  value: difficulty,
                  decoration: const InputDecoration(labelText: 'Độ khó'),
                  items: QuestionDifficulty.values
                      .where((d) => d != QuestionDifficulty.draft)
                      .map((d) => DropdownMenuItem(
                            value: d,
                            child: Text(d.name.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => difficulty = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                if (contentController.text.isNotEmpty && answerControllers.every((c) => c.text.isNotEmpty)) {
                  try {
                    // Đồng bộ hóa với BE: Đổi 'correctAnswer' thành 'correctOption'
                    await ref.read(questionRepositoryProvider).createQuestion({
                      'contestId': contestId,
                      'content': contentController.text,
                      'optionA': answerControllers[0].text,
                      'optionB': answerControllers[1].text,
                      'optionC': answerControllers[2].text,
                      'optionD': answerControllers[3].text,
                      'correctOption': String.fromCharCode(65 + correctAnswerIndex), // BE yêu cầu trường này
                      'points': int.tryParse(pointsController.text) ?? 10,
                      'durationSeconds': int.tryParse(durationController.text) ?? 30,
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
              child: const Text('Lưu'),
            ),
          ],
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
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5)),
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
            color: isSelected ? Colors.white : Colors.black54,
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
  final VoidCallback onDelete;

  const _QuestionCard({required this.question, required this.index, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
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
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: onDelete,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
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
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
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
