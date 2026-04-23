import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../teacher/subjects/models/subject.dart';
import '../../teacher/subjects/screens/quiz_management_screen.dart';
import '../repositories/admin_repository.dart';

class AdminContestListScreen extends ConsumerStatefulWidget {
  final String subjectId;
  final String subjectName;

  const AdminContestListScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  ConsumerState<AdminContestListScreen> createState() => _AdminContestListScreenState();
}

class _AdminContestListScreenState extends ConsumerState<AdminContestListScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _showContestDialog({Map<String, dynamic>? contest}) {
    if (contest != null) {
      _nameController.text = contest['name'] ?? '';
      _descController.text = contest['description'] ?? '';
    } else {
      _nameController.clear();
      _descController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(contest == null ? 'Tạo kỳ thi gốc (Contest)' : 'Cập nhật kỳ thi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên kỳ thi',
                prefixIcon: Icon(Icons.quiz_outlined),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: _isSaving
                ? null
                : () async {
              final name = _nameController.text.trim();
              if (name.isEmpty) {
                return;
              }
              setState(() => _isSaving = true);
              final data = {
                'name': name,
                'description': _descController.text.trim(),
                'durationMinutes': 60,
                'startAt': DateTime.now().toIso8601String(),
                'endAt': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
              };
              try {
                if (contest == null) {
                  await ref.read(adminRepositoryProvider).createContest(widget.subjectId, data);
                } else {
                  await ref.read(adminRepositoryProvider).updateContest(widget.subjectId, contest['id'].toString(), data);
                }
                if (!context.mounted) return;
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(contest == null ? 'Đã tạo kỳ thi' : 'Đã cập nhật kỳ thi')),
                );
              } finally {
                if (mounted) {
                  setState(() => _isSaving = false);
                }
              }
            },
            child: Text(_isSaving ? 'Đang lưu...' : contest == null ? 'Tạo' : 'Cập nhật'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Môn học: ${widget.subjectName}'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              tooltip: 'AI Builder',
              onPressed: () => context.pushNamed(
                AppRouteNames.adminAiBuilder,
                pathParameters: {'subjectId': widget.subjectId},
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Bộ đề gốc'),
              Tab(icon: Icon(Icons.rocket_launch_outlined), text: 'Quiz Public'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildContestTab(),
            // Dùng chung màn hình quản lý Quiz với Teacher nhưng Role Admin sẽ tự tạo Public Quiz
            QuizManagementScreen(subject: Subject(id: widget.subjectId, name: widget.subjectName)),
          ],
        ),
      ),
    );
  }

  Widget _buildContestTab() {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: FutureBuilder<List<dynamic>>(
          future: ref.watch(adminRepositoryProvider).getContestsBySubject(widget.subjectId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final contests = snapshot.data ?? [];
            if (contests.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 140),
                  Icon(Icons.inventory_2_outlined, size: 52, color: Colors.grey),
                  SizedBox(height: 8),
                  Center(child: Text('Chưa có bộ đề gốc nào')),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: contests.length,
              itemBuilder: (context, index) {
                final c = contests[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                      child: Icon(Icons.quiz_outlined, color: Theme.of(context).colorScheme.primary),
                    ),
                    title: Text(c['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Thời lượng: ${c['durationMinutes'] ?? 60} phút'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (val) async {
                        if (val == 'edit') _showContestDialog(contest: c);
                        if (val == 'delete') {
                          await ref.read(adminRepositoryProvider).deleteContest(widget.subjectId, c['id'].toString());
                          if (mounted) {
                            setState(() {});
                          }
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Sửa')),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Xóa', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                    onTap: () => context.pushNamed(
                      AppRouteNames.adminQuestions,
                      pathParameters: {
                        'subjectId': widget.subjectId,
                        'contestId': c['id'].toString(),
                      },
                      queryParameters: {'name': c['name'] ?? 'Kỳ thi'},
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showContestDialog(),
        label: const Text('Tạo bộ đề gốc'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
