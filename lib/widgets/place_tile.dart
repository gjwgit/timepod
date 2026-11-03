/// The choice of where the desktop clock opens.
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

import 'package:timepod/models/clock_place.dart';
import 'package:timepod/services/clock_prefs.dart';

/// A menu of the places the desktop clock can open.

class PlaceTile extends StatelessWidget {
  const PlaceTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Desktop clock place'),
      subtitle: const Text('Where on the screen the desktop clock opens.'),
      trailing: DropdownButton<ClockPlace>(
        value: clockPrefs.place,
        onChanged: (place) => clockPrefs.setPlace(place!),
        items: [
          for (final place in ClockPlace.values)
            DropdownMenuItem(value: place, child: Text(place.label)),
        ],
      ),
    );
  }
}
