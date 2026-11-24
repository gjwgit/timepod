/// The sounds a timer can ring with.
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

/// The sound a timer rings with once it runs out, chosen under Settings.
/// All are made for TimePod, so carry no one else's licence.

enum AlarmSound {
  guitar(
    'Gentle guitar',
    'Fingerpicked guitar, very quiet at first and swelling over 15 '
        'seconds.',
    'sounds/timer_guitar.wav',
    swells: true,
  ),

  // 20261124 gjw An original piece in the romantic classical guitar style,
  // not any existing work, which would carry its composer's copyright.

  classical(
    'Classical guitar',
    'A slow, singing classical guitar melody over flowing arpeggios, very '
        'quiet at first and swelling over 15 seconds.',
    'sounds/timer_classical.wav',
    swells: true,
  ),
  beeps(
    'Beeps',
    'Four quick beeps, again and again, at the same volume throughout.',
    'sounds/timer_beeps.wav',
    swells: false,
  );

  const AlarmSound(
    this.label,
    this.description,
    this.asset, {
    required this.swells,
  });

  /// The name of the sound in Settings.

  final String label;

  /// What the sound is like, under its name in Settings.

  final String description;

  /// The sound file, relative to `assets/`, as the audio player takes it.

  final String asset;

  /// Whether the sound starts quiet and swells, or starts at full volume.

  final bool swells;
}
