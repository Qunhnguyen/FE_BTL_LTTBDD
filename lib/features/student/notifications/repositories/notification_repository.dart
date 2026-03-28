import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationRepository(apiClient);
});

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

  Future<Map<String, dynamic>> getNotifications() async {
    final response = await _apiClient.get('/api/student/notifications');
    return response.data;
  }

  Future<void> markAsRead(String id) async {
    await _apiClient.patch('/api/student/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _apiClient.patch('/api/student/notifications/read-all');
  }
}
