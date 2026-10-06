import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/habit_repository.dart';
import '../domain/habit.dart';
import 'habit_tab.dart';

part 'habit_providers.g.dart';

/// The cached habit with [id], or null if it doesn't exist.
///
/// Shared by the detail and edit screens so they don't each re-derive it
/// from the repository. Re-read whenever today's routine list reloads, so
/// every habit write (edit, archive, restore, delete) shows up here too.
@riverpod
Future<Habit?> habitById(Ref ref, String id) async {
  ref.watch(habitTabControllerProvider);
  final repository = await ref.watch(habitRepositoryProvider.future);
  final matches = repository.getHabits().where((habit) => habit.id == id);
  return matches.isEmpty ? null : matches.first;
}
