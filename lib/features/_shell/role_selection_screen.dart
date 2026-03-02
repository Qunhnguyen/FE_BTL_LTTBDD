import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_env.dart';
import '../../core/router/app_router.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We ignore the baseUrl check for now as we are using Mock Data
    const hasBaseUrl = true; 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hệ thống Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chọn vai trò truy cập',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.goNamed(AppRouteNames.teacherDashboard),
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Giảng viên (Admin)'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.goNamed(AppRouteNames.studentHome),
              icon: const Icon(Icons.school),
              label: const Text('Sinh viên'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
            ),
          ],
        ),
      ),
    );
  }
}
