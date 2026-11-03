/// Tests for the display choices.

library;

import 'package:flutter_test/flutter_test.dart';

import 'package:timepod/models/clock_option.dart';

void main() {
  test('only the desktop clock choices are desktop only', () {
    expect(ClockOption.values.where((option) => option.desktopOnly), [
      ClockOption.transparent,
      ClockOption.appSize,
    ]);
  });

  test('each choice is saved under its own key', () {
    final keys = ClockOption.values.map((option) => option.key).toSet();
    expect(keys.length, ClockOption.values.length);
    expect(ClockOption.transparent.key, 'timepod_transparent');
  });
}
