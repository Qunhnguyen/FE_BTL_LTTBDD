import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/providers/auth_provider.dart';

class TeacherSettingsScreen extends ConsumerWidget {
  const TeacherSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt hệ thống', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.primary,
                  child: const Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Giảng viên',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user?.email ?? 'teacher@school.edu.vn',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          const Text('QUẢN LÝ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          _buildMenuTile(
            Icons.people_outline_rounded, 
            'Quản lý Sinh viên', 
            () => context.goNamed(AppRouteNames.teacherSubjects), // Điều hướng qua môn học để quản lý SV theo lớp
            isDark: isDark
          ),
          _buildMenuTile(
            Icons.analytics_outlined, 
            'Thống kê kết quả', 
            () => context.goNamed(AppRouteNames.teacherDashboard), // Quay lại Dashboard để xem thống kê
            isDark: isDark
          ),
          _buildMenuTile(
            Icons.cloud_upload_outlined, 
            'Sao lưu dữ liệu', 
            () => _showSnackBar(context, 'Tính năng sao lưu đang được phát triển'),
            isDark: isDark
          ),
          
          const SizedBox(height: 24),
          const Text('ỨNG DỤNG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          
          // KẾT NỐI CHẾ ĐỘ TỐI THẬT
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: isDark ? Colors.white70 : Colors.black87),
            title: const Text('Chế độ tối', style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (val) => ref.read(themeProvider.notifier).toggleTheme(val),
            ),
          ),
          
          _buildMenuTile(
            Icons.info_outline, 
            'Thông tin phiên bản', 
            () => _showVersionDialog(context),
            isDark: isDark
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),

          // Logout Button
          ListTile(
            onTap: () => _showLogoutDialog(context, ref),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout, color: Colors.red),
            ),
            title: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String label, VoidCallback onTap, {bool isDark = false}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isDark ? Colors.white70 : Colors.black87),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showVersionDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Quiz System',
      applicationVersion: '1.0.0+1',
      applicationIcon: const Icon(Icons.quiz, color: Colors.blue, size: 48),
      children: [const Text('Hệ thống quản lý thi trắc nghiệm trực tuyến dành cho Giảng viên và Sinh viên.')],
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản Giảng viên?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.goNamed(AppRouteNames.welcome);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
