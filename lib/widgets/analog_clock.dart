/// The analog clock, square and as large as its space allows.
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

import 'package:flutter/material.dart';

import 'package:timepod/widgets/analog_clock_painter.dart';

/// The clock face for [time] in the theme's colours: the marks and hands in
/// onSurface and the second hand in primary.

class AnalogClock extends StatelessWidget {
  const AnalogClock({super.key, required this.time, required this.showSeconds});

  /// The time the hands show.

  final DateTime time;

  /// Whether to draw the second hand.

  final bool showSeconds;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: AnalogClockPainter(
          time: time,
          showSeconds: showSeconds,
          colour: scheme.onSurface,
          accent: scheme.primary,
        ),
      ),
    );
  }
}
