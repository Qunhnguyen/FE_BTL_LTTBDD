import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../repositories/admin_repository.dart';

class AdminSubjectScreen extends ConsumerStatefulWidget {
  const AdminSubjectScreen({super.key});

  @override
  ConsumerState<AdminSubjectScreen> createState() => _AdminSubjectScreenState();
}

class _AdminSubjectScreenState extends ConsumerState<AdminSubjectScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _showSubjectDialog({Map<String, dynamic>? subject}) {
    if (subject != null) {
      _nameController.text = subject['name'] ?? '';
      _descController.text = subject['description'] ?? '';
    } else {
      _nameController.clear();
      _descController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(subject == null ? 'Thêm môn học mới' : 'Cập nhật môn học'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên môn học',
                prefixIcon: Icon(Icons.menu_book_outlined),
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
              final desc = _descController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tên môn học không được để trống')),
                );
                return;
              }
              setState(() => _isSaving = true);
              try {
                if (subject == null) {
                  await ref.read(adminRepositoryProvider).createSubject(
                    name,
                    desc,
                  );
                } else {
                  await ref.read(adminRepositoryProvider).updateSubject(
                    subject['id'].toString(),
                    name,
                    desc,
                  );
                }
                if (!context.mounted) return;
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(subject == null ? 'Đã thêm môn học' : 'Đã cập nhật môn học'),
                  ),
                );
              } finally {
                if (mounted) {
                  setState(() => _isSaving = false);
                }
              }
            },
            child: Text(_isSaving ? 'Đang lưu...' : subject == null ? 'Thêm' : 'Cập nhật'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý môn học'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: FutureBuilder<List<dynamic>>(
          future: ref.watch(adminRepositoryProvider).getAllSubjects(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final subjects = snapshot.data ?? [];
            if (subjects.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 140),
                  Icon(Icons.menu_book_outlined, size: 52, color: Colors.grey),
                  SizedBox(height: 8),
                  Center(child: Text('Chưa có môn học nào')),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final s = subjects[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                      child: Icon(Icons.menu_book_rounded, color: Theme.of(context).colorScheme.primary),
                    ),
                    title: Text(s['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text((s['description'] ?? '').toString().trim().isEmpty ? 'Chưa có mô tả' : s['description']),
                    trailing: PopupMenuButton<String>(
                      onSelected: (val) async {
                        if (val == 'edit') {
                          _showSubjectDialog(subject: s);
                        } else if (val == 'delete') {
                          await ref.read(adminRepositoryProvider).deleteSubject(s['id'].toString());
                          if (mounted) {
                            setState(() {});
                          }
                        } else if (val == 'knowledge') {
                          context.pushNamed(
                            AppRouteNames.adminKnowledge,
                            pathParameters: {'subjectId': s['id'].toString()},
                            queryParameters: {'name': s['name'] ?? 'Môn học'},
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'knowledge',
                          child: ListTile(
                            leading: Icon(Icons.psychology_outlined),
                            title: Text('Kiến thức AI'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Sửa'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete_outline, color: Colors.red),
                            title: Text('Xóa'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => context.pushNamed(
                      AppRouteNames.adminContests,
                      pathParameters: {'subjectId': s['id'].toString()},
                      queryParameters: {'name': s['name']},
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSubjectDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm môn'),
      ),
    );
  }
}
