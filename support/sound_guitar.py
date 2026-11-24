#!/usr/bin/env python3
#
# Usage: python3 support/sound_guitar.py assets/sounds/timer_guitar.wav
#
# TimePod's timer alarm: an original, gentle fingerpicked guitar loop,
# C Am F G at 80 bpm, plucked strings by Karplus-Strong synthesis.
# The tail of the last notes wraps to the start so the loop is seamless.
import sys
import numpy as np
import wave

RATE = 22050
EIGHTH = 60 / 80 / 2
BAR = 8 * EIGHTH
CHORDS = [  # bass, then three upper strings
    [130.81, 196.00, 261.63, 329.63],  # C
    [110.00, 164.81, 220.00, 261.63],  # Am
    [87.31, 174.61, 220.00, 261.63],   # F
    [98.00, 146.83, 196.00, 246.94],   # G
]
PATTERN = [0, 2, 1, 3, 0, 2, 1, 2]  # string picked on each eighth
LOOP = int(len(CHORDS) * BAR * RATE)
rng = np.random.default_rng(20261124)


def pluck(freq, seconds, loud):
    n = int(RATE / freq)
    # A soft pluck: noise smoothed, so the attack is warm not bright.
    buf = rng.uniform(-1, 1, n)
    buf = np.convolve(buf, np.ones(4) / 4, mode='same')
    out = np.empty(int(seconds * RATE))
    decay = 0.996 if freq < 150 else 0.997
    for i in range(len(out)):
        out[i] = buf[i % n]
        buf[i % n] = decay * 0.5 * (buf[i % n] + buf[(i + 1) % n])
    # 20261124 gjw A 4ms fade in, so no note, the one at the loop's start
    # included, begins with a click.
    ramp = int(0.004 * RATE)
    out[:ramp] *= np.linspace(0, 1, ramp)
    return loud * out


track = np.zeros(LOOP + int(4 * RATE))
for b, chord in enumerate(CHORDS):
    for k, string in enumerate(PATTERN):
        start = int((b * BAR + k * EIGHTH) * RATE)
        loud = 0.9 if string == 0 else 0.55
        note = pluck(chord[string], 3.5, loud)
        track[start:start + len(note)] += note

# Wrap the ringing tail into the beginning, then normalise gently.
loop = track[:LOOP].copy()
loop[:len(track) - LOOP] += track[LOOP:]
loop = np.tanh(1.2 * loop / np.max(np.abs(loop)))
loop = 0.8 * loop / np.max(np.abs(loop))

with wave.open(sys.argv[1], 'wb') as out:
    out.setnchannels(1)
    out.setsampwidth(2)
    out.setframerate(RATE)
    out.writeframes((loop * 32767).astype('<i2').tobytes())
