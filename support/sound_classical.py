#!/usr/bin/env python3
#
# Usage: python3 support/sound_classical.py assets/sounds/timer_classical.wav
#
# TimePod's classical guitar alarm: an ORIGINAL slow, lyrical piece in E
# major, a singing melody over flowing arpeggios, in the romantic style of
# the classical guitar repertoire. Not any existing work.
#
# Nylon strings by Karplus-Strong synthesis with a soft, mid-string pluck,
# a hint of body resonance and a little room reverb. Note tails and the
# reverb wrap from the end to the start so the loop has no seam.
import sys
import wave

import numpy as np
from scipy.signal import lfilter

RATE = 22050
BPM = 66
EIGHTH = 60 / BPM / 2
BAR = 6 * EIGHTH  # 3/4
rng = np.random.default_rng(20261124)


def hz(midi):
    return 440 * 2 ** ((midi - 69) / 12)


# Each bar: chords as (eighths, bass, three inner notes), then the melody
# as (beat, midi, beats long).
BARS = [
    ([(6, 40, [47, 52, 56])], [(0, 68, 2), (2, 69, 1)]),             # E
    ([(6, 49, [56, 61, 64])], [(0, 71, 2), (2, 68, 1)]),             # C#m
    ([(6, 45, [52, 57, 61])], [(0, 73, 2), (2, 71, 1)]),             # A
    ([(6, 47, [54, 57, 63])], [(0, 69, 2), (2, 66, 1)]),             # B7
    ([(6, 40, [47, 52, 56])], [(0, 68, 1), (1, 71, 1), (2, 76, 1)]),  # E
    ([(6, 44, [51, 56, 59])], [(0, 75, 2), (2, 71, 1)]),             # G#m
    ([(3, 45, [52, 57, 61]), (3, 42, [49, 54, 57])],
     [(0, 73, 1), (1, 71, 1), (2, 69, 1)]),                          # A F#m
    ([(6, 47, [54, 59, 63])], [(0, 66, 2), (2, 63, 1)]),             # B
]
ARP = [None, 0, 1, 2, 1, 0]  # bass first, then the inner strings
LOOP = int(len(BARS) * BAR * RATE)


def pluck(freq, seconds, loud):
    n = int(round(RATE / freq))
    # Soft excitation: noise, low-passed, plucked a fifth of the way along
    # the string (a comb), as a fingertip near the soundhole.
    buf = rng.uniform(-1, 1, n)
    for _ in range(3):
        buf = np.convolve(buf, [0.25, 0.5, 0.25], mode='same')
    buf = buf - np.roll(buf, int(n / 5))
    buf /= np.max(np.abs(buf)) + 1e-9
    out = np.empty(int(seconds * RATE))
    decay = 0.9985 if freq < 200 else 0.9978
    for i in range(len(out)):
        j = i % n
        out[i] = buf[j]
        buf[j] = decay * (0.5 * buf[j] + 0.5 * buf[(j + 1) % n])
    ramp = int(0.004 * RATE)
    out[:ramp] *= np.linspace(0, 1, ramp)
    return loud * out


def place(track, at, midi, loud, seconds=4.0):
    # A touch of human timing and touch on every note.
    start = int((at + rng.normal(0, 0.008)) * RATE)
    note = pluck(hz(midi), seconds, loud * rng.uniform(0.92, 1.05))
    track[max(0, start):start + len(note)] += note[max(0, -start):]


track = np.zeros(LOOP + int(6 * RATE))
for b, (chords, melody) in enumerate(BARS):
    t0 = b * BAR
    k = 0
    for count, bass, inner in chords:
        for e in range(count):
            step = ARP[(k + e) % 6] if (k + e) % 6 else None
            at = t0 + (k + e) * EIGHTH
            if (k + e) % 6 == 0 or e == 0:
                place(track, at, bass, 0.75)
            else:
                place(track, at, inner[step], 0.38)
        k += count
    for beat, midi, length in melody:
        place(track, t0 + beat * 2 * EIGHTH + 0.012, midi, 0.85,
              seconds=max(3.0, length * 2 * EIGHTH + 2))


def biquad_peak(x, f0, q, gain_db):
    a = 10 ** (gain_db / 40)
    w = 2 * np.pi * f0 / RATE
    alpha = np.sin(w) / (2 * q)
    b = [1 + alpha * a, -2 * np.cos(w), 1 - alpha * a]
    den = [1 + alpha / a, -2 * np.cos(w), 1 - alpha / a]
    return lfilter(b, den, x)


# The guitar body: gentle resonances low down and a softer top end.
track = biquad_peak(track, 110, 1.2, 4)
track = biquad_peak(track, 220, 1.5, 2.5)
track = lfilter([0.6, 0.4], [1], track)

# A small room: four feedback combs and two all-passes (Schroeder).
wet = np.zeros_like(track)
for delay, gain in [(0.0297, 0.78), (0.0371, 0.76), (0.0411, 0.74),
                    (0.0437, 0.72)]:
    d = int(delay * RATE)
    den = np.zeros(d + 1)
    den[0], den[d] = 1, -gain
    wet += lfilter([1], den, track)
for delay, gain in [(0.005, 0.7), (0.0017, 0.7)]:
    d = int(delay * RATE)
    num = np.zeros(d + 1)
    num[0], num[d] = -gain, 1
    den = np.zeros(d + 1)
    den[0], den[d] = 1, -gain
    wet = lfilter(num, den, wet)
mix = track + 0.12 * wet

# Wrap the tails into the start, then level it gently.
loop = mix[:LOOP].copy()
loop[:len(mix) - LOOP] += mix[LOOP:]
loop = np.tanh(1.1 * loop / np.max(np.abs(loop)))
loop = 0.85 * loop / np.max(np.abs(loop))

with wave.open(sys.argv[1], 'wb') as out:
    out.setnchannels(1)
    out.setsampwidth(2)
    out.setframerate(RATE)
    out.writeframes((loop * 32767).astype('<i2').tobytes())
