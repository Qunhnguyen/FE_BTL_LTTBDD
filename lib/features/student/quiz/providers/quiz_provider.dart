import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import '../repositories/quiz_repository.dart';

// --- State --- 
class QuizState {
  final List<Question> questions;
  final int currentQuestionIndex;
  final Map<String, String> selectedAnswers; // questionId -> answerId
  final int remainingSeconds;
  final bool isLoading;
  final String? errorMessage;
  final String? submissionId;

  QuizState({
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.selectedAnswers = const {},
    this.remainingSeconds = 0,
    this.isLoading = false,
    this.errorMessage,
    this.submissionId,
  });

  QuizState copyWith({
    List<Question>? questions,
    int? currentQuestionIndex,
    Map<String, String>? selectedAnswers,
    int? remainingSeconds,
    bool? isLoading,
    String? errorMessage,
    String? submissionId,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      submissionId: submissionId ?? this.submissionId,
    );
  }
}

// --- State Notifier --- 
class QuizNotifier extends StateNotifier<QuizState> {
  final QuizRepository _repository;
  Timer? _timer;

  QuizNotifier(this._repository) : super(QuizState());

  // Bắt đầu bài thi thật từ API
  Future<void> startQuiz(String contestId, String studentId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // 1. Gọi API để bắt đầu cuộc thi
      final submissionData = await _repository.startSubmission(contestId, studentId);
      final submissionId = (submissionData['id'] ?? submissionData['_id']).toString();
      
      // 2. Lấy danh sách câu hỏi cho cuộc thi này
      final questions = await _repository.getQuestionsForContest(contestId);
      
      if (questions.isEmpty) {
        state = state.copyWith(isLoading: false, errorMessage: 'Cuộc thi này hiện chưa có câu hỏi.');
        return;
      }

      state = QuizState(
        questions: questions,
        submissionId: submissionId,
        remainingSeconds: 45 * 60, // Tạm thời để 45p, có thể lấy từ BE nếu có
        isLoading: false,
      );
      
      _startTimer();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Không thể bắt đầu bài thi: $e');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        timer.cancel();
        // Xử lý nộp bài tự động khi hết giờ
      }
    });
  }

  Future<void> selectAnswer(String questionId, String answerId) async {
    final newAnswers = Map<String, String>.from(state.selectedAnswers);
    newAnswers[questionId] = answerId;
    state = state.copyWith(selectedAnswers: newAnswers);

    // Gửi đáp án về BE ngay lập tức để đồng bộ
    if (state.submissionId != null) {
      try {
        await _repository.submitAnswer(state.submissionId!, questionId, answerId);
      } catch (e) {
        print('Error syncing answer: $e');
      }
    }
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
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
  final repository = ref.watch(quizRepositoryProvider);
  return QuizNotifier(repository);
});

final currentQuestionProvider = Provider<Question?>((ref) {
  final quizState = ref.watch(quizProvider);
  if (quizState.questions.isEmpty) return null;
  return quizState.questions[quizState.currentQuestionIndex];
});

final quizProgressProvider = Provider<double>((ref) {
    final quizState = ref.watch(quizProvider);
    if (quizState.questions.isEmpty) return 0.0;
    return (quizState.currentQuestionIndex + 1) / quizState.questions.length;
});
