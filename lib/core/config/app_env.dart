class AppEnv {
  AppEnv._();

  // Sử dụng IP mạng nội bộ để điện thoại thật có thể kết nối tới Backend trên máy tính
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.4.194:8080',
  );

  static const String appName = 'Quiz System';

  static bool get hasValidBaseUrl => apiBaseUrl.isNotEmpty;
}
