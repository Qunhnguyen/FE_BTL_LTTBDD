import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../features/classroom/classroom_providers.dart';
import '../../../../features/classroom/presentation/cubit/classroom_state.dart';
import '../models/subject.dart';
import '../../../auth/models/user.dart';

// Provider lấy danh sách lớp sử dụng Repository chuẩn Clean Architecture
final classroomsProvider = FutureProvider.family<List<dynamic>, String>((ref, subjectId) {
  return ref.watch(classroomRepositoryProvider).getTeacherClassrooms(subjectId);
});

// Provider lấy danh sách sinh viên toàn hệ thống để mời
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
  bool get wantKeepAlive => true;

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
                      onTap: () {
                        context.pushNamed(
                          AppRouteNames.teacherClassroomDetail,
                          pathParameters: {
                            'subjectId': widget.subject.id,
                            'classroomId': cls.id,
                          },
                        );
                      },
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
        title: const Text('Xác nhận xóa lớp học?'),
        content: const Text('Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    
    if (ok == true) {
      await ref.read(classroomCubitProvider.notifier).deleteClassroom(widget.subject.id, classroomId);
      ref.invalidate(classroomsProvider(widget.subject.id));
    }
  }

  void _showAddEditClassroomDialog({dynamic classroom}) {
    showDialog(
      context: context,
      builder: (context) => _ClassroomDialog(
        subjectId: widget.subject.id,
        classroom: classroom,
      ),
    );
  }
}

class _ClassroomCard extends StatelessWidget {
  final dynamic classroom;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onTap;

  const _ClassroomCard({
    required this.classroom,
    required this.onDelete,
    required this.onEdit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text('${classroom.studentCount}', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
        ),
        title: Text(classroom.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          'SV: ${classroom.studentCount == 0 ? "Chưa có sinh viên" : "Nhấn để xem danh sách"}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: onDelete),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _ClassroomDialog extends ConsumerStatefulWidget {
  final String subjectId;
  final dynamic classroom;
  const _ClassroomDialog({required this.subjectId, this.classroom});

  @override
  ConsumerState<_ClassroomDialog> createState() => _ClassroomDialogState();
}

class _ClassroomDialogState extends ConsumerState<_ClassroomDialog> {
  late TextEditingController _nameController;
  late List<String> _selectedIds;
  late List<String> _initialIds;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.classroom?.name);
    _selectedIds = List<String>.from(widget.classroom?.studentIds ?? []);
    _initialIds = List<String>.from(widget.classroom?.studentIds ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(allStudentsProvider);

    return AlertDialog(
      title: Text(widget.classroom == null ? 'Tạo lớp mới' : 'Sửa lớp & Mời sinh viên'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên lớp',
                hintText: 'VD: Lớp Java nâng cao',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Align(alignment: Alignment.centerLeft, child: Text('Danh sách sinh viên:', style: TextStyle(fontWeight: FontWeight.bold))),
            const Divider(),
            Expanded(
              child: studentsAsync.when(
                data: (students) => ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final s = students[index];
                    final isAlreadyIn = _initialIds.contains(s.id);

                    return CheckboxListTile(
                      title: Text(s.name),
                      subtitle: Text(s.email + (isAlreadyIn ? " (Đã trong lớp)" : "")),
                      value: _selectedIds.contains(s.id),
                      onChanged: isAlreadyIn ? null : (val) {
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
          child: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(widget.classroom == null ? 'Lưu' : 'Cập nhật & Mời'),
        ),
      ],
    );
  }

  void _save() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên lớp')));
      return;
    }
    setState(() => _isSaving = true);
    try {
      final notifier = ref.read(classroomCubitProvider.notifier);
      if (widget.classroom == null) {
        // Luồng tạo lớp mới và mời luôn
        await notifier.createClassroom(widget.subjectId, _nameController.text, _selectedIds);
      } else {
        // Luồng cập nhật tên và mời thêm người mới
        if (_nameController.text != widget.classroom!.name) {
          await notifier.updateClassroom(widget.subjectId, widget.classroom!.id, name: _nameController.text);
        }
        final newInvites = _selectedIds.where((id) => !_initialIds.contains(id)).toList();
        if (newInvites.isNotEmpty) {
          await notifier.sendInvites(widget.subjectId, widget.classroom!.id, newInvites);
        }
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
