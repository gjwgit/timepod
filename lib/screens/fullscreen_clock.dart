/// The clock filling the whole screen.
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
import 'package:flutter/services.dart';

import 'package:solidui/solidui.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:window_manager/window_manager.dart';

import 'package:timepod/constants/app.dart';
import 'package:timepod/models/clock_option.dart';
import 'package:timepod/services/clock_prefs.dart';
import 'package:timepod/utils/burn_in_offset.dart';
import 'package:timepod/widgets/clock_face.dart';
import 'package:timepod/widgets/clock_ticker.dart';

/// The clock on black, the screen kept awake and the window or the system
/// bars out of the way. A tap, Escape or Back returns to the app.

class FullscreenClock extends StatefulWidget {
  const FullscreenClock({super.key});

  /// Show the fullscreen clock over the app.

  static Future<void> open(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const FullscreenClock()));

  @override
  State<FullscreenClock> createState() => _FullscreenClockState();
}

class _FullscreenClockState extends State<FullscreenClock> {
  // 20261101 gjw Dark whatever the app's theme, since the clock is often left
  // running at night, and black pixels on an OLED screen are switched off.

  static final _dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColour,
      brightness: Brightness.dark,
      surface: Colors.black,
    ),
  );

  @override
  void initState() {
    super.initState();
    _fill(true);
  }

  @override
  void dispose() {
    _fill(false);
    super.dispose();
  }

  // Fill the screen and keep it awake, or put it all back. On a desktop the
  // window goes fullscreen, on a phone the system bars hide.

  void _fill(bool on) {
    WakelockPlus.toggle(enable: on);
    SystemChrome.setEnabledSystemUIMode(
      on ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
    if (isDesktop) windowManager.setFullScreen(on);
  }

  void _exit() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _dark,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: CallbackShortcuts(
          bindings: {const SingleActivator(LogicalKeyboardKey.escape): _exit},
          child: Focus(
            autofocus: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _exit,
              child: ListenableBuilder(
                listenable: clockPrefs,
                builder: (context, _) => ClockTicker(
                  builder: (context, now) => Transform.translate(
                    offset: clockPrefs[ClockOption.burnIn]
                        ? burnInOffset(now)
                        : Offset.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: ClockFace(now: now, prefs: clockPrefs),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
