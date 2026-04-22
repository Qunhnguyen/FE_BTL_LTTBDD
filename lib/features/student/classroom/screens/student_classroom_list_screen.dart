import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tham gia lớp học', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nhập mã mời do giảng viên cung cấp để tham gia vào lớp học mới.', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 20),
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: 'Mã mời (8 ký tự)',
                hintText: 'VD: AB12CD34',
                prefixIcon: const Icon(Icons.vpn_key_outlined),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
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
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Tham gia ngay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(classroomCubitProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    ref.listen(classroomCubitProvider, (previous, next) {
      if (next is ClassroomOperationSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message), 
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else if (next is ClassroomError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message), 
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lớp học của tôi', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _buildBody(state, theme, isDark),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showJoinDialog,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Tham gia lớp học', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBody(ClassroomState state, ThemeData theme, bool isDark) {
    if (state is ClassroomLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<dynamic> displayList = (state is ClassroomLoaded) ? state.classrooms : [];

    if (displayList.isEmpty && state is! ClassroomLoading) {
      return RefreshIndicator(
        onRefresh: () => ref.read(classroomCubitProvider.notifier).fetchStudentClassrooms(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(Icons.class_outlined, size: 80, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 24),
                  const Text('Bạn chưa tham gia lớp học nào', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text('Hãy nhập mã mời để bắt đầu học tập cùng lớp nhé!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: _showJoinDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Tham gia lớp ngay'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: displayList.length,
        itemBuilder: (context, index) {
          final cls = displayList[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
              boxShadow: [
                if (!isDark)
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: InkWell(
              onTap: () => context.pushNamed(AppRouteNames.studentClassroomDetail, pathParameters: {'classroomId': cls.id.toString()}),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                      child: Icon(Icons.class_rounded, color: theme.colorScheme.primary, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cls.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.people_outline, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text('${cls.studentCount} sinh viên', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                              const SizedBox(width: 12),
                              Icon(Icons.key_outlined, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text('Mã: ${cls.inviteCode ?? "N/A"}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
