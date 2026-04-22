import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../auth/providers/auth_provider.dart';
import '../models/question.dart';
import '../providers/quiz_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.contestId});

  final String contestId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  @override
  void initState() {
    super.initState();
    _initQuiz();
  }

  void _initQuiz() {
    Future.microtask(() async {
      if (!mounted) return;
      final user = await ref.read(authProvider.notifier).ensureCurrentUser();
      if (!mounted) return;
      if (user != null) {
        ref.read(quizProvider.notifier).startQuiz(widget.contestId);
      } else {
        context.go('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(quizProvider, (previous, next) {
      if (next.isFinished && previous?.isFinished != true) {
        context.pushReplacementNamed(AppRouteNames.studentResult);
      }
    });

    final quizState = ref.watch(quizProvider);
    final currentQuestion = ref.watch(currentQuestionProvider);
    final progress = ref.watch(quizProgressProvider);
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmation(context);
        if (shouldPop == true && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldPop = await _showExitConfirmation(context);
              if (shouldPop == true && context.mounted) {
                context.pop();
              }
            },
          ),
          title: Text(
            quizState.submission?.quizName ?? 'Bài thi trực tuyến',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          centerTitle: true,
        ),
        body: _buildBody(quizState, currentQuestion, progress),
      ),
    );
  }

  Widget _buildBody(QuizState quizState, Question? currentQuestion, double progress) {
    if (quizState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (quizState.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(quizState.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: () => context.go('/student/home'), child: const Text('Quay lại')),
            ],
          ),
        ),
      );
    }

    if (currentQuestion == null) return const SizedBox.shrink();

    // LẤY GỢI Ý NẾU CÓ
    final hintText = quizState.questionHints[currentQuestion.id];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              _TimerSection(remainingSeconds: quizState.remainingSeconds),
              const SizedBox(height: 12),
              _ProgressBar(progress: progress, currentIndex: quizState.currentQuestionIndex + 1, total: quizState.questions.length),
            ],
          ),
        ),
        
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              children: [
                _QuestionCard(question: currentQuestion, index: quizState.currentQuestionIndex + 1),
                
                // HIỂN THỊ BOX GỢI Ý
                if (hintText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              hintText,
                              style: const TextStyle(fontSize: 13, color: Colors.blue, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),
                _AnswersList(
                  question: currentQuestion,
                  selectedAnswerKey: quizState.selectedAnswers[currentQuestion.id],
                  isCorrect: quizState.isCorrectMap[currentQuestion.id],
                  correctKey: quizState.correctOptionMap[currentQuestion.id],
                  disabledKeys: quizState.disabledOptions[currentQuestion.id] ?? [],
                  onSelect: (key) => ref.read(quizProvider.notifier).selectAnswer(currentQuestion.id, key),
                ),
              ],
            ),
          ),
        ),

        _QuizBottomBar(
          isLastQuestion: quizState.currentQuestionIndex == quizState.questions.length - 1,
          isSubmitting: quizState.isSubmitting,
          usedPowerUps: quizState.usedPowerUps,
          onNext: () => ref.read(quizProvider.notifier).nextQuestion(),
          onFinish: _submitQuiz,
          onPowerUp: (type) => ref.read(quizProvider.notifier).usePowerUp(type),
        ),
      ],
    );
  }

  Future<bool?> _showExitConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thoát bài thi?'),
        content: const Text('Tiến độ của bạn sẽ không được lưu nếu thoát bây giờ.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tiếp tục')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Thoát', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Future<void> _submitQuiz() async {
    final shouldFinish = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nộp bài thi?'),
        content: const Text('Bạn chắc chắn muốn nộp bài chứ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Quay lại')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Nộp bài')),
        ],
      ),
    );
    
    if (shouldFinish == true && mounted) {
      try {
        await ref.read(quizProvider.notifier).finishQuiz();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress, required this.currentIndex, required this.total});
  final double progress;
  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Câu hỏi $currentIndex/$total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text('${(progress * 100).toInt()}%', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: progress, minHeight: 4, borderRadius: BorderRadius.circular(4)),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question, required this.index});
  final Question question;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CÂU $index', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 8),
          Text(question.content, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, height: 1.4)),
        ],
      ),
    );
  }
}

class _AnswersList extends StatelessWidget {
  const _AnswersList({
    required this.question, 
    required this.selectedAnswerKey, 
    this.isCorrect, 
    this.correctKey,
    required this.onSelect, 
    this.disabledKeys = const []
  });
  
  final Question question;
  final String? selectedAnswerKey;
  final bool? isCorrect;
  final String? correctKey;
  final void Function(String) onSelect;
  final List<String> disabledKeys;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: question.options.map((option) {
        final isSelected = selectedAnswerKey == option.key;
        final isDisabled = disabledKeys.contains(option.key);
        
        Color borderColor = Colors.grey.shade200;
        Color? bgColor;
        
        if (isSelected) {
          if (isCorrect == true) {
            borderColor = Colors.green;
            bgColor = Colors.green.withOpacity(0.05);
          } else if (isCorrect == false) {
            borderColor = Colors.red;
            bgColor = Colors.red.withOpacity(0.05);
          } else {
            borderColor = Colors.blue;
            bgColor = Colors.blue.withOpacity(0.05);
          }
        } else if (isCorrect == false && option.key == correctKey) {
          borderColor = Colors.green.withOpacity(0.3);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: (isDisabled || isCorrect != null) ? null : () => onSelect(option.key),
            borderRadius: BorderRadius.circular(12),
            child: Opacity(
              opacity: isDisabled ? 0.1 : 1.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: bgColor ?? Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? borderColor : Colors.grey.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        option.key, 
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black54, 
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        )
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option.content, 
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        )
                      ),
                    ),
                    if (isSelected && isCorrect == true) const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                    if (isSelected && isCorrect == false) const Icon(Icons.cancel_rounded, color: Colors.red, size: 18),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TimerSection extends StatelessWidget {
  const _TimerSection({required this.remainingSeconds});
  final int remainingSeconds;

  @override
  Widget build(BuildContext context) {
    final minutes = (remainingSeconds / 60).floor();
    final seconds = remainingSeconds % 60;
    final isLowTime = remainingSeconds < 30;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: (isLowTime ? Colors.red : Colors.orange).withOpacity(0.08), 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (isLowTime ? Colors.red : Colors.orange).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, color: isLowTime ? Colors.red : Colors.orange, size: 14),
          const SizedBox(width: 6),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}', 
            style: TextStyle(
              color: isLowTime ? Colors.red : Colors.orange, 
              fontWeight: FontWeight.w900, 
              fontSize: 14,
              letterSpacing: 1.1,
            )
          ),
        ],
      ),
    );
  }
}

class _QuizBottomBar extends StatelessWidget {
  const _QuizBottomBar({
    required this.isLastQuestion, 
    required this.isSubmitting, 
    required this.onNext, 
    required this.onFinish, 
    required this.onPowerUp,
    required this.usedPowerUps,
  });
  final bool isLastQuestion;
  final bool isSubmitting;
  final VoidCallback onNext;
  final Future<void> Function() onFinish;
  final void Function(String) onPowerUp;
  final Set<String> usedPowerUps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: theme.cardColor, 
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PowerUpButton(
                icon: Icons.hdr_strong_rounded, 
                label: '50/50', 
                color: Colors.purple, 
                isUsed: usedPowerUps.contains('FIFTY_FIFTY'),
                onTap: () => onPowerUp('FIFTY_FIFTY')
              ),
              _PowerUpButton(
                icon: Icons.skip_next_rounded, 
                label: 'Bỏ qua', 
                color: Colors.amber.shade700, 
                isUsed: usedPowerUps.contains('SKIP'),
                onTap: () => onPowerUp('SKIP')
              ),
              _PowerUpButton(
                icon: Icons.lightbulb_outline_rounded, 
                label: 'Gợi ý', 
                color: Colors.blue, 
                isUsed: usedPowerUps.contains('HINT'),
                onTap: () {
                   onPowerUp('HINT');
                }
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : () async {
                if (isLastQuestion) await onFinish();
                else onNext();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(
                      isLastQuestion ? 'NỘP BÀI' : 'CÂU TIẾP THEO', 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PowerUpButton extends StatelessWidget {
  const _PowerUpButton({required this.icon, required this.label, required this.color, required this.onTap, this.isUsed = false});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isUsed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isUsed ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Opacity(
        opacity: isUsed ? 0.3 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
