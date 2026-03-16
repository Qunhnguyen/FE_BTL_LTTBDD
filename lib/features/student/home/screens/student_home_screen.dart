import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/contest_provider.dart';
import '../models/contest.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentFilter = ref.watch(contestStatusFilterProvider);
    final filteredContestsAsync = ref.watch(filteredContestsProvider);
    final authState = ref.watch(authProvider);
    final userName = authState.user?.name ?? 'Người dùng';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.colorScheme.primary, width: 2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAJg5bQ-BcKFk9IHHvlBQ4OqyYf9pR5JA_HOIOgD9emmitnEzZYgCNGWJtNAfZmpbjWQJoDsUZkh2S3wZCItGmWESeCfWgfNQQxPhGpqXllwwoHdo-fu2VVjF3aLLUJtCESoQFrupyI836ABpR4eESFyyRy28jBRUsU1Gr5vClnscp2014LaJY6hgsZ0zhyoduJYe1HvIt_ifdeyEY86r3Xt98uRiL6uf7_IJqaxiM7EIRHYjRujj5pymkhsSW03n4cgs0RI-JAyVU',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _CircleAvatarFallback(
                            size: 44,
                            borderColor: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xin chào,',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$userName!',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications_outlined, size: 28),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
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
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm cuộc thi...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: isDark ? Colors.white10 : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
          ),

          // Quick Access
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Truy cập nhanh',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAccessCard(
                          title: 'Lịch sử thi',
                          subtitle: 'Xem lại kết quả',
                          icon: Icons.history,
                          color: Colors.orange,
                          onTap: () => context.go('/student/history'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickAccessCard(
                          title: 'Xếp hạng',
                          subtitle: 'Top sinh viên',
                          icon: Icons.emoji_events,
                          color: Colors.purple,
                          onTap: () => context.go('/student/leaderboard'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tabs
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              child: Container(
                color: theme.scaffoldBackgroundColor,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Đang diễn ra',
                        isSelected: currentFilter == ContestStatus.live,
                        onTap: () => ref.read(contestStatusFilterProvider.notifier).state =
                            ContestStatus.live,
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Sắp diễn ra',
                        isSelected: currentFilter == ContestStatus.upcoming,
                        onTap: () => ref.read(contestStatusFilterProvider.notifier).state =
                            ContestStatus.upcoming,
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Đã kết thúc',
                        isSelected: currentFilter == ContestStatus.finished,
                        onTap: () => ref.read(contestStatusFilterProvider.notifier).state =
                            ContestStatus.finished,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Contest List
          filteredContestsAsync.when(
            data: (contests) {
              if (contests.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text('Không có cuộc thi nào.'),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final contest = contests[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ContestCard(contest: contest),
                      );
                    },
                    childCount: contests.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('Lỗi: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : (Colors.grey[200] ?? Colors.grey),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : (Colors.grey[300] ?? Colors.grey),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ContestCard extends StatelessWidget {
  final Contest contest;

  const _ContestCard({required this.contest});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : (Colors.grey[200] ?? Colors.grey),
        ),
      ),
      child: Stack(
        children: [
          if (contest.status == ContestStatus.live)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 4,
              child: Container(decoration: const BoxDecoration(color: Colors.red, borderRadius: BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)))),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusBadge(status: contest.status),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${contest.durationMinutes} phút',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  contest.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Môn: ${contest.subject} • ${contest.description}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),
                if (contest.status == ContestStatus.upcoming)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.schedule, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Bắt đầu lúc: 14:00 - Hôm nay',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (contest.status == ContestStatus.live)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ParticipantStack(avatars: contest.participantAvatars, total: contest.totalParticipants),
                      ElevatedButton(
                        onPressed: () => context.pushNamed(
                          AppRouteNames.studentQuiz,
                          pathParameters: {'contestId': contest.id}, // Truyền tham số ID cuộc thi
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(120, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Tham gia ngay', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                if (contest.status == ContestStatus.upcoming)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 40),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Chi tiết', style: TextStyle(fontSize: 13)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 40),
                              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                              foregroundColor: theme.colorScheme.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Đăng ký', style: TextStyle(fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ContestStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ContestStatus.live:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              const Text(
                'TRỰC TIẾP',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ],
          ),
        );
      case ContestStatus.upcoming:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.event, size: 12, color: Colors.blue),
              const SizedBox(width: 4),
              const Text(
                'SẮP DIỄN RA',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ],
          ),
        );
      case ContestStatus.finished:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'ĐÃ KẾT THÚC',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10),
          ),
        );
    }
  }
}

class _ParticipantStack extends StatelessWidget {
  final List<String> avatars;
  final int total;

  const _ParticipantStack({required this.avatars, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final visibleAvatars = avatars.length > 3 ? avatars.sublist(0, 3) : avatars;
    
    return Row(
      children: [
        SizedBox(
          width: (visibleAvatars.isEmpty ? 0 : 28 + ((visibleAvatars.length - 1) * 18)),
          height: 28,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleAvatars.length,
            itemBuilder: (context, index) {
              return Transform.translate(
                offset: Offset(index * -10.0, 0),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    visibleAvatars[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _CircleAvatarFallback(
                      size: 28,
                      borderColor: theme.scaffoldBackgroundColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Transform.translate(
          offset: Offset((visibleAvatars.isNotEmpty ? visibleAvatars.length - 1 : 0) * -10.0 + 4.0, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '+$total',
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleAvatarFallback extends StatelessWidget {
  final double size;
  final Color borderColor;

  const _CircleAvatarFallback({
    required this.size,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.person,
        size: size * 0.45,
        color: theme.colorScheme.primary.withValues(alpha: 0.7),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverAppBarDelegate({required this.child});

  @override
  double get minExtent => 72.0;
  @override
  double get maxExtent => 72.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Force the header to paint exactly within the sliver extent.
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
