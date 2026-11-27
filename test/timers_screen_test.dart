/// Tests for the Timers page.

library;

import 'package:flutter/gestures.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timepod/screens/timers_screen.dart';
import 'package:timepod/services/screen_awake.dart';
import 'package:timepod/services/timer_store.dart';
import 'package:timepod/widgets/timer_card.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    screenAwake.toggle = ({required enable}) async {};
    await timerStore.load();
  });

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    const MaterialApp(home: Scaffold(body: TimersScreen())),
  );

  FilledButton start(WidgetTester tester) => tester.widget<FilledButton>(
    find.widgetWithIcon(FilledButton, Icons.play_arrow),
  );

  testWidgets('with no timers the page is the keypad', (tester) async {
    await pump(tester);

    expect(find.text('Add Timer'), findsOneWidget);
    expect(find.text('00'), findsNWidgets(1));
    expect(start(tester).onPressed, isNull);
  });

  testWidgets('typed digits come in from the right', (tester) async {
    await pump(tester);

    for (final key in ['1', '3', '0']) {
      await tester.tap(find.widgetWithText(FilledButton, key));
    }
    await tester.pump();

    expect(find.textContaining('01m 30s'), findsOneWidget);
    expect(start(tester).onPressed, isNotNull);

    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pump();
    expect(find.textContaining('00m 13s'), findsOneWidget);
  });

  testWidgets('starting shows a card that pauses and deletes', (tester) async {
    await pump(tester);

    await tester.tap(find.widgetWithText(FilledButton, '5'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    expect(find.byType(TimerCard), findsOneWidget);
    expect(find.text('5s timer'), findsOneWidget);
    expect(find.text('0:05'), findsOneWidget);

    // A tap on the ring waits out a possible double tap.

    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump(kDoubleTapTimeout);
    expect(timerStore.timers.single.isRunning, isFalse);
    expect(find.byIcon(Icons.replay), findsOneWidget);

    await tester.tap(find.text('+1:00'));
    await tester.pump();
    expect(find.text('1:05'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.replay));
    await tester.pump();
    expect(find.text('0:05'), findsOneWidget);

    // The hidden buttons keep their place but do nothing.

    await tester.tap(find.text('+1:00'), warnIfMissed: false);
    await tester.pump();
    expect(find.text('0:05'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(find.byType(TimerCard), findsNothing);
  });

  testWidgets('a double tapped timer starts and fills the page', (
    tester,
  ) async {
    timerStore.add(const Duration(minutes: 1));
    timerStore.add(const Duration(minutes: 2));
    timerStore.reset(timerStore.timers.first);
    await pump(tester);
    expect(find.byType(TimerCard), findsNWidgets(2));

    Future<void> doubleTap(IconData icon) async {
      await tester.tap(find.byIcon(icon));
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(find.byIcon(icon));
      await tester.pump();
    }

    await doubleTap(Icons.play_arrow);
    expect(find.byType(TimerCard), findsOneWidget);
    expect(find.text('1m timer'), findsOneWidget);
    expect(timerStore.timers.first.isRunning, isTrue);

    // Pausing it brings back the grid.

    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump(kDoubleTapTimeout);
    expect(find.byType(TimerCard), findsNWidgets(2));

    for (final timer in timerStore.timers) {
      timerStore.remove(timer);
    }
  });
}
