/// The timers kept on the Pod, so every device shows the same ones.
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

import 'package:flutter/widgets.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:solidpod/solidpod.dart'
    show ResourceNotExistException, readPod, writePod;
import 'package:solidui/solidui.dart' show SolidPendingWrites;

import 'package:timepod/services/clock_prefs.dart';
import 'package:timepod/services/timer_store.dart';
import 'package:timepod/utils/merge_timers.dart';

/// Keeps the timers on the Pod in step with this device's, once connected.
///
/// Each sync reads the Pod's copy, merges it with this device's, takes on
/// the result here and writes it back if the Pod's copy differs. It runs on
/// connecting, after every change made here, and as the app comes back to
/// the screen, picking up changes made on another device meanwhile, and
/// once a minute while the app is open, every five seconds while a timer
/// rings and countdowns are shared.
///
/// 20261126 gjw The timers themselves, their lengths and names, are always
/// kept in step. Their countdowns are too only while
/// `ClockPrefs.shareCountdowns` is on. Otherwise this device keeps its own
/// countdowns and leaves the Pod's as they were for the devices sharing
/// them.

class PodTimers {
  // 20261125 gjw solidpod encrypts only turtle files, so the JSON is kept in
  // a .ttl, encrypted like everything the suite writes to a Pod.

  static const _file = 'timers.ttl';
  static const _connectedKey = 'timepod_podConnected';

  // 20261125 gjw Check the Pod once a minute, so a desktop clock that never
  // leaves the screen still picks up a timer stopped on the phone, and
  // every five seconds while a timer rings, so stopping it on one device
  // soon silences it on the others.

  static const _poll = Duration(seconds: 5);
  static const _idlePoll = Duration(minutes: 1);

  AppLifecycleListener? _lifecycle;
  Timer? _poller;
  Future<void>? _run;
  bool _again = false;
  DateTime _synced = DateTime(0);

  /// Whether the timers can be kept on the Pod, logged in with the security
  /// key to hand.

  final connected = ValueNotifier(false);

  /// Whether this device has ever synced with a Pod, after which starting
  /// up without a connection is worth a word.

  static Future<bool> wasConnected() async =>
      (await SharedPreferences.getInstance()).getBool(_connectedKey) ?? false;

  /// Start keeping the timers on the Pod, syncing them now.

  Future<void> start() async {
    connected.value = true;
    timerStore.onEdit = sync;
    _lifecycle ??= AppLifecycleListener(onResume: sync);
    _poller ??= Timer.periodic(_poll, (_) => _tick());
    await sync();
  }

  /// Stop, the Pod no longer connected. The timers carry on on this device.

  void stop() {
    connected.value = false;
    timerStore.onEdit = null;
    _poller?.cancel();
    _poller = null;
  }

  // A sync still under way is left to finish rather than queued behind.

  void _tick() {
    final now = DateTime.now();
    final ringing =
        clockPrefs.shareCountdowns &&
        timerStore.timers.any((timer) => timer.isExpired(now));

    if (_run == null && (ringing || now.difference(_synced) >= _idlePoll)) {
      unawaited(sync());
    }
  }

  // 20261125 gjw One sync at a time. A change made while one runs asks for
  // another after it, which picks the change up, rather than a second
  // racing the first to write the Pod.

  /// Sync the timers with the Pod.

  Future<void> sync() async {
    if (!connected.value) return;

    if (_run != null) {
      _again = true;
      return _run;
    }

    _run = _syncAll();
    try {
      await _run;
    } finally {
      _run = null;
    }
  }

  Future<void> _syncAll() async {
    do {
      _again = false;
      try {
        await _syncOnce();
      } on Object catch (e) {
        debugPrint('[PodTimers] sync failed: $e');
        return;
      }
    } while (_again && connected.value);
  }

  Future<void> _syncOnce() async {
    String? text;
    _synced = DateTime.now();

    // 20261125 gjw Only a missing file counts as no timers. Any other
    // failure, offline say, ends the sync rather than writing this device's
    // timers over the Pod's.

    try {
      text = await readPod(_file);
    } on ResourceNotExistException {
      text = null;
    }

    final TimerSet theirs = text == null || text.trim().isEmpty
        ? (timers: [], deleted: {})
        : timerSetFromJson(jsonDecode(text) as Map<String, dynamic>);

    // Merged with the timers as they are NOW, after the read, so a change
    // made while the Pod was being read is not lost.

    final mine = timerStore.snapshot;
    final now = DateTime.now();
    final runs = clockPrefs.shareCountdowns;
    final merged = mergeTimers(mine, theirs, now, runs: runs);
    timerStore.adopt(merged);

    // Not sharing, the Pod keeps its own countdowns, with this device's
    // changes to the timers themselves.

    final pod = runs ? merged : mergeTimers(theirs, mine, now, runs: false);
    final json = jsonEncode(timerSetToJson(pod));
    if (json != jsonEncode(timerSetToJson(theirs))) {
      await SolidPendingWrites.track(writePod(_file, json, overwrite: true));
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_connectedKey, true);
  }
}

/// The app's one link between the timers and the Pod.

final podTimers = PodTimers();
