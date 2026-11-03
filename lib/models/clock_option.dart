/// The display choices for the clock, each a switch under Display.
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

/// One display choice. All of them start on, as they do in Fullscreen Clock,
/// on which TimePod is based.

enum ClockOption {
  analog('Analog clock', 'Show the clock face with its hands.'),
  digital('Digital clock', 'Show the time in digits.'),
  date('Date', 'Show the weekday and the date.'),
  seconds('Seconds', 'Show the second hand and the seconds digits.'),
  hour24('24 hour time', 'Show 13:00 rather than 1:00 PM.'),
  burnIn(
    'Burn-in protection',
    'Shift the fullscreen clock a little each minute so the face does not '
        'burn into an OLED screen.',
  ),
  transparent(
    'Transparent desktop clock',
    'Show the desktop through the desktop clock rather than a black '
        'background.',
    desktopOnly: true,
  ),
  appSize(
    'Desktop clock the size of the app',
    'Open the desktop clock the size of the app window, rather than the size '
        'it was last left at.',
    desktopOnly: true,
  );

  const ClockOption(this.title, this.description, {this.desktopOnly = false});

  /// The label of the option's switch.

  final String title;

  /// A sentence beneath the label saying what the option does.

  final String description;

  /// Whether the option only applies on a desktop, so Display shows it only
  /// there.

  final bool desktopOnly;

  /// The SharedPreferences key the choice is saved under.

  String get key => 'timepod_$name';
}
