import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';
import '../../../auth/providers/auth_provider.dart';

class NotificationState {
  final List<AppNotification> items;
  final int unreadCount;
  final bool isLoading;

  NotificationState({
    this.items = const [],
    this.unreadCount = 0,
    this.isLoading = false,
  });

  NotificationState copyWith({
    List<AppNotification>? items,
    int? unreadCount,
    bool? isLoading,
  }) {
    return NotificationState(
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;
  final Ref _ref;
  Timer? _timer;

  NotificationNotifier(this._repository, this._ref) : super(NotificationState()) {
    _init();
  }

  void _init() {
    // Chỉ chạy nếu là Sinh viên
    final authState = _ref.read(authProvider);
    if (authState.user?.role == 'STUDENT') {
      fetchNotifications();
      // Bật Polling mỗi 60 giây
      _timer = Timer.periodic(const Duration(seconds: 60), (_) => fetchNotifications());
    }
  }

  Future<void> fetchNotifications() async {
    // Kiểm tra role một lần nữa trước khi gọi API để chắc chắn
    final authState = _ref.read(authProvider);
    if (authState.user?.role != 'STUDENT') {
      return;
    }

    try {
      final data = await _repository.getNotifications();
      final List<dynamic> itemsRaw = data['items'] ?? [];
      final unread = data['unreadCount'] ?? 0;
      
      state = state.copyWith(
        items: itemsRaw.map((e) => AppNotification.fromJson(e)).toList(),
        unreadCount: unread,
        isLoading: false,
      );
    } catch (e) {
      // Bỏ qua log lỗi 403 nếu lỡ gọi nhầm, để tránh làm rối console
      if (!e.toString().contains('403')) {
        print('Error fetching notifications: $e');
      }
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      await fetchNotifications();
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      await fetchNotifications();
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return NotificationNotifier(repo, ref);
});
