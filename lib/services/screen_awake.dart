/// Keep the screen awake while any part of the app needs it.
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

import 'dart:async';

import 'package:wakelock_plus/wakelock_plus.dart';

/// The one wakelock, held while any reason for it holds. The fullscreen
/// clock and a running timer each keep the screen awake, and leaving one
/// must not let the screen sleep while the other still needs it.

class ScreenAwake {
  final _reasons = <String>{};

  /// Turns the platform's wakelock on or off, replaced in tests.

  Future<void> Function({required bool enable}) toggle = WakelockPlus.toggle;

  /// Whether the screen is being kept awake.

  bool get isOn => _reasons.isNotEmpty;

  /// Keep the screen awake for [reason], or stop doing so, turning the
  /// wakelock on with the first reason and off with the last.

  void keep(String reason, bool on) {
    final was = isOn;

    if (on) {
      _reasons.add(reason);
    } else {
      _reasons.remove(reason);
    }

    if (isOn != was) unawaited(toggle(enable: isOn));
  }
}

/// The app's one wakelock.

final screenAwake = ScreenAwake();
