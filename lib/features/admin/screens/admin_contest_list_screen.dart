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
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Tên kỳ thi')),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Mô tả')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'name': _nameController.text.trim(),
                'description': _descController.text.trim(),
                'durationMinutes': 60,
                'startAt': DateTime.now().toIso8601String(),
                'endAt': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
              };
              if (contest == null) {
                await ref.read(adminRepositoryProvider).createContest(widget.subjectId, data);
              } else {
                await ref.read(adminRepositoryProvider).updateContest(widget.subjectId, contest['id'].toString(), data);
              }
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: Text(contest == null ? 'Tạo' : 'Cập nhật'),
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
          title: Text('Quản lý: ${widget.subjectName}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              tooltip: 'AI Builder',
              onPressed: () => context.push('/admin/subjects/${widget.subjectId}/ai-builder'),
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
    return FutureBuilder<List<dynamic>>(
      future: ref.watch(adminRepositoryProvider).getContestsBySubject(widget.subjectId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final contests = snapshot.data ?? [];
        if (contests.isEmpty) return const Center(child: Text('Chưa có bộ đề nào'));
        return Scaffold(
          body: ListView.builder(
            itemCount: contests.length,
            itemBuilder: (context, index) {
              final c = contests[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.quiz)),
                title: Text(c['name'] ?? ''),
                subtitle: Text('Thời lượng: ${c['durationMinutes']} phút'),
                trailing: PopupMenuButton<String>(
                  onSelected: (val) async {
                    if (val == 'edit') _showContestDialog(contest: c);
                    if (val == 'delete') {
                      await ref.read(adminRepositoryProvider).deleteContest(widget.subjectId, c['id'].toString());
                      setState(() {});
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                    const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: Colors.red))),
                  ],
                ),
                onTap: () {
                  context.pushNamed(
                    AppRouteNames.adminQuestions,
                    pathParameters: {'subjectId': widget.subjectId, 'contestId': c['id'].toString()},
                    queryParameters: {'name': c['name']},
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showContestDialog(),
            label: const Text('Tạo bộ đề gốc'),
            icon: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
