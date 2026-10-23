import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/journal_repository.dart';

/// A signed URL for the private Supabase Storage photo at [path], valid for
/// an hour — cheap enough to re-fetch per widget build via [ref.watch].
///
/// Hand-written rather than @riverpod: riverpod_generator's analyzer 7
/// crashes on the current SDK's syntax (see SPEC.md Stack decisions).
final journalPhotoUrlProvider = FutureProvider.autoDispose
    .family<String, String>(_journalPhotoUrl);

Future<String> _journalPhotoUrl(Ref ref, String path) async {
  final repository = await ref.watch(journalRepositoryProvider.future);
  return repository.signedPhotoUrl(path);
}
