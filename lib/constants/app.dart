/// Constants used throughout the app.
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

/// Application name displayed in the UI.

const appName = 'TimePod';

/// Application title displayed as the window title.

const String appTitle = 'TimePod - Privacy-First Fullscreen Clock';

/// App directory name used by solidpod for storage paths.

const appDirectory = 'timepod';

/// The seed for the app's colour scheme, a deep night blue.

const seedColour = Color(0xFF2E5A88);

// 20261101 gjw Dark whatever the app's theme, since the clock is often left
// running at night, and black pixels on an OLED screen are switched off.
//
// 20261102 gjw Shared by the fullscreen and the desktop clocks. Light on dark
// also reads on most desktop backgrounds when the desktop clock is
// transparent.

/// The theme of the clock shown on its own, light on black.

final clockTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: seedColour,
    brightness: Brightness.dark,
    surface: Colors.black,
  ),
);

/// The CHANGELOG, linked from the version shown in the app bar.

const changelogUrl = 'https://github.com/gjwgit/timepod/blob/dev/CHANGELOG.md';
