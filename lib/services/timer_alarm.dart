/// The sound of a timer that has run out.
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
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';

import 'package:timepod/services/clock_prefs.dart';

/// Loops the sound chosen under Settings while any timer rings, and stops
/// when none does. A sound that swells, the gentle guitar, rises from quiet
/// to full over the first 15 seconds.

class TimerAlarm {
  // 20261124 gjw On Android play as media, not as an alarm. The alarm
  // volume is often at its loudest and the volume keys do not change it
  // while the app plays, so a timer rang far too loud with no way to quieten
  // it. As media it follows the media volume, and the keys turn it up or
  // down as it rings.

  static const _android = AudioContextAndroid(
    usageType: AndroidUsageType.media,
    contentType: AndroidContentType.music,
    audioFocus: AndroidAudioFocus.gainTransientMayDuck,
  );

  // 20261124 gjw Gentle by default: a swelling sound starts at a whisper and
  // rises to six tenths of the volume set, as does a sound that does not
  // swell from the start, leaving the volume keys room either way.

  static const _swell = Duration(seconds: 15);
  static const _quiet = 0.03;
  static const _full = 0.6;

  // 20261124 gjw The player is made on the first ring, not before, so an
  // app, or a test, in which no timer runs out never loads the plugin.

  AudioPlayer? _player;
  Timer? _fade;
  bool _ringing = false;

  /// Start the alarm looping when [on], or stop it.

  Future<void> ring(bool on) async {
    if (on == _ringing) return;
    _ringing = on;

    if (!on) {
      _fade?.cancel();
      _fade = null;
      await _player?.stop();
      return;
    }

    final player = _player ??= AudioPlayer();
    await player.setAudioContext(AudioContext(android: _android));
    await player.setReleaseMode(ReleaseMode.loop);
    final sound = clockPrefs.alarm;

    // 20261124 gjw Load the sound, then set its volume, then start it, so
    // it never begins at full volume, as it might were the volume set before
    // the player has a sound to apply it to.

    await player.setSource(AssetSource(sound.asset));
    await player.setVolume(sound.swells ? _quiet : _full);
    await player.resume();

    // 20261124 gjw Stopped while starting, so stop what was just started.

    if (!_ringing) {
      await player.stop();
      return;
    }

    if (sound.swells) _swellUp(player);
  }

  // 20261124 gjw Rise from quiet to full exponentially, which the ear
  // hears as an even rise, where a straight line in volume jumps at first
  // and then barely changes.

  void _swellUp(AudioPlayer player) {
    final start = DateTime.now();

    _fade = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      final t =
          DateTime.now().difference(start).inMilliseconds /
          _swell.inMilliseconds;
      unawaited(player.setVolume(min(_full, _quiet * pow(_full / _quiet, t))));
      if (t >= 1) timer.cancel();
    });
  }
}

/// The app's one alarm.

final timerAlarm = TimerAlarm();
