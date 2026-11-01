/// Tests for the digital time and the date as text.

library;

import 'package:flutter_test/flutter_test.dart';

import 'package:timepod/utils/time_format.dart';

void main() {
  final afternoon = DateTime(2026, 11, 1, 13, 5, 9);
  final morning = DateTime(2026, 11, 1, 9, 5, 9);

  test('24 hour time, with and without seconds', () {
    expect(
      formatTime(afternoon, use24Hour: true, showSeconds: true),
      '13:05:09',
    );
    expect(formatTime(afternoon, use24Hour: true, showSeconds: false), '13:05');
    expect(formatTime(morning, use24Hour: true, showSeconds: false), '09:05');
  });

  test('12 hour time, with and without seconds', () {
    expect(
      formatTime(afternoon, use24Hour: false, showSeconds: true),
      '1:05:09 PM',
    );
    expect(
      formatTime(morning, use24Hour: false, showSeconds: false),
      '9:05 AM',
    );
  });

  test('the date has the weekday and the month in full', () {
    expect(formatDate(afternoon), 'Sunday 1 November 2026');
  });
}
