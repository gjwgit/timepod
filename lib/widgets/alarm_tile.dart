/// The choice of the sound a timer rings with.
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

import 'package:material_ui/material_ui.dart';

import 'package:timepod/models/alarm_sound.dart';
import 'package:timepod/services/clock_prefs.dart';

/// A menu of the alarm sounds, with what the chosen one is like beneath.

class AlarmTile extends StatelessWidget {
  const AlarmTile({super.key});

  @override
  Widget build(BuildContext context) {
    // 20261124 gjw Listen here, not only in the page around it: the page
    // builds this tile as a constant, so its rebuild alone would leave the
    // menu showing the old choice.

    return ListenableBuilder(
      listenable: clockPrefs,
      builder: (context, _) => ListTile(
        title: const Text('Alarm sound'),
        subtitle: Text(clockPrefs.alarm.description),
        trailing: DropdownButton<AlarmSound>(
          value: clockPrefs.alarm,
          onChanged: (sound) => clockPrefs.setAlarm(sound!),
          items: [
            for (final sound in AlarmSound.values)
              DropdownMenuItem(value: sound, child: Text(sound.label)),
          ],
        ),
      ),
    );
  }
}
