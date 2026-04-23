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
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Họ tên', prefixIcon: Icon(Icons.badge_outlined)),
            ),
            if (teacher == null)
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
              ),
            if (teacher == null)
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
            onPressed: _isSaving ? null : () async {
              final name = _nameController.text.trim();
              if (name.isEmpty) return;
              setState(() => _isSaving = true);
              try {
              if (teacher == null) {
                await ref.read(adminRepositoryProvider).createTeacher(
                  _emailController.text.trim(),
                  name,
                  _passwordController.text.trim(),
                );
              } else {
                await ref.read(adminRepositoryProvider).updateTeacher(teacher['id'].toString(), {
                  'name': name,
                });
              }
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(teacher == null ? 'Đã thêm giảng viên' : 'Đã cập nhật giảng viên')),
                );
              }
              } finally {
                if (mounted) setState(() => _isSaving = false);
              }
            },
            child: Text(_isSaving ? 'Đang lưu...' : teacher == null ? 'Thêm' : 'Cập nhật'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý giảng viên'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: FutureBuilder<List<dynamic>>(
          future: ref.watch(adminRepositoryProvider).getAllTeachers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            final teachers = snapshot.data ?? [];
            if (teachers.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 140),
                  Icon(Icons.groups_outlined, size: 52, color: Colors.grey),
                  SizedBox(height: 8),
                  Center(child: Text('Chưa có giảng viên nào')),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: teachers.length,
              itemBuilder: (context, index) {
                final t = teachers[index];
                final isActive = t['active'] ?? true;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    leading: CircleAvatar(
                      backgroundColor: isActive ? Colors.green.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.12),
                      child: Icon(Icons.person_outline, color: isActive ? Colors.green : Colors.grey),
                    ),
                    title: Text(t['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(t['email'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue), onPressed: () => _showTeacherDialog(teacher: t)),
                        IconButton(
                          icon: Icon(isActive ? Icons.block : Icons.check_circle, color: isActive ? Colors.red : Colors.green),
                          onPressed: () async {
                            await ref.read(adminRepositoryProvider).deactivateTeacher(t['id'].toString());
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
        onPressed: () => _showTeacherDialog(),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Thêm GV'),
      ),
    );
  }
}
