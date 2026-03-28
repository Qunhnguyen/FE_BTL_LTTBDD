import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/notification_provider.dart';
import '../../../../core/router/app_router.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Thông báo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (state.items.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(notificationProvider.notifier).markAllAsRead(),
              child: const Text('Đọc tất cả', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationProvider.notifier).fetchNotifications(),
        child: state.items.isEmpty
            ? ListView( // Dùng ListView để có thể Pull to refresh kể cả khi rỗng
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.notifications_none_outlined, size: 80, color: theme.colorScheme.primary.withOpacity(0.5)),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Bạn chưa có thông báo nào',
                          style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        const Text('Vuốt xuống để cập nhật', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: state.items.length,
                separatorBuilder: (context, index) => const Divider(height: 1, indent: 80),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  final translatedTitle = _translateTitle(item.title);
                  final translatedMessage = _translateMessage(item.message);

                  return Material(
                    color: item.read ? Colors.transparent : theme.colorScheme.primary.withOpacity(0.03),
                    child: InkWell(
                      onTap: () {
                        ref.read(notificationProvider.notifier).markAsRead(item.id);
                        if (item.contestId != null) {
                          context.pushNamed(AppRouteNames.studentQuiz, pathParameters: {'contestId': item.contestId!});
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildNotificationIcon(item, theme),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          translatedTitle,
                                          style: TextStyle(
                                            fontWeight: item.read ? FontWeight.w600 : FontWeight.bold,
                                            fontSize: 15,
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (!item.read)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    translatedMessage,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? Colors.white70 : Colors.black54,
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatDateTime(item.createdAt),
                                    style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _translateTitle(String title) {
    if (title.contains('New contest available')) {
      final parts = title.split(':');
      final contestName = parts.length > 1 ? parts.last.trim() : '';
      return 'Cuộc thi mới: $contestName';
    }
    return title;
  }

  String _translateMessage(String message) {
    if (message.contains('Subject') && message.contains('has a new contest')) {
      final regExp = RegExp(r'Subject (.*) has a new contest: (.*)');
      final match = regExp.firstMatch(message);
      if (match != null) {
        final subject = match.group(1);
        final contest = match.group(2);
        return 'Môn $subject vừa có cuộc thi mới: $contest. Hãy tham gia ngay!';
      }
    }
    return message;
  }

  Widget _buildNotificationIcon(dynamic item, ThemeData theme) {
    IconData iconData = Icons.notifications_outlined;
    Color iconColor = theme.colorScheme.primary;
    if (item.type == 'NEW_CONTEST') {
      iconData = Icons.assignment_outlined;
      iconColor = Colors.orange;
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: item.read ? Colors.grey[200] : iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: item.read ? Colors.grey : iconColor, size: 24),
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);
    if (difference.inMinutes < 60) return '${difference.inMinutes} phút trước';
    if (difference.inHours < 24) return '${difference.inHours} giờ trước';
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')} - ${dt.day}/${dt.month}';
  }
}
