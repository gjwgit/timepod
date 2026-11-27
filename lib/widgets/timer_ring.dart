/// A timer's ring, with the time left and a play or pause icon inside it.
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

import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:material_ui/material_ui.dart';

import 'package:timepod/models/timer_entry.dart';
import 'package:timepod/services/timer_store.dart';
import 'package:timepod/utils/timer_format.dart';

/// A thin ring that empties as the timer counts down, around the time left
/// in light digits and, beneath them, the icon for what a tap does: start,
/// pause, or stop the ringing. The whole ring is the button, as on a phone's
/// clock. A double tap makes the timer the focus, filling the page.

class TimerRing extends StatelessWidget {
  const TimerRing({
    super.key,
    required this.timer,
    required this.now,
    required this.ink,
  });

  /// The timer shown.

  final TimerEntry timer;

  /// The time to show the timer at.

  final DateTime now;

  /// The colour of the digits and icon.

  final Color ink;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final expired = timer.isExpired(now);
    final (icon, title, body) = expired
        ? (
            Icons.stop,
            'Stop',
            'Stop the ringing and set this timer back to the time it started '
                'from.',
          )
        : timer.isRunning
        ? (Icons.pause, 'Pause', 'Pause this timer, keeping the time left.')
        : (Icons.play_arrow, 'Start', 'Count down from the time left.');
    final focus = timerStore.focused == timer
        ? 'Double tap to go back to all the timers.'
        : 'Double tap to start it and fill the page with it until it stops.';

    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, box) {
          final size = box.maxWidth;

          return MarkdownTooltip(
            message:
                '''

**$title**

$body $focus

''',
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => timerStore.toggle(timer),
              onDoubleTap: () => timerStore.focus(timer),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: timer.fraction(now),
                    strokeWidth: size * 0.03,
                    strokeCap: StrokeCap.round,
                    color: scheme.primary,
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: size * 0.12),
                      SizedBox(
                        width: size * 0.72,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            formatTimer(timer.remaining(now)),
                            style: TextStyle(
                              fontSize: size * 0.26,
                              fontWeight: FontWeight.w300,
                              color: ink,
                            ),
                          ),
                        ),
                      ),
                      Icon(icon, size: size * 0.2, color: ink),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
