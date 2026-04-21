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

    // Listen for success messages
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
            const SizedBox(height: 20),
            _buildSectionTitle('Mã mời tham gia'),
            _buildInviteCodeCard(classroom),
            const SizedBox(height: 20),
            _buildSectionTitle('Sinh viên (${classroom.studentCount})'),
            _buildStudentList(classroom),
            const SizedBox(height: 20),
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
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoCard(dynamic classroom) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(Icons.class_, size: 30, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classroom.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${classroom.id}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteCodeCard(dynamic classroom) {
    return Card(
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classroom.inviteCode,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.blue,
                  ),
                ),
                const Text('Chia sẻ mã này để sinh viên tự tham gia'),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.blue),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: classroom.inviteCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã sao chép mã mời')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.orange),
                  onPressed: () => _confirmRegenerateCode(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentList(dynamic classroom) {
    if (classroom.students.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('Chưa có sinh viên nào trong lớp')),
        ),
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
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(student.name),
            subtitle: Text(student.email),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () => _confirmRemoveStudent(student),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContestList(dynamic classroom) {
    if (classroom.assignedContests.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('Chưa có bài kiểm tra nào được giao cho lớp này')),
        ),
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
          child: ListTile(
            leading: const Icon(Icons.quiz, color: Colors.orange),
            title: Text(contest.name),
            subtitle: Text('${contest.durationMinutes} phút | ${contest.computedStatus}'),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }

  void _showInviteStudentsDialog(dynamic classroom) async {
    // Sử dụng repository mới từ module Classroom
    final repo = ref.read(classroomRepositoryProvider);
    final allStudents = await repo.getAllStudents();
    
    // Lọc bỏ những sinh viên đã có trong lớp
    final List<String> existingIds = List<String>.from(classroom.studentIds);
    final availableStudents = allStudents.where((s) => !existingIds.contains(s.id)).toList();

    if (!mounted) return;

    List<String> selectedIds = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Mời sinh viên vào lớp'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: availableStudents.isEmpty
                ? const Center(child: Text('Tất cả sinh viên đã có mặt trong lớp'))
                : ListView.builder(
                    itemCount: availableStudents.length,
                    itemBuilder: (context, index) {
                      final s = availableStudents[index];
                      return CheckboxListTile(
                        title: Text(s.name),
                        subtitle: Text(s.email),
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
        content: const Text('Mã cũ sẽ không còn hiệu lực. Sinh viên chưa tham gia sẽ cần mã mới.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(classroomCubitProvider.notifier).regenerateInviteCode(widget.subjectId, widget.classroomId);
            },
            child: const Text('Đổi mã', style: TextStyle(color: Colors.orange)),
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
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
