/// The clock's display choices, kept on this device.
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

import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:timepod/models/clock_option.dart';
import 'package:timepod/models/clock_place.dart';

/// The display choices, saved to SharedPreferences as they change. They are
/// device preferences, never synced to the Pod: a clock on the bedside tablet
/// and one on the desk monitor are set up differently.

class ClockPrefs extends ChangeNotifier {
  static const _placeKey = 'timepod_desktopClockPlace';

  final _values = {for (final option in ClockOption.values) option: true};

  /// Where the desktop clock opens.

  ClockPlace place = ClockPlace.left;

  /// Whether [option] is on.

  bool operator [](ClockOption option) => _values[option]!;

  /// Read the saved choices, any not yet saved staying on.

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    for (final option in ClockOption.values) {
      _values[option] = prefs.getBool(option.key) ?? true;
    }
    place =
        ClockPlace.values.asNameMap()[prefs.getString(_placeKey)] ??
        ClockPlace.left;

    notifyListeners();
  }

  /// Turn [option] on or off, saving the choice.

  Future<void> set(ClockOption option, bool value) async {
    _values[option] = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(option.key, value);
  }

  /// Open the desktop clock at [value], saving the choice.

  Future<void> setPlace(ClockPlace value) async {
    place = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_placeKey, value.name);
  }

  /// Whether [option] is the only clock showing, which Display keeps on so
  /// the screen is never left without a clock.

  bool isLastFace(ClockOption option) => switch (option) {
    ClockOption.analog => !this[ClockOption.digital],
    ClockOption.digital => !this[ClockOption.analog],
    _ => false,
  };
}

/// The app's one set of display choices.

final clockPrefs = ClockPrefs();
