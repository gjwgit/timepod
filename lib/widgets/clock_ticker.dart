/// Rebuild once a second with the current time.
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

/// Builds [builder] with the time now, and again as each second turns over.

class ClockTicker extends StatefulWidget {
  const ClockTicker({super.key, required this.builder, this.clock});

  /// Builds the widget for the time given.

  final Widget Function(BuildContext context, DateTime now) builder;

  /// Where the time comes from, [DateTime.now] unless a test fixes it.

  final DateTime Function()? clock;

  @override
  State<ClockTicker> createState() => _ClockTickerState();
}

class _ClockTickerState extends State<ClockTicker> {
  late DateTime _now = _read();
  Timer? _timer;

  DateTime _read() => (widget.clock ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  // 20261101 gjw Wake just after each second turns over rather than every
  // 1000ms from whenever the clock started, so the display changes with the
  // real second and never skips or repeats one as the timer drifts.

  void _schedule() {
    final wait = 1000 - _read().millisecond;

    _timer = Timer(Duration(milliseconds: wait), () {
      setState(() => _now = _read());
      _schedule();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _now);
}
