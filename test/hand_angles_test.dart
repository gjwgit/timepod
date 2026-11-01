/// Tests for the angles of the analog clock's hands.

library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:timepod/utils/hand_angles.dart';

void main() {
  test('all hands point to twelve at midnight and noon', () {
    for (final time in [DateTime(2026, 11, 1), DateTime(2026, 11, 1, 12)]) {
      expect(hourAngle(time), 0);
      expect(minuteAngle(time), 0);
      expect(secondAngle(time), 0);
    }
  });

  test('three o\'clock is a quarter turn', () {
    expect(hourAngle(DateTime(2026, 11, 1, 15)), closeTo(pi / 2, 1e-9));
  });

  test('the hour hand is half way to the next hour at half past', () {
    final angle = hourAngle(DateTime(2026, 11, 1, 3, 30));

    expect(angle, closeTo(3.5 * 2 * pi / 12, 1e-9));
  });

  test('the minute hand moves on through the minute', () {
    final angle = minuteAngle(DateTime(2026, 11, 1, 0, 15, 30));

    expect(angle, closeTo(15.5 * 2 * pi / 60, 1e-9));
  });

  test('the second hand steps by whole seconds', () {
    final time = DateTime(2026, 11, 1, 0, 0, 45, 900);

    expect(secondAngle(time), closeTo(3 * pi / 2, 1e-9));
  });
}
