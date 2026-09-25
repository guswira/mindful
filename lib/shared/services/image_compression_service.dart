import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/l10n/l10n.dart';
import '../../features/ai/domain/food_scan_exception.dart';

part 'image_compression_service.g.dart';

/// Shrinks a food photo before it's sent to Gemini. See SPEC.md AI Lab
/// Feature ImageCompressionService.
class ImageCompressionService {
  const ImageCompressionService();

  static const int _maxBytes = 4 * 1024 * 1024;

  /// Compresses [original] to at most 1024x1024, quality 75 — retried at
  /// quality 50 if that first pass is still over 4MB (a large enough
  /// original can still clear 4MB at quality 75).
  Future<File> compress(File original) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';

    var result = await FlutterImageCompress.compressAndGetFile(
      original.path,
      targetPath,
      quality: 75,
      minWidth: 1024,
      minHeight: 1024,
    );
    if (result == null) {
      throw FoodScanException(
        currentL10n.aiErrorCompressFailed,
        FoodScanErrorType.unknown,
      );
    }

    if (await result.length() > _maxBytes) {
      final retried = await FlutterImageCompress.compressAndGetFile(
        original.path,
        targetPath,
        quality: 50,
        minWidth: 1024,
        minHeight: 1024,
      );
      if (retried == null) {
        throw FoodScanException(
          currentL10n.aiErrorCompressFailed,
          FoodScanErrorType.unknown,
        );
      }
      result = retried;
    }

    return File(result.path);
  }
}

/// The app-wide [ImageCompressionService].
@riverpod
ImageCompressionService imageCompressionService(Ref ref) =>
    const ImageCompressionService();
