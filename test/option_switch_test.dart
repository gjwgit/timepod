/// Tests for the switch of a display choice.

library;

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timepod/models/clock_option.dart';
import 'package:timepod/screens/display_screen.dart';
import 'package:timepod/services/clock_prefs.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await clockPrefs.load();
  });

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    const MaterialApp(home: Scaffold(body: DisplayScreen())),
  );

  SwitchListTile tile(WidgetTester tester, ClockOption option) =>
      tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, option.title),
      );

  testWidgets('a switch for each choice, all on', (tester) async {
    await pump(tester);

    for (final option in ClockOption.values) {
      expect(tile(tester, option).value, isTrue, reason: option.name);
    }
  });

  testWidgets('tapping a switch turns its choice off', (tester) async {
    await pump(tester);

    await tester.tap(find.text(ClockOption.date.title));
    await tester.pump();

    expect(clockPrefs[ClockOption.date], isFalse);
    expect(tile(tester, ClockOption.date).value, isFalse);
  });

  testWidgets('the only clock showing cannot be turned off', (tester) async {
    await pump(tester);

    await tester.tap(find.text(ClockOption.digital.title));
    await tester.pump();

    expect(tile(tester, ClockOption.analog).onChanged, isNull);
    expect(tile(tester, ClockOption.digital).onChanged, isNotNull);
  });
}
