import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/ai_models.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AiRepository(apiClient);
});

class AiRepository {
  final ApiClient _apiClient;

  AiRepository(this._apiClient);

  Future<KnowledgeIngestResponse> ingestKnowledgeText(
    String subjectId,
    KnowledgeIngestRequest request,
  ) async {
    final response = await _apiClient.post(
      '/api/admin/subjects/$subjectId/ai/knowledge/ingest',
      data: request.toJson(),
    );
    return KnowledgeIngestResponse.fromJson(response.data);
  }

  Future<KnowledgeIngestResponse> ingestKnowledgeFile({
    required String subjectId,
    required String title,
    required String filePath,
    required String fileName,
    String? classroomId,
    String sourceType = 'FILE',
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'sourceType': sourceType,
      if (classroomId != null) 'classroomId': classroomId,
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await _apiClient.post(
      '/api/admin/subjects/$subjectId/ai/knowledge/ingest-file',
      data: formData,
    );
    return KnowledgeIngestResponse.fromJson(response.data);
  }

  Future<AiExamGenerateResponse> generateAiExam(
    String subjectId,
    AiExamGenerateRequest request,
  ) async {
    final response = await _apiClient.post(
      '/api/admin/subjects/$subjectId/ai/exams/generate',
      data: request.toJson(),
    );
    return AiExamGenerateResponse.fromJson(response.data);
  }

  Future<AiExamJobResponse> getAiJobDetail(String subjectId, String jobId) async {
    final response = await _apiClient.get(
      '/api/admin/subjects/$subjectId/ai/exams/jobs/$jobId',
    );
    return AiExamJobResponse.fromJson(response.data);
  }

  Future<AiExamApproveResponse> approveAiJob(
    String subjectId,
    String jobId,
    AiExamApproveRequest request,
  ) async {
    final response = await _apiClient.post(
      '/api/admin/subjects/$subjectId/ai/exams/jobs/$jobId/approve',
      data: request.toJson(),
    );
    return AiExamApproveResponse.fromJson(response.data);
  }
}
