import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/quiz_history_entry.dart';
import '../providers/quiz_history_provider.dart';

class QuizHistoryScreen extends ConsumerWidget {
  const QuizHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final groupedHistory = ref.watch(groupedHistoryProvider);
    final currentFilter = ref.watch(historyFilterProvider);
    final groupKeys = groupedHistory.keys.toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Expanded(
                        child: Text(
                          'Lịch sử Làm bài',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 48), // Placeholder for balance
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'Tất cả',
                          isSelected: currentFilter == HistoryFilter.all,
                          onTap: () => ref.read(historyFilterProvider.notifier).state = HistoryFilter.all,
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Hoàn thành',
                          isSelected: currentFilter == HistoryFilter.completed,
                          onTap: () => ref.read(historyFilterProvider.notifier).state = HistoryFilter.completed,
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Chưa xong',
                          isSelected: currentFilter == HistoryFilter.inProgress,
                          onTap: () => ref.read(historyFilterProvider.notifier).state = HistoryFilter.inProgress,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: groupKeys.length,
                itemBuilder: (context, index) {
                  final groupKey = groupKeys[index];
                  final items = groupedHistory[groupKey]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        child: Text(
                          groupKey.toUpperCase(),
                          style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                      ),
                      ...items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HistoryCard(entry: item),
                      )),
                    ],
                  );
                },
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

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? theme.colorScheme.primary : (theme.brightness == Brightness.dark ? Colors.white10 : Colors.grey[100]),
        foregroundColor: isSelected ? Colors.white : (theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        elevation: isSelected ? 4 : 0,
        shadowColor: theme.colorScheme.primary.withOpacity(0.3),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final QuizHistoryEntry entry;

  const _HistoryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isCompleted = entry.status == QuizHistoryStatus.completed;
    final scoreValue = entry.score ?? 0;
    bool isLowScore = isCompleted && scoreValue < 5.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isLowScore ? Colors.red : entry.color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(entry.icon, color: isLowScore ? Colors.red : entry.color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(entry.category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isLowScore ? Colors.red : Colors.green).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${scoreValue.toStringAsFixed(scoreValue % 1 == 0 ? 0 : 1)}/${entry.maxScore.toStringAsFixed(entry.maxScore % 1 == 0 ? 0 : 1)}',
                    style: TextStyle(color: isLowScore ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(isCompleted ? Icons.calendar_today : Icons.schedule, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    isCompleted
                        ? '${entry.dateTime.day}/${entry.dateTime.month}/${entry.dateTime.year} • ${entry.dateTime.hour}:${entry.dateTime.minute.toString().padLeft(2, '0')}'
                        : (entry.remainingTime ?? 'Dang cap nhat'),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              Text(
                isCompleted ? 'Hoàn thành' : 'Đang làm',
                style: TextStyle(
                  color: isCompleted ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
