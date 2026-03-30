class AppEnv {
  AppEnv._();

  // Sử dụng 10.0.2.2 để máy ảo Android có thể truy cập localhost của máy tính host
  // Nếu dùng máy ảo iOS hoặc thiết bị thật, hãy dùng IP mạng nội bộ (v.d. 192.168.x.x)
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.98.92:9999',
  );

  static const String appName = 'Quiz System';

  static bool get hasValidBaseUrl => apiBaseUrl.isNotEmpty;
}
