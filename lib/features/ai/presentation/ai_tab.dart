import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/blob_background.dart';
import 'food_scan_flow.dart';
import 'widgets/experimental_banner.dart';
import 'widgets/food_checker_card.dart';
import 'widgets/recent_scans_section.dart';

/// The experimental AI Lab tab: an experimental banner and the food
/// calorie checker's camera/gallery entry point and scan history. See
/// SPEC.md AI Lab Feature AI Lab Tab.
class AITab extends StatefulWidget {
  const AITab({super.key});

  @override
  State<AITab> createState() => _AITabState();
}

class _AITabState extends State<AITab> {
  final _picker = ImagePicker();

  /// Lets the platform picker downscale a 12–48MP photo natively, so the
  /// app never reads and re-decodes the full-size original — the scan
  /// only needs 768px (ImageCompressionService), this just leaves room.
  static const double _maxPickedSide = 1536;

  Future<void> _openCamera() async {
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      maxWidth: _maxPickedSide,
      maxHeight: _maxPickedSide,
      imageQuality: 85,
    );
    if (photo == null) {
      return;
    }
    await _analyzeImage(await photo.readAsBytes());
  }

  Future<void> _pickFromGallery() async {
    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: _maxPickedSide,
      maxHeight: _maxPickedSide,
    );
    if (photo == null) {
      return;
    }
    await _analyzeImage(await photo.readAsBytes());
  }

  /// Hands [image] to [scanFood], which runs in the background — the user
  /// can keep using the app while the AI activity pill tracks it.
  Future<void> _analyzeImage(Uint8List image) async {
    if (!mounted) {
      return;
    }
    await scanFood(context, image);
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
