import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_history_entry.dart';
import '../providers/quiz_history_provider.dart';

class QuizHistoryScreen extends ConsumerWidget {
  const QuizHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedHistoryAsync = ref.watch(groupedHistoryProvider);
    final currentFilter = ref.watch(historyFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử làm bài', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    label: 'Đang làm',
                    isSelected: currentFilter == HistoryFilter.inProgress,
                    onTap: () => ref.read(historyFilterProvider.notifier).state = HistoryFilter.inProgress,
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: groupedHistoryAsync.when(
              data: (groupedHistory) {
                final groupKeys = groupedHistory.keys.toList();
                if (groupKeys.isEmpty) {
                  return const Center(child: Text('Chưa có lịch sử làm bài.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: groupKeys.length,
                  itemBuilder: (context, index) {
                    final groupKey = groupKeys[index];
                    final items = groupedHistory[groupKey] ?? [];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Text(
                            groupKey.toUpperCase(),
                            style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                          ),
                        ),
                        ...items.map((item) => _HistoryCard(entry: item)),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi: $err')),
            ),
          ),
        ],
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
    final isDark = theme.brightness == Brightness.dark;
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.primary,
      // SỬA: Sử dụng màu chữ phù hợp với chế độ sáng/tối
      labelStyle: TextStyle(
        color: isSelected 
          ? Colors.white 
          : (isDark ? Colors.white70 : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      // Cải thiện màu nền ở chế độ tối
      backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final QuizHistoryEntry entry;
  const _HistoryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = entry.status == QuizHistoryStatus.completed;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: entry.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(entry.icon, color: entry.color),
        ),
        title: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              isCompleted 
                ? 'Đã hoàn thành lúc ${entry.dateTime.hour}:${entry.dateTime.minute.toString().padLeft(2, '0')}' 
                : 'Đang thực hiện',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: isCompleted 
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.score}/${entry.totalQuestions}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: entry.color, fontSize: 16),
                ),
                const Text('Điểm', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            )
          : const Icon(Icons.timer_outlined, color: Colors.orange),
      ),
    );
  }
}
