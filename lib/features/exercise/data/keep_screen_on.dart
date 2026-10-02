import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

part 'keep_screen_on.g.dart';

/// Keeps the screen awake while a breathing session runs — auto-lock
/// would otherwise kick in mid-session, since the user isn't touching
/// the screen.
class KeepScreenOn {
  const KeepScreenOn();

  Future<void> set({required bool enabled}) async {
    try {
      await WakelockPlus.toggle(enable: enabled);
    } catch (error) {
      debugPrint('Wakelock unavailable: $error');
    }
  }
}

/// The app-wide [KeepScreenOn].
@Riverpod(keepAlive: true)
KeepScreenOn keepScreenOn(Ref ref) => const KeepScreenOn();
