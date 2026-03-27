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

  Future<List<LeaderboardEntry>> getLeaderboard(String contestId, {int? limit, String? currentUserId}) async {
    final response = await _apiClient.get(
      '/api/public/leaderboard/$contestId',
      queryParameters: {
        if (limit != null) 'limit': limit,
      },
    );
    
    final List<dynamic> data = response.data;
    // Sử dụng map và cast sang kiểu List<LeaderboardEntry>
    return data.map((json) {
      return LeaderboardEntry.fromJson(
        Map<String, dynamic>.from(json), 
        currentUserId: currentUserId,
      );
    }).toList();
  }
}
