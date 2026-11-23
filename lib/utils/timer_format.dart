/// Show a timer's time, and read the digits typed on its keypad.
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

/// The most digits the keypad takes, two each for hours, minutes, seconds.

const keypadMaxDigits = 6;

String _two(int n) => n.toString().padLeft(2, '0');

// 20261124 gjw The time left is rounded UP to the second, so a five minute
// timer shows 5:00 as it starts and 0:00 only as it runs out. The time past
// zero is rounded down, so -0:01 shows once a full second has passed.

/// The time [left] as 4:59 or 1:04:59, with a minus sign once past zero.

String formatTimer(Duration left) {
  final ms = left.inMilliseconds;
  final seconds = ms < 0 ? -ms ~/ 1000 : (ms + 999) ~/ 1000;

  final h = seconds ~/ 3600;
  final m = seconds ~/ 60 % 60;
  final s = seconds % 60;
  final body = h > 0 ? '$h:${_two(m)}:${_two(s)}' : '$m:${_two(s)}';

  return ms < 0 && seconds > 0 ? '-$body' : body;
}

/// The [length] a timer was set to, as 10m, 1h 30m or 45s, to name it.

String formatLength(Duration length) {
  final h = length.inHours;
  final m = length.inMinutes % 60;
  final s = length.inSeconds % 60;

  return [if (h > 0) '${h}h', if (m > 0) '${m}m', if (s > 0) '${s}s'].join(' ');
}

/// The keypad's [digits] as hours, minutes and seconds, each two digits, the
/// last typed digit being the last of the seconds.

List<String> keypadFields(String digits) {
  final padded = digits.padLeft(keypadMaxDigits, '0');
  return [padded.substring(0, 2), padded.substring(2, 4), padded.substring(4)];
}

// 20261124 gjw Each field is read as typed, so 90 seconds or 75 minutes are
// fine and come out as 1:30 or 1:15:00.

/// The length the keypad's [digits] set.

Duration keypadDuration(String digits) {
  final [h, m, s] = keypadFields(digits).map(int.parse).toList();
  return Duration(hours: h, minutes: m, seconds: s);
}
