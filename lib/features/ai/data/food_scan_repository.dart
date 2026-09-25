import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../domain/food_analysis.dart';
import '../domain/food_scan.dart';
import 'supabase_food_scan_datasource.dart';

part 'food_scan_repository.g.dart';

/// Saves and lists food scans. Unlike the journal/habit/task/money
/// repositories, there's no Hive cache here — a scan is a one-shot AI
/// result, not something the app needs to show offline. See SPEC.md AI Lab
/// Feature.
class FoodScanRepository {
  FoodScanRepository({
    SupabaseFoodScanDatasource? datasource,
    Uuid uuid = const Uuid(),
  }) : _datasource = datasource ?? SupabaseFoodScanDatasource(),
       _uuid = uuid;

  final SupabaseFoodScanDatasource _datasource;
  final Uuid _uuid;

  /// Saves [analysis] as a new scan owned by [userId].
  Future<FoodScan> saveScan({
    required String userId,
    required FoodAnalysis analysis,
  }) async {
    final scan = FoodScan(
      id: _uuid.v4(),
      userId: userId,
      scannedAt: DateTime.now(),
      foodName: analysis.foodName,
      calories: analysis.calories,
      protein: analysis.protein,
      carbs: analysis.carbs,
      fat: analysis.fat,
      fiber: analysis.fiber,
      confidence: analysis.confidence,
    );
    await _datasource.saveScan(scan);
    return scan;
  }

  /// The signed-in user's last [limit] scans, newest first.
  Future<List<FoodScan>> getRecentScans({int limit = 10}) =>
      _datasource.getRecentScans(limit: limit);

  /// Deletes the scan with [id].
  Future<void> deleteScan(String id) => _datasource.deleteScan(id);
}

/// The app-wide [FoodScanRepository].
@riverpod
FoodScanRepository foodScanRepository(Ref ref) => FoodScanRepository();

/// The signed-in user's last 10 food scans, newest first.
@riverpod
Future<List<FoodScan>> recentScans(Ref ref) {
  final repository = ref.watch(foodScanRepositoryProvider);
  return repository.getRecentScans();
}
