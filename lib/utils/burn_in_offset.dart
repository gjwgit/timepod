/// How far to shift the fullscreen clock to save an OLED screen.
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
import 'dart:ui' show Offset;

/// The shift for [now], a point [radius] logical pixels from the centre.
///
/// 20261101 gjw The point steps round by the golden angle each minute, so
/// successive positions spread evenly round the circle rather than wearing
/// a path, and no pixel shows the same part of the face for more than a
/// minute. Fullscreen Clock does the same with a random shift.

Offset burnInOffset(DateTime now, {double radius = 12}) {
  final minute = now.hour * 60 + now.minute;
  final angle = minute * pi * (3 - sqrt(5));

  return Offset(cos(angle), sin(angle)) * radius;
}
