/// The switch for one display choice.
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

import 'package:markdown_tooltip/markdown_tooltip.dart';

import 'package:timepod/models/clock_option.dart';
import 'package:timepod/services/clock_prefs.dart';

/// A switch for [option], disabled when it is the only clock showing, with a
/// tooltip saying why.

class OptionSwitch extends StatelessWidget {
  const OptionSwitch({super.key, required this.option});

  /// The choice the switch turns on and off.

  final ClockOption option;

  @override
  Widget build(BuildContext context) {
    final locked = clockPrefs.isLastFace(option);

    final tile = SwitchListTile(
      title: Text(option.title),
      subtitle: Text(option.description),
      value: clockPrefs[option],
      onChanged: locked ? null : (value) => clockPrefs.set(option, value),
    );

    if (!locked) return tile;

    return MarkdownTooltip(
      message: '''

**Keep a Clock**

This is the only clock showing. Turn on the other clock first, so there is
always a clock on the screen.

''',
      child: tile,
    );
  }
}
