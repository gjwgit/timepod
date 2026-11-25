/// The Timers page's switch between sharing countdowns and keeping them here.
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

import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solidui/solidui.dart' show showPositiveSnackBar;

import 'package:timepod/services/clock_prefs.dart';
import 'package:timepod/services/pod_timers.dart';

/// A cloud that turns sharing this device's countdowns through the Pod on
/// and off: shared, every device sharing them runs the same countdowns; not
/// shared, a timer counts down only on the device it was started on. The
/// timers themselves are the same on every device either way. Disabled
/// until logged in to a Pod, with a tooltip saying so.

class TimerSyncButton extends StatelessWidget {
  const TimerSyncButton({super.key});

  void _toggle(BuildContext context) {
    final on = !clockPrefs.shareCountdowns;

    unawaited(clockPrefs.setShareCountdowns(on).then((_) => podTimers.sync()));
    showPositiveSnackBar(
      context,
      on
          ? 'Countdowns are shared with your other devices.'
          : 'Countdowns now run on this device only.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([clockPrefs, podTimers.connected]),
      builder: (context, _) {
        final connected = podTimers.connected.value;
        final on = clockPrefs.shareCountdowns;

        return MarkdownTooltip(
          message: !connected
              ? '''

**Share Countdowns**

Log in to your Solid Pod, from the profile menu, to have the same timers on
all your devices and, if you choose, share their countdowns. Until then
timers run on this device only.

'''
              : on
              ? '''

**Countdowns Shared**

A timer started, paused or stopped here does the same on every device
sharing countdowns, and rings on each as it runs out. Tap to keep this
device's countdowns to itself.

'''
              : '''

**Countdowns on This Device**

A timer counts down only on the device where it was started. The timers
themselves, their lengths and names, are the same on all your devices. Tap
to share countdowns with your other devices that share them.

''',
          child: IconButton(
            icon: Icon(on ? Icons.cloud_sync_outlined : Icons.cloud_off),
            onPressed: connected ? () => _toggle(context) : null,
          ),
        );
      },
    );
  }
}
