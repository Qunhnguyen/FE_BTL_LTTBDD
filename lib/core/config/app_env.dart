class AppEnv {
  AppEnv._();

  // Cập nhật theo IP Wi-Fi thực tế từ ipconfig của bạn: 172.11.219.61
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://172.11.219.61:8080',
  );

  static const String appName = 'Quiz System';

  static bool get hasValidBaseUrl => apiBaseUrl.isNotEmpty;
}
