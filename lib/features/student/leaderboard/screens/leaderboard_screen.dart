import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/leaderboard_entry.dart';
import '../providers/leaderboard_provider.dart';
import '../../home/providers/contest_provider.dart';
import '../../../../core/router/app_router.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final contestsAsync = ref.watch(contestsProvider);
    final selectedContestId = ref.watch(selectedLeaderboardContestIdProvider);
    final entriesAsync = ref.watch(leaderboardEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Bảng xếp hạng', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Contest Selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: contestsAsync.when(
              data: (contests) => DropdownButtonFormField<String>(
                value: selectedContestId ?? (contests.isNotEmpty ? contests.first.id : null),
                decoration: InputDecoration(
                  labelText: 'Chọn cuộc thi',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                items: contests.map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(c.title, overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (val) {
                  ref.read(selectedLeaderboardContestIdProvider.notifier).state = val;
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Lỗi tải danh sách cuộc thi'),
            ),
          ),

          Expanded(
            child: entriesAsync.when(
              data: (entries) {
                if (entries.isEmpty) {
                  return const Center(child: Text('Chưa có dữ liệu xếp hạng.'));
                }

                final podiumEntries = entries.take(3).toList();
                final remainingEntries = entries.skip(3).toList();
                final currentUserEntry = entries.where((e) => e.isCurrentUser).isNotEmpty
                    ? entries.firstWhere((e) => e.isCurrentUser)
                    : null;

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (podiumEntries.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                                child: _Podium(entries: podiumEntries),
                              ),
                            
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? theme.cardColor : Colors.white,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, -5),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                                    child: Row(
                                      children: const [
                                        SizedBox(width: 32, child: Text('#', style: TextStyle(color: Colors.grey, fontSize: 12))),
                                        Expanded(child: Text('Thành viên', style: TextStyle(color: Colors.grey, fontSize: 12))),
                                        SizedBox(width: 60, child: Text('Điểm', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey, fontSize: 12))),
                                        SizedBox(width: 70, child: Text('Nộp lúc', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey, fontSize: 12))),
                                      ],
                                    ),
                                  ),
                                  const Divider(indent: 24, endIndent: 24),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                                    itemCount: remainingEntries.length,
                                    itemBuilder: (context, index) {
                                      final entry = remainingEntries[index];
                                      return _LeaderboardTile(entry: entry);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (currentUserEntry != null && currentUserEntry.rank > 3)
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          border: Border(top: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2))),
                        ),
                        child: _LeaderboardTile(entry: currentUserEntry, isHighlight: true),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Lỗi: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  const _Podium({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (entries.length > 1)
          Expanded(child: _PodiumItem(entry: entries[1], rank: 2, height: 100, color: Colors.grey[400]!)),
        const SizedBox(width: 12),
        if (entries.isNotEmpty)
          Expanded(child: _PodiumItem(entry: entries[0], rank: 1, height: 140, color: Colors.yellow[600]!, isLarge: true)),
        const SizedBox(width: 12),
        if (entries.length > 2)
          Expanded(child: _PodiumItem(entry: entries[2], rank: 3, height: 80, color: Colors.orange[300]!)),
      ],
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final double height;
  final Color color;
  final bool isLarge;

  const _PodiumItem({
    required this.entry,
    required this.rank,
    required this.height,
    required this.color,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarSize = isLarge ? 80.0 : 64.0;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (rank == 1)
              const Positioned(
                top: -30,
                child: Icon(Icons.workspace_premium, color: Colors.yellow, size: 32),
              ),
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 4),
                boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                entry.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _AvatarFallback(size: avatarSize),
              ),
            ),
            Positioned(
              bottom: -12,
              child: Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text('$rank', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(entry.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
        Text('${entry.score} pts', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 12),
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.5), color.withOpacity(0.1)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isHighlight;

  const _LeaderboardTile({required this.entry, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isHighlight ? Colors.transparent : (isDark ? Colors.white.withOpacity(0.05) : theme.scaffoldBackgroundColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '${entry.rank}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isHighlight ? theme.colorScheme.primary : Colors.grey,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isHighlight ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              entry.avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const _AvatarFallback(size: 40),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: TextStyle(
                    fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              '${entry.score}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              entry.submittedAt != null 
                ? '${entry.submittedAt!.hour}:${entry.submittedAt!.minute.toString().padLeft(2, '0')}' 
                : '--:--',
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final double size;
  const _AvatarFallback({required this.size});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      color: theme.colorScheme.primary.withOpacity(0.08),
      alignment: Alignment.center,
      child: Icon(
        Icons.person,
        size: size * 0.45,
        color: theme.colorScheme.primary.withOpacity(0.7),
      ),
    );
  }
}
