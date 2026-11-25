/// One countdown timer: its length, the time left, and whether it runs.
//
// Time-stamp: <>
//
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://opensource.org/license/gpl-3-0.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://opensource.org/license/gpl-3-0>.
///
/// Authors: Graham Williams

library;

/// A countdown timer. While it runs it keeps the moment it reaches zero,
/// not a count of seconds, so it stays true across a restart of the app and
/// never drifts with the ticker that redraws it.

class TimerEntry {
  TimerEntry({
    required this.id,
    required this.length,
    this.label = '',
    Duration? total,
    Duration? left,
    this.endAt,
    this.updated = 0,
    this.ran = 0,
  }) : total = total ?? length,
       left = left ?? length;

  /// Rebuild a timer saved by [toJson].

  factory TimerEntry.fromJson(Map<String, dynamic> json) => TimerEntry(
    id: json['id'] as int,
    label: json['label'] as String? ?? '',
    length: Duration(milliseconds: json['length'] as int),
    total: Duration(milliseconds: json['total'] as int),
    left: Duration(milliseconds: json['left'] as int),
    endAt: json['endAt'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(json['endAt'] as int),
    updated: json['updated'] as int? ?? 0,
    ran: json['ran'] as int? ?? 0,
  );

  /// Identifies the timer within the list.

  final int id;

  /// A name for the timer, empty until one is given.

  String label;

  /// The length the timer was set to, which Reset returns it to.

  final Duration length;

  /// The length with any minutes added, the full sweep of the ring.

  Duration total;

  /// The time left while paused.

  Duration left;

  /// When the timer reaches zero, while it runs.

  DateTime? endAt;

  /// When the timer's length or name was last changed, in milliseconds
  /// since the epoch, so the newer of two copies wins when the timers are
  /// merged with the Pod.

  int updated;

  /// When the timer was last started, paused, reset or given a minute, so
  /// the newer of two countdowns wins when countdowns are shared.

  int ran;

  /// Whether the timer is counting down, or counting up past zero.

  bool get isRunning => endAt != null;

  /// Whether the timer is stopped at its full length.

  bool get isReset => !isRunning && left == total && total == length;

  /// The time left at [now], negative once the timer has run out.

  Duration remaining(DateTime now) => endAt?.difference(now) ?? left;

  /// Whether the timer has run out and is ringing at [now].

  bool isExpired(DateTime now) => isRunning && remaining(now) <= Duration.zero;

  /// The share of the ring still to go at [now], from 1 down to 0.

  double fraction(DateTime now) {
    if (total <= Duration.zero) return 0;

    final share = remaining(now).inMilliseconds / total.inMilliseconds;
    return share.clamp(0.0, 1.0);
  }

  /// Count down from the time left.

  void start(DateTime now) => endAt = now.add(left);

  /// Stop counting, keeping the time left.

  void pause(DateTime now) {
    left = remaining(now);
    endAt = null;
  }

  /// Stop, back at the length the timer was set to.

  void reset() {
    total = length;
    left = length;
    endAt = null;
  }

  // 20261124 gjw As on a phone's clock, +1:00 on a ringing timer starts a
  // fresh minute from now rather than adding to the time already overrun.

  /// Add a minute to the timer.

  void addMinute(DateTime now) {
    const minute = Duration(minutes: 1);

    if (isExpired(now)) {
      total = minute;
      endAt = now.add(minute);
    } else {
      total += minute;
      if (isRunning) {
        endAt = endAt!.add(minute);
      } else {
        left += minute;
      }
    }
  }

  /// The timer as JSON, to save.

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'length': length.inMilliseconds,
    'total': total.inMilliseconds,
    'left': left.inMilliseconds,
    'endAt': endAt?.millisecondsSinceEpoch,
    'updated': updated,
    'ran': ran,
  };
}
