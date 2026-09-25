import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/habit_repository.dart';
import '../domain/habit.dart';

part 'habit_providers.g.dart';

/// The cached habit with [id], or null if it doesn't exist.
///
/// Shared by the detail and edit screens so they don't each re-derive it
/// from the repository.
@riverpod
Future<Habit?> habitById(Ref ref, String id) async {
  final repository = await ref.watch(habitRepositoryProvider.future);
  final matches = repository.getHabits().where((habit) => habit.id == id);
  return matches.isEmpty ? null : matches.first;
}
