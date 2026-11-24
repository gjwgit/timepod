/// Tests for keeping the screen awake.

library;

import 'package:flutter_test/flutter_test.dart';

import 'package:timepod/services/screen_awake.dart';

void main() {
  late ScreenAwake awake;
  late List<bool> calls;

  setUp(() {
    calls = [];
    awake = ScreenAwake()
      ..toggle = ({required enable}) async => calls.add(enable);
  });

  test('the first reason turns the wakelock on, the last off', () {
    awake.keep('timers', true);
    expect(awake.isOn, isTrue);
    expect(calls, [true]);

    awake.keep('timers', false);
    expect(awake.isOn, isFalse);
    expect(calls, [true, false]);
  });

  test('leaving one reason keeps the screen awake for another', () {
    awake
      ..keep('fullscreen', true)
      ..keep('timers', true)
      ..keep('fullscreen', false);

    expect(awake.isOn, isTrue);
    expect(calls, [true]);

    awake.keep('timers', false);
    expect(calls, [true, false]);
  });

  test('repeating a reason changes nothing', () {
    awake
      ..keep('timers', true)
      ..keep('timers', true)
      ..keep('fullscreen', false);

    expect(calls, [true]);
  });
}
