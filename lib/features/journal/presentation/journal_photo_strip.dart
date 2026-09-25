import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/widgets/dashed_border_container.dart';
import 'journal_tab_list.dart' show JournalPhotoThumbnail;

/// Horizontal strip of existing and newly-picked photos, plus an add tile.
/// See SPEC.md Journal Editor Screen.
class JournalPhotoStrip extends StatelessWidget {
  const JournalPhotoStrip({
    required this.existingPhotoIds,
    required this.newPhotos,
    required this.onRemoveExisting,
    required this.onRemoveNew,
    required this.onAdd,
    super.key,
  });

  final List<String> existingPhotoIds;
  final List<XFile> newPhotos;
  final ValueChanged<String> onRemoveExisting;
  final ValueChanged<XFile> onRemoveNew;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final id in existingPhotoIds)
            _PhotoTile(
              onRemove: () => onRemoveExisting(id),
              child: JournalPhotoThumbnail(path: id),
            ),
          for (final photo in newPhotos)
            _PhotoTile(
              onRemove: () => onRemoveNew(photo),
              child: Image.file(File(photo.path), fit: BoxFit.cover),
            ),
          GestureDetector(
            onTap: onAdd,
            child: const Padding(
              padding: EdgeInsets.only(right: 8),
              child: SizedBox(
                width: 80,
                height: 80,
                child: DashedBorderContainer(
                  padding: EdgeInsets.zero,
                  child: Center(child: Icon(Icons.add, color: Colors.white38)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.child, required this.onRemove});

  final Widget child;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SizedBox(
        width: 80,
        height: 80,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: child,
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
