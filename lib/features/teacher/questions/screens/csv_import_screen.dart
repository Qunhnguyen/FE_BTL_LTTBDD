import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../repositories/question_repository.dart';
import '../providers/question_management_provider.dart';

final selectedFilePathProvider = StateProvider<String?>((ref) => null);
final selectedFileNameProvider = StateProvider<String?>((ref) => null);
final isImportingProvider = StateProvider<bool>((ref) => false);

class CsvImportScreen extends ConsumerWidget {
  const CsvImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedPath = ref.watch(selectedFilePathProvider);
    final selectedName = ref.watch(selectedFileNameProvider);
    final isImporting = ref.watch(isImportingProvider);
    final contestId = ref.watch(activeContestIdProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Nhập dữ liệu CSV',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload Questions',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Chọn file CSV để nhập câu hỏi hàng loạt vào cuộc thi. Đảm bảo định dạng file của bạn khớp với mẫu.',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Upload Area
              GestureDetector(
                onTap: isImporting ? null : () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['csv'],
                  );

                  if (result != null) {
                    ref.read(selectedFilePathProvider.notifier).state = result.files.single.path;
                    ref.read(selectedFileNameProvider.notifier).state = result.files.single.name;
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.cloud_upload_outlined, size: 48, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nhấn để tải lên file CSV',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Hỗ trợ file .csv dung lượng lên đến 10MB',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Selected File Info
              if (selectedName != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.description_outlined, color: Colors.green),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Đã sẵn sàng để nhập',
                              style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: isImporting ? null : () {
                          ref.read(selectedFilePathProvider.notifier).state = null;
                          ref.read(selectedFileNameProvider.notifier).state = null;
                        },
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 48),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (selectedPath == null || contestId == null || isImporting) 
                      ? null 
                      : () => _handleImport(context, ref, contestId, selectedPath),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: isImporting 
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text(
                          'Bắt đầu Import vào Contest',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 24),
              Center(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined, size: 20),
                  label: const Text('Tải file CSV mẫu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleImport(BuildContext context, WidgetRef ref, String contestId, String path) async {
    ref.read(isImportingProvider.notifier).state = true;
    
    try {
      await ref.read(questionRepositoryProvider).importQuestionsFromCsv(contestId, path);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã nhập câu hỏi thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(managedQuestionsProvider);
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi nhập file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      ref.read(isImportingProvider.notifier).state = false;
    }
  }
}
