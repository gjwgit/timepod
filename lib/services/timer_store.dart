/// The timers, kept on this device, and the ticker that drives them.
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
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:timepod/models/timer_entry.dart';
import 'package:timepod/services/screen_awake.dart';
import 'package:timepod/services/timer_alarm.dart';

/// The list of timers, saved to SharedPreferences on every change. Like the
/// display choices they belong to this device, never synced to the Pod: a
/// kitchen timer rings in the kitchen.

class TimerStore extends ChangeNotifier {
  static const _key = 'timepod_timers';

  // 20261124 gjw Tick four times a second rather than once, so the rings
  // sweep smoothly and each timer's digits change close to its own second,
  // whatever fraction of a second it was started on.

  static const _tick = Duration(milliseconds: 250);

  final List<TimerEntry> _timers = [];
  Timer? _ticker;
  int _ticks = 0;

  /// The timers, oldest first.

  List<TimerEntry> get timers => List.unmodifiable(_timers);

  /// Read the saved timers. Any left running carry on, or are ringing if
  /// they ran out while the app was closed.

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);

    _timers
      ..clear()
      ..addAll([
        if (saved != null)
          for (final json in jsonDecode(saved) as List)
            TimerEntry.fromJson(json as Map<String, dynamic>),
      ]);

    _changed(save: false);
  }

  /// Add a timer of [length] and start it.

  void add(Duration length) {
    final now = DateTime.now();

    _timers.add(TimerEntry(id: now.microsecondsSinceEpoch, length: length));
    _timers.last.start(now);
    _changed();
  }

  /// Delete [timer].

  void remove(TimerEntry timer) {
    _timers.remove(timer);
    _changed();
  }

  /// Start a stopped [timer], pause a running one, or stop a ringing one.

  void toggle(TimerEntry timer) {
    final now = DateTime.now();

    if (timer.isExpired(now)) {
      timer.reset();
    } else if (timer.isRunning) {
      timer.pause(now);
    } else {
      timer.start(now);
    }
    _changed();
  }

  /// Return [timer] to the length it was set to.

  void reset(TimerEntry timer) {
    timer.reset();
    _changed();
  }

  /// Add a minute to [timer].

  void addMinute(TimerEntry timer) {
    timer.addMinute(DateTime.now());
    _changed();
  }

  /// Name [timer] [label].

  void rename(TimerEntry timer, String label) {
    timer.label = label.trim();
    _changed();
  }

  // 20261124 gjw Run the ticker only while a timer runs, so an idle Timers
  // page costs nothing. Keep the screen awake while a timer runs or rings,
  // so its count is there to glance at, letting it sleep once every timer
  // is paused, stopped or deleted.

  void _changed({bool save = true}) {
    if (save) unawaited(_save());

    final running = _timers.any((timer) => timer.isRunning);
    screenAwake.keep('timers', running);
    _ring(DateTime.now());
    if (running && _ticker == null) {
      _ticker = Timer.periodic(_tick, (_) => _onTick());
    } else if (!running) {
      _ticker?.cancel();
      _ticker = null;
    }

    notifyListeners();
  }

  // 20261124 gjw Buzz once a second while any timer has run out, the
  // alarm looping meanwhile, until it is stopped, reset or deleted.

  void _onTick() {
    final now = DateTime.now();

    if (_ring(now) && ++_ticks % 4 == 0) HapticFeedback.heavyImpact();

    notifyListeners();
  }

  // 20261124 gjw Sound the alarm while any timer has run out, and silence
  // it as soon as none has. SystemSound.alert, used before, is silent on
  // Android.

  bool _ring(DateTime now) {
    final ringing = _timers.any((timer) => timer.isExpired(now));
    unawaited(timerAlarm.ring(ringing));
    return ringing;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_timers));
  }
}

/// The app's one list of timers.

final timerStore = TimerStore();
