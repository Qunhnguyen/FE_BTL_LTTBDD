import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../notifications/providers/notification_provider.dart';
import '../providers/home_providers.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // SỬA: Dùng filteredStudentSubjectsProvider thay vì subjectsProvider gốc
    final subjectsAsync = ref.watch(filteredStudentSubjectsProvider);
    final authState = ref.watch(authProvider);
    
    final user = authState.user;
    final userName = user?.name ?? 'Người dùng';
    final avatarUrl = user?.avatarUrl;

    final notificationState = ref.watch(notificationProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.goNamed(AppRouteNames.studentProfile),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.colorScheme.primary, width: 2),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: (avatarUrl != null && avatarUrl.isNotEmpty)
                          ? Image.network(avatarUrl, fit: BoxFit.cover)
                          : const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Xin chào,', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                  
                  IconButton(
                    onPressed: () => context.pushNamed(AppRouteNames.studentNotifications),
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.notifications_none_rounded, size: 28),
                        if (notificationState.unreadCount > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                              child: Text(
                                '${notificationState.unreadCount}',
                                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                // SỬA: Thêm logic cập nhật Search Query
                onChanged: (value) => ref.read(subjectSearchQueryProvider.notifier).state = value,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm môn học...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: isDark ? Colors.white10 : Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
            ),
          ),

          // Quick Access
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickAccessCard(
                      title: 'Lịch sử thi',
                      icon: Icons.history,
                      color: Colors.orange,
                      onTap: () => context.goNamed(AppRouteNames.studentHistory),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAccessCard(
                      title: 'Xếp hạng',
                      icon: Icons.emoji_events,
                      color: Colors.purple,
                      onTap: () => context.goNamed(AppRouteNames.studentLeaderboard),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text('Môn học của tôi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),

          subjectsAsync.when(
            data: (subjects) {
              if (subjects.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('Không tìm thấy môn học nào')),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final subject = subjects[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                            child: Icon(Icons.book, color: theme.colorScheme.primary),
                          ),
                          title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(subject.description ?? 'Không có mô tả', maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            context.pushNamed(
                              AppRouteNames.studentQuizCatalog,
                              pathParameters: {'subjectId': subject.id},
                              queryParameters: {'name': subject.name},
                            );
                          },
                        ),
                      );
                    },
                    childCount: subjects.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Lỗi: $err'))),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickAccessCard({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
