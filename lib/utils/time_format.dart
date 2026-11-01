/// The digital time and the date as text.
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

import 'package:intl/intl.dart';

/// The time as digits, as 13:45 or 1:45 PM, with the seconds when asked.

String formatTime(
  DateTime time, {
  required bool use24Hour,
  required bool showSeconds,
}) {
  final seconds = showSeconds ? ':ss' : '';
  final pattern = use24Hour ? 'HH:mm$seconds' : 'h:mm$seconds a';

  return DateFormat(pattern).format(time);
}

/// The weekday and the date, as Sunday 1 November 2026.

String formatDate(DateTime time) => DateFormat('EEEE d MMMM yyyy').format(time);
