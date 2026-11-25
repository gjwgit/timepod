/// Merge two copies of the timers, this device's and the Pod's.
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

import 'package:timepod/models/timer_entry.dart';

/// The timers and, by id, when each deleted timer was deleted, in
/// milliseconds since the epoch. The deletions are kept so a timer deleted
/// on one device is not brought back by another that still has it.

typedef TimerSet = ({List<TimerEntry> timers, Map<int, int> deleted});

// 20261125 gjw A deletion only has to outlive the time for every device to
// sync once. A month is ample, and keeps the list from growing for ever.

const _keepDeleted = Duration(days: 30);

/// Merge [mine] and [theirs]: every timer either has, less any either has
/// deleted, oldest first, each with the newer of its two lengths and names.
/// Its countdown is the newer of the two if [runs], the countdowns being
/// shared, otherwise mine, a timer new to me stopped at its length.
/// Deletions older than a month as at [now] are forgotten.

TimerSet mergeTimers(
  TimerSet mine,
  TimerSet theirs,
  DateTime now, {
  required bool runs,
}) {
  final since = now.subtract(_keepDeleted).millisecondsSinceEpoch;
  final deleted = <int, int>{};

  for (final entry in [...theirs.deleted.entries, ...mine.deleted.entries]) {
    if (entry.value < since) continue;
    if (entry.value > (deleted[entry.key] ?? 0)) {
      deleted[entry.key] = entry.value;
    }
  }

  final myTimers = {for (final timer in mine.timers) timer.id: timer};
  final theirTimers = {for (final timer in theirs.timers) timer.id: timer};
  final ids = {...myTimers.keys, ...theirTimers.keys}.toList()..sort();

  return (
    timers: [
      for (final id in ids)
        if (!deleted.containsKey(id))
          _merge(myTimers[id], theirTimers[id], runs: runs),
    ],
    deleted: {for (final id in deleted.keys.toList()..sort()) id: deleted[id]!},
  );
}

// 20261126 gjw Of two copies stamped the same moment, the one with the
// greater label is kept, so the merge comes out the same whichever side
// does it: this device's merge and the Pod's must agree.

TimerEntry _merge(TimerEntry? mine, TimerEntry? theirs, {required bool runs}) {
  final settings = mine == null || theirs == null
      ? (mine ?? theirs)!
      : mine.updated != theirs.updated
      ? (mine.updated > theirs.updated ? mine : theirs)
      : (mine.label.compareTo(theirs.label) >= 0 ? mine : theirs);
  final countdown = !runs || mine == null || theirs == null
      ? mine
      : (mine.ran >= theirs.ran ? mine : theirs);

  if (identical(settings, countdown)) return settings;

  return TimerEntry(
    id: settings.id,
    length: settings.length,
    label: settings.label,
    updated: settings.updated,
    total: countdown?.total,
    left: countdown?.left,
    endAt: countdown?.endAt,
    ran: countdown?.ran ?? 0,
  );
}

/// [set] as JSON, to save on the Pod or the device.

Map<String, dynamic> timerSetToJson(TimerSet set) => {
  'timers': set.timers,
  'deleted': {
    for (final entry in set.deleted.entries) '${entry.key}': entry.value,
  },
};

/// Rebuild a set saved by [timerSetToJson].

TimerSet timerSetFromJson(Map<String, dynamic> json) => (
  timers: [
    for (final timer in json['timers'] as List? ?? [])
      TimerEntry.fromJson(timer as Map<String, dynamic>),
  ],
  deleted: {
    for (final entry in (json['deleted'] as Map? ?? {}).entries)
      int.parse(entry.key as String): entry.value as int,
  },
);
