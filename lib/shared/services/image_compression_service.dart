import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/l10n/l10n.dart';
import '../../features/ai/domain/food_scan_exception.dart';

part 'image_compression_service.g.dart';

/// Shrinks a food photo before it's sent to Gemini. See SPEC.md AI Lab
/// Feature ImageCompressionService.
class ImageCompressionService {
  const ImageCompressionService();

  static const int _maxBytes = 4 * 1024 * 1024;
  static const int _shortSide = 768;

  /// Scales [original] down so its short side is 768px, quality 75 — a
  /// food photo needs no more detail, and every extra KB is base64'd
  /// through the proxy to Gemini. Retried at quality 50 if that first pass is still over 4MB (a large enough
  /// original can still clear 4MB at quality 75).
  ///
  /// Works on bytes rather than files so it also runs on web, which has no
  /// file system.
  Future<Uint8List> compress(Uint8List original) async {
    final stopwatch = Stopwatch()..start();
    var result = await _compress(original, quality: 75);
    if (result.length > _maxBytes) {
      result = await _compress(original, quality: 50);
    }
    debugPrint(
      'Food photo compressed in ${stopwatch.elapsedMilliseconds}ms '
      '(${original.length ~/ 1024}KB → ${result.length ~/ 1024}KB)',
    );
    return result;
  }

  Future<Uint8List> _compress(
    Uint8List original, {
    required int quality,
  }) async {
    try {
      return await FlutterImageCompress.compressWithList(
        original,
        quality: quality,
        minWidth: _shortSide,
        minHeight: _shortSide,
      );
    } catch (error) {
      debugPrint('Food photo compression failed: $error');
      throw FoodScanException(
        currentL10n.aiErrorCompressFailed,
        FoodScanErrorType.unknown,
      );
    }
  }
}

/// The app-wide [ImageCompressionService].
@riverpod
ImageCompressionService imageCompressionService(Ref ref) =>
    const ImageCompressionService();
