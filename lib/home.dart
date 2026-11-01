/// The app's home, the solidui scaffold with its menu of pages.
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

import 'package:solidpod/solidpod.dart' show getWebId;
import 'package:solidui/solidui.dart';

import 'package:timepod/constants/app.dart';
import 'package:timepod/screens/clock_screen.dart';
import 'package:timepod/screens/display_screen.dart';
import 'package:timepod/screens/fullscreen_clock.dart';

/// The scaffold: the Clock and Display pages, a Fullscreen button in the app
/// bar, and the login status for the optional Pod.

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? _webId;

  @override
  void initState() {
    super.initState();
    _loadWebId();
  }

  Future<void> _loadWebId() async {
    final webId = await getWebId();
    if (mounted) setState(() => _webId = webId);
  }

  @override
  Widget build(BuildContext context) {
    return SolidScaffold(
      appBar: SolidAppBarConfig(
        title: appName,
        actions: [
          SolidAppBarAction(
            icon: Icons.fullscreen,
            tooltip:
                '**Fullscreen**\n\nFill the screen with the clock and keep '
                'the screen awake. Tap, or press Escape, to come back.',
            onPressed: () => FullscreenClock.open(context),
          ),
        ],

        // 20261002 gjw Always supply the versionConfig. SolidScaffold loads the
        // version only if it is present when the scaffold is first built.
        versionConfig: const SolidVersionConfig(changelogUrl: changelogUrl),
      ),
      themeToggle: const SolidThemeToggleConfig(enabled: true),
      statusBar: SolidStatusBarConfig(
        serverInfo: _webId != null ? SolidServerInfo.fromWebId(_webId!) : null,
        loginStatus: SolidLoginStatus(webId: _webId),
      ),
      aboutConfig: SolidAboutConfig(
        applicationName: appTitle.replaceAll(' - ', '\n'),
        applicationIcon: Image.asset(
          'assets/images/app_icon.png',
          width: 64,
          height: 64,
        ),
        applicationLegalese: '© 2026 Togaware Pty Ltd',
        text: '''
TimePod shows a large clock, analog, digital or both, with the weekday and
date. Tap Fullscreen to fill the screen with it and keep the screen awake, as
a bedside or desk clock on a spare phone, tablet or monitor.

The app needs no login and sends nothing anywhere. Logging in to a Solid Pod
is optional, ready for features that keep your data private and encrypted on
your own Pod.

TimePod is based on [Fullscreen
Clock](https://github.com/schorschii/FsClock-Android) 2.2 by Georg Sieber,
also free software under the GNU GPL version 3.

**GitHub** [https://github.com/gjwgit/timepod](https://github.com/gjwgit/timepod)

**Author** [Graham Williams](https://togaware.com/graham.williams.html)
''',
      ),
      menu: const [
        SolidMenuItem(
          title: 'Clock',
          icon: Icons.access_time,
          tooltip: '**Clock**\n\nThe time and date, updated every second.',
          child: ClockScreen(),
        ),
        SolidMenuItem(
          title: 'Display',
          icon: Icons.tune,
          tooltip:
              '**Display**\n\nChoose what the clock shows. The choices are '
              'kept on this device.',
          child: DisplayScreen(),
        ),
      ],
    );
  }
}
