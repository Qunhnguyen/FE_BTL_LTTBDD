import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_failure.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';
import 'quiz_result_provider.dart';
import '../repositories/quiz_repository.dart';

// --- State --- 
class QuizState {
  static const _unset = Object();

  final List<Question> questions;
  final int currentQuestionIndex;
  final Map<String, String> selectedAnswers; 
  final int remainingSeconds;
  final int initialDurationSeconds;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? submissionId;

  QuizState({
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.selectedAnswers = const {},
    this.remainingSeconds = 0,
    this.initialDurationSeconds = 0,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.submissionId,
  });

  QuizState copyWith({
    List<Question>? questions,
    int? currentQuestionIndex,
    Map<String, String>? selectedAnswers,
    int? remainingSeconds,
    int? initialDurationSeconds,
    bool? isLoading,
    bool? isSubmitting,
    Object? errorMessage = _unset,
    Object? submissionId = _unset,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      initialDurationSeconds: initialDurationSeconds ?? this.initialDurationSeconds,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      submissionId: identical(submissionId, _unset)
          ? this.submissionId
          : submissionId as String?,
    );
  }
}

// --- State Notifier --- 
class QuizNotifier extends StateNotifier<QuizState> {
  final QuizRepository _repository;
  final Ref _ref;
  Timer? _timer;
  Future<void>? _lastAnswerSync;

  QuizNotifier(this._repository, this._ref) : super(QuizState());

  Future<void> startQuiz(String contestId, String studentId) async {
    _timer?.cancel();
    _ref.read(quizResultProvider.notifier).state = null;
    state = QuizState(isLoading: true);
    
    try {
      // 1. Gọi API lấy CHI TIẾT cuộc thi (Dành cho Sinh viên)
      final responseData = await _repository.getStudentContestDetail(contestId);
      
      // 2. Dò tìm mảng câu hỏi (BE có thể trả về questions hoặc questionList)
      dynamic questionsData = responseData['questions'] ?? responseData['questionList'];
      
      // Nếu responseData chính là một mảng
      if (responseData is List) {
        questionsData = responseData;
      }

      if (questionsData == null || !(questionsData is List)) {
        state = state.copyWith(
          isLoading: false, 
          errorMessage: 'Không tìm thấy danh sách câu hỏi trong phản hồi từ Server. (Key: questions/questionList)'
        );
        return;
      }

      final questions = (questionsData as List).map((q) => Question.fromJson(q)).toList();

      if (questions.isEmpty) {
        state = state.copyWith(isLoading: false, errorMessage: 'Cuộc thi này hiện chưa có câu hỏi nào.');
        return;
      }

      // 3. Gọi API bắt đầu làm bài
      final submissionData = await _repository.startSubmission(contestId, studentId);
      final sId = (
        submissionData['submissionId'] ??
        submissionData['id'] ??
        submissionData['_id']
      )?.toString();

      if (sId == null || sId.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Server không trả về submissionId hợp lệ.',
        );
        return;
      }

      final rootData = responseData is Map ? Map<String, dynamic>.from(responseData) : null;
      final contestInfo = rootData?['contest'];
      final durationValue = contestInfo is Map
          ? (contestInfo['durationMinutes'] ?? rootData?['durationMinutes'] ?? 45)
          : (rootData?['durationMinutes'] ?? 45);
      final durationMinutes = durationValue is num
          ? durationValue.toInt()
          : int.tryParse(durationValue?.toString() ?? '') ?? 45;

      state = QuizState(
        questions: questions,
        submissionId: sId,
        remainingSeconds: durationMinutes * 60,
        initialDurationSeconds: durationMinutes * 60,
        isLoading: false,
      );
      
      _startTimer();
    } on AppFailure catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Lỗi hệ thống: $e');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        timer.cancel();
        unawaited(finishQuiz());
      }
    });
  }

  Future<void> selectAnswer(String questionId, String answerId) async {
    if (state.selectedAnswers.containsKey(questionId)) {
      return;
    }

    final newAnswers = Map<String, String>.from(state.selectedAnswers);
    newAnswers[questionId] = answerId;
    state = state.copyWith(selectedAnswers: newAnswers);

    if (state.submissionId != null) {
      final sync = _repository.submitAnswer(state.submissionId!, questionId, answerId);
      try {
        _lastAnswerSync = sync;
        await sync;
      } catch (e) {
        print('Sync error: $e');
      } finally {
        if (identical(_lastAnswerSync, sync)) {
          _lastAnswerSync = null;
        }
      }
    }
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
    }
  }

  Future<QuizResult?> finishQuiz() async {
    if (state.isSubmitting || state.submissionId == null) {
      return _ref.read(quizResultProvider);
    }

    _timer?.cancel();
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await _lastAnswerSync;

      final responseData = await _repository.finishSubmission(state.submissionId!);
      final totalPossibleScore = state.questions.fold<double>(
        0,
        (sum, question) => sum + question.points,
      );
      final elapsedSeconds = state.initialDurationSeconds > 0
          ? state.initialDurationSeconds - state.remainingSeconds
          : 0;
      final result = QuizResult.fromSubmission(
        submissionData: responseData,
        totalPossibleScore: totalPossibleScore > 0
            ? totalPossibleScore
            : (state.questions.length * 10).toDouble(),
        elapsedSeconds: elapsedSeconds,
      );

      _ref.read(quizResultProvider.notifier).state = result;
      state = state.copyWith(isSubmitting: false);
      return result;
    } on AppFailure catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Không thể kết thúc bài thi: $e',
      );
      return null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  final repository = ref.watch(quizRepositoryProvider);
  return QuizNotifier(repository, ref);
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
