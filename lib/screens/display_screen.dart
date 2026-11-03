/// The Display page, the clock's display choices.
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

import 'package:solidui/solidui.dart' show isDesktop;

import 'package:timepod/models/clock_option.dart';
import 'package:timepod/services/clock_prefs.dart';
import 'package:timepod/widgets/option_switch.dart';
import 'package:timepod/widgets/place_tile.dart';

/// A switch for each display choice, and on a desktop where the desktop
/// clock opens, saved on this device as they change.

class DisplayScreen extends StatelessWidget {
  const DisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: clockPrefs,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final option in ClockOption.values)
            if (isDesktop || !option.desktopOnly) OptionSwitch(option: option),
          if (isDesktop) const PlaceTile(),
        ],
      ),
    );
  }
}
