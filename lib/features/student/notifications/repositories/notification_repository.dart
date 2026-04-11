import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationRepository(apiClient);
});

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

  // Lấy danh sách thông báo trong app
  Future<Map<String, dynamic>> getNotifications() async {
    final response = await _apiClient.get('/api/student/notifications');
    return response.data;
  }

  // Đăng ký thiết bị để nhận PUSH Notification
  Future<void> registerDevice({
    required String token,
    required String deviceId,
    required String deviceName,
    required String appVersion,
  }) async {
    await _apiClient.post(
      '/api/student/notifications/devices',
      data: {
        'token': token,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'deviceId': deviceId,
        'deviceName': deviceName,
        'appVersion': appVersion,
      },
    );
  }

  // Hủy đăng ký thiết bị khi Logout
  Future<void> unregisterDevice(String token) async {
    await _apiClient.delete(
      '/api/student/notifications/devices',
      queryParameters: {'token': token},
    );
  }

  Future<void> markAsRead(String id) async {
    await _apiClient.patch('/api/student/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _apiClient.patch('/api/student/notifications/read-all');
  }
}
