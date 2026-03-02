import 'package:dio/dio.dart';

class AppFailure implements Exception {
  AppFailure({
    required this.message,
    this.code,
    this.status,
    this.path,
    this.timestamp,
    this.errors,
    this.isNetwork = false,
  });

  final String message;
  final int? code;
  final int? status;
  final String? path;
  final DateTime? timestamp;
  final Map<String, dynamic>? errors;
  final bool isNetwork;

  @override
  String toString() => 'AppFailure(message: $message, code: $code)';

  static AppFailure fromDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return AppFailure(
        message: 'Network error. Please check your connection and try again.',
        isNetwork: true,
      );
    }

    final response = error.response;
    if (response == null) {
      return AppFailure(
        message: 'Unexpected error occurred. Please try again.',
      );
    }

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString() ??
          'Unexpected server error. Please try again.';

      DateTime? timestamp;
      final ts = data['timestamp'];
      if (ts is String) {
        try {
          timestamp = DateTime.parse(ts);
        } catch (_) {
          timestamp = null;
        }
      }

      return AppFailure(
        message: message,
        code: response.statusCode,
        status: data['status'] is int ? data['status'] as int : null,
        path: data['path']?.toString(),
        timestamp: timestamp,
        errors: data['errors'] is Map<String, dynamic>
            ? data['errors'] as Map<String, dynamic>
            : null,
      );
    }

    return AppFailure(
      message: 'Unexpected server error. Please try again.',
      code: response.statusCode,
    );
  }
}

