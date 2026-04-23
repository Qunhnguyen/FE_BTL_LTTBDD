import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/classroom/classroom_providers.dart';
import '../../../../features/classroom/presentation/cubit/classroom_state.dart';

class TeacherClassroomDetailScreen extends ConsumerStatefulWidget {
  final String subjectId;
  final String classroomId;

  const TeacherClassroomDetailScreen({
    super.key,
    required this.subjectId,
    required this.classroomId,
  });

  @override
  ConsumerState<TeacherClassroomDetailScreen> createState() => _TeacherClassroomDetailScreenState();
}

class _TeacherClassroomDetailScreenState extends ConsumerState<TeacherClassroomDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(classroomCubitProvider.notifier).fetchClassroomDetail(widget.subjectId, widget.classroomId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(classroomCubitProvider);

    ref.listen(classroomCubitProvider, (previous, next) {
      if (next is ClassroomOperationSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.green),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết lớp học'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: state is ClassroomDetailLoaded ? () => _showInviteStudentsDialog(state.classroom) : null,
            tooltip: 'Mời sinh viên',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(classroomCubitProvider.notifier).fetchClassroomDetail(widget.subjectId, widget.classroomId),
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(ClassroomState state) {
    if (state is ClassroomLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ClassroomError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: () => ref.read(classroomCubitProvider.notifier).fetchClassroomDetail(widget.subjectId, widget.classroomId),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    } else if (state is ClassroomDetailLoaded) {
      final classroom = state.classroom;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(classroom),
            const SizedBox(height: 24),
            _buildSectionTitle('Mã mời tham gia'),
            _buildInviteCodeCard(classroom),
            const SizedBox(height: 24),
            _buildSectionTitle('Sinh viên (${classroom.studentCount})'),
            _buildStudentList(classroom),
            const SizedBox(height: 24),
            _buildSectionTitle('Bài kiểm tra đã giao'),
            _buildContestList(classroom),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoCard(dynamic classroom) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(Icons.class_, size: 28, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classroom.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID Lớp: ${classroom.id}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteCodeCard(dynamic classroom) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // SỬA LỖI TRÀN VIỀN: Dùng Expanded bao bọc text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classroom.inviteCode ?? 'CHƯA CÓ MÃ',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Chia sẻ mã mời này để sinh viên tự tham gia vào lớp',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Các nút thao tác
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.copy_rounded, color: theme.colorScheme.primary, size: 22),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: classroom.inviteCode ?? ''));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã sao chép mã mời')));
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.autorenew_rounded, color: Colors.orange, size: 22),
                onPressed: () => _confirmRegenerateCode(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(dynamic classroom) {
    if (classroom.students == null || (classroom.students as List).isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Text('Chưa có sinh viên nào trong lớp', style: TextStyle(color: Colors.grey, fontSize: 13))),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: classroom.students.length,
      itemBuilder: (context, index) {
        final student = classroom.students[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withOpacity(0.1))),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: Text(student.name[0], style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
            title: Text(student.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text(student.email, style: const TextStyle(fontSize: 12)),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
              onPressed: () => _confirmRemoveStudent(student),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContestList(dynamic classroom) {
    if (classroom.assignedContests == null || (classroom.assignedContests as List).isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Text('Chưa có bài thi nào được giao', style: TextStyle(color: Colors.grey, fontSize: 13))),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: classroom.assignedContests.length,
      itemBuilder: (context, index) {
        final contest = classroom.assignedContests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withOpacity(0.1))),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.quiz_outlined, color: Colors.orange, size: 20),
            ),
            title: Text(contest.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text('${contest.durationMinutes} phút | ${contest.computedStatus}', style: const TextStyle(fontSize: 11)),
            trailing: const Icon(Icons.chevron_right, size: 18),
          ),
        );
      },
    );
  }

  void _showInviteStudentsDialog(dynamic classroom) async {
    final repo = ref.read(classroomRepositoryProvider);
    List<dynamic> availableStudents = [];
    try {
      final allStudents = await repo.getAllStudents();
      final List<String> existingIds = List<String>.from(classroom.studentIds ?? []);
      availableStudents = allStudents.where((s) => !existingIds.contains(s.id)).toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tải được danh sách sinh viên: $e'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    if (!mounted) return;
    List<String> selectedIds = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Mời sinh viên', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: availableStudents.isEmpty
                ? const Center(child: Text('Tất cả sinh viên đã có mặt'))
                : ListView.builder(
                    itemCount: availableStudents.length,
                    itemBuilder: (context, index) {
                      final s = availableStudents[index];
                      return CheckboxListTile(
                        title: Text(s.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        subtitle: Text(s.email, style: const TextStyle(fontSize: 12)),
                        value: selectedIds.contains(s.id),
                        onChanged: (val) {
                          setDialogState(() {
                            if (val == true) selectedIds.add(s.id);
                            else selectedIds.remove(s.id);
                          });
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: selectedIds.isEmpty ? null : () {
                Navigator.pop(context);
                ref.read(classroomCubitProvider.notifier).sendInvites(widget.subjectId, widget.classroomId, selectedIds);
              },
              child: const Text('Gửi lời mời'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRegenerateCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi mã mời?'),
        content: const Text('Mã cũ sẽ không còn hiệu lực. Sinh viên chưa tham gia sẽ cần mã mới để vào lớp.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(classroomCubitProvider.notifier).regenerateInviteCode(widget.subjectId, widget.classroomId);
            },
            child: const Text('Đổi mã', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveStudent(dynamic student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sinh viên?'),
        content: Text('Bạn có chắc chắn muốn xóa ${student.name} khỏi lớp học này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(classroomCubitProvider.notifier).removeStudent(widget.subjectId, widget.classroomId, student.id);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
