class AppEnv {
  AppEnv._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const String appName = 'Quiz System';

  static bool get hasValidBaseUrl => apiBaseUrl.isNotEmpty;
}

