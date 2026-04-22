class AppEnv {
  AppEnv._();

  // Cập nhật theo IP Wi-Fi thực tế từ ipconfig của bạn: 192.168.0.104
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.0.104:8080',
  );

  static const String appName = 'Quiz System';

  static bool get hasValidBaseUrl => apiBaseUrl.isNotEmpty;
}
