/// Tests for the Settings page.

library;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timepod/models/alarm_sound.dart';
import 'package:timepod/screens/settings_screen.dart';
import 'package:timepod/services/clock_prefs.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await clockPrefs.load();
  });

  // A window tall enough for every setting, since the list builds only the
  // rows on screen.

  Future<void> pump(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    return tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SettingsScreen())),
    );
  }

  testWidgets('a Display and a Timer section', (tester) async {
    await pump(tester);

    expect(find.text('Display'), findsOneWidget);
    expect(find.text('Timer'), findsOneWidget);
    expect(find.text('Alarm sound'), findsOneWidget);
  });

  testWidgets('choosing a sound saves it and describes it', (tester) async {
    await pump(tester);

    expect(find.text(AlarmSound.guitar.description), findsOneWidget);

    await tester.tap(find.text(AlarmSound.guitar.label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AlarmSound.beeps.label).last);
    await tester.pumpAndSettle();

    expect(clockPrefs.alarm, AlarmSound.beeps);
    expect(find.text(AlarmSound.beeps.description), findsOneWidget);
  });
}
