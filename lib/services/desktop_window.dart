/// The window as the desktop clock: frameless, small and below the others.
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

import 'package:flutter/material.dart';

import 'package:screen_retriever/screen_retriever.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'package:timepod/models/clock_place.dart';

/// Turns the window into the desktop clock and back, remembering on this
/// device where each was left.
///
/// 20261102 gjw The app's own bounds are kept here because solidui's
/// SolidWindowSize remembers whatever size the window is resized to, the
/// desktop clock's included. Leaving the desktop clock puts them back, and
/// an app closed as the desktop clock opens as it again, so the small size
/// never becomes the app's.

class DesktopWindow {
  static const _onKey = 'timepod_desktopClock';
  static const _appKey = 'timepod_appBounds';
  static const _clockKey = 'timepod_desktopClockBounds';

  /// The size of a first desktop clock, before it has been resized.

  static const _firstSize = Size(360, 360);

  /// The gap left between a clock in a corner and the edge of the screen.

  static const _margin = 16.0;

  /// Whether the app was closed as the desktop clock.

  static Future<bool> wasOn() async =>
      (await SharedPreferences.getInstance()).getBool(_onKey) ?? false;

  /// Make the window the desktop clock, [transparent] or on black, at
  /// [place], and the [appSize] or else the size it was last left at.

  static Future<void> enter({
    required bool transparent,
    required bool appSize,
    required ClockPlace place,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Keep the app's bounds, unless the app opened as the desktop clock,
    // when the window is already the clock's.

    if (!(prefs.getBool(_onKey) ?? false)) {
      await _put(prefs, _appKey, await windowManager.getBounds());
      await prefs.setBool(_onKey, true);
    }

    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setAsFrameless();
    await windowManager.setBackgroundColor(
      transparent ? Colors.transparent : Colors.black,
    );
    await windowManager.setAlwaysOnBottom(true);

    final app = _get(prefs, _appKey);
    final left = _get(prefs, _clockKey);
    final size = appSize && app != null ? app.size : left?.size ?? _firstSize;

    if (place.alignment case final alignment?) {
      final screen = await _screen(app ?? await windowManager.getBounds());
      await windowManager.setBounds(
        alignment.inscribe(size, screen.deflate(_margin)),
      );
    } else if (left != null) {
      await windowManager.setBounds(left.topLeft & size);
    } else {
      await windowManager.setSize(size);
    }
  }

  // The part of the screen the app is on that windows may use, less any
  // panel or dock, or of the main screen when the app's is not known.

  static Future<Rect> _screen(Rect app) async {
    Rect usable(Display d) =>
        (d.visiblePosition ?? Offset.zero) & (d.visibleSize ?? d.size);

    for (final display in await screenRetriever.getAllDisplays()) {
      if (usable(display).contains(app.center)) return usable(display);
    }

    return usable(await screenRetriever.getPrimaryDisplay());
  }

  /// Remember where the desktop clock is and its size.

  static Future<void> save() async => _put(
    await SharedPreferences.getInstance(),
    _clockKey,
    await windowManager.getBounds(),
  );

  /// Put the window back as the app, where it was.

  static Future<void> leave() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onKey, false);

    await windowManager.setAlwaysOnBottom(false);
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);

    final bounds = _get(prefs, _appKey);
    if (bounds != null) await windowManager.setBounds(bounds);
  }

  static Future<void> _put(SharedPreferences prefs, String key, Rect r) =>
      prefs.setStringList(key, [
        for (final v in [r.left, r.top, r.width, r.height]) '$v',
      ]);

  static Rect? _get(SharedPreferences prefs, String key) {
    final v = prefs.getStringList(key)?.map(double.tryParse).toList();
    if (v == null || v.length != 4 || v.contains(null)) return null;

    return Rect.fromLTWH(v[0]!, v[1]!, v[2]!, v[3]!);
  }
}
