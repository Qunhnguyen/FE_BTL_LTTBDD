import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import 'data/repositories/classroom_repository_impl.dart';
import 'domain/repositories/classroom_repository.dart';
import 'presentation/cubit/classroom_cubit.dart';
import 'presentation/cubit/classroom_state.dart';

final classroomRepositoryProvider = Provider<ClassroomRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ClassroomRepositoryImpl(apiClient);
});

final classroomCubitProvider = StateNotifierProvider<ClassroomNotifier, ClassroomState>((ref) {
  final repository = ref.watch(classroomRepositoryProvider);
  return ClassroomNotifier(repository);
});
