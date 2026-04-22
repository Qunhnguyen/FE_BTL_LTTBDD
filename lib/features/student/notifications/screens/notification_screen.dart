import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    ref.listen(notificationProvider, (previous, next) {
      if (next.actionMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.actionMessage!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          if (state.items.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(notificationProvider.notifier).markAllAsRead(),
              child: const Text('Đọc tất cả'),
            ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => ref.read(notificationProvider.notifier).fetchNotifications(),
            child: state.items.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return _NotificationTile(item: item);
                    },
                  ),
          ),
          if (state.isLoading)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'Bạn không có thông báo nào',
            style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final dynamic item;
  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isInvite = item.type == 'CLASSROOM_INVITE';
    final bool isRead = item.read ?? false;

    return InkWell(
      onTap: isRead ? null : () => ref.read(notificationProvider.notifier).markAsRead(item.id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // CẢI THIỆN MÀU SẮC: Sáng hơn và có độ tương phản tốt hơn
          color: isDark 
            ? (isRead ? Colors.white.withOpacity(0.05) : Colors.blue.withOpacity(0.15))
            : (isRead ? Colors.white : Colors.blue.withOpacity(0.08)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead 
              ? (isDark ? Colors.white10 : Colors.grey.shade200)
              : Colors.blue.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            if (!isRead)
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isInvite ? Colors.blue : Colors.orange).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isInvite ? Icons.group_add_rounded : Icons.notifications_active_rounded,
                    color: isInvite ? Colors.blue : Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                          fontSize: 15,
                          // MÀU CHỮ: Tự động điều chỉnh theo Theme
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.message,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  ),
              ],
            ),
            
            if (isInvite && !isRead)
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 44),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => ref.read(notificationProvider.notifier).declineClassroomInvite(item.id),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Từ chối'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => ref.read(notificationProvider.notifier).acceptClassroomInvite(item.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Chấp nhận'),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: Text(
                _formatTime(item.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white38 : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')} - ${time.day}/${time.month}';
    }
  }
}
