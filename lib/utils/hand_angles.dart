/// The angles of the analog clock's hands.
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

import 'dart:math';

/// The hour hand's angle in radians, clockwise from twelve. It moves on
/// through the hour rather than jumping on the hour.

double hourAngle(DateTime time) =>
    (time.hour % 12 + time.minute / 60 + time.second / 3600) * 2 * pi / 12;

/// The minute hand's angle in radians, clockwise from twelve, moving on
/// through the minute.

double minuteAngle(DateTime time) =>
    (time.minute + time.second / 60) * 2 * pi / 60;

/// The second hand's angle in radians, clockwise from twelve, stepping once
/// a second.

double secondAngle(DateTime time) => time.second * 2 * pi / 60;
