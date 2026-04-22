import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/leaderboard_entry.dart';
import '../providers/leaderboard_provider.dart';
import '../../../teacher/subjects/providers/subject_providers.dart';
import '../../quiz/providers/quiz_provider.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  String? _selectedSubjectId;
  String? _selectedQuizId;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Đồng bộ với Provider nếu có dữ liệu từ bài thi vừa làm
    if (!_isInitialized) {
      final contestId = ref.watch(selectedLeaderboardContestIdProvider);
      if (contestId != null) {
        _selectedQuizId = contestId;
        // Chúng ta chưa có subjectId ở đây, nhưng UI sẽ tự động load khi subjectsProvider hoàn tất
      }
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Lắng nghe danh sách môn học
    final subjectsAsync = ref.watch(subjectsProvider);
    
    // Lấy contestId từ provider (dành cho trường hợp vừa thi xong)
    final contestIdFromProvider = ref.watch(selectedLeaderboardContestIdProvider);
    
    // Đồng bộ local state với provider nếu cần
    if (contestIdFromProvider != null && _selectedQuizId != contestIdFromProvider) {
       _selectedQuizId = contestIdFromProvider;
    }

    // Lấy danh sách Quiz nếu đã chọn môn
    final quizzesAsync = _selectedSubjectId != null 
        ? ref.watch(studentQuizListProvider(_selectedSubjectId!))
        : const AsyncValue.data([]);

    // Lấy bảng xếp hạng theo Quiz được chọn
    final entriesAsync = _selectedQuizId != null 
        ? ref.watch(leaderboardEntriesProvider)
        : const AsyncValue<List<LeaderboardEntry>>.data([]);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: context.canPop() ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ) : null,
        title: const Text('Bảng xếp hạng', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // DROPDOWN MÔN HỌC
                subjectsAsync.when(
                  data: (subjects) {
                    return DropdownButtonFormField<String>(
                      value: _selectedSubjectId,
                      hint: const Text('Chọn môn học'),
                      items: subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedSubjectId = val;
                          _selectedQuizId = null; // Reset quiz khi đổi môn
                          ref.read(selectedLeaderboardContestIdProvider.notifier).state = null;
                        });
                      },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Lỗi tải môn học'),
                ),
                const SizedBox(height: 8),
                
                // DROPDOWN BÀI THI (QUIZ)
                quizzesAsync.when(
                  data: (quizzes) {
                    // Tự động chọn Quiz nếu nó nằm trong danh sách của môn này
                    bool containsSelected = quizzes.any((q) => q['id'].toString() == _selectedQuizId);
                    
                    return DropdownButtonFormField<String>(
                      value: containsSelected ? _selectedQuizId : null,
                      hint: const Text('Chọn bài thi (Quiz)'),
                      items: quizzes.map<DropdownMenuItem<String>>((q) => DropdownMenuItem(
                        value: q['id'].toString(), 
                        child: Text(q['name'] ?? '')
                      )).toList(),
                      onChanged: (val) {
                        setState(() => _selectedQuizId = val);
                        if (val != null) {
                          ref.read(selectedLeaderboardContestIdProvider.notifier).state = val;
                        }
                      },
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: _selectedQuizId == null 
              ? const Center(child: Text('Vui lòng chọn một bài thi để xem xếp hạng'))
              : entriesAsync.when(
                  data: (entries) {
                    if (entries.isEmpty) {
                      return const Center(child: Text('Chưa có dữ liệu xếp hạng cho bài thi này.'));
                    }

                    final podiumEntries = entries.take(3).toList();
                    final remainingEntries = entries.skip(3).toList();

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
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                                    itemCount: remainingEntries.length,
                                    itemBuilder: (context, index) => _LeaderboardTile(entry: remainingEntries[index]),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
        if (entries.length > 1) Expanded(child: _PodiumItem(entry: entries[1], rank: 2, height: 100, color: Colors.grey[400]!)),
        const SizedBox(width: 12),
        if (entries.isNotEmpty) Expanded(child: _PodiumItem(entry: entries[0], rank: 1, height: 140, color: Colors.yellow[600]!, isLarge: true)),
        const SizedBox(width: 12),
        if (entries.length > 2) Expanded(child: _PodiumItem(entry: entries[2], rank: 3, height: 80, color: Colors.orange[300]!)),
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
  const _PodiumItem({required this.entry, required this.rank, required this.height, required this.color, this.isLarge = false});
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
            if (rank == 1) const Positioned(top: -30, child: Icon(Icons.workspace_premium, color: Colors.yellow, size: 32)),
            Container(
              width: avatarSize, height: avatarSize,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 4)),
              clipBehavior: Clip.antiAlias,
              child: entry.avatarUrl.isNotEmpty 
                ? Image.network(entry.avatarUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _AvatarFallback(size: avatarSize, name: entry.name))
                : _AvatarFallback(size: avatarSize, name: entry.name),
            ),
            Positioned(bottom: -12, child: Container(width: 24, height: 24, alignment: Alignment.center, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), child: Text('$rank', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)))),
          ],
        ),
        const SizedBox(height: 20),
        Text(entry.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
        Text('${entry.score} pts', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 12),
        Container(height: height, decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withOpacity(0.5), color.withOpacity(0.1)], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: const BorderRadius.vertical(top: Radius.circular(12)))),
      ],
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  const _LeaderboardTile({required this.entry});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          SizedBox(width: 32, child: Text('${entry.rank}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          CircleAvatar(
            radius: 20, 
            backgroundImage: entry.avatarUrl.isNotEmpty ? NetworkImage(entry.avatarUrl) : null,
            child: entry.avatarUrl.isEmpty ? Text(entry.name.characters.first.toUpperCase()) : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(entry.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
          Text('${entry.score}', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final double size;
  final String name;
  const _AvatarFallback({required this.size, required this.name});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, 
      height: size, 
      color: Colors.blue.withOpacity(0.1), 
      alignment: Alignment.center, 
      child: Text(
        name.isNotEmpty ? name.characters.first.toUpperCase() : '?',
        style: TextStyle(fontSize: size * 0.4, fontWeight: FontWeight.bold, color: Colors.blue),
      )
    );
  }
}
