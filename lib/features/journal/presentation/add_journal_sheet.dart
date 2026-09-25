import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/shake_widget.dart';
import '../../../shared/widgets/sheet_header.dart';
import '../../../shared/widgets/tinted_pill.dart';
import '../data/journal_entries_controller.dart';
import '../data/journal_photo_mime_type.dart';
import '../domain/journal_entry.dart';
import 'journal_editor_widgets.dart';

/// Bottom sheet for a quick journal entry: body, mood and optional photos
/// — no title, unlike the full editor. See SPEC.md Journal Editor Screen
/// and the bottom-sheet design rules.
class AddJournalSheet extends ConsumerStatefulWidget {
  const AddJournalSheet({super.key});

  @override
  ConsumerState<AddJournalSheet> createState() => _AddJournalSheetState();
}

class _AddJournalSheetState extends ConsumerState<AddJournalSheet> {
  final _bodyController = TextEditingController();
  final _bodyShake = GlobalKey<ShakeWidgetState>();
  final _picker = ImagePicker();

  Mood? _mood;
  final List<XFile> _newPhotos = [];
  bool _saving = false;

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(context.l10n.journalPhotoCamera),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(context.l10n.journalPhotoGallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted || source == null) {
      return;
    }
    final photo = await _picker.pickImage(source: source);
    if (!context.mounted || photo == null) {
      return;
    }
    setState(() => _newPhotos.add(photo));
  }

  Future<void> _save() async {
    final body = _bodyController.text.trim();
    if (body.isEmpty) {
      _bodyShake.currentState?.shake();
      return;
    }

    setState(() => _saving = true);
    final notifier = ref.read(journalEntriesProvider.notifier);
    final uploadedIds = <String>[];
    for (final photo in _newPhotos) {
      final bytes = await File(photo.path).readAsBytes();
      uploadedIds.add(
        await notifier.uploadPhoto(
          bytes: bytes,
          mimeType: journalPhotoMimeType(photo.path),
        ),
      );
    }
    await notifier.createEntry(body: body, mood: _mood, photoUrls: uploadedIds);

    if (!mounted) {
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHeader(
            title: context.l10n.journalAddSheetTitle,
            onClose: () => Navigator.pop(context),
          ),
          const SizedBox(height: Spacing.sm),
          ShakeWidget(
            key: _bodyShake,
            child: TextField(
              controller: _bodyController,
              autofocus: true,
              maxLines: null,
              minLines: 4,
              textInputAction: TextInputAction.newline,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 16,
                height: 1.6,
              ),
              decoration: InputDecoration(
                hintText: context.l10n.journalBodyHint,
                hintStyle: TextStyle(color: glass.textHint),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
          JournalMoodBar(
            selected: _mood,
            onChanged: (mood) => setState(() => _mood = mood),
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Badge(
                label: Text('${_newPhotos.length}'),
                isLabelVisible: _newPhotos.isNotEmpty,
                child: IconButton(
                  icon: const Icon(
                    Icons.photo_library_outlined,
                    color: Colors.white60,
                  ),
                  onPressed: _pickPhoto,
                ),
              ),
              const Spacer(),
              if (_saving)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: glass.journalAccent,
                    strokeWidth: 2,
                  ),
                )
              else
                TintedPill(
                  label: context.l10n.journalSaveEntry,
                  color: glass.journalAccent,
                  onTap: _save,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
