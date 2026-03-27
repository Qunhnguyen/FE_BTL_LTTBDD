import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/models/user.dart';
import '../../../auth/providers/auth_provider.dart';

class StudentProfileScreen extends ConsumerStatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  ConsumerState<StudentProfileScreen> createState() =>
      _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> {
  static const int _maxAvatarBytes = 5 * 1024 * 1024;
  static const Set<String> _allowedImageExtensions = {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp',
    'heic',
    'heif',
  };

  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _imagePicker = ImagePicker();

  bool _isSavingProfile = false;
  bool _isUploadingAvatar = false;
  String? _syncedUserId;
  String? _syncedUserName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).ensureCurrentUser();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    _syncFormWithUser(user);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cá nhân',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: user == null
            ? _buildEmptyState(context, authState.status == AuthStatus.initial)
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileAvatarSection(
                      user: user,
                      theme: theme,
                      isUploading: _isUploadingAvatar,
                    ),
                    const SizedBox(height: 24),
                    _SectionCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Bạn chỉ có thể cập nhật tên và ảnh đại diện. Nhấn "Chỉnh sửa thông tin" để mở form cập nhật tên.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionCard(
                      child: Column(
                        children: [
                          _buildProfileOption(
                            context: context,
                            icon: Icons.person_outline,
                            label: 'Chỉnh sửa thông tin',
                            subtitle: 'Cập nhật họ và tên',
                            onTap: () => _showEditProfileSheet(user),
                          ),
                          const Divider(height: 20),
                          _buildProfileOption(
                            context: context,
                            icon: Icons.photo_camera_outlined,
                            label: 'Đổi ảnh đại diện',
                            subtitle: _isUploadingAvatar
                                ? 'Đang tải ảnh lên...'
                                : 'Chọn ảnh từ thư viện',
                            onTap: _isUploadingAvatar
                                ? null
                                : _pickAndUploadAvatar,
                            trailing: _isUploadingAvatar
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.chevron_right),
                          ),
                          const Divider(height: 20),
                          _buildProfileOption(
                            context: context,
                            icon: Icons.email_outlined,
                            label: 'Email',
                            subtitle: user.email,
                            onTap: null,
                          ),
                          const Divider(height: 20),
                          _buildProfileOption(
                            context: context,
                            icon: Icons.badge_outlined,
                            label: 'Vai trò',
                            subtitle: user.role == 'TEACHER'
                                ? 'Giảng viên'
                                : 'Sinh viên',
                            onTap: null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    ListTile(
                      onTap: () => _showLogoutDialog(context, ref),
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.logout, color: Colors.red),
                      ),
                      title: const Text(
                        'Đăng xuất',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Kết thúc phiên đăng nhập hiện tại'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isLoading) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading) const CircularProgressIndicator(),
            if (isLoading) const SizedBox(height: 16),
            Text(
              isLoading
                  ? 'Đang tải thông tin cá nhân...'
                  : 'Không lấy được thông tin người dùng.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () =>
                  ref.read(authProvider.notifier).ensureCurrentUser(),
              child: const Text('Tải lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback? onTap,
    Widget? trailing,
  }) {
    final isEnabled = onTap != null;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isEnabled ? null : Colors.grey[700],
        ),
      ),
      subtitle: Text(subtitle),
      trailing:
          trailing ?? (isEnabled ? const Icon(Icons.chevron_right) : null),
    );
  }

  bool _canSaveProfile(User user) {
    final nextName = _nameController.text.trim();
    return !_isSavingProfile &&
        !_isUploadingAvatar &&
        nextName.isNotEmpty &&
        nextName != user.name.trim();
  }

  Future<void> _saveProfile() async {
    final user = ref.read(authProvider).user;
    final nextName = _nameController.text.trim();

    if (user == null) {
      _showSnackBar('Không tìm thấy thông tin người dùng.');
      return;
    }

    if (nextName.isEmpty) {
      _showSnackBar('Vui lòng nhập họ và tên.');
      return;
    }

    if (nextName == user.name.trim()) {
      _showSnackBar('Tên hiện tại chưa thay đổi.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSavingProfile = true);

    try {
      final updatedUser =
          await ref.read(authProvider.notifier).updateStudentProfile(nextName);
      _syncFormWithUser(updatedUser, force: true);
      _showSnackBar('Cập nhật thông tin thành công.', isError: false);
    } catch (error) {
      _showSnackBar(_mapError(error));
    } finally {
      if (mounted) {
        setState(() => _isSavingProfile = false);
      }
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    FocusScope.of(context).unfocus();
    try {
      final selectedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (selectedImage == null) {
        return;
      }

      final path = selectedImage.path;
      final extension = (selectedImage.name.contains('.')
              ? selectedImage.name.split('.').last
              : '')
          .toLowerCase();

      if (!_allowedImageExtensions.contains(extension)) {
        _showSnackBar('Vui lòng chọn file ảnh hợp lệ.');
        return;
      }

      final imageFile = File(path);
      final imageSize = await imageFile.length();

      if (imageSize > _maxAvatarBytes) {
        _showSnackBar('Ảnh đại diện phải nhỏ hơn hoặc bằng 5MB.');
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() => _isUploadingAvatar = true);

      await ref.read(authProvider.notifier).uploadStudentAvatar(imageFile);
      _showSnackBar('Cập nhật ảnh đại diện thành công.', isError: false);
    } catch (error) {
      _showSnackBar(_mapError(error));
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  Future<void> _showEditProfileSheet(User user) async {
    _syncFormWithUser(user, force: true);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            final canSave = _canSaveProfile(user);

            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    Text(
                      'Chỉnh sửa thông tin',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bạn chỉ có thể cập nhật họ và tên.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) => setModalState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Họ và tên',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      readOnly: true,
                      initialValue: user.email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: canSave
                          ? () async {
                              await _saveProfile();
                              if (mounted && !_isSavingProfile) {
                                Navigator.pop(sheetContext);
                              }
                            }
                          : null,
                      icon: _isSavingProfile
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                          _isSavingProfile ? 'Đang lưu...' : 'Lưu thay đổi'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _mapError(Object error) {
    if (error is AppFailure) {
      return error.message;
    }
    if (error is PlatformException) {
      return error.message ?? 'Không thể mở thư viện ảnh trên thiết bị.';
    }
    return 'Đã có lỗi xảy ra. Vui lòng thử lại.';
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
  }

  void _syncFormWithUser(User? user, {bool force = false}) {
    if (user == null) {
      return;
    }

    final shouldSync =
        force || _syncedUserId != user.id || _syncedUserName != user.name;

    if (!shouldSync) {
      return;
    }

    if (_nameFocusNode.hasFocus && !force) {
      return;
    }

    _nameController.value = TextEditingValue(
      text: user.name,
      selection: TextSelection.collapsed(offset: user.name.length),
    );
    _syncedUserId = user.id;
    _syncedUserName = user.name;
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi hệ thống?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.goNamed(AppRouteNames.welcome);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatarSection extends StatelessWidget {
  const _ProfileAvatarSection({
    required this.user,
    required this.theme,
    required this.isUploading,
  });

  final User user;
  final ThemeData theme;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.primary, width: 3),
              ),
              clipBehavior: Clip.antiAlias,
              child: _AvatarView(user: user),
            ),
            if (isUploading)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}

class _AvatarView extends StatelessWidget {
  const _AvatarView({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarUrl = user.avatarUrl;
    final initial = user.name.trim().isEmpty
        ? 'U'
        : user.name.trim().characters.first.toUpperCase();

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _AvatarFallback(
          label: initial,
          theme: theme,
        ),
      );
    }

    return _AvatarFallback(label: initial, theme: theme);
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({
    required this.label,
    required this.theme,
  });

  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colorScheme.primary.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: Text(
        label,
        style: theme.textTheme.headlineMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : (Colors.grey[200] ?? Colors.grey),
        ),
      ),
      child: child,
    );
  }
}
