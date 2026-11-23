/// Tests for a countdown timer.

library;

import 'package:flutter_test/flutter_test.dart';

import 'package:timepod/models/timer_entry.dart';

void main() {
  final t0 = DateTime(2026, 11, 24, 12);
  const five = Duration(minutes: 5);

  TimerEntry timer() => TimerEntry(id: 1, length: five);

  test('a new timer is stopped at its full length', () {
    final entry = timer();

    expect(entry.isRunning, isFalse);
    expect(entry.isReset, isTrue);
    expect(entry.remaining(t0), five);
    expect(entry.fraction(t0), 1);
  });

  test('a running timer counts down and runs out', () {
    final entry = timer()..start(t0);

    expect(
      entry.remaining(t0.add(const Duration(minutes: 2))),
      const Duration(minutes: 3),
    );
    expect(entry.fraction(t0.add(const Duration(minutes: 1))), 0.8);
    expect(entry.isExpired(t0.add(five)), isTrue);
    expect(
      entry.remaining(t0.add(const Duration(minutes: 6))),
      const Duration(minutes: -1),
    );
    expect(entry.fraction(t0.add(const Duration(minutes: 6))), 0);
  });

  test('pausing keeps the time left and resuming carries on', () {
    final entry = timer()..start(t0);
    entry.pause(t0.add(const Duration(minutes: 2)));

    final later = t0.add(const Duration(hours: 1));
    expect(entry.remaining(later), const Duration(minutes: 3));
    expect(entry.isReset, isFalse);

    entry.start(later);
    expect(
      entry.remaining(later.add(const Duration(minutes: 1))),
      const Duration(minutes: 2),
    );
  });

  test('a minute is added to a running or paused timer', () {
    final running = timer()
      ..start(t0)
      ..addMinute(t0);
    expect(running.remaining(t0), const Duration(minutes: 6));
    expect(running.total, const Duration(minutes: 6));

    final paused = timer()..addMinute(t0);
    expect(paused.remaining(t0), const Duration(minutes: 6));
    expect(paused.isReset, isFalse);
  });

  test('a minute on a ringing timer starts a fresh minute', () {
    final entry = timer()..start(t0);
    final late = t0.add(const Duration(minutes: 7));

    entry.addMinute(late);

    expect(entry.remaining(late), const Duration(minutes: 1));
    expect(entry.fraction(late), 1);
  });

  test('reset returns to the length set', () {
    final entry = timer()
      ..start(t0)
      ..addMinute(t0)
      ..reset();

    expect(entry.isReset, isTrue);
    expect(entry.remaining(t0), five);
  });

  test('a timer survives a round trip through JSON', () {
    final entry = timer()
      ..label = 'Tea'
      ..start(t0);
    final copy = TimerEntry.fromJson(entry.toJson());

    expect(copy.label, 'Tea');
    expect(copy.length, five);
    expect(copy.endAt, entry.endAt);
    expect(copy.remaining(t0), five);
  });
}
