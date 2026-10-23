import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

/// A photo just picked with image_picker, before it's uploaded anywhere.
///
/// On web the picked [XFile]'s path is a `blob:` URL rather than a file on
/// disk (`Image.file` asserts there), so it's drawn as a network image.
class PickedImage extends StatelessWidget {
  const PickedImage(this.file, {this.fit = BoxFit.cover, super.key});

  final XFile file;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => kIsWeb
      ? Image.network(file.path, fit: fit)
      : Image.file(File(file.path), fit: fit);
}
