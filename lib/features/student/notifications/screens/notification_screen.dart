import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationProvider);
    final theme = Theme.of(context);

    // Listen for action messages (Success/Error)
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
                : ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return _NotificationTile(item: item);
                    },
                  ),
          ),
          if (state.isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Bạn không có thông báo nào', style: TextStyle(color: Colors.grey)),
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
    final isInvite = item.type == 'CLASSROOM_INVITE';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: item.read ? null : Colors.blue.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isInvite ? Icons.group_add : Icons.notifications,
                  color: isInvite ? Colors.blue : Colors.orange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: item.read ? FontWeight.normal : FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.message, style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 12),
            if (isInvite && !item.read) // Show actions only for unread invites
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => ref.read(notificationProvider.notifier).declineClassroomInvite(item.id),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(80, 36), // Fix infinite width error
                    ),
                    child: const Text('Từ chối'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => ref.read(notificationProvider.notifier).acceptClassroomInvite(item.id),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 36), // Fix infinite width error
                    ),
                    child: const Text('Chấp nhận'),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                _formatTime(item.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')} - ${time.day}/${time.month}';
  }
}
