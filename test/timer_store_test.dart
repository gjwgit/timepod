/// Tests for the list of timers.

library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timepod/services/timer_store.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

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
}
