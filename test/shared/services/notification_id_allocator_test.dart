import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/shared/services/notification_id_allocator.dart';

void main() {
  late NotificationIdAllocator allocator;

  setUp(() {
    allocator = NotificationIdAllocator(
      InMemoryNotificationIdStore(),
      base: 3000,
      slotCount: 10,
    );
  });

  test('the first item ever allocated gets the base id', () {
    expect(allocator.idFor('a'), 3000);
  });

  test('a second, different item gets the next free id', () {
    allocator.idFor('a');
    expect(allocator.idFor('b'), 3001);
  });

  test('asking for the same item again returns the same id', () {
    final first = allocator.idFor('a');
    final second = allocator.idFor('a');
    expect(second, first);
  });

  test('existingIdFor returns null without allocating', () {
    expect(allocator.existingIdFor('a'), isNull);
    // Confirm it really didn't allocate — the next real allocation still
    // starts at the base id.
    expect(allocator.idFor('b'), 3000);
  });

  test('existingIdFor returns the id once one has been allocated', () {
    final id = allocator.idFor('a');
    expect(allocator.existingIdFor('a'), id);
  });

  test('releasing an item frees its id for reuse by a later item — the '
      'freed id is not left dangling for whoever held it before', () {
    allocator.idFor('a'); // 3000
    allocator.idFor('b'); // 3001
    allocator.release('a');

    expect(allocator.existingIdFor('a'), isNull);
    expect(allocator.idFor('c'), 3000); // reused, not 3002
    expect(allocator.existingIdFor('b'), 3001); // b is untouched
  });

  test('throws once every slot in the range is taken', () {
    for (var i = 0; i < 10; i++) {
      allocator.idFor('item$i');
    }
    expect(() => allocator.idFor('one-too-many'), throwsStateError);
  });

  test('a wider block size reserves a contiguous range per item', () {
    final blocked = NotificationIdAllocator(
      InMemoryNotificationIdStore(),
      base: 2000,
      slotCount: 5,
      blockSize: 7,
    );

    expect(blocked.idFor('h1'), 2000);
    expect(blocked.idFor('h2'), 2007);
    blocked.release('h1');
    expect(blocked.idFor('h3'), 2000); // reuses h1's freed block
    expect(blocked.existingIdFor('h2'), 2007); // h2's block is untouched
  });
}
