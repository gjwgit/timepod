/// Connect the timers to the Pod when logged in, or say why they are not.
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

import 'package:material_ui/material_ui.dart';
import 'package:solidpod/solidpod.dart' show KeyManager, isUserLoggedIn;
import 'package:solidui/solidui.dart' show getKeyFromUserIfRequired;

import 'package:timepod/services/pod_timers.dart';
import 'package:timepod/widgets/local_only_dialog.dart';

// 20261125 gjw Session-wide, since solidui rebuilds the home page on login,
// on logout, and when the security key prompt is cancelled. The startup
// note is for the first build only, not for a deliberate logout later.
// The key is asked for once a login: the prompt's Cancel rebuilds the home
// page, which would otherwise ask again, for ever.

bool _startup = true;
bool _keyAsked = false;

/// Sync the timers with the Pod if [webId] has a live session and the
/// security key is to hand. Otherwise keep them on this device, saying so
/// at startup if this device has used a Pod before.
/// [child] is the page the security key prompt returns to.

Future<void> connectPod(
  BuildContext context,
  Widget child,
  String? webId,
) async {
  final startup = _startup;
  _startup = false;

  // 20261125 gjw A stored WebID is not a session: its access token may have
  // expired, as radiopod found, so check for a live login too.

  final loggedIn = webId != null && webId.isNotEmpty && await isUserLoggedIn();

  if (!loggedIn) {
    podTimers.stop();
    _keyAsked = false;
    if (startup && await PodTimers.wasConnected() && context.mounted) {
      await showLocalOnlyDialog(context);
    }
    return;
  }

  if (!_keyAsked && context.mounted) {
    _keyAsked = true;
    await getKeyFromUserIfRequired(context, child);
  }

  if (await KeyManager.hasSecurityKey()) await podTimers.start();
}
