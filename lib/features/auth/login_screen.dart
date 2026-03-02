import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';

enum UserType { student, teacher }

final userTypeProvider = StateProvider<UserType>((ref) => UserType.student);
final obscurePasswordProvider = StateProvider<bool>((ref) => true);

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userType = ref.watch(userTypeProvider);
    final obscurePassword = ref.watch(obscurePasswordProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Đăng nhập Hệ thống',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Logo/Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.school,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Segmented Control (User Type)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SegmentButton(
                        label: 'Sinh viên',
                        isSelected: userType == UserType.student,
                        onTap: () => ref.read(userTypeProvider.notifier).state =
                            UserType.student,
                      ),
                    ),
                    Expanded(
                      child: _SegmentButton(
                        label: 'Giảng viên',
                        isSelected: userType == UserType.teacher,
                        onTap: () => ref.read(userTypeProvider.notifier).state =
                            UserType.teacher,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Form
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userType == UserType.student ? 'MSSV / Email' : 'Email Giảng viên',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: userType == UserType.student
                          ? 'Nhập MSSV hoặc Email'
                          : 'Nhập email của bạn',
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: theme.brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Mật khẩu',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Nhập mật khẩu',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => ref
                            .read(obscurePasswordProvider.notifier)
                            .update((state) => !state),
                      ),
                      filled: true,
                      fillColor: theme.brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Quên mật khẩu?'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Login Button
              ElevatedButton(
                onPressed: () {
                  if (userType == UserType.student) {
                    context.goNamed(AppRouteNames.studentHome);
                  } else {
                    context.goNamed(AppRouteNames.teacherDashboard);
                  }
                },
                child: const Text('Đăng nhập'),
              ),

              const SizedBox(height: 32),

              // Footer
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    const Text('Gặp sự cố đăng nhập? '),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Liên hệ hỗ trợ',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? theme.colorScheme.primary : Colors.grey,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
