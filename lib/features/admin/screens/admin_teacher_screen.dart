import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/admin_repository.dart';

class AdminTeacherScreen extends ConsumerStatefulWidget {
  const AdminTeacherScreen({super.key});

  @override
  ConsumerState<AdminTeacherScreen> createState() => _AdminTeacherScreenState();
}

class _AdminTeacherScreenState extends ConsumerState<AdminTeacherScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _showTeacherDialog({Map<String, dynamic>? teacher}) {
    if (teacher != null) {
      _nameController.text = teacher['name'] ?? '';
      _emailController.text = teacher['email'] ?? '';
      _passwordController.clear();
    } else {
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(teacher == null ? 'Thêm giảng viên mới' : 'Cập nhật giảng viên'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Họ tên')),
            if (teacher == null)
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            if (teacher == null)
              TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Mật khẩu'), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (teacher == null) {
                await ref.read(adminRepositoryProvider).createTeacher(
                  _emailController.text.trim(),
                  _nameController.text.trim(),
                  _passwordController.text.trim(),
                );
              } else {
                await ref.read(adminRepositoryProvider).updateTeacher(teacher['id'].toString(), {
                  'name': _nameController.text.trim(),
                });
              }
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: Text(teacher == null ? 'Thêm' : 'Cập nhật'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý giảng viên')),
      body: FutureBuilder<List<dynamic>>(
        future: ref.watch(adminRepositoryProvider).getAllTeachers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final teachers = snapshot.data ?? [];
          return ListView.builder(
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final t = teachers[index];
              final isActive = t['active'] ?? true;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                  child: Icon(Icons.person, color: isActive ? Colors.green : Colors.grey),
                ),
                title: Text(t['name'] ?? ''),
                subtitle: Text(t['email'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showTeacherDialog(teacher: t)),
                    IconButton(
                      icon: Icon(isActive ? Icons.block : Icons.check_circle, color: isActive ? Colors.red : Colors.green),
                      onPressed: () async {
                        await ref.read(adminRepositoryProvider).deactivateTeacher(t['id'].toString());
                        setState(() {});
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showTeacherDialog(), child: const Icon(Icons.person_add)),
    );
  }
}
