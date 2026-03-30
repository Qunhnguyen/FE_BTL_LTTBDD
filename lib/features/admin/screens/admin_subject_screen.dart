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
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Tên môn học')),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Mô tả')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final name = _nameController.text.trim();
              final desc = _descController.text.trim();
              if (name.isNotEmpty) {
                if (subject == null) {
                  await ref.read(adminRepositoryProvider).createSubject(name, desc);
                } else {
                  await ref.read(adminRepositoryProvider).updateSubject(subject['id'].toString(), name, desc);
                }
                if (mounted) {
                  Navigator.pop(context);
                  setState(() {});
                }
              }
            },
            child: Text(subject == null ? 'Thêm' : 'Cập nhật'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý môn học')),
      body: FutureBuilder<List<dynamic>>(
        future: ref.watch(adminRepositoryProvider).getAllSubjects(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final subjects = snapshot.data ?? [];
          return ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final s = subjects[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.book)),
                title: Text(s['name'] ?? ''),
                subtitle: Text(s['description'] ?? ''),
                trailing: PopupMenuButton<String>(
                  onSelected: (val) async {
                    if (val == 'edit') {
                      _showSubjectDialog(subject: s);
                    } else if (val == 'delete') {
                      await ref.read(adminRepositoryProvider).deleteSubject(s['id'].toString());
                      setState(() {});
                    } else if (val == 'knowledge') {
                      // Chuyển đến trang nạp kiến thức AI
                      context.push('/admin/subjects/${s['id']}/knowledge', extra: s['name']);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'knowledge', child: ListTile(leading: Icon(Icons.psychology), title: Text('Kiến thức AI'), contentPadding: EdgeInsets.zero)),
                    const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Sửa'), contentPadding: EdgeInsets.zero)),
                    const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Xóa'), contentPadding: EdgeInsets.zero)),
                  ],
                ),
                onTap: () {
                  context.pushNamed(AppRouteNames.adminContests, pathParameters: {'subjectId': s['id'].toString()}, queryParameters: {'name': s['name']});
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showSubjectDialog(), child: const Icon(Icons.add)),
    );
  }
}
