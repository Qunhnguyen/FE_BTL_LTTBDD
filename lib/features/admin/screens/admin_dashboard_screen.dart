import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../repositories/admin_repository.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminRepo = ref.watch(adminRepositoryProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng quan quản trị'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => adminRepo.getDashboardStats(),
        child: FutureBuilder<Map<String, dynamic>>(
          future: adminRepo.getDashboardStats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 42, color: colorScheme.error),
                    const SizedBox(height: 8),
                    const Text('Không thể tải dashboard'),
                  ],
                ),
              );
            }
            final stats = snapshot.data ?? {};
            final subjects = stats['subjectCount'] ?? 0;
            final teachers = stats['teacherCount'] ?? 0;
            final students = stats['studentCount'] ?? 0;
            final total = teachers + students;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _HeroHeader(totalUsers: total),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _StatCard(title: 'Môn học', count: subjects, icon: Icons.menu_book_rounded, color: Colors.blue),
                    _StatCard(title: 'Giảng viên', count: teachers, icon: Icons.groups_rounded, color: Colors.green),
                    _StatCard(title: 'Sinh viên', count: students, icon: Icons.school_rounded, color: Colors.orange),
                    _StatCard(title: 'Người dùng', count: total, icon: Icons.people_alt_rounded, color: Colors.purple),
                  ],
                ),
                const SizedBox(height: 18),
                const Text('Tác vụ nhanh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                _QuickActionTile(
                  icon: Icons.menu_book_outlined,
                  title: 'Quản lý môn học',
                  subtitle: 'Tạo và cập nhật danh mục môn học',
                  onTap: () => context.goNamed(AppRouteNames.adminSubjects),
                ),
                _QuickActionTile(
                  icon: Icons.groups_outlined,
                  title: 'Quản lý giảng viên',
                  subtitle: 'Xem danh sách và trạng thái giảng viên',
                  onTap: () => context.goNamed(AppRouteNames.adminTeachers),
                ),
                _QuickActionTile(
                  icon: Icons.school_outlined,
                  title: 'Quản lý sinh viên',
                  subtitle: 'Quản trị tài khoản sinh viên',
                  onTap: () => context.goNamed(AppRouteNames.adminStudents),
                ),
                _QuickActionTile(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Cài đặt Admin',
                  subtitle: 'Cập nhật thông tin và cấu hình cá nhân',
                  onTap: () => context.goNamed(AppRouteNames.adminSettings),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final int totalUsers;

  const _HeroHeader({required this.totalUsers});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [primary.withValues(alpha: 0.95), primary.withValues(alpha: 0.75)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ADMIN', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
          const SizedBox(height: 6),
          const Text('Bảng điều khiển', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Tổng tài khoản đang quản lý: $totalUsers', style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.16),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(count.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withValues(alpha: 0.15)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: primary.withValues(alpha: 0.12),
          child: Icon(icon, color: primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
