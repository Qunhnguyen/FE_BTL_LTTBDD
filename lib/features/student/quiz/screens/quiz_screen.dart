import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/quiz_provider.dart';
import '../models/question.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final quizState = ref.watch(quizProvider);
    final currentQuestion = ref.watch(currentQuestionProvider);
    final progress = ref.watch(quizProgressProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Kiến thức chung IT',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Timer Section
                  _TimerSection(remainingSeconds: quizState.remainingSeconds),
                  const SizedBox(height: 24),

                  // Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tiến độ',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                          RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(
                                    text: '${quizState.currentQuestionIndex + 1}'),
                                TextSpan(
                                  text: '/${quizState.questions.length}',
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 12,
                          backgroundColor:
                              isDark ? Colors.white12 : Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Question Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:
                          isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isDark ? Colors.white10 : Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _Tag(
                                label: currentQuestion.difficulty,
                                color: Colors.amber),
                            ...currentQuestion.tags.map(
                                (tag) => _Tag(label: tag, color: Colors.purple)),
                            _Tag(
                              label: '${currentQuestion.points} điểm',
                              color: Colors.green,
                              icon: Icons.star,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Câu ${quizState.currentQuestionIndex + 1}: ${currentQuestion.text}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Answers
                  Column(
                    children: currentQuestion.answers.map((answer) {
                      final isSelected =
                          quizState.selectedAnswers[currentQuestion.id] ==
                              answer.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AnswerButton(
                          answer: answer,
                          isSelected: isSelected,
                          onTap: () => ref
                              .read(quizProvider.notifier)
                              .selectAnswer(currentQuestion.id, answer.id),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 80), // Padding for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
              top: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey[200]!)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _PowerUpButton(
              icon: Icons.hdr_strong,
              label: '50/50',
              color: Colors.purple,
              onTap: () {},
            ),
            _PowerUpButton(
              icon: Icons.skip_next,
              label: 'Bỏ qua',
              color: Colors.amber,
              onTap: () => ref.read(quizProvider.notifier).nextQuestion(),
            ),
            _PowerUpButton(
              icon: Icons.groups,
              label: 'Khán giả',
              color: Colors.blue,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerSection extends StatelessWidget {
  final int remainingSeconds;

  const _TimerSection({required this.remainingSeconds});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hours = remainingSeconds ~/ 3600;
    final minutes = (remainingSeconds % 3600) ~/ 60;
    final seconds = remainingSeconds % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TimeUnit(value: hours.toString().padLeft(2, '0'), label: 'Giờ'),
        const _TimeSeparator(),
        _TimeUnit(
            value: minutes.toString().padLeft(2, '0'),
            label: 'Phút',
            isHighlight: true),
        const _TimeSeparator(),
        _TimeUnit(value: seconds.toString().padLeft(2, '0'), label: 'Giây'),
      ],
    );
  }
}

class _TimeUnit extends StatelessWidget {
  final String value;
  final String label;
  final bool isHighlight;

  const _TimeUnit(
      {required this.value, required this.label, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isHighlight
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isHighlight
                ? [
                    BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]
                : [],
          ),
          child: Text(
            value,
            style: TextStyle(
              color: isHighlight ? Colors.white : theme.colorScheme.primary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isHighlight ? theme.colorScheme.primary : Colors.grey,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _TimeSeparator extends StatelessWidget {
  const _TimeSeparator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 8, right: 8, bottom: 24),
      child: Text(':',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _Tag({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final Answer answer;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.answer,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark ? Colors.white10 : Colors.grey[200]!),
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4))
            else
              BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : (isDark ? Colors.white10 : Colors.grey[100]),
                shape: BoxShape.circle,
              ),
              child: Text(
                answer.label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                answer.text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

class _PowerUpButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PowerUpButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
                fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
