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
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Họ tên', prefixIcon: Icon(Icons.badge_outlined)),
            ),
            if (student == null)
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
              ),
            if (student == null)
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mật khẩu', prefixIcon: Icon(Icons.lock_outline)),
                obscureText: true,
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
              if (name.isEmpty) return;
              setState(() => _isSaving = true);
              try {
              if (student == null) {
                await ref.read(adminRepositoryProvider).createStudent(
                  _emailController.text.trim(),
                  name,
                  _passwordController.text.trim(),
                );
              } else {
                await ref.read(adminRepositoryProvider).updateStudent(student['id'].toString(), {
                  'name': name,
                });
              }
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(student == null ? 'Đã thêm sinh viên' : 'Đã cập nhật sinh viên')),
                );
              }
              } finally {
                if (mounted) setState(() => _isSaving = false);
              }
            },
            child: Text(_isSaving ? 'Đang lưu...' : student == null ? 'Thêm' : 'Cập nhật'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý sinh viên'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: FutureBuilder<List<dynamic>>(
          future: ref.watch(adminRepositoryProvider).getAllStudents(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            final students = snapshot.data ?? [];
            if (students.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 140),
                  Icon(Icons.school_outlined, size: 52, color: Colors.grey),
                  SizedBox(height: 8),
                  Center(child: Text('Chưa có sinh viên nào')),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final s = students[index];
                final isActive = s['active'] ?? true;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    leading: CircleAvatar(
                      backgroundColor: isActive ? Colors.orange.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.12),
                      child: Icon(Icons.school_outlined, color: isActive ? Colors.orange : Colors.grey),
                    ),
                    title: Text(s['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(s['email'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue), onPressed: () => _showStudentDialog(student: s)),
                        IconButton(
                          icon: Icon(isActive ? Icons.block : Icons.check_circle, color: isActive ? Colors.red : Colors.green),
                          onPressed: () async {
                            await ref.read(adminRepositoryProvider).deactivateStudent(s['id'].toString());
                            if (mounted) setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStudentDialog(),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Thêm SV'),
      ),
    );
  }
}
