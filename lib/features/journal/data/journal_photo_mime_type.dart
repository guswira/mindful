/// The MIME type Supabase Storage should use for the photo at [path],
/// inferred from its file extension. Shared by every journal entry point
/// that uploads a picked photo.
String journalPhotoMimeType(String path) {
  final lower = path.toLowerCase();
  return switch (lower) {
    _ when lower.endsWith('.png') => 'image/png',
    _ when lower.endsWith('.heic') => 'image/heic',
    _ => 'image/jpeg',
  };
}
