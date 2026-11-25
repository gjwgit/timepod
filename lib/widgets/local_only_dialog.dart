/// Tell the user the Pod is not connected and the timers are this device's.
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

/// Say, as the app starts, that the Pod it has used before is not connected,
/// so the timers shown are this device's own.

Future<void> showLocalOnlyDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Not connected to your Pod'),
    content: const Text(
      'You are not currently connected to your Solid Pod, where your timers '
      'are kept so that every device shows the same ones.\n\n'
      'TimePod will use the timers kept on this device. Any changes made '
      'here stay on this device until you connect again, when they are '
      'merged with the timers on your Pod.\n\n'
      'Log in from the profile menu to connect to your Pod.',
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('OK'),
      ),
    ],
  ),
);
