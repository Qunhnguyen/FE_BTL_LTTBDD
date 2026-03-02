// Fixed build errors
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/managed_question.dart';
import '../providers/question_management_provider.dart';

class QuestionManagementScreen extends ConsumerWidget {
  const QuestionManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final questions = ref.watch(managedQuestionsProvider);
    final currentFilter = ref.watch(questionFilterProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Expanded(
                        child: Text(
                          'Quản lý Câu hỏi',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
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
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.filter_list),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Tất cả',
                    isSelected: currentFilter == null,
                    onTap: () => ref.read(questionFilterProvider.notifier).state = null,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Dễ',
                    isSelected: currentFilter == QuestionDifficulty.easy,
                    onTap: () => ref.read(questionFilterProvider.notifier).state = QuestionDifficulty.easy,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Trung bình',
                    isSelected: currentFilter == QuestionDifficulty.medium,
                    onTap: () => ref.read(questionFilterProvider.notifier).state = QuestionDifficulty.medium,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Khó',
                    isSelected: currentFilter == QuestionDifficulty.hard,
                    onTap: () => ref.read(questionFilterProvider.notifier).state = QuestionDifficulty.hard,
                  ),
                ],
              ),
            ),

            // Questions List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _QuestionCard(question: questions[index], index: index + 1),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
            ? (isDark ? Colors.white : Colors.black)
            : (isDark ? Colors.white10 : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: isDark ? Colors.white10 : Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
              ? (isDark ? Colors.black : Colors.white)
              : (isDark ? Colors.white70 : Colors.black54),
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

  const _QuestionCard({required this.question, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[100]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (question.type == QuestionType.image && question.imageUrl != null)
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(question.imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _Badge(
                          label: 'CÂU $index',
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _DifficultyBadge(difficulty: question.difficulty),
                      ],
                    ),
                    Text(
                      '${question.points} điểm',
                      style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  question.text,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (question.type == QuestionType.multipleChoice) ...[
                      const Icon(Icons.format_list_bulleted, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${question.answerCount} đáp án', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ] else if (question.type == QuestionType.essay) ...[
                      const Icon(Icons.edit_note, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      const Text('Tự luận', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ] else ...[
                      const Icon(Icons.image, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      const Text('Hình ảnh', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                    if (question.durationSeconds > 0) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.circle, size: 4, color: Colors.grey),
                      const SizedBox(width: 12),
                      const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${question.durationSeconds}s', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ],
                ),
              ],
            ),
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
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final QuestionDifficulty difficulty;

  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    
    switch (difficulty) {
      case QuestionDifficulty.easy:
        color = Colors.green;
        label = 'Dễ';
        break;
      case QuestionDifficulty.medium:
        color = Colors.orange;
        label = 'Trung bình';
        break;
      case QuestionDifficulty.hard:
        color = Colors.red;
        label = 'Khó';
        break;
      case QuestionDifficulty.draft:
        color = Colors.grey;
        label = 'Nháp';
        break;
    }

    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
        ),
      ],
    );
  }
}
