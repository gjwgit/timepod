/// Where the desktop clock is placed on the screen.
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

import 'package:flutter/painting.dart';

/// Where the desktop clock opens: where it was last left, or in a corner or
/// the centre of the screen the app is on.

enum ClockPlace {
  left('Where it was left'),
  topLeft('Top left', Alignment.topLeft),
  topRight('Top right', Alignment.topRight),
  bottomLeft('Bottom left', Alignment.bottomLeft),
  bottomRight('Bottom right', Alignment.bottomRight),
  centre('Centre', Alignment.center);

  const ClockPlace(this.label, [this.alignment]);

  /// The name of the place in Display.

  final String label;

  /// Where on the screen the clock goes, or null to leave it where it was.

  final Alignment? alignment;
}
