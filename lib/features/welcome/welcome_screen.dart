import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: Container(
              color: isDark ? const Color(0xFF101C22) : const Color(0xFFF6F7F8),
            ),
          ),
          
          // Decorative Gradient Shapes
          Positioned(
            top: -MediaQuery.of(context).size.height * 0.1,
            right: -MediaQuery.of(context).size.width * 0.1,
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.3,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.2),
                    Colors.teal.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -MediaQuery.of(context).size.height * 0.1,
            left: -MediaQuery.of(context).size.width * 0.1,
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.blue.withOpacity(0.2),
                    theme.colorScheme.primary.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Column(
                children: [
                  const Spacer(),
                  
                  // Illustration Area
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 280,
                          height: 280,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                "https://lh3.googleusercontent.com/aida-public/AB6AXuBzdhnfZJd4w0lwDl5v9l7hFYKS4YktaS2-KyZEdAi1bm9C48QtGSu5j9G_G5t_pcr536-8ErSHICdrb0il8y6GEvzFUS3I4WUT39lKoEA8ELufW9WI_YRtciqH7O8Rxtb--UKjN6zgxTBUlLy5VxZ7L4hwgmBgKjxMkJcSl8wkI4l6Hw5ernuCEeWvlQV-Twxae9392Y230Sl5Zc5LhZvqbvWMToiFl3hrjJ5n_SbiO3Yj0-4UANEsQSi4VZh5r5KSd1YjLxLXDmU",
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 20,
                          child: _FloatingIcon(
                            icon: Icons.school,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Positioned(
                          bottom: 40,
                          left: 0,
                          child: _FloatingIcon(
                            icon: Icons.quiz,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // App Title & Description
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, size: 14, color: theme.colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              'PHIÊN BẢN 2.0',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          children: [
                            const TextSpan(text: 'Quiz '),
                            TextSpan(
                              text: 'App',
                              style: TextStyle(color: theme.colorScheme.primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Học tập & Thi trắc nghiệm\nReal-time mọi lúc mọi nơi',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Buttons
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => context.push(AppRouteNames.login),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('Bắt đầu ngay'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => context.push(AppRouteNames.login),
                        style: TextButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_pin_circle_outlined,
                              size: 18,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tiếp tục với tư cách Giảng viên',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Bằng việc tiếp tục, bạn đồng ý với Điều khoản sử dụng',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _FloatingIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
