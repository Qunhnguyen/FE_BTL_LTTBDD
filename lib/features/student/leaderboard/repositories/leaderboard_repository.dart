import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/leaderboard_entry.dart';

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LeaderboardRepository(apiClient);
});

class LeaderboardRepository {
  final ApiClient _apiClient;

  LeaderboardRepository(this._apiClient);

  /// Lấy bảng xếp hạng công khai của một Quiz
  /// Gọi Endpoint: GET /api/public/leaderboard/quizzes/{quizId}
  Future<List<LeaderboardEntry>> getLeaderboard(String quizId, {String? currentUserId}) async {
    // Gọi đúng Endpoint Public của Backend
    final response = await _apiClient.get('/api/public/leaderboard/quizzes/$quizId');
    
    final List<dynamic> data = response.data;
    
    // Ánh xạ dữ liệu sang Model LeaderboardEntry
    return data.map((json) {
      return LeaderboardEntry.fromJson(
        Map<String, dynamic>.from(json), 
        currentUserId: currentUserId,
      );
    }).toList();
  }
}
