import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/blob_background.dart';
import '../data/journal_entries_controller.dart';
import '../data/journal_photo_mime_type.dart';
import '../domain/journal_entry.dart';
import 'journal_editor_widgets.dart';
import 'journal_photo_strip.dart';

/// Full-page editor for an existing journal entry — the body autofocuses
/// on open, and the mood/save bars stay pinned above the keyboard.
/// Creating a new entry uses `AddJournalSheet` instead; this screen is
/// edit-only, for entries long enough to want the full page. See
/// SPEC.md Journal Editor Screen and the bottom-sheet design rules.
class JournalEditorScreen extends ConsumerStatefulWidget {
  const JournalEditorScreen({required this.id, super.key});

  final String id;

  @override
  ConsumerState<JournalEditorScreen> createState() =>
      _JournalEditorScreenState();
}

class _JournalEditorScreenState extends ConsumerState<JournalEditorScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _bodyFocus = FocusNode();
  final _picker = ImagePicker();

  Mood? _mood;
  List<String> _existingPhotoIds = const [];
  final List<XFile> _newPhotos = [];
  bool _seeded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _bodyFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _bodyFocus.dispose();
    super.dispose();
  }

  void _seedFrom(JournalEntry entry) {
    _titleController.text = entry.title ?? '';
    _bodyController.text = entry.body;
    _mood = entry.mood;
    _existingPhotoIds = entry.photoUrls;
    _seeded = true;
  }

  @override
  Widget build(BuildContext context) {
    final entry = ref.watch(journalEntryProvider(widget.id));
    if (entry != null && !_seeded) {
      _seedFrom(entry);
    }
    final photoCount = _existingPhotoIds.length + _newPhotos.length;
    final glass = Theme.of(context).extension<GlassTheme>()!;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: glass.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white70),
        title: Text(
          entry == null ? '' : DateFormat('MMMM d').format(entry.date),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          if (entry != null)
            IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.white70),
              onPressed: () => _showMoreOptions(entry),
            ),
        ],
      ),
      body: BlobBackground(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: context.l10n.journalTitleHint,
                        hintStyle: const TextStyle(color: Colors.white24),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_existingPhotoIds.isNotEmpty || _newPhotos.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: JournalPhotoStrip(
                          existingPhotoIds: _existingPhotoIds,
                          newPhotos: _newPhotos,
                          onRemoveExisting: (id) => setState(
                            () => _existingPhotoIds = [
                              for (final photoId in _existingPhotoIds)
                                if (photoId != id) photoId,
                            ],
                          ),
                          onRemoveNew: (photo) =>
                              setState(() => _newPhotos.remove(photo)),
                          onAdd: _pickPhoto,
                        ),
                      ),
                    TextField(
                      controller: _bodyController,
                      focusNode: _bodyFocus,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.6,
                      ),
                      decoration: InputDecoration(
                        hintText: context.l10n.journalBodyHint,
                        hintStyle: const TextStyle(color: Colors.white24),
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      minLines: 10,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: 200),
                  ],
                ),
              ),
            ),
            JournalMoodBar(
              selected: _mood,
              onChanged: (mood) => setState(() => _mood = mood),
            ),
            JournalActionBar(
              photoCount: photoCount,
              saving: _saving,
              onPickPhoto: _pickPhoto,
              onSave: () => _save(entry),
            ),
            SizedBox(
              height: MediaQuery.of(context).viewInsets.bottom == 0
                  ? MediaQuery.of(context).padding.bottom
                  : 0,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMoreOptions(JournalEntry entry) async {
    final action = await showModalBottomSheet<_MoreAction>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                context.l10n.journalDeleteEntry,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () => Navigator.pop(context, _MoreAction.delete),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action != _MoreAction.delete) return;
    await _delete(entry);
  }

  Future<void> _delete(JournalEntry entry) async {
    await ref.read(journalEntriesProvider.notifier).deleteEntry(entry);
    if (!context.mounted) return;
    // context.mounted was just checked above; go_router's extension methods
    // aren't recognized by the use_build_context_synchronously lint.
    // ignore: use_build_context_synchronously
    if (context.canPop()) context.pop();
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
    if (!context.mounted || source == null) return;

    final photo = await _picker.pickImage(source: source);
    if (!context.mounted || photo == null) return;
    setState(() => _newPhotos.add(photo));
  }

  Future<void> _save(JournalEntry? existing) async {
    if (existing == null) return;
    final body = _bodyController.text.trim();
    if (body.isEmpty) return;

    setState(() => _saving = true);
    await _writeEntry(existing, body);

    if (!context.mounted) return;
    // context.mounted was just checked above; go_router's extension methods
    // aren't recognized by the use_build_context_synchronously lint.
    // ignore: use_build_context_synchronously
    if (!context.canPop()) {
      setState(() => _saving = false);
      return;
    }
    // ignore: use_build_context_synchronously
    context.pop();
  }

  Future<void> _writeEntry(JournalEntry existing, String body) async {
    final notifier = ref.read(journalEntriesProvider.notifier);
    final uploadedIds = <String>[];
    for (final photo in _newPhotos) {
      final bytes = await File(photo.path).readAsBytes();
      final id = await notifier.uploadPhoto(
        bytes: bytes,
        mimeType: journalPhotoMimeType(photo.path),
      );
      uploadedIds.add(id);
    }
    final photoUrls = [..._existingPhotoIds, ...uploadedIds];
    final title = _titleController.text.trim();

    await notifier.updateEntry(
      existing.copyWith(
        body: body,
        title: title.isEmpty ? null : title,
        mood: _mood,
        photoUrls: photoUrls,
      ),
    );
  }
}

enum _MoreAction { delete }
