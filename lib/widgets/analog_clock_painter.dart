/// Paints the analog clock face and its hands.
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

import 'package:flutter/material.dart';

import 'package:timepod/utils/hand_angles.dart';

/// Draws the minute and hour marks, the hands for [time], and the second
/// hand in [accent] when [showSeconds].

class AnalogClockPainter extends CustomPainter {
  AnalogClockPainter({
    required this.time,
    required this.showSeconds,
    required this.colour,
    required this.accent,
  });

  /// The time the hands show.

  final DateTime time;

  /// Whether to draw the second hand.

  final bool showSeconds;

  /// The colour of the marks and the hour and minute hands.

  final Color colour;

  /// The colour of the second hand.

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = min(size.width, size.height) / 2;
    final centre = size.center(Offset.zero);

    final mark = Paint()
      ..color = colour
      ..strokeCap = StrokeCap.round;

    // The hour marks are longer and heavier than the minute marks.

    for (var i = 0; i < 60; i++) {
      final hour = i % 5 == 0;
      final direction = _direction(i * 2 * pi / 60);

      mark.strokeWidth = radius * (hour ? 0.03 : 0.012);
      canvas.drawLine(
        centre + direction * radius * (hour ? 0.84 : 0.91),
        centre + direction * radius * 0.97,
        mark,
      );
    }

    _hand(canvas, centre, hourAngle(time), radius * 0.5, radius * 0.05, colour);
    _hand(
      canvas,
      centre,
      minuteAngle(time),
      radius * 0.78,
      radius * 0.035,
      colour,
    );

    if (showSeconds) {
      _hand(
        canvas,
        centre,
        secondAngle(time),
        radius * 0.88,
        radius * 0.012,
        accent,
        tail: radius * 0.15,
      );
    }

    canvas.drawCircle(centre, radius * 0.04, Paint()..color = accent);
  }

  // The unit vector for an angle measured clockwise from twelve.

  Offset _direction(double angle) => Offset(sin(angle), -cos(angle));

  // A hand from just behind the centre, by [tail], out to [length].

  void _hand(
    Canvas canvas,
    Offset centre,
    double angle,
    double length,
    double width,
    Color colour, {
    double tail = 0,
  }) {
    final direction = _direction(angle);
    final paint = Paint()
      ..color = colour
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      centre - direction * tail,
      centre + direction * length,
      paint,
    );
  }

  @override
  bool shouldRepaint(AnalogClockPainter old) =>
      old.time != time ||
      old.showSeconds != showSeconds ||
      old.colour != colour ||
      old.accent != accent;
}
