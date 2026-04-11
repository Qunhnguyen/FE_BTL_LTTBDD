class AppEnv {
  AppEnv._();

  // Sử dụng IP Wi-Fi từ ipconfig: 192.168.0.104
  // Cổng 9999 theo log lỗi của bạn
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.0.104:8080',
  );

  static const String appName = 'Quiz System';

  static bool get hasValidBaseUrl => apiBaseUrl.isNotEmpty;
}
