import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/managed_question.dart';

final questionFilterProvider = StateProvider<QuestionDifficulty?>((ref) => null);

final mockManagedQuestions = [
  ManagedQuestion(
    id: '1',
    text: 'Thủ đô của Việt Nam là gì?',
    difficulty: QuestionDifficulty.easy,
    points: 10,
    answerCount: 4,
    durationSeconds: 15,
    type: QuestionType.multipleChoice,
  ),
  ManagedQuestion(
    id: '2',
    text: 'Ai là người đầu tiên đặt chân lên Mặt Trăng trong lịch sử nhân loại?',
    difficulty: QuestionDifficulty.medium,
    points: 20,
    answerCount: 4,
    durationSeconds: 30,
    type: QuestionType.multipleChoice,
  ),
  ManagedQuestion(
    id: '3',
    text: 'Giải phương trình bậc hai: x^2 - 4x + 4 = 0. Tìm nghiệm của phương trình?',
    difficulty: QuestionDifficulty.hard,
    points: 30,
    durationSeconds: 60,
    type: QuestionType.essay,
  ),
  ManagedQuestion(
    id: '4',
    text: 'Đây là giống chó gì?',
    difficulty: QuestionDifficulty.easy,
    points: 10,
    durationSeconds: 15,
    type: QuestionType.image,
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDcgWfKtGhUuVCLJrUi_SKNb13nYiqBVlUPcOJRiMEWgCpG_OZGPsi6T6huQGfjp2mqC_luq4DT3sC1APp2XrjSLg2dxU63H4wp3x9zYiwHZ2v-pYE-Lkmd-dXEzHEx8Zz-GOeyaag0aP_3dZBiBwQuOez1yKJZRATzDyzVtyQ4TuxwOI_3CUhaypmiA8JcBz5jWVu-9e5ItJkBuPNPouzDVc8UKW3AXEPYt4Dwf5pEh8npiw_vEZpQL9MFT2G2pZj7bnhPR35Ed8A',
  ),
  ManagedQuestion(
    id: '5',
    text: 'Câu hỏi chưa hoàn thiện...',
    difficulty: QuestionDifficulty.draft,
    points: 0,
    durationSeconds: 0,
    type: QuestionType.multipleChoice,
  ),
];

final managedQuestionsProvider = Provider<List<ManagedQuestion>>((ref) {
  final filter = ref.watch(questionFilterProvider);
  if (filter == null) return mockManagedQuestions;
  return mockManagedQuestions.where((q) => q.difficulty == filter).toList();
});
