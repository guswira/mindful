import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../ai/data/food_scan_repository.dart';
import '../../ai/domain/food_scan.dart';
import '../../habits/data/habit_repository.dart';
import '../../money/data/money_repository.dart';
import '../../money/domain/budget_type.dart';
import '../../tasks/data/task_repository.dart';
import '../domain/monthly_recap.dart';
import '../domain/monthly_recap_builder.dart';
import '../domain/recap_window.dart';

part 'monthly_recap_providers.g.dart';

/// [month]'s recap, from the Hive caches plus a fresh fetch of that
/// month's habit logs and food scans.
@riverpod
Future<MonthlyRecap> monthlyRecap(Ref ref, DateTime month) async {
  final habitRepository = await ref.watch(habitRepositoryProvider.future);
  final taskRepository = await ref.watch(taskRepositoryProvider.future);
  final moneyRepository = await ref.watch(moneyRepositoryProvider.future);

  final habitLogs = await habitRepository.logsInMonth(month);
  final currency = await moneyRepository.getCurrency();

  List<FoodScan>? foodScans;
  try {
    foodScans = await ref
        .read(foodScanRepositoryProvider)
        .getScansInMonth(month)
        .timeout(const Duration(seconds: 10));
  } catch (error) {
    // Scans are Supabase-only; the AI slide says it couldn't load them.
    debugPrint('Monthly recap: food scans unavailable: $error');
  }

  return buildMonthlyRecap(
    month: month,
    now: DateTime.now(),
    habits: habitRepository.getHabits(),
    habitLogs: habitLogs,
    tasks: taskRepository.getAll(),
    moneyEntries: moneyRepository.getEntries(),
    currency: currency,
    monthlyBudget: moneyRepository
        .getBudgetSettings(BudgetType.monthly)
        ?.amount,
    foodScans: foodScans,
  );
}

/// The month the home banner offers a recap for right now, or null outside
/// the window (see [recapMonthForBanner]). Not dismissible — it shows
/// every day of the window.
@riverpod
DateTime? monthlyRecapBannerMonth(Ref ref) =>
    recapMonthForBanner(DateTime.now());
