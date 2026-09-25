import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/settings/data/settings_repository.dart';
import 'app_language.dart';

part 'app_language_controller.g.dart';

/// The language picked in Settings — [AppLanguage.system] until [restore]
/// loads a saved choice at startup.
@Riverpod(keepAlive: true)
class AppLanguageController extends _$AppLanguageController {
  @override
  AppLanguage build() => AppLanguage.system;

  /// Loads the saved choice. Awaited in main() before the first frame so
  /// the app never flashes in the device language first.
  Future<void> restore() async {
    state = await ref.read(settingsRepositoryProvider).readAppLanguage();
  }

  /// Persists [language] and switches the app to it immediately.
  Future<void> select(AppLanguage language) async {
    state = language;
    await ref.read(settingsRepositoryProvider).writeAppLanguage(language);
  }
}
