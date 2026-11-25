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

import 'package:material_ui/material_ui.dart';
import 'package:solidpod/solidpod.dart' show getWebId;
import 'package:solidui/solidui.dart';

import 'package:timepod/constants/app.dart';
import 'package:timepod/screens/clock_screen.dart';
import 'package:timepod/screens/desktop_clock.dart';
import 'package:timepod/screens/fullscreen_clock.dart';
import 'package:timepod/screens/settings_screen.dart';
import 'package:timepod/screens/timers_screen.dart';
import 'package:timepod/services/desktop_window.dart';
import 'package:timepod/services/pod_connect.dart';

/// The scaffold: the Clock, Timers and Settings pages, Fullscreen and, on a desktop,
/// Desktop Clock buttons in the app bar, and the login status for the
/// optional Pod.

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
    _reopenDesktopClock();
  }

  // 20261102 gjw An app closed as the desktop clock opens as it again, as a
  // clock started with the desktop would want.

  Future<void> _reopenDesktopClock() async {
    if (isDesktop && await DesktopWindow.wasOn() && mounted) {
      await DesktopClock.open(context);
    }
  }

  Future<void> _loadWebId() async {
    final webId = await getWebId();
    if (!mounted) return;
    setState(() => _webId = webId);

    // 20261125 gjw Keep the timers on the Pod once logged in to one.

    await connectPod(context, widget, webId);
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
          if (isDesktop)
            SolidAppBarAction(
              icon: Icons.desktop_windows_outlined,
              tooltip:
                  '**Desktop Clock**\n\nShow just the clock in a small window '
                  'with no frame, sitting on the desktop. Drag it to move it '
                  'and drag its edges to resize it. Double-click it, '
                  'right-click it, or press Escape, to come back. Settings '
                  'chooses whether the desktop shows through it.',
              onPressed: () => DesktopClock.open(context),
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
a bedside or desk clock on a spare phone, tablet or monitor. On a desktop,
Desktop Clock shows just the clock in a small window on the desktop.

The app needs no login and collects nothing about you. It fetches only its
public change log, to show whether a newer version is out. Logging in to a
Solid Pod is optional. Once logged in, your timers are kept encrypted on your
own Pod, so every device you log in from has the same ones. The cloud on the
Timers page also shares their countdowns, so a timer started on one device
runs on them all.

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
          title: 'Timers',
          icon: Icons.hourglass_empty,
          tooltip:
              '**Timers**\n\nCount down from a time you type, as many '
              'timers at once as you like, each ringing as it runs out. '
              'They keep running on through a restart of the app. Logged in '
              'to your Pod, every device has the same timers. Tap the cloud '
              'on the page to share their countdowns too.',
          child: TimersScreen(),
        ),
        SolidMenuItem(
          title: 'Settings',
          icon: Icons.settings_outlined,
          tooltip:
              '**Settings**\n\nChoose what the clock shows and the sound a '
              'timer rings with. The choices are kept on this device.',
          child: SettingsScreen(),
        ),
      ],
    );
  }
}
