/// Tests for the switch between sharing timers and keeping them here.

library;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timepod/services/clock_prefs.dart';
import 'package:timepod/services/pod_timers.dart';
import 'package:timepod/widgets/timer_sync_button.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await clockPrefs.load();
  });

  tearDown(() => podTimers.connected.value = false);

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    const MaterialApp(home: Scaffold(body: TimerSyncButton())),
  );

  IconButton button(WidgetTester tester) =>
      tester.widget<IconButton>(find.byType(IconButton));

  testWidgets('disabled until connected to a Pod', (tester) async {
    await pump(tester);

    expect(button(tester).onPressed, isNull);
    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
  });

  testWidgets('once connected it turns sharing on and off', (tester) async {
    podTimers.connected.value = true;
    await pump(tester);
    expect(button(tester).onPressed, isNotNull);

    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(clockPrefs.shareCountdowns, isTrue);
    expect(find.byIcon(Icons.cloud_sync_outlined), findsOneWidget);

    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(clockPrefs.shareCountdowns, isFalse);

    // Let the SnackBar time out.

    await tester.pumpAndSettle(const Duration(seconds: 5));
  });
}
