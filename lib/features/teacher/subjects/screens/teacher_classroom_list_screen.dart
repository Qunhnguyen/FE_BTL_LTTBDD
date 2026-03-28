import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subject.dart';
import '../models/classroom.dart';
import '../repositories/classroom_repository.dart';
import '../../../auth/models/user.dart';

// Provider duy nhất và chuẩn xác cho danh sách lớp
final classroomsProvider = FutureProvider.family<List<Classroom>, String>((ref, subjectId) {
  return ref.watch(classroomRepositoryProvider).getClassroomsBySubject(subjectId);
});

// Provider lấy danh sách sinh viên (chỉ lấy một lần)
final allStudentsProvider = FutureProvider<List<User>>((ref) {
  return ref.watch(classroomRepositoryProvider).getAllStudents();
});

class TeacherClassroomListScreen extends ConsumerStatefulWidget {
  final Subject subject;
  const TeacherClassroomListScreen({super.key, required this.subject});

  @override
  ConsumerState<TeacherClassroomListScreen> createState() => _TeacherClassroomListScreenState();
}

class _TeacherClassroomListScreenState extends ConsumerState<TeacherClassroomListScreen> with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true; // Giữ trạng thái tab, không load lại khi chuyển qua lại

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final classroomsAsync = ref.watch(classroomsProvider(widget.subject.id));

    return Scaffold(
      body: classroomsAsync.when(
        data: (list) => RefreshIndicator(
          onRefresh: () => ref.refresh(classroomsProvider(widget.subject.id).future),
          child: list.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final cls = list[index];
                    return _ClassroomCard(
                      classroom: cls,
                      onDelete: () => _handleDelete(cls.id),
                      onEdit: () => _showAddEditClassroomDialog(classroom: cls),
                    );
                  },
                ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditClassroomDialog(),
        label: const Text('Tạo lớp mới'),
        icon: const Icon(Icons.group_add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        const Center(
          child: Column(
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Chưa có lớp học nào.', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  void _handleDelete(String classroomId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lớp học?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    
    if (ok == true) {
      await ref.read(classroomRepositoryProvider).deleteClassroom(widget.subject.id, classroomId);
      ref.invalidate(classroomsProvider(widget.subject.id));
    }
  }

  void _showAddEditClassroomDialog({Classroom? classroom}) {
    showDialog(
      context: context,
      builder: (context) => _ClassroomDialog(
        subjectId: widget.subject.id,
        classroom: classroom,
      ),
    );
  }
}

// Widget Card tách riêng để tối ưu performance
class _ClassroomCard extends StatelessWidget {
  final Classroom classroom;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ClassroomCard({required this.classroom, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Text('${classroom.studentCount}')),
        title: Text(classroom.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          'SV: ${classroom.students.map((s) => s.name).join(", ")}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: onDelete),
        onTap: onEdit,
      ),
    );
  }
}

// Widget Dialog tách riêng để tránh lag màn hình chính
class _ClassroomDialog extends ConsumerStatefulWidget {
  final String subjectId;
  final Classroom? classroom;
  const _ClassroomDialog({required this.subjectId, this.classroom});

  @override
  ConsumerState<_ClassroomDialog> createState() => _ClassroomDialogState();
}

class _ClassroomDialogState extends ConsumerState<_ClassroomDialog> {
  late TextEditingController _nameController;
  late List<String> _selectedIds;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.classroom?.name);
    _selectedIds = List.from(widget.classroom?.studentIds ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(allStudentsProvider);

    return AlertDialog(
      title: Text(widget.classroom == null ? 'Tạo lớp mới' : 'Sửa lớp học'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Tên lớp')),
            const SizedBox(height: 16),
            Expanded(
              child: studentsAsync.when(
                data: (students) => ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final s = students[index];
                    return CheckboxListTile(
                      title: Text(s.name),
                      value: _selectedIds.contains(s.id),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) _selectedIds.add(s.id);
                          else _selectedIds.remove(s.id);
                        });
                      },
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Lỗi tải SV: $err'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Lưu'),
        ),
      ],
    );
  }

  void _save() async {
    if (_nameController.text.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(classroomRepositoryProvider);
      if (widget.classroom == null) {
        await repo.createClassroom(widget.subjectId, _nameController.text, _selectedIds);
      } else {
        await repo.updateClassroom(widget.subjectId, widget.classroom!.id, _nameController.text, _selectedIds);
      }
      ref.invalidate(classroomsProvider(widget.subjectId));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }
}
