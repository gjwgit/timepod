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
import 'package:timepod/utils/merge_timers.dart';

/// The list of timers, saved to SharedPreferences on every change.
///
/// 20261125 gjw Once the app has connected to a Pod the timers are also kept
/// there, so every device shows the same ones; see `PodTimers`. Until then
/// they stay on this device only.

class TimerStore extends ChangeNotifier {
  static const _key = 'timepod_timers';
  static const _deletedKey = 'timepod_timersDeleted';

  // 20261124 gjw Tick four times a second rather than once, so the rings
  // sweep smoothly and each timer's digits change close to its own second,
  // whatever fraction of a second it was started on.

  static const _tick = Duration(milliseconds: 250);

  final List<TimerEntry> _timers = [];
  final Map<int, int> _deleted = {};
  Timer? _ticker;
  int _ticks = 0;
  int? _focus;

  /// The timers, oldest first.

  List<TimerEntry> get timers => List.unmodifiable(_timers);

  /// The timer filling the Timers page, if one is in focus. It stays in
  /// focus only while it runs, the page going back to the grid once it is
  /// paused, stopped, reset or deleted.

  TimerEntry? get focused =>
      _timers.where((timer) => timer.id == _focus).firstOrNull;

  /// Start [timer] if it is stopped and fill the Timers page with it, or,
  /// with it already in focus, go back to the grid.

  void focus(TimerEntry timer) {
    final leave = _focus == timer.id;
    _focus = leave ? null : timer.id;

    if (leave || timer.isRunning) {
      notifyListeners();
    } else {
      toggle(timer);
    }
  }

  /// Called after the user changes a timer, to pass the change on to the Pod.

  VoidCallback? onEdit;

  /// The timers and deletions as they stand, to merge with the Pod's.

  TimerSet get snapshot =>
      (timers: List.of(_timers), deleted: Map.of(_deleted));

  /// Take on [set], the timers merged with the Pod's, saving them here.

  void adopt(TimerSet set) {
    _timers
      ..clear()
      ..addAll(set.timers);
    _deleted
      ..clear()
      ..addAll(set.deleted);
    _changed();
  }

  /// Read the saved timers. Any left running carry on, or are ringing if
  /// they ran out while the app was closed.

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    final deleted = prefs.getString(_deletedKey);

    _timers
      ..clear()
      ..addAll([
        if (saved != null)
          for (final json in jsonDecode(saved) as List)
            TimerEntry.fromJson(json as Map<String, dynamic>),
      ]);
    _deleted
      ..clear()
      ..addAll({
        if (deleted != null)
          for (final MapEntry(:key, :value)
              in (jsonDecode(deleted) as Map).entries)
            int.parse(key as String): value as int,
      });

    _changed(save: false);
  }

  /// Add a timer of [length] and start it.

  void add(Duration length) {
    final now = DateTime.now();
    final stamp = now.millisecondsSinceEpoch;

    _timers.add(
      TimerEntry(
        id: now.microsecondsSinceEpoch,
        length: length,
        updated: stamp,
        ran: stamp,
      ),
    );
    _timers.last.start(now);
    _edited();
  }

  /// Delete [timer].

  void remove(TimerEntry timer) {
    _timers.remove(timer);
    _deleted[timer.id] = DateTime.now().millisecondsSinceEpoch;
    _edited();
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
    _edited(timer);
  }

  /// Return [timer] to the length it was set to.

  void reset(TimerEntry timer) {
    timer.reset();
    _edited(timer);
  }

  /// Add a minute to [timer].

  void addMinute(TimerEntry timer) {
    timer.addMinute(DateTime.now());
    _edited(timer);
  }

  /// Name [timer] [label].

  void rename(TimerEntry timer, String label) {
    timer.label = label.trim();
    timer.updated = DateTime.now().millisecondsSinceEpoch;
    _edited();
  }

  // 20261125 gjw Pass on a change the user made.
  //
  // 20261126 gjw Stamp a change to [timer]'s countdown, so it wins over an
  // older countdown on the Pod when countdowns are shared. A rename stamps
  // the timer's settings instead.

  void _edited([TimerEntry? timer]) {
    timer?.ran = DateTime.now().millisecondsSinceEpoch;
    _changed();
    onEdit?.call();
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

    // 20261128 gjw A focused timer that stops, here or on another device
    // through the Pod, hands the page back to the grid.

    if (!_timers.any((timer) => timer.id == _focus && timer.isRunning)) {
      _focus = null;
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
    await prefs.setString(
      _deletedKey,
      jsonEncode(_deleted.map((id, at) => MapEntry('$id', at))),
    );
  }
}

/// The app's one list of timers.

final timerStore = TimerStore();
