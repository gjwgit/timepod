/// The Clock page within the app.
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

import 'package:timepod/services/clock_prefs.dart';
import 'package:timepod/widgets/clock_face.dart';
import 'package:timepod/widgets/clock_ticker.dart';

/// The ticking clock, redrawn as the display choices change.

class ClockScreen extends StatelessWidget {
  const ClockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: clockPrefs,
      builder: (context, _) => ClockTicker(
        builder: (context, now) => Padding(
          padding: const EdgeInsets.all(24),
          child: ClockFace(now: now, prefs: clockPrefs),
        ),
      ),
    );
  }
}
