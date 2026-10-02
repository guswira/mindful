import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'custom_background_repository.g.dart';

/// Keeps the user's custom background photo: a private copy in the app's
/// documents directory (the gallery original may be moved or deleted).
///
/// Only the copy's file name is persisted, not its absolute path — on iOS
/// the app container's path changes across updates/reinstalls, so a
/// stored absolute path would silently stop resolving.
class CustomBackgroundRepository {
  CustomBackgroundRepository({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
    Future<Directory> Function()? directory,
  }) : _storage = storage,
       _directory = directory ?? getApplicationDocumentsDirectory;

  final FlutterSecureStorage _storage;
  final Future<Directory> Function() _directory;

  static const String _fileNameKey = 'custom_background_file';
  static const String _folder = 'backgrounds';

  /// The saved photo's absolute path, or null if none is set or the file
  /// has gone missing.
  Future<String?> readPath() async {
    final fileName = await _storage.read(key: _fileNameKey);
    if (fileName == null) return null;
    final file = File('${await _folderPath()}/$fileName');
    return file.existsSync() ? file.path : null;
  }

  /// Copies [source] in as the new background, replacing (and deleting)
  /// any previous one. Returns the copy's absolute path.
  Future<String> save(String source) async {
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
