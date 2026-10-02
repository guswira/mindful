import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/features/settings/data/custom_background_repository.dart';

void main() {
  late Directory docs;
  late File picked;
  late CustomBackgroundRepository repository;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    docs = Directory.systemTemp.createTempSync('mindful_bg_test');
    picked = File('${docs.path}/picked.JPG')..writeAsBytesSync([1, 2, 3]);
    repository = CustomBackgroundRepository(directory: () async => docs);
  });

  tearDown(() => docs.deleteSync(recursive: true));

  test('nothing is set by default', () async {
    expect(await repository.readPath(), isNull);
  });

  test('save copies the photo in and readPath finds it again', () async {
    final path = await repository.save(picked.path);

    expect(path, startsWith('${docs.path}/backgrounds/'));
    expect(path, endsWith('.jpg'));
    expect(File(path).readAsBytesSync(), [1, 2, 3]);
    expect(await repository.readPath(), path);
  });

  test('saving again replaces and deletes the previous copy', () async {
    final first = await repository.save(picked.path);
    // Distinct timestamp-based file name for the second copy.
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final second = await repository.save(picked.path);

    expect(second, isNot(first));
    expect(File(first).existsSync(), isFalse);
    expect(await repository.readPath(), second);
  });

  test('clear resets to default and deletes the copy', () async {
    final path = await repository.save(picked.path);
    await repository.clear();

    expect(await repository.readPath(), isNull);
    expect(File(path).existsSync(), isFalse);
  });

  test('a saved photo that has gone missing reads as no background', () async {
    final path = await repository.save(picked.path);
    File(path).deleteSync();

    expect(await repository.readPath(), isNull);
  });
}
