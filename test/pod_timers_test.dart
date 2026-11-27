/// Tests for keeping the timers on the Pod.

library;

import 'package:flutter_test/flutter_test.dart';

import 'package:timepod/services/pod_timers.dart';

void main() {
  test('refresh from the Pod says why it cannot until connected', () {
    expect(PodTimers().refresh(), throwsStateError);
  });
}
