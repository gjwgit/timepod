/// The Timers page within the app.
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

import 'dart:math';

import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:material_ui/material_ui.dart';

import 'package:timepod/services/timer_store.dart';
import 'package:timepod/widgets/timer_card.dart';
import 'package:timepod/widgets/timer_setup.dart';

/// A grid of timer cards with a + button to add another. With no timers the
/// page is the keypad for the first one, as on a phone's clock.

class TimersScreen extends StatelessWidget {
  const TimersScreen({super.key});

  void _add(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) => TimerSetup(
        onStart: (length) {
          timerStore.add(length);
          Navigator.pop(context);
        },
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: timerStore,
      builder: (context, _) {
        final timers = timerStore.timers;
        if (timers.isEmpty) return TimerSetup(onStart: timerStore.add);

        final now = DateTime.now();

        return LayoutBuilder(
          builder: (context, box) {
            // 20261124 gjw As many columns as fit cards at least 170 wide,
            // two on a phone as on its own clock, but no more than there are
            // timers, and the cards no wider than 420, so one timer is one
            // large card in the middle rather than a small one in the corner.

            final columns = (box.maxWidth ~/ 170).clamp(1, timers.length);
            final width = min(box.maxWidth, columns * 420.0);
            final cardWidth = (width - 16 - 8 * (columns - 1)) / columns;

            // 20261124 gjw A card is no taller than the space above the +
            // button, so a short window still shows a row of cards whole,
            // buttons and all, the ring shrinking to fit. The + button is
            // the smaller size on a short window, to leave the cards room.

            final compact = box.maxHeight < 600;
            final bottom = compact ? 80.0 : 128.0;
            final cardHeight = max(
              200.0,
              min(cardWidth / 0.68, box.maxHeight - 8 - bottom),
            );
            final scheme = Theme.of(context).colorScheme;
            final fab = compact
                ? FloatingActionButton.new
                : FloatingActionButton.large;

            return Scaffold(
              backgroundColor: Colors.transparent,
              floatingActionButton: MarkdownTooltip(
                message: '''

**Add Timer**

Type the length of another timer and start it. Timers run side by side.

''',
                child: fab(
                  heroTag: null,
                  backgroundColor: scheme.tertiaryContainer,
                  foregroundColor: scheme.onTertiaryContainer,
                  onPressed: () => _add(context),
                  child: const Icon(Icons.add),
                ),
              ),
              body: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: width,
                  child: GridView.builder(
                    padding: EdgeInsets.fromLTRB(8, 8, 8, bottom),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisExtent: cardHeight,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: timers.length,
                    itemBuilder: (context, i) => TimerCard(
                      key: ValueKey(timers[i].id),
                      timer: timers[i],
                      now: now,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
