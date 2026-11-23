/// One timer in the grid: its label, ring and time, and its buttons.
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
import 'package:timepod/widgets/timer_label_dialog.dart';
import 'package:timepod/widgets/timer_ring.dart';

/// A rounded card, after a phone's clock: the label and a delete button
/// along the top, the ring in the middle, and +1:00 and Reset beneath it
/// once the timer has been started. A ringing timer's card takes on the
/// theme's accent so it stands out in the grid.

class TimerCard extends StatelessWidget {
  const TimerCard({super.key, required this.timer, required this.now});

  /// The timer shown.

  final TimerEntry timer;

  /// The time to show the timer at.

  final DateTime now;

  Future<void> _rename(BuildContext context) async {
    final label = await showDialog<String>(
      context: context,
      builder: (_) => TimerLabelDialog(label: timer.label),
    );
    if (label != null) timerStore.rename(timer, label);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final expired = timer.isExpired(now);
    final ink = expired ? scheme.onPrimaryContainer : scheme.onSurface;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: expired ? scheme.primaryContainer : scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: MarkdownTooltip(
                    message: '''

**Label**

Give this timer a name, to tell it from the others.

''',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _rename(context),
                      child: Text(
                        timer.label.isEmpty
                            ? '${formatLength(timer.length)} timer'
                            : timer.label,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: ink),
                      ),
                    ),
                  ),
                ),
                MarkdownTooltip(
                  message: '''

**Delete**

Delete this timer.

''',
                  child: IconButton(
                    color: ink,
                    icon: const Icon(Icons.close),
                    onPressed: () => timerStore.remove(timer),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
                child: Center(
                  child: TimerRing(timer: timer, now: now, ink: ink),
                ),
              ),
            ),

            // 20261124 gjw The buttons keep their place even while hidden,
            // so the ring does not shift as a timer is started or reset, but
            // take no taps then, which Visibility.maintain alone allows.
            IgnorePointer(
              ignoring: timer.isReset,
              child: Opacity(
                opacity: timer.isReset ? 0 : 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MarkdownTooltip(
                      message: '''

**Add a Minute**

Add one minute to this timer. A timer that is ringing starts again with one
minute to go.

''',
                      child: FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: () => timerStore.addMinute(timer),
                        child: const Text('+1:00'),
                      ),
                    ),
                    MarkdownTooltip(
                      message: '''

**Reset**

Stop this timer and set it back to the time it started from.

''',
                      child: IconButton(
                        color: ink,
                        icon: const Icon(Icons.replay),
                        onPressed: () => timerStore.reset(timer),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
