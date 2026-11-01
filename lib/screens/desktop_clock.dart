/// The clock alone in a small frameless window, sitting on the desktop.
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:window_manager/window_manager.dart';

import 'package:timepod/constants/app.dart';
import 'package:timepod/models/clock_option.dart';
import 'package:timepod/services/clock_prefs.dart';
import 'package:timepod/services/desktop_window.dart';
import 'package:timepod/widgets/clock_face.dart';
import 'package:timepod/widgets/clock_ticker.dart';

/// The clock with no app around it, a little like a conky clock: drag it to
/// move it, drag its edges to resize it, and double-click, right-click or
/// press Escape to return to the app. Only on a desktop.

class DesktopClock extends StatefulWidget {
  const DesktopClock({super.key});

  /// Show the desktop clock in place of the app.
  ///
  /// 20261102 gjw An opaque route with no transition, so the app beneath is
  /// never painted and does not show through a transparent clock.

  static Future<void> open(BuildContext context) => Navigator.of(context).push(
    PageRouteBuilder<void>(
      pageBuilder: (_, _, _) => const DesktopClock(),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
  );

  @override
  State<DesktopClock> createState() => _DesktopClockState();
}

class _DesktopClockState extends State<DesktopClock> with WindowListener {
  Timer? _settle;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    DesktopWindow.enter(transparent: clockPrefs[ClockOption.transparent]);
  }

  @override
  void dispose() {
    _settle?.cancel();
    windowManager.removeListener(this);
    DesktopWindow.leave();
    super.dispose();
  }

  // Remember the clock's place once it stops moving, as for the app's size.

  void _remember() {
    _settle?.cancel();
    _settle = Timer(const Duration(seconds: 1), DesktopWindow.save);
  }

  @override
  void onWindowMove() => _remember();

  @override
  void onWindowResize() => _remember();

  void _exit() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: clockTheme,
      child: ListenableBuilder(
        listenable: clockPrefs,
        builder: (context, _) => Scaffold(
          backgroundColor: clockPrefs[ClockOption.transparent]
              ? Colors.transparent
              : Colors.black,
          body: CallbackShortcuts(
            bindings: {const SingleActivator(LogicalKeyboardKey.escape): _exit},
            child: Focus(
              autofocus: true,
              child: DragToResizeArea(
                child: DragToMoveArea(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onDoubleTap: _exit,
                    onSecondaryTap: _exit,
                    child: ClockTicker(
                      builder: (context, now) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: ClockFace(now: now, prefs: clockPrefs),
                      ),
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
