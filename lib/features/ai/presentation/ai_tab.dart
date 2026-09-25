import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/services/gemini_service.dart';
import '../../../shared/services/image_compression_service.dart';
import '../../../shared/widgets/blob_background.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../../auth/domain/auth_state.dart';
import '../data/food_scan_repository.dart';
import '../domain/food_analysis.dart';
import '../domain/food_scan_exception.dart';
import 'food_analyzing_sheet.dart';
import 'food_result_sheet.dart';
import 'food_scan_retry.dart';
import 'widgets/experimental_banner.dart';
import 'widgets/food_checker_card.dart';
import 'widgets/recent_scans_section.dart';

/// The experimental AI Lab tab: an experimental banner and the food
/// calorie checker's camera/gallery entry point and scan history. See
/// SPEC.md AI Lab Feature AI Lab Tab.
class AITab extends ConsumerStatefulWidget {
  const AITab({super.key});

  @override
  ConsumerState<AITab> createState() => _AITabState();
}

class _AITabState extends ConsumerState<AITab> {
  final _picker = ImagePicker();

  Future<void> _openCamera() async {
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 85,
    );
    if (photo == null) {
      return;
    }
    await _analyzeImage(File(photo.path));
  }

  Future<void> _pickFromGallery() async {
    final photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo == null) {
      return;
    }
    await _analyzeImage(File(photo.path));
  }

  /// Compresses [image] and sends it to Gemini, auto-retrying a busy
  /// response (per [runWithRetry]) instead of failing on the first one —
  /// the 503s Gemini's shared Flash capacity returns under load are almost
  /// always transient. A companion progress/failure notification tracks
  /// this for as long as it runs, since the retry can easily outlast the
  /// user watching the in-app sheet.
  Future<void> _analyzeImage(File image) async {
    showGlassBottomSheet<void>(
      context: context,
      isDismissible: false,
      builder: (_) => const FoodAnalyzingSheet(),
    );
    await showFoodScanProgressNotification(
      ref,
      context.l10n.aiNotifAnalyzingBody,
    );

    final File compressed;
    try {
      compressed = await ref
          .read(imageCompressionServiceProvider)
          .compress(image);
    } on FoodScanException catch (error) {
      await _finishWithFailure(error, sheetOpen: true);
      return;
    }

    var sheetOpen = true;
    try {
      final analysis = await runWithRetry(
        attempt: () => ref.read(geminiServiceProvider).analyzeFood(compressed),
        onRetry: (attemptNumber) async {
          // Free up the UI once we know this will take a while — the
          // notification carries progress from here instead.
          if (sheetOpen && mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          sheetOpen = false;
          await showFoodScanProgressNotification(
            ref,
            currentL10n.aiNotifRetryingBody(
              attemptNumber,
              FoodScanRetryPolicy.maxAttempts,
            ),
          );
        },
      );
      await _finishWithSuccess(analysis, sheetOpen: sheetOpen);
    } on FoodScanException catch (error) {
      await _finishWithFailure(error, sheetOpen: sheetOpen);
    }
  }

  Future<void> _finishWithSuccess(
    FoodAnalysis? analysis, {
    required bool sheetOpen,
  }) async {
    await resolveFoodScanNotification(ref);
    if (!mounted) {
      return;
    }
    if (sheetOpen) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    if (analysis == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.aiErrorNotFood)),
      );
      return;
    }
    _showResult(analysis);
  }

  Future<void> _finishWithFailure(
    FoodScanException error, {
    required bool sheetOpen,
  }) async {
    // Once the sheet's already been dismissed for a retry, the user may
    // well not be watching any more — leave a notification they can act
    // on instead of a SnackBar they might never see.
    await resolveFoodScanNotification(
      ref,
      failureMessage: sheetOpen ? null : foodScanMessage(error),
    );
    if (!mounted) {
      return;
    }
    if (sheetOpen) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    _showScanError(error);
  }

  void _showResult(FoodAnalysis analysis) {
    showGlassBottomSheet<void>(
      context: context,
      builder: (_) => FoodResultSheet(
        analysis: analysis,
        onSave: () => _saveScan(analysis),
      ),
    );
  }

  Future<void> _saveScan(FoodAnalysis analysis) async {
    final repository = ref.read(foodScanRepositoryProvider);
    await repository.saveScan(
      userId: ref.read(currentUserIdProvider),
      analysis: analysis,
    );
    ref.invalidate(recentScansProvider);
    if (!mounted) {
      return;
    }
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.aiScanSaved)));
  }

  void _showScanError(FoodScanException error) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(foodScanMessage(error)),
        backgroundColor: glass.moneySpending,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Scaffold(
      backgroundColor: glass.background,
      body: RepaintBoundary(
        child: BlobBackground(
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const ExperimentalBanner(),
                      const SizedBox(height: Spacing.lg),
                      FoodCheckerCard(
                        onOpenCamera: _openCamera,
                        onPickFromGallery: _pickFromGallery,
                      ),
                      const SizedBox(height: Spacing.lg + Spacing.xs),
                      const RecentScansSection(),
                      const SizedBox(height: 88),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
