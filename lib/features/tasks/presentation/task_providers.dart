import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/task_repository.dart';
import '../domain/task.dart';

part 'task_providers.g.dart';

/// The cached task with [id], or null if it doesn't exist.
///
/// Shared by the detail and edit screens so they don't each re-derive it
/// from the repository.
@riverpod
Future<Task?> taskById(Ref ref, String id) async {
  final repository = await ref.watch(taskRepositoryProvider.future);
  final matches = repository.getAll().where((task) => task.id == id);
  return matches.isEmpty ? null : matches.first;
}
