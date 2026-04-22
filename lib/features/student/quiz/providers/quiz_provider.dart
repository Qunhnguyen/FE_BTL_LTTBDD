import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import '../models/quiz_submission.dart';
import '../models/quiz_result.dart';
import '../repositories/quiz_repository.dart';
import 'quiz_result_provider.dart';
import '../../leaderboard/providers/leaderboard_provider.dart';

typedef QuizState = QuizRuntimeState;

final studentQuizListProvider = FutureProvider.family<List<dynamic>, String>((ref, subjectId) async {
  final repository = ref.watch(studentQuizRepositoryProvider);
  return repository.getQuizzes(subjectId);
});

final studentQuizDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, quizId) async {
  final repository = ref.watch(studentQuizRepositoryProvider);
  return repository.getQuizDetail(quizId);
});

class QuizRuntimeState {
  final StartQuizResponse? submission;
  final int currentQuestionIndex;
  final Map<String, String> selectedAnswers;
  final Map<String, bool> isCorrectMap;
  final Map<String, String> correctOptionMap;
  final bool isSubmitting;
  final bool isFinished;
  final bool isLoading;
  final String? errorMessage;
  final SubmissionResult? result;
  final int remainingSeconds;
  final Map<String, List<String>> disabledOptions;
  final Set<String> usedPowerUps;
  final Map<String, String> questionHints; // THEEM: Luu text gợi ý theo questionId

  QuizRuntimeState({
    this.submission,
    this.currentQuestionIndex = 0,
    this.selectedAnswers = const {},
    this.isCorrectMap = const {},
    this.correctOptionMap = const {},
    this.isSubmitting = false,
    this.isFinished = false,
    this.isLoading = false,
    this.errorMessage,
    this.result,
    this.remainingSeconds = 0,
    this.disabledOptions = const {},
    this.usedPowerUps = const {},
    this.questionHints = const {},
  });

  QuizRuntimeState copyWith({
    StartQuizResponse? submission,
    int? currentQuestionIndex,
    Map<String, String>? selectedAnswers,
    Map<String, bool>? isCorrectMap,
    Map<String, String>? correctOptionMap,
    bool? isSubmitting,
    bool? isFinished,
    bool? isLoading,
    String? errorMessage,
    SubmissionResult? result,
    int? remainingSeconds,
    Map<String, List<String>>? disabledOptions,
    Set<String>? usedPowerUps,
    Map<String, String>? questionHints,
  }) {
    return QuizRuntimeState(
      submission: submission ?? this.submission,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      isCorrectMap: isCorrectMap ?? this.isCorrectMap,
      correctOptionMap: correctOptionMap ?? this.correctOptionMap,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isFinished: isFinished ?? this.isFinished,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      result: result ?? this.result,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      disabledOptions: disabledOptions ?? this.disabledOptions,
      usedPowerUps: usedPowerUps ?? this.usedPowerUps,
      questionHints: questionHints ?? this.questionHints,
    );
  }

  List<Question> get questions => submission?.questions ?? [];
  Question? get currentQuestion => (submission != null && currentQuestionIndex < questions.length) ? questions[currentQuestionIndex] : null;
}

class QuizRuntimeController extends StateNotifier<QuizRuntimeState> {
  final StudentQuizRepository _repository;
  final Ref _ref;
  Timer? _timer;
  int _elapsedSeconds = 0;

  QuizRuntimeController(this._repository, this._ref) : super(QuizRuntimeState());

  Future<void> startQuiz(String quizId) async {
    state = QuizRuntimeState(); 
    state = state.copyWith(isLoading: true);
    try {
      final submission = await _repository.startQuiz(quizId);
      _elapsedSeconds = 0;
      state = state.copyWith(
        submission: submission,
        isLoading: false,
        remainingSeconds: submission.durationMinutes * 60,
      );
      _startTimer();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        timer.cancel();
        finishQuiz();
      }
    });
  }

  Future<void> selectAnswer(String questionId, String optionKey) async {
    if (state.submission == null) return;
    if (state.isCorrectMap.containsKey(questionId)) return;

    final newAnswers = Map<String, String>.from(state.selectedAnswers);
    newAnswers[questionId] = optionKey;
    state = state.copyWith(selectedAnswers: newAnswers);

    try {
      final response = await _repository.submitAnswer(state.submission!.submissionId, questionId, optionKey);
      final newIsCorrectMap = Map<String, bool>.from(state.isCorrectMap);
      final newCorrectOptionMap = Map<String, String>.from(state.correctOptionMap);
      newIsCorrectMap[questionId] = response['isCorrect'] ?? false;
      newCorrectOptionMap[questionId] = response['correctOption'] ?? '';
      state = state.copyWith(isCorrectMap: newIsCorrectMap, correctOptionMap: newCorrectOptionMap);
    } catch (e) {}
  }

  void nextQuestion() {
    if (state.submission != null && state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
    }
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1);
    }
  }

  Future<void> usePowerUp(String type) async {
    final currentQuestionId = state.currentQuestion?.id;
    if (state.submission == null || currentQuestionId == null) return;
    
    if (state.usedPowerUps.contains(type)) return;

    try {
      final response = await _repository.usePowerUp(state.submission!.submissionId, currentQuestionId, type);
      print('DEBUG: Power-up response for $type: $response');

      final newUsed = Set<String>.from(state.usedPowerUps)..add(type);
      
      if (type == 'FIFTY_FIFTY') {
        final dynamic rawKeys = response['removedOptions'];
        final List<String> disabledKeys = rawKeys != null ? List<String>.from(rawKeys) : [];
        final newDisabled = Map<String, List<String>>.from(state.disabledOptions);
        newDisabled[currentQuestionId] = disabledKeys;
        state = state.copyWith(disabledOptions: newDisabled, usedPowerUps: newUsed);
      } else if (type == 'SKIP') {
        state = state.copyWith(usedPowerUps: newUsed);
        nextQuestion();
      } else if (type == 'HINT') {
        // XỬ LÝ HINT TỪ BE
        final String hintText = response['hintText'] ?? response['hint'] ?? 'Không có gợi ý cụ thể.';
        final newHints = Map<String, String>.from(state.questionHints);
        newHints[currentQuestionId] = hintText;
        state = state.copyWith(questionHints: newHints, usedPowerUps: newUsed);
      } else {
        state = state.copyWith(usedPowerUps: newUsed);
      }
    } catch (e) {
      print('ERROR: Power-up failed: $e');
      if (e.toString().contains('already been used')) {
        state = state.copyWith(usedPowerUps: {...state.usedPowerUps, type});
      }
    }
  }

  Future<void> finishQuiz() async {
    if (state.submission == null || state.isFinished) return;
    final quizId = state.submission!.quizId;
    
    state = state.copyWith(isSubmitting: true);
    _timer?.cancel();
    try {
      final resultData = await _repository.finishQuiz(state.submission!.submissionId);
      final subResult = SubmissionResult.fromJson(resultData);
      final finalResult = QuizResult(
        score: subResult.totalScore,
        correctCount: subResult.correctCount,
        totalQuestions: subResult.totalQuestions,
        elapsedSeconds: _elapsedSeconds,
        completedAt: DateTime.now(),
      );
      
      _ref.read(quizResultProvider.notifier).state = finalResult;
      _ref.read(selectedLeaderboardContestIdProvider.notifier).state = quizId;

      state = state.copyWith(isSubmitting: false, isFinished: true, result: subResult);
    } catch (e) {
      state = state.copyWith(isSubmitting: false);
      rethrow;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final quizProvider = StateNotifierProvider<QuizRuntimeController, QuizRuntimeState>((ref) {
  final repository = ref.watch(studentQuizRepositoryProvider);
  return QuizRuntimeController(repository, ref);
});

final currentQuestionProvider = Provider<Question?>((ref) {
  final quizState = ref.watch(quizProvider);
  return quizState.currentQuestion;
});

final quizProgressProvider = Provider<double>((ref) {
  final quizState = ref.watch(quizProvider);
  if (quizState.questions.isEmpty) return 0.0;
  return (quizState.currentQuestionIndex + 1) / quizState.questions.length;
});
