/// The clock as the display choices ask: analog, digital, date.
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

import 'package:timepod/models/clock_option.dart';
import 'package:timepod/services/clock_prefs.dart';
import 'package:timepod/utils/time_format.dart';
import 'package:timepod/widgets/analog_clock.dart';
import 'package:timepod/widgets/clock_text.dart';

/// The clock for [now]. With the analog face and text both showing they sit
/// side by side in a wide space and one above the other in a tall one.

class ClockFace extends StatelessWidget {
  const ClockFace({super.key, required this.now, required this.prefs});

  /// The time to show.

  final DateTime now;

  /// The display choices.

  final ClockPrefs prefs;

  @override
  Widget build(BuildContext context) {
    final digital = prefs[ClockOption.digital];
    final date = prefs[ClockOption.date];
    final seconds = prefs[ClockOption.seconds];

    final text = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (digital)
          Flexible(
            flex: 3,
            child: ClockText(
              formatTime(
                now,
                use24Hour: prefs[ClockOption.hour24],
                showSeconds: seconds,
              ),
            ),
          ),
        if (date) Flexible(child: ClockText(formatDate(now))),
      ],
    );

    if (!prefs[ClockOption.analog]) return Center(child: text);

    final face = Center(
      child: AnalogClock(time: now, showSeconds: seconds),
    );

    if (!digital && !date) return face;

    return LayoutBuilder(
      builder: (context, constraints) {
        final children = [
          Expanded(child: face),
          const SizedBox.square(dimension: 24),
          Expanded(child: text),
        ];

        return constraints.maxWidth > constraints.maxHeight
            ? Row(children: children)
            : Column(children: children);
      },
    );
  }
}
