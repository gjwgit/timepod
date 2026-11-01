/// Tests for the burn-in shift of the fullscreen clock.

library;

import 'package:flutter_test/flutter_test.dart';

import 'package:timepod/utils/burn_in_offset.dart';

void main() {
  test('the shift is always the radius from the centre', () {
    for (var minute = 0; minute < 24 * 60; minute += 37) {
      final now = DateTime(2026, 11, 1, minute ~/ 60, minute % 60);

      expect(burnInOffset(now, radius: 10).distance, closeTo(10, 1e-9));
    }
  });

  test('the shift holds through a minute', () {
    expect(
      burnInOffset(DateTime(2026, 11, 1, 3, 4, 0)),
      burnInOffset(DateTime(2026, 11, 1, 3, 4, 59)),
    );
  });

  test('the shift moves from one minute to the next', () {
    final first = burnInOffset(DateTime(2026, 11, 1, 3, 4));
    final next = burnInOffset(DateTime(2026, 11, 1, 3, 5));

    expect((first - next).distance, greaterThan(1));
  });
}
