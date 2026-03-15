import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return QuizRepository(apiClient);
});

class QuizRepository {
  final ApiClient _apiClient;

  QuizRepository(this._apiClient);

  // API lấy chi tiết cuộc thi kèm danh sách câu hỏi dành cho Student
  Future<dynamic> getStudentContestDetail(String contestId) async {
    final response = await _apiClient.get('/api/student/contests/$contestId');
    _logJson('GET /api/student/contests/$contestId', response.data);
    return response.data;
  }

  // API bắt đầu làm bài
  Future<Map<String, dynamic>> startSubmission(String contestId, String studentId) async {
    final response = await _apiClient.post(
      '/api/student/submissions/$contestId/start',
      queryParameters: {'studentId': studentId},
    );
    _logJson('POST /api/student/submissions/$contestId/start', response.data);
    return _asJsonMap(response.data);
  }

  // API nộp đáp án từng câu
  Future<void> submitAnswer(String submissionId, String questionId, String answer) async {
    final response = await _apiClient.post(
      '/api/student/submissions/$submissionId/answer',
      data: {
        'questionId': questionId,
        'selectedOption': answer,
      },
    );
    _logJson('POST /api/student/submissions/$submissionId/answer', response.data);
  }

  // API kết thúc bài thi
  Future<Map<String, dynamic>> finishSubmission(String submissionId) async {
    final response = await _apiClient.post('/api/student/submissions/$submissionId/finish');
    _logJson('POST /api/student/submissions/$submissionId/finish', response.data);
    return _asJsonMap(response.data);
  }

  Map<String, dynamic> _asJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return {'data': data};
  }

  void _logJson(String label, dynamic data) {
    try {
      final responseText = data is String
          ? data
          : const JsonEncoder.withIndent('  ').convert(data);
      debugPrint('Response Text [$label]:\n$responseText');
    } catch (_) {
      debugPrint('Response Text [$label]: $data');
    }
  }
}
