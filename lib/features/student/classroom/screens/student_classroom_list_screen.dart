import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../classroom/classroom_providers.dart';
import '../../../classroom/presentation/cubit/classroom_state.dart';

class StudentClassroomListScreen extends ConsumerStatefulWidget {
  const StudentClassroomListScreen({super.key});

  @override
  ConsumerState<StudentClassroomListScreen> createState() => _StudentClassroomListScreenState();
}

class _StudentClassroomListScreenState extends ConsumerState<StudentClassroomListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(classroomCubitProvider.notifier).fetchStudentClassrooms();
    });
  }

  void _showJoinDialog() {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tham gia lớp học'),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(
            labelText: 'Mã mời (8 ký tự)',
            hintText: 'VD: AB12CD34',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final code = codeController.text.trim();
              if (code.isNotEmpty) {
                Navigator.pop(context);
                ref.read(classroomCubitProvider.notifier).joinByCode(code);
              }
            },
            child: const Text('Tham gia'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(classroomCubitProvider);

    // Listen for success/error messages
    ref.listen(classroomCubitProvider, (previous, next) {
      if (next is ClassroomOperationSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.green),
        );
      } else if (next is ClassroomError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lớp học của tôi', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showJoinDialog,
        label: const Text('Tham gia lớp'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(ClassroomState state) {
    if (state is ClassroomLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ClassroomLoaded || state is ClassroomOperationSuccess || state is ClassroomInitial) {
      final List<dynamic> classrooms = (state is ClassroomLoaded) 
          ? state.classrooms 
          : (state is ClassroomOperationSuccess ? (previousClassrooms ?? []) : []);
      
      // Note: We might need to handle persistent list in State properly.
      // For now, let's just use what's in the state.
      final displayList = (state is ClassroomLoaded) ? state.classrooms : [];

      if (displayList.isEmpty && state is! ClassroomLoading) {
        return RefreshIndicator(
          onRefresh: () => ref.read(classroomCubitProvider.notifier).fetchStudentClassrooms(),
          child: ListView(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.3),
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.class_outlined, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Bạn chưa tham gia lớp học nào', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Hãy nhập mã mời để tham gia ngay!', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => ref.read(classroomCubitProvider.notifier).fetchStudentClassrooms(),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: displayList.length,
          itemBuilder: (context, index) {
            final cls = displayList[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Icon(Icons.class_, color: Theme.of(context).primaryColor),
                ),
                title: Text(cls.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text('ID: ${cls.id} • ${cls.studentCount} sinh viên'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Optional: Navigate to student classroom detail if needed
                },
              ),
            );
          },
        ),
      );
    }

    if (state is ClassroomError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Lỗi: ${state.message}'),
            ElevatedButton(
              onPressed: () => ref.read(classroomCubitProvider.notifier).fetchStudentClassrooms(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  // Helper to keep track of classrooms during operation success
  List<dynamic>? get previousClassrooms {
    // This is a simplified approach. In a real app, 
    // State should probably contain the list and the status separately.
    return null;
  }
}
