import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/custom_background_repository.dart';

part 'custom_background_controller.g.dart';

/// The custom background photo's path (null = the default navy + blobs),
/// read by [App] and handed to every [BlobBackground] via
/// [AppBackgroundScope].
@Riverpod(keepAlive: true)
class CustomBackgroundController extends _$CustomBackgroundController {
  @override
  Future<String?> build() =>
      ref.watch(customBackgroundRepositoryProvider).readPath();

  /// Lets the user pick a gallery photo and makes it the background.
  /// Returns false if they cancelled the picker.
  Future<bool> pickFromGallery({ImagePicker? picker}) async {
    final photo = await (picker ?? ImagePicker()).pickImage(
      source: ImageSource.gallery,
      // Plenty for a full-screen phone background, without keeping a
      // 50MP original decoded behind every screen.
      maxWidth: 2160,
      maxHeight: 2160,
      imageQuality: 88,
    );
    if (photo == null) return false;
    final path = await ref
        .read(customBackgroundRepositoryProvider)
        .save(photo.path);
    state = AsyncData(path);
    return true;
  }

  /// Goes back to the default background.
  Future<void> reset() async {
    await ref.read(customBackgroundRepositoryProvider).clear();
    state = const AsyncData(null);
  }
}
