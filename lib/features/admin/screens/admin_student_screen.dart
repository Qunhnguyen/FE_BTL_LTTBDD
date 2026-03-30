import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/admin_repository.dart';

class AdminStudentScreen extends ConsumerStatefulWidget {
  const AdminStudentScreen({super.key});

  @override
  ConsumerState<AdminStudentScreen> createState() => _AdminStudentScreenState();
}

class _AdminStudentScreenState extends ConsumerState<AdminStudentScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _showStudentDialog({Map<String, dynamic>? student}) {
    if (student != null) {
      _nameController.text = student['name'] ?? '';
      _emailController.text = student['email'] ?? '';
      _passwordController.clear();
    } else {
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(student == null ? 'Thêm sinh viên mới' : 'Cập nhật sinh viên'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Họ tên')),
            if (student == null)
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            if (student == null)
              TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Mật khẩu'), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (student == null) {
                await ref.read(adminRepositoryProvider).createStudent(
                  _emailController.text.trim(),
                  _nameController.text.trim(),
                  _passwordController.text.trim(),
                );
              } else {
                await ref.read(adminRepositoryProvider).updateStudent(student['id'].toString(), {
                  'name': _nameController.text.trim(),
                });
              }
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: Text(student == null ? 'Thêm' : 'Cập nhật'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý sinh viên')),
      body: FutureBuilder<List<dynamic>>(
        future: ref.watch(adminRepositoryProvider).getAllStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final students = snapshot.data ?? [];
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final s = students[index];
              final isActive = s['active'] ?? true;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isActive ? Colors.orange.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                  child: Icon(Icons.school, color: isActive ? Colors.orange : Colors.grey),
                ),
                title: Text(s['name'] ?? ''),
                subtitle: Text(s['email'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showStudentDialog(student: s)),
                    IconButton(
                      icon: Icon(isActive ? Icons.block : Icons.check_circle, color: isActive ? Colors.red : Colors.green),
                      onPressed: () async {
                        await ref.read(adminRepositoryProvider).deactivateStudent(s['id'].toString());
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
      floatingActionButton: FloatingActionButton(onPressed: () => _showStudentDialog(), child: const Icon(Icons.person_add_alt_1)),
    );
  }
}
