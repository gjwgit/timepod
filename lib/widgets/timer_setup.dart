/// Type the length of a new timer and start it.
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

import 'package:timepod/utils/timer_format.dart';
import 'package:timepod/widgets/timer_keypad.dart';

/// The Add Timer page: Start in the app bar, and the 00h 00m 00s display
/// over a number pad, scaled to fit. Digits come in from the right, as on a
/// phone's clock, so typing 1 3 0 sets one minute thirty.

class TimerSetup extends StatefulWidget {
  const TimerSetup({super.key, required this.onStart, this.actions = const []});

  /// Called with the length typed when Start is tapped.

  final ValueChanged<Duration> onStart;

  /// Buttons for the app bar, before Start.

  final List<Widget> actions;

  @override
  State<TimerSetup> createState() => _TimerSetupState();
}

class _TimerSetupState extends State<TimerSetup> {
  static const _units = ['h ', 'm ', 's'];

  String _digits = '';

  // 20261124 gjw Leading zeros are dropped, so they never use up one of the
  // six places.

  void _type(String digits) => setState(() {
    final typed = '$_digits$digits'.replaceFirst(RegExp('^0+'), '');
    if (typed.length <= keypadMaxDigits) _digits = typed;
  });

  void _delete() => setState(
    () => _digits = _digits.isEmpty
        ? ''
        : _digits.substring(0, _digits.length - 1),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colour = _digits.isEmpty
        ? theme.colorScheme.outline
        : theme.colorScheme.primary;
    final big = theme.textTheme.displayMedium?.copyWith(color: colour);
    final small = theme.textTheme.titleLarge?.copyWith(color: colour);
    final fields = keypadFields(_digits);

    // 20261124 gjw Start sits in the app bar, on the line with the title
    // and, on the Add Timer page, the close button, where it is never lost
    // below the keypad. The keypad has its own app bar so that line is the
    // same on the empty Timers page.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Timer'),
        actions: [
          ...widget.actions,
          MarkdownTooltip(
            message: '''

**Start**

Start a timer for the time typed. It keeps running while you use the rest of
the app, and on through a restart of the app.

''',
            child: FilledButton(
              // 20261124 gjw Name the icon colour. Left to the default, the
              // enabled button drew its icon in the faint disabled colour.

              style: FilledButton.styleFrom(
                iconColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _digits.isEmpty
                  ? null
                  : () => widget.onStart(keypadDuration(_digits)),
              child: const Icon(Icons.play_arrow, size: 28),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),

      // 20261124 gjw Lay the keypad out at a fixed 360 wide and scale it
      // all, keys and time together, to fill the space, no more than twice
      // that size, so it is neither lost on a desktop nor cut off on a phone
      // turned on its side.
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SizedBox.expand(
              child: FittedBox(
                child: SizedBox(
                  width: 360,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            for (final (i, unit) in _units.indexed) ...[
                              TextSpan(text: fields[i], style: big),
                              TextSpan(text: unit, style: small),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TimerKeypad(onDigits: _type, onDelete: _delete),
                    ],
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
