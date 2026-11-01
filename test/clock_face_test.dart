/// Tests for the clock face as the display choices ask.

library;

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timepod/models/clock_option.dart';
import 'package:timepod/services/clock_prefs.dart';
import 'package:timepod/widgets/analog_clock.dart';
import 'package:timepod/widgets/clock_face.dart';
import 'package:timepod/widgets/clock_ticker.dart';

void main() {
  final now = DateTime(2026, 11, 1, 13, 45, 30);
  late ClockPrefs prefs;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    prefs = ClockPrefs();
  });

  Future<void> pump(WidgetTester tester, {Size size = const Size(800, 500)}) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClockFace(now: now, prefs: prefs),
        ),
      ),
    );
  }

  testWidgets('shows the analog clock, time and date by default', (
    tester,
  ) async {
    await pump(tester);

    expect(find.byType(AnalogClock), findsOneWidget);
    expect(find.text('13:45:30'), findsOneWidget);
    expect(find.text('Sunday 1 November 2026'), findsOneWidget);
  });

  testWidgets('follows the time choices', (tester) async {
    await prefs.set(ClockOption.seconds, false);
    await prefs.set(ClockOption.hour24, false);
    await pump(tester);

    expect(find.text('1:45 PM'), findsOneWidget);
  });

  testWidgets('leaves out what is turned off', (tester) async {
    await prefs.set(ClockOption.analog, false);
    await prefs.set(ClockOption.date, false);
    await pump(tester);

    expect(find.byType(AnalogClock), findsNothing);
    expect(find.text('13:45:30'), findsOneWidget);
    expect(find.text('Sunday 1 November 2026'), findsNothing);
  });

  testWidgets('sits side by side when wide, stacked when tall', (tester) async {
    await pump(tester);
    expect(find.byType(Row), findsOneWidget);

    await pump(tester, size: const Size(500, 800));
    expect(find.byType(Row), findsNothing);
  });

  testWidgets('the ticker moves on with the second', (tester) async {
    var time = now;

    await tester.pumpWidget(
      MaterialApp(
        home: ClockTicker(
          clock: () => time,
          builder: (context, now) => Text('${now.second}'),
        ),
      ),
    );
    expect(find.text('30'), findsOneWidget);

    time = now.add(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('31'), findsOneWidget);
  });
}
