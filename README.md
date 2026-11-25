# TimePod

> Privacy-First Fullscreen Clock

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

[![GitHub](https://img.shields.io/badge/GitHub-Repository-blue?logo=github)](https://github.com/gjwgit/timepod)
[![GitHub License](https://img.shields.io/github/license/gjwgit/timepod)](https://raw.githubusercontent.com/gjwgit/timepod/dev/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/gjwgit/timepod?label=last%20updated)](https://github.com/gjwgit/timepod/commits/dev/)
[![GitHub Issues](https://img.shields.io/github/issues/gjwgit/timepod)](https://github.com/gjwgit/timepod/issues)

[TimePod](https://gjwgit.github.io/timepod/) shows a large clock,
analog, digital or both, with the weekday and date. Tap
**Fullscreen** to fill the screen with the clock and keep the screen
awake. Leave it running on a spare phone, tablet or monitor as a
bedside or desk clock. The fullscreen clock drifts a little every
minute so an OLED screen does not burn in. Under **Settings** choose
what the clock shows: the analog face, the digits, the date, the
seconds, and 24 or 12 hour time. Under **Timers** run as many
countdown timers as you like, side by side in a grid, each ringing as
it runs out with a gentle fingerpicked guitar or a classical guitar
piece, each swelling over 15 seconds, or with beeps, as chosen under
**Settings**. The screen stays awake while a timer runs.

The app needs no login and collects nothing about you. It fetches only
its public change log, to show whether a newer version is out. Logging
in to your own personal online data store (Pod) is optional. Once
logged in, your timers are kept private and encrypted on your own Pod,
so every device you log in from has the same timers. A timer counts
down only on the device where it is started, unless you tap the cloud on
the Timers page to share countdowns, when a timer started on one device
runs on them all. Pods are
an innovation from the inventor of the World Wide Web, Sir Tim
Berners-Lee. For more information visit the [Solid
Project](https://solidproject.org). **You do not need a Solid Pod to use
this app.**

TimePod is based on [Fullscreen
Clock](https://github.com/schorschii/FsClock-Android) 2.2 by Georg
Sieber, an Android app that is also free software under the GNU
General Public License version 3.

The app is developed by [Togaware](https://togaware.com) utilising
 Claude Code using our [solidui](https://pub.dev/packages/solidui)
 template for the [Flutter](https://flutter.dev) framework for a cross
 platform deployment.

We make this project available for free so if you appreciate the app
then please show some ❤️ and tap on the star at
[GitHub](https://github.com/gjwgit/timepod) to support our work. See
the [AU Solid Community](https://solidcommunity.au) **showcase** for
our apps using the Solid ecosystem.

## Installation

See the [Install
Guide](https://gjwgit.github.io/timepod/INSTALL.html) for
installation instructions for any platform.

## Screens

Here we walk through TimePod on various platforms and use cases. Every
screen looks the same across the devices from phones, tablets,
desktops and in a browser. As with all
[solidui](https://solidcommunity.au/showcase) apps, the screen size is
remembered on restarting the app.

To try it without any installation visit [TimePod
Web](https://timepod.solidcommunity.au) in your browser.

![TimePod running in a browser](assets/screenshots/timepod_web_landscape.png)

### The Family Room Clock

![TimePod as a Family Room Clock](assets/screenshots/timepod_android_landscape_fullscreen.png)

The app can be installed on a retired Android phone and sit in the
family room as the family clock. We get into this mode with a tap of
the full screen icon in the top toolbar to display the clock over the
whole screen, while turning off the screen sleep mode. Tap in the
window to restore to the original app.

### The Desktop Clock

![TimePod as a Desktop Clock](assets/screenshots/timepod_linux_landscape_desktop.png)

The app can sit inconspicuously in a small window on your computer's
desktop. Dark mode and light mode are supported. Tap the full screen
icon in the top toolbar to display the clock over the whole screen,
while turning off the screen sleep mode. Tap the `ESC` key or click in
the window to restore to the original window. Outside fullscreen, in
the app window or the desktop clock, the screen sleeps as usual.

On a technical note we see here the standard
[solidui](https://pub.dev/packages/solidui) scaffold that houses the
TimePod app including the top toolbar and the bottom app buttons.

## Transparent Desktop Clock

![Transparent TimePod on the desktop](assets/screenshots/timepod_linux_transparent_desktop.png)

The desktop transparent mode allows the time to sit by itself on the desktop.

Under **Settings** choose whether the desktop clock opens the size of
the app window, and where on the screen it opens: where it was last
left, a corner or the centre. On a Wayland desktop TimePod runs through
XWayland, as conky does, since GNOME on Wayland will not let an app
place its own window.

## Roadmap

TimePod is built using the [SolidUI](https://solidcommunity.au)
framework. This framework utilises open standard Solid Servers to
store any data within your personal online datastore (Pods). At this
time (November 2026) the Pod functionality is not utilised no data is
collected by the app nor shared with anyone. I do plan to support Pods
eventually whre calendar events can be securely and privately stored
and shared, if you choose, with other TimePod users. Some of the
functionality below will depend on supporting Solid Pods.

+ Configurable font and colour.

+ Add support for alarms, world clock, timers, and a stopwatch.

+ Add a calendar function to record event dates and times. A popup
  will appear at that date/time with the correspending event
  details. The popup remains until dismissed.

+ Allow individual events to be share with other Pods. A family might
  all be running TimePod to have the reminders popup for everyone.

+ Access RoloPod data within the user's Pod to catch birthdays,
  wedding anniversaries, etc, and then popup a reminder in TimePod the
  day before.

+ As we add support for Solid Pods data can be optionally shared
  across devices and other users of your choosing using secure and
  private personal data stores on Solid Pods.
