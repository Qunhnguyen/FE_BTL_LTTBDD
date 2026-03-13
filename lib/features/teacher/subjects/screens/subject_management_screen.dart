import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subject.dart';
import '../repositories/subject_repository.dart';

final subjectsProvider = FutureProvider<List<Subject>>((ref) async {
  return ref.watch(subjectRepositoryProvider).getSubjects();
});

class SubjectManagementScreen extends ConsumerWidget {
  const SubjectManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Môn học', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () => ref.refresh(subjectsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: subjectsAsync.when(
        data: (subjects) => subjects.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.library_books_outlined, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text('Chưa có môn học nào', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.book)),
                      title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(subject.description ?? 'Không có mô tả'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          await ref.read(subjectRepositoryProvider).deleteSubject(subject.id);
                          ref.refresh(subjectsProvider);
                        },
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSubjectDialog(context, ref),
        label: const Text('Thêm môn học'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm Môn học Mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Tên môn học'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Mô tả'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final newSubject = Subject(
                  id: '', // Backend tự tạo ID
                  name: nameController.text,
                  description: descController.text,
                );
                await ref.read(subjectRepositoryProvider).createSubject(newSubject);
                ref.refresh(subjectsProvider);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}
