import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'custom_background_repository.g.dart';

/// Keeps the user's custom background photo: a private copy in the app's
/// documents directory (the gallery original may be moved or deleted).
///
/// Only the copy's file name is persisted, not its absolute path — on iOS
/// the app container's path changes across updates/reinstalls, so a
/// stored absolute path would silently stop resolving.
///
/// Web has no file system: there the photo is kept as a `data:` URI in a
/// Hive box (IndexedDB — too big for secure storage's localStorage), and
/// that URI stands in for the path everywhere ([backgroundImageProvider]).
class CustomBackgroundRepository {
  CustomBackgroundRepository({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
    Future<Directory> Function()? directory,
    bool? isWeb,
    Future<Box<String>> Function()? webBox,
  }) : _storage = storage,
       _directory = directory ?? getApplicationDocumentsDirectory,
       _isWeb = isWeb ?? kIsWeb,
       _webBox = webBox ?? (() => Hive.openBox<String>(webBoxName));

  final FlutterSecureStorage _storage;
  final Future<Directory> Function() _directory;
  final bool _isWeb;
  final Future<Box<String>> Function() _webBox;

  static const String _fileNameKey = 'custom_background_file';
  static const String _folder = 'backgrounds';

  /// Web only. A device preference, so not one of the account boxes
  /// cleared on sign-out.
  static const String webBoxName = 'custom_background';
  static const String _webImageKey = 'image';

  /// The saved photo's absolute path (a `data:` URI on web), or null if
  /// none is set or the file has gone missing.
  Future<String?> readPath() async {
    if (_isWeb) {
      return (await _webBox()).get(_webImageKey);
    }
    final fileName = await _storage.read(key: _fileNameKey);
    if (fileName == null) return null;
    final file = File('${await _folderPath()}/$fileName');
    return file.existsSync() ? file.path : null;
  }

  /// Copies [photo] in as the new background, replacing (and deleting)
  /// any previous one. Returns the copy's absolute path (a `data:` URI on
  /// web).
  Future<String> save(XFile photo) async {
    if (_isWeb) {
      final mimeType = photo.mimeType ?? 'image/jpeg';
      final uri =
          'data:$mimeType;base64,${base64Encode(await photo.readAsBytes())}';
      await (await _webBox()).put(_webImageKey, uri);
      return uri;
    }
    final source = photo.path;
    final folder = Directory(await _folderPath());
    await folder.create(recursive: true);
    // A fresh name each time, so Flutter's image cache never serves the
    // previous photo for a reused path.
    final fileName =
        'bg_${DateTime.now().millisecondsSinceEpoch}'
        '${_extension(source)}';
    final copy = await File(source).copy('${folder.path}/$fileName');
    await _deleteSavedExcept(fileName);
    await _storage.write(key: _fileNameKey, value: fileName);
    return copy.path;
  }

  /// Goes back to the default background and deletes the saved photo.
  Future<void> clear() async {
    if (_isWeb) {
      await (await _webBox()).delete(_webImageKey);
      return;
    }
    await _storage.delete(key: _fileNameKey);
    await _deleteSavedExcept(null);
  }

  Future<String> _folderPath() async => '${(await _directory()).path}/$_folder';

  /// `.jpg` etc. (lowercased), or empty if [path]'s file name has none.
  static String _extension(String path) {
    final name = File(path).uri.pathSegments.last;
    final dot = name.lastIndexOf('.');
    return dot <= 0 ? '' : name.substring(dot).toLowerCase();
  }

  Future<void> _deleteSavedExcept(String? keep) async {
    final folder = Directory(await _folderPath());
    if (!folder.existsSync()) return;
    for (final entity in folder.listSync()) {
      if (entity is File && entity.uri.pathSegments.last != keep) {
        try {
          await entity.delete();
        } catch (error) {
          debugPrint('Could not delete old background ${entity.path}: $error');
        }
      }
    }
  }
}

@Riverpod(keepAlive: true)
CustomBackgroundRepository customBackgroundRepository(Ref ref) =>
    CustomBackgroundRepository();
