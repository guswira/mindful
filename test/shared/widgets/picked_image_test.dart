import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mindful/shared/widgets/picked_image.dart';

void main() {
  testWidgets('draws a picked photo from its file off the web', (tester) async {
    final dir = Directory.systemTemp.createTempSync('mindful_picked');
    addTearDown(() => dir.deleteSync(recursive: true));
    final path = '${dir.path}/photo.png';

    await tester.pumpWidget(PickedImage(XFile(path)));

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<FileImage>());
    expect((image.image as FileImage).file.path, path);
    expect(image.fit, BoxFit.cover);
  });
}
