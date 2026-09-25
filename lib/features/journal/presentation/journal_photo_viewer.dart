import 'package:flutter/material.dart';

import 'journal_tab_list.dart' show JournalPhotoThumbnail;

/// Full-screen viewer for a single journal photo, dismissed by tapping
/// anywhere. See SPEC.md Journal Editor Screen and the bottom-sheet
/// design rules.
Future<void> showJournalPhotoViewer(BuildContext context, String path) {
  return Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: InteractiveViewer(
              child: JournalPhotoThumbnail(path: path, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    ),
  );
}
