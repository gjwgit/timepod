/// Tests for showing a timer's time and reading its keypad.

library;

import 'package:flutter_test/flutter_test.dart';

import 'package:timepod/utils/timer_format.dart';

void main() {
  test('the time left rounds up to the second', () {
    expect(formatTimer(const Duration(minutes: 5)), '5:00');
    expect(
      formatTimer(const Duration(minutes: 4, seconds: 59, milliseconds: 1)),
      '5:00',
    );
    expect(formatTimer(const Duration(milliseconds: 400)), '0:01');
    expect(formatTimer(Duration.zero), '0:00');
  });

  test('hours show only when there are some', () {
    expect(
      formatTimer(const Duration(hours: 1, minutes: 4, seconds: 9)),
      '1:04:09',
    );
    expect(formatTimer(const Duration(minutes: 59, seconds: 59)), '59:59');
  });

  test('time past zero is negative once a second has passed', () {
    expect(formatTimer(const Duration(milliseconds: -400)), '0:00');
    expect(formatTimer(const Duration(seconds: -1)), '-0:01');
    expect(formatTimer(const Duration(minutes: -2, seconds: -5)), '-2:05');
  });

  test('a length names a timer', () {
    expect(formatLength(const Duration(minutes: 10)), '10m');
    expect(formatLength(const Duration(hours: 1, minutes: 30)), '1h 30m');
    expect(formatLength(const Duration(minutes: 1, seconds: 5)), '1m 5s');
    expect(formatLength(const Duration(seconds: 45)), '45s');
  });

  test('keypad digits fill from the right', () {
    expect(keypadFields(''), ['00', '00', '00']);
    expect(keypadFields('130'), ['00', '01', '30']);
    expect(keypadFields('123456'), ['12', '34', '56']);
  });

  test('keypad fields may overflow into the next unit', () {
    expect(keypadDuration('130'), const Duration(minutes: 1, seconds: 30));
    expect(keypadDuration('90'), const Duration(minutes: 1, seconds: 30));
    expect(keypadDuration('7500'), const Duration(hours: 1, minutes: 15));
  });
}
