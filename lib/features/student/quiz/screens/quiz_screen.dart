import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../providers/quiz_provider.dart';
import '../providers/quiz_result_provider.dart';
import '../models/question.dart';
import '../../../auth/providers/auth_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String contestId;
  const QuizScreen({super.key, required this.contestId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  bool _navigatedToResult = false;

  @override
  void initState() {
    super.initState();
    _initQuiz();
  }

  void _initQuiz() {
    // Sử dụng microtask để tránh lỗi build conflict
    Future.microtask(() async {
      if (!mounted) return;
      final user = await ref.read(authProvider.notifier).ensureCurrentUser();
      if (!mounted) return;
      if (user != null) {
        ref.read(quizProvider.notifier).startQuiz(widget.contestId, user.id);
      } else {
        context.go('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(quizResultProvider, (previous, next) {
      if (next == null || _navigatedToResult || !mounted) {
        return;
      }

      _navigatedToResult = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        context.pushReplacementNamed(AppRouteNames.studentResult);
      });
    });

    final quizState = ref.watch(quizProvider);
    final currentQuestion = ref.watch(currentQuestionProvider);
    final progress = ref.watch(quizProgressProvider);
    final isLastQuestion = currentQuestion != null &&
        quizState.currentQuestionIndex == quizState.questions.length - 1;

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldPop = await _handleWillPop();
              if (shouldPop && context.mounted) {
                context.pop();
              }
            },
          ),
          title: const Text('Bài thi trực tuyến', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          centerTitle: true,
        ),
        body: _buildBody(quizState, currentQuestion, progress),
        bottomSheet: currentQuestion != null 
            ? _QuizBottomBar(
                isLastQuestion: isLastQuestion,
                isSubmitting: quizState.isSubmitting,
                onNext: () => ref.read(quizProvider.notifier).nextQuestion(),
                onFinish: _submitQuiz,
              )
            : null,
      ),
    );
  }

  Future<bool> _handleWillPop() async {
    final shouldPop = await _showExitConfirmation(context);
    return shouldPop == true;
  }

  Future<void> _submitQuiz() async {
    final shouldFinish = await _showFinishConfirmation(context);
    if (shouldFinish != true || !mounted) {
      return;
    }

    await ref.read(quizProvider.notifier).finishQuiz();
  }

  Widget _buildBody(QuizState quizState, Question? currentQuestion, double progress) {
    if (quizState.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải câu hỏi...'),
          ],
        ),
      );
    }

    if (quizState.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                quizState.errorMessage ?? 'Đã có lỗi xảy ra',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Quay lại trang chủ'),
              ),
            ],
          ),
        ),
      );
    }

    if (currentQuestion == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Không tìm thấy dữ liệu câu hỏi.'),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('Quay lại'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _TimerSection(remainingSeconds: quizState.remainingSeconds),
                const SizedBox(height: 24),
                _ProgressBar(
                  progress: progress, 
                  currentIndex: quizState.currentQuestionIndex + 1, 
                  total: quizState.questions.length
                ),
                const SizedBox(height: 24),
                _QuestionCard(question: currentQuestion, index: quizState.currentQuestionIndex + 1),
                const SizedBox(height: 24),
                _AnswersList(
                  question: currentQuestion,
                  selectedAnswerId: quizState.selectedAnswers[currentQuestion.id],
                  onSelect: (id) => ref.read(quizProvider.notifier).selectAnswer(currentQuestion.id, id),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<bool?> _showExitConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thoát bài thi?'),
        content: const Text('Tiến độ của bạn đã được lưu lại. Bạn có chắc chắn muốn thoát không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tiếp tục thi')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Thoát', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showFinishConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nộp bài thi?'),
        content: const Text('Bạn có muốn kết thúc bài thi và xem kết quả ngay bây giờ không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tiếp tục làm'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Nộp bài'),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final int currentIndex;
  final int total;

  const _ProgressBar({required this.progress, required this.currentIndex, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tiến độ', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text('$currentIndex/$total', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: (Colors.grey[200] ?? Colors.grey),
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final Question question;
  final int index;

  const _QuestionCard({required this.question, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text('CÂU $index', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(height: 16),
          Text(
            question.content,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _AnswersList extends StatelessWidget {
  final Question question;
  final String? selectedAnswerId;
  final Function(String) onSelect;

  const _AnswersList({required this.question, required this.selectedAnswerId, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: question.answers.map((answer) {
        final isSelected = selectedAnswerId == answer.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => onSelect(answer.id),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.withOpacity(0.1) : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? Colors.blue : (Colors.grey[200] ?? Colors.grey), width: 2),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: isSelected ? Colors.blue : (Colors.grey[100] ?? Colors.grey),
                    child: Text(answer.label, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 12)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Text(answer.text, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
                  if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TimerSection extends StatelessWidget {
  final int remainingSeconds;
  const _TimerSection({required this.remainingSeconds});

  @override
  Widget build(BuildContext context) {
    final minutes = (remainingSeconds / 60).floor();
    final seconds = remainingSeconds % 60;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class _QuizBottomBar extends StatelessWidget {
  final bool isLastQuestion;
  final bool isSubmitting;
  final VoidCallback onNext;
  final Future<void> Function() onFinish;

  const _QuizBottomBar({
    required this.isLastQuestion,
    required this.isSubmitting,
    required this.onNext,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: (Colors.grey[200] ?? Colors.grey))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PowerUpButton(icon: Icons.hdr_strong, label: '50/50', color: Colors.purple, onTap: () {}),
              _PowerUpButton(icon: Icons.skip_next, label: 'Bỏ qua', color: Colors.amber, onTap: onNext),
              _PowerUpButton(icon: Icons.groups, label: 'Khán giả', color: Colors.blue, onTap: () {}),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (isLastQuestion) {
                        await onFinish();
                      } else {
                        onNext();
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isLastQuestion ? 'Nộp bài' : 'Câu tiếp'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PowerUpButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _PowerUpButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}
