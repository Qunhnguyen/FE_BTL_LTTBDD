import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/api_client.dart';
import '../models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  const storage = FlutterSecureStorage();
  return AuthRepository(apiClient, storage);
});

class AuthRepository {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  AuthRepository(this._apiClient, this._storage);

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _userRoleKey = 'user_role';

  Future<User> login(String email, String password, String role) async {
    final response = await _apiClient.post('/api/auth/login', data: {
      'email': email,
      'password': password,
      'role': role,
    });

    final String token = response.data['token'];
    final userJson = response.data['user'];
    final user = User.fromJson(userJson, token: token);

    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: user.id);
    await _storage.write(key: _userRoleKey, value: user.role);

    return user;
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<User?> getCurrentUser() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final response = await _apiClient.get('/api/student/profile');
      return User.fromJson(
        Map<String, dynamic>.from(response.data as Map),
        token: token,
      );
    } catch (_) {
      return null;
    }
  }

  // Cập nhật thông tin profile (chỉ sửa tên)
  Future<User> updateProfile(String name) async {
    final response = await _apiClient.put('/api/student/profile', data: {
      'name': name,
    });
    final token = await getToken();
    return User.fromJson(Map<String, dynamic>.from(response.data as Map), token: token);
  }

  // Upload ảnh đại diện
  Future<User> uploadAvatar(File imageFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imageFile.path),
    });

    final response = await _apiClient.post(
      '/api/student/profile/avatar',
      data: formData,
    );
    final token = await getToken();
    return User.fromJson(Map<String, dynamic>.from(response.data as Map), token: token);
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userRoleKey);
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
