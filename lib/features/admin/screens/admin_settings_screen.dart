import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../repositories/admin_repository.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  final _nameController = TextEditingController();
  bool _isEditingName = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController.text = user?.name ?? '';
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _isUploading = true);
      try {
        await ref.read(adminRepositoryProvider).uploadAvatar(File(image.path));
        await ref.read(authProvider.notifier).ensureCurrentUser();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật ảnh đại diện thành công')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isUploading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeMode = ref.watch(themeProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt hệ thống', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                ? NetworkImage(user.avatarUrl!)
                                : null,
                            child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                                ? const Icon(Icons.admin_panel_settings, size: 34)
                                : null,
                          ),
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: IconButton(
                              onPressed: _isUploading ? null : _pickAndUploadAvatar,
                              icon: _isUploading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.camera_alt_rounded, size: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(user.email, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                            const SizedBox(height: 6),
                            const Text('Quản trị viên', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  enabled: _isEditingName,
                  decoration: const InputDecoration(
                    labelText: 'Họ tên Admin',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                if (!_isEditingName)
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _isEditingName = true),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Chỉnh sửa hồ sơ'),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _nameController.text = user.name;
                            setState(() => _isEditingName = false);
                          },
                          child: const Text('Hủy'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await ref.read(adminRepositoryProvider).updateMyProfile(_nameController.text.trim());
                            await ref.read(authProvider.notifier).ensureCurrentUser();
                            if (mounted) {
                              setState(() => _isEditingName = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã lưu thông tin')),
                              );
                            }
                          },
                          child: const Text('Lưu'),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: themeMode == ThemeMode.dark,
                  onChanged: (value) => ref.read(themeProvider.notifier).toggleTheme(value),
                  title: const Text('Chế độ tối', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(themeMode == ThemeMode.dark ? 'Đang bật' : 'Đang tắt'),
                  secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                ),
                const SizedBox(height: 24),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: Colors.red.withValues(alpha: 0.08),
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Đăng xuất', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Quay về màn hình đăng nhập'),
                  onTap: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      context.goNamed(AppRouteNames.login);
                    }
                  },
                ),
              ],
            ),
    );
  }
}
