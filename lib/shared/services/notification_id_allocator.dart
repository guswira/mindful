import 'package:hive/hive.dart';

/// Minimal persistent key-value storage [NotificationIdAllocator] needs —
/// a thin seam over Hive's [Box] API so allocator logic can be tested
/// without spinning up real Hive, and swapped for [HiveNotificationIdStore]
/// in production.
abstract class NotificationIdStore {
  int? get(String key);
  Future<void> put(String key, int value);
  Future<void> delete(String key);
  Iterable<int> get values;
}

/// Assigns each item a stable notification-id slot within a fixed range,
/// persisted via [NotificationIdStore] so the same item keeps the same id
/// across reschedules and app restarts — unlike deriving an id from a
/// task/habit's position in a list, which silently shifts (and can collide
/// with another item's still-pending reminder) whenever an earlier item in
/// the list is deleted.
class NotificationIdAllocator {
  NotificationIdAllocator(
    this._store, {
    required this.base,
    required this.slotCount,
    this.blockSize = 1,
  });

  final NotificationIdStore _store;

  /// The first id in this allocator's reserved range.
  final int base;

  /// How many [blockSize]-wide blocks fit in the reserved range.
  final int slotCount;

  /// How many consecutive ids each item reserves — 1 for a single
  /// notification, or e.g. 7 for a habit's one-id-per-weekday reminders.
  final int blockSize;

  /// The id (or block's first id, if [blockSize] > 1) already reserved for
  /// [itemId], or null if none has been assigned yet. Doesn't allocate one.
  int? existingIdFor(String itemId) {
    final slot = _store.get(itemId);
    return slot == null ? null : base + slot * blockSize;
  }

  /// The stable id (or block's first id) reserved for [itemId] — the same
  /// one every time until [release]. Allocates the lowest free slot the
  /// first time it's called for a given [itemId].
  int idFor(String itemId) {
    final existing = existingIdFor(itemId);
    if (existing != null) {
      return existing;
    }

    final used = _store.values.toSet();
    for (var slot = 0; slot < slotCount; slot++) {
      if (!used.contains(slot)) {
        _store.put(itemId, slot);
        return base + slot * blockSize;
      }
    }
    throw StateError(
      'No free notification id slots left in range starting at $base',
    );
  }

  /// Frees [itemId]'s slot so a future item can reuse it — call only once
  /// the item is permanently deleted, not merely when its reminder is
  /// turned off (the same item should keep the same id if it gets a
  /// reminder again later).
  Future<void> release(String itemId) => _store.delete(itemId);
}

/// [NotificationIdStore] backed by a real Hive [Box] — the production
/// implementation, persisting allocations across app restarts.
class HiveNotificationIdStore implements NotificationIdStore {
  HiveNotificationIdStore(this._box);

  final Box<int> _box;

  @override
  int? get(String key) => _box.get(key);

  @override
  Future<void> put(String key, int value) => _box.put(key, value);

  @override
  Future<void> delete(String key) => _box.delete(key);

  @override
  Iterable<int> get values => _box.values;
}

/// [NotificationIdStore] backed by a plain in-memory map — [NotificationService]'s
/// own default when no persistent store is wired up (e.g. in tests), and
/// otherwise replaced by [HiveNotificationIdStore] via its constructor.
class InMemoryNotificationIdStore implements NotificationIdStore {
  final _values = <String, int>{};

  @override
  int? get(String key) => _values[key];

  @override
  Future<void> put(String key, int value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Iterable<int> get values => _values.values;
}
