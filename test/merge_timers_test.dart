/// Tests for merging this device's timers with the Pod's.

library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:timepod/models/timer_entry.dart';
import 'package:timepod/utils/merge_timers.dart';

TimerEntry _timer(int id, int updated, [String label = '']) => TimerEntry(
  id: id,
  length: const Duration(minutes: 1),
  label: label,
  updated: updated,
);

TimerEntry _running(int id, int ran, DateTime endAt) => TimerEntry(
  id: id,
  length: const Duration(minutes: 1),
  endAt: endAt,
  ran: ran,
);

void main() {
  final now = DateTime(2026, 11, 25);
  final at = now.millisecondsSinceEpoch;

  test('every timer either has is kept, oldest first', () {
    final merged = mergeTimers(
      (timers: [_timer(3, at)], deleted: {}),
      (timers: [_timer(1, at)], deleted: {}),
      now,
      runs: true,
    );

    expect(merged.timers.map((t) => t.id), [1, 3]);
  });

  test('the newer name wins, a tie the same from either side', () {
    final TimerSet mine = (
      timers: [_timer(1, at + 1, 'a'), _timer(2, at, 'a')],
      deleted: {},
    );
    final TimerSet theirs = (
      timers: [_timer(1, at, 'b'), _timer(2, at, 'b')],
      deleted: {},
    );

    for (final (one, two) in [(mine, theirs), (theirs, mine)]) {
      final merged = mergeTimers(one, two, now, runs: true);
      expect(merged.timers.map((t) => t.label), ['a', 'b']);
    }
  });

  test('shared, the newer countdown wins', () {
    final merged = mergeTimers(
      (timers: [_timer(1, at)], deleted: {}),
      (timers: [_running(1, at + 1, now)], deleted: {}),
      now,
      runs: true,
    );

    expect(merged.timers.single.isRunning, isTrue);
  });

  test('not shared, the countdown is mine, with their new name', () {
    final mine = (timers: [_timer(1, at, 'old')], deleted: <int, int>{});
    final theirs = (
      timers: [_running(1, at + 1, now)..label = 'new', _running(2, at, now)],
      deleted: <int, int>{},
    );
    theirs.timers.first.updated = at + 1;

    final local = mergeTimers(mine, theirs, now, runs: false);
    expect(local.timers.map((t) => t.label), ['new', '']);
    expect(local.timers.any((t) => t.isRunning), isFalse);

    // The Pod's copy keeps its own countdowns, and the same names.

    final pod = mergeTimers(theirs, mine, now, runs: false);
    expect(pod.timers.map((t) => t.label), ['new', '']);
    expect(pod.timers.every((t) => t.isRunning), isTrue);
  });

  test('a timer deleted on either side is gone', () {
    final merged = mergeTimers(
      (timers: [_timer(1, at), _timer(2, at)], deleted: {3: at}),
      (timers: [_timer(3, at)], deleted: {1: at}),
      now,
      runs: true,
    );

    expect(merged.timers.map((t) => t.id), [2]);
    expect(merged.deleted, {1: at, 3: at});
  });

  test('deletions older than a month are forgotten', () {
    final old = now.subtract(const Duration(days: 31)).millisecondsSinceEpoch;
    final merged = mergeTimers(
      (timers: [], deleted: {1: old, 2: at}),
      (timers: [], deleted: {}),
      now,
      runs: true,
    );

    expect(merged.deleted, {2: at});
  });

  test('a set round trips through JSON', () {
    final set = (timers: [_timer(1, at, 'Eggs')], deleted: {2: at});
    final copy = timerSetFromJson(
      jsonDecode(jsonEncode(timerSetToJson(set))) as Map<String, dynamic>,
    );

    expect(copy.timers.single.label, 'Eggs');
    expect(copy.timers.single.updated, at);
    expect(copy.timers.single.ran, 0);
    expect(copy.deleted, {2: at});
  });
}
