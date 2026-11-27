/// Tests for the list of timers.

library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timepod/services/screen_awake.dart';
import 'package:timepod/services/timer_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    screenAwake.toggle = ({required enable}) async {};
  });

  test('an added timer starts, and is saved and read back', () async {
    final store = TimerStore();
    await store.load();
    expect(store.timers, isEmpty);

    store.add(const Duration(minutes: 3));
    expect(store.timers.single.isRunning, isTrue);
    store.rename(store.timers.single, '  Eggs ');

    // Let the save finish before reading it back.

    await Future<void>.delayed(Duration.zero);

    final copy = TimerStore();
    await copy.load();
    expect(copy.timers.single.label, 'Eggs');
    expect(copy.timers.single.isRunning, isTrue);

    store.remove(store.timers.single);
    copy.remove(copy.timers.single);
  });

  test('toggle pauses, resumes, and a removed timer is gone', () async {
    final store = TimerStore();
    await store.load();

    store.add(const Duration(minutes: 1));
    final timer = store.timers.single;

    store.toggle(timer);
    expect(timer.isRunning, isFalse);
    store.toggle(timer);
    expect(timer.isRunning, isTrue);

    store.remove(timer);
    expect(store.timers, isEmpty);
  });

  test('edits are stamped, passed on, and deletions kept', () async {
    final store = TimerStore();
    await store.load();
    var edits = 0;
    store.onEdit = () => edits++;

    store.add(const Duration(minutes: 1));
    final timer = store.timers.single;
    expect(timer.updated, greaterThan(0));

    store.remove(timer);
    expect(edits, 2);
    expect(store.snapshot.deleted.keys, [timer.id]);

    await Future<void>.delayed(Duration.zero);

    final copy = TimerStore();
    await copy.load();
    expect(copy.snapshot.deleted.keys, [timer.id]);
  });

  test('the screen stays awake only while a timer runs', () async {
    final store = TimerStore();
    await store.load();
    expect(screenAwake.isOn, isFalse);

    store.add(const Duration(minutes: 1));
    expect(screenAwake.isOn, isTrue);

    final timer = store.timers.single;
    store.toggle(timer);
    expect(screenAwake.isOn, isFalse);

    store.toggle(timer);
    expect(screenAwake.isOn, isTrue);

    store.remove(timer);
    expect(screenAwake.isOn, isFalse);
  });

  test('a focused timer starts, and leaves focus once it stops', () async {
    final store = TimerStore();
    await store.load();

    store.add(const Duration(minutes: 1));
    final timer = store.timers.single;
    store.reset(timer);
    expect(store.focused, isNull);

    store.focus(timer);
    expect(store.focused, timer);
    expect(timer.isRunning, isTrue);

    // Focusing it again goes back to the grid, leaving it running.

    store.focus(timer);
    expect(store.focused, isNull);
    expect(timer.isRunning, isTrue);

    store.focus(timer);
    store.toggle(timer);
    expect(store.focused, isNull);

    store.focus(timer);
    store.remove(timer);
    expect(store.focused, isNull);
  });
}
