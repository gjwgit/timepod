/// Tests for the clock's display choices.

library;

import 'package:flutter_test/flutter_test.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:timepod/models/clock_option.dart';
import 'package:timepod/services/clock_prefs.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('every choice starts on', () async {
    final prefs = ClockPrefs();
    await prefs.load();

    for (final option in ClockOption.values) {
      expect(prefs[option], isTrue, reason: option.name);
    }
  });

  test('a choice is saved and read back', () async {
    await ClockPrefs().set(ClockOption.seconds, false);

    final prefs = ClockPrefs();
    await prefs.load();

    expect(prefs[ClockOption.seconds], isFalse);
    expect(prefs[ClockOption.date], isTrue);
  });

  test('a change notifies listeners', () async {
    final prefs = ClockPrefs();
    var notified = 0;
    prefs.addListener(() => notified++);

    await prefs.set(ClockOption.date, false);

    expect(notified, 1);
  });

  test('the only clock showing is the last face', () async {
    final prefs = ClockPrefs();

    expect(prefs.isLastFace(ClockOption.analog), isFalse);
    expect(prefs.isLastFace(ClockOption.digital), isFalse);

    await prefs.set(ClockOption.digital, false);

    expect(prefs.isLastFace(ClockOption.analog), isTrue);
    expect(prefs.isLastFace(ClockOption.digital), isFalse);
    expect(prefs.isLastFace(ClockOption.date), isFalse);
  });
}
