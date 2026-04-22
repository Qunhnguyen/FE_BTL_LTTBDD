import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import 'providers/auth_provider.dart';

final obscurePasswordProvider = StateProvider<bool>((ref) => true);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final obscurePassword = ref.watch(obscurePasswordProvider);
    final authState = ref.watch(authProvider);

    // CHỈ ĐIỀU HƯỚNG KHI TRẠNG THÁI THAY ĐỔI TỪ CHƯA LOGIN SANG ĐÃ LOGIN
    ref.listen(authProvider, (previous, next) {
      final wasAuthenticated = previous?.status == AuthStatus.authenticated;
      final isNowAuthenticated = next.status == AuthStatus.authenticated;

      if (isNowAuthenticated && !wasAuthenticated) {
        final role = next.user?.role;
        if (role == 'TEACHER') {
          context.goNamed(AppRouteNames.teacherDashboard);
        } else if (role == 'ADMIN') {
          context.goNamed(AppRouteNames.adminDashboard);
        } else {
          context.goNamed(AppRouteNames.studentHome);
        }
      } else if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Email hoặc mật khẩu không chính xác'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Đăng nhập',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Chào mừng quay trở lại!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Vui lòng đăng nhập để tiếp tục học tập',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 48),

              // Form
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Email đăng nhập',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Nhập email của bạn',
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: theme.brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
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
                    controller: _passwordController,
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
                        borderRadius: BorderRadius.circular(16),
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

              const SizedBox(height: 32),

              // Login Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: authState.status == AuthStatus.authenticating
                      ? null
                      : () {
                          final email = _emailController.text.trim();
                          final password = _passwordController.text.trim();
                          
                          if (email.isNotEmpty && password.isNotEmpty) {
                            ref.read(authProvider.notifier).login(email, password, ''); 
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: authState.status == AuthStatus.authenticating
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : const Text(
                          'Đăng nhập',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 48),

              // Footer
              Center(
                child: Column(
                  children: [
                    const Text('Gặp sự cố đăng nhập? ', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Liên hệ hỗ trợ kỹ thuật',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
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
