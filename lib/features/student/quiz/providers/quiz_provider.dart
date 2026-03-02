import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';

// --- Mock Data ---
final mockQuestions = [
  Question(
    id: 'q1',
    text: 'Đâu là Framework được phát triển bởi Google để xây dựng giao diện người dùng đa nền tảng?',
    answers: [
      Answer(id: 'a1', text: 'React Native', label: 'A'),
      Answer(id: 'a2', text: 'Flutter', label: 'B'),
      Answer(id: 'a3', text: 'SwiftUI', label: 'C'),
      Answer(id: 'a4', text: 'Kotlin Multiplatform', label: 'D'),
    ],
    correctAnswerId: 'a2',
    tags: ['Mobile', 'Framework'],
  ),
  Question(
    id: 'q2',
    text: 'Ngôn ngữ lập trình nào thường được sử dụng cùng với Flutter?',
    answers: [
      Answer(id: 'a5', text: 'Dart', label: 'A'),
      Answer(id: 'a6', text: 'Java', label: 'B'),
      Answer(id: 'a7', text: 'Swift', label: 'C'),
      Answer(id: 'a8', text: 'Python', label: 'D'),
    ],
    correctAnswerId: 'a5',
    tags: ['Programming', 'Mobile'],
  ),
  Question(
    id: 'q3',
    text: 'Đâu là ngôn ngữ lập trình hướng đối tượng?',
    answers: [
        Answer(id: 'a9', text: 'HTML', label: 'A'),
        Answer(id: 'a10', text: 'Java', label: 'B'),
        Answer(id: 'a11', text: 'CSS', label: 'C'),
        Answer(id: 'a12', text: 'SQL', label: 'D'),
    ],
    correctAnswerId: 'a10',
    difficulty: 'Dễ',
    points: 3,
  ),
  // Add more mock questions here
];

// --- State --- 
class QuizState {
  final List<Question> questions;
  final int currentQuestionIndex;
  final Map<String, String> selectedAnswers; // questionId -> answerId
  final int remainingSeconds;

  QuizState({
    required this.questions,
    required this.currentQuestionIndex,
    required this.selectedAnswers,
    required this.remainingSeconds,
  });

  QuizState copyWith({
    int? currentQuestionIndex,
    Map<String, String>? selectedAnswers,
    int? remainingSeconds,
  }) {
    return QuizState(
      questions: questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }
}

// --- State Notifier --- 
class QuizNotifier extends StateNotifier<QuizState> {
  Timer? _timer;

  QuizNotifier() : super(QuizState(
    questions: mockQuestions, // Start with mock questions
    currentQuestionIndex: 0,
    selectedAnswers: {},
    remainingSeconds: 15 * 60, // 15 minutes
  )) {
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        timer.cancel();
        // Handle quiz timeout
      }
    });
  }

  void selectAnswer(String questionId, String answerId) {
    final newAnswers = Map<String, String>.from(state.selectedAnswers);
    newAnswers[questionId] = answerId;
    state = state.copyWith(selectedAnswers: newAnswers);
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
    }
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// --- Providers --- 
final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier();
});

// Derived providers for easier access in UI
final currentQuestionProvider = Provider<Question>((ref) {
  final quizState = ref.watch(quizProvider);
  return quizState.questions[quizState.currentQuestionIndex];
});

final quizProgressProvider = Provider<double>((ref) {
    final quizState = ref.watch(quizProvider);
    return (quizState.currentQuestionIndex + 1) / quizState.questions.length;
});
