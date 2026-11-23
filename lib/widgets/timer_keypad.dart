/// The number pad for typing the length of a new timer.
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

/// Digits 1 to 9, then 00, 0 and a delete key, in round buttons.

class TimerKeypad extends StatelessWidget {
  const TimerKeypad({
    super.key,
    required this.onDigits,
    required this.onDelete,
  });

  /// Called with the digits of the key tapped, one or, for 00, two.

  final ValueChanged<String> onDigits;

  /// Called when the delete key is tapped.

  final VoidCallback onDelete;

  static const _keys = [
    '1', '2', '3', '4', '5', '6', '7', '8', '9', '00', '0', //
  ];

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headlineMedium;

    Widget key(Widget child, VoidCallback onPressed) => Padding(
      padding: const EdgeInsets.all(6),
      child: FilledButton.tonal(
        style: FilledButton.styleFrom(shape: const StadiumBorder()),
        onPressed: onPressed,
        child: child,
      ),
    );

    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final digits in _keys)
          key(Text(digits, style: style), () => onDigits(digits)),
        MarkdownTooltip(
          message: '''

**Delete**

Remove the last digit typed.

''',
          child: key(const Icon(Icons.backspace_outlined), onDelete),
        ),
      ],
    );
  }
}
