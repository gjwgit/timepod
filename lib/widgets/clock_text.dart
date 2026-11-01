/// A line of the clock's text, scaled to fill its space.
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

/// Shows [text] as large as the space allows.
///
/// 20261101 gjw The digits are tabular, all one width, so the text keeps its
/// size as the seconds tick over. With proportional digits a 1 is narrower
/// than an 8 and the scaled text would pulse every second.

class ClockText extends StatelessWidget {
  const ClockText(this.text, {super.key, this.weight = FontWeight.w300});

  /// The text to show.

  final String text;

  /// The weight of the font.

  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 120,
          fontWeight: weight,
          fontFeatures: const [FontFeature.tabularFigures()],
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
