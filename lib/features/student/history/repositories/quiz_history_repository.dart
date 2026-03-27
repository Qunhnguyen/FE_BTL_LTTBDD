import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/network/api_client.dart';
import '../models/quiz_history_entry.dart';

final quizHistoryRepositoryProvider = Provider<QuizHistoryRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return QuizHistoryRepository(apiClient);
});

class QuizHistoryRepository {
  QuizHistoryRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<QuizHistoryEntry>> getHistory({
    String? studentId,
    int? page,
    int? size,
  }) async {
    final queryParameters = <String, dynamic>{
      if (studentId != null && studentId.isNotEmpty) 'studentId': studentId,
      if (page != null) 'page': page,
      if (size != null) 'size': size,
    };

    try {
      final response = await _apiClient.get(
        '/api/student/submissions/history',
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );
      
      print('DEBUG - History API Response: ${response.data}');

      final rawItems = _extractHistoryItems(response.data);
      if (rawItems == null) {
        return []; // Trả về rỗng thay vì ném lỗi để tránh văng app
      }

      final entries = rawItems
          .whereType<Map>()
          .map((item) =>
              QuizHistoryEntry.fromJson(Map<String, dynamic>.from(item)))
          .toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

      return entries;
    } catch (e) {
      print('ERROR - History API Error: $e');
      return [];
    }
  }

  List<dynamic>? _extractHistoryItems(dynamic data, {int depth = 0}) {
    if (data == null) return null;
    if (data is List) return data;
    
    if (data is! Map || depth > 3) return null;

    final map = Map<String, dynamic>.from(data);
    
    // Thử tìm trong các key phổ biến của Backend
    final candidateKeys = [
      'submissions',
      'history',
      'items',
      'content', // Phổ biến trong Pageable của Spring Boot
      'data',
      'results',
    ];

    for (final key in candidateKeys) {
      if (map[key] is List) {
        return map[key];
      }
    }

    // Nếu không thấy, thử tìm đệ quy vào sâu hơn (ví dụ: data { submissions: [...] })
    for (final key in map.keys) {
      final nested = _extractHistoryItems(map[key], depth: depth + 1);
      if (nested != null) return nested;
    }

    return null;
  }
}
