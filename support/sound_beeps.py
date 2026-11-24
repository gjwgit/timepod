#!/usr/bin/env python3
#
# Usage: python3 support/sound_beeps.py assets/sounds/timer_beeps.wav
#
# Generate TimePod's timer alarm: four bell-like beeps in 1.2s, to loop.
import math, struct, sys, wave

RATE = 22050
LENGTH = 1.2
BEEP = 0.14
GAP = 0.18
FREQ = 1046.5  # C6

samples = [0.0] * int(RATE * LENGTH)
for k in range(4):
    start = int(k * GAP * RATE)
    for i in range(int(BEEP * RATE)):
        t = i / RATE
        attack = min(1.0, t / 0.005)
        decay = math.exp(-t * 18)
        tone = (math.sin(2 * math.pi * FREQ * t)
                + 0.35 * math.sin(2 * math.pi * 2 * FREQ * t)
                + 0.15 * math.sin(2 * math.pi * 3 * FREQ * t))
        samples[start + i] += 0.6 * attack * decay * tone / 1.5

with wave.open(sys.argv[1], 'wb') as out:
    out.setnchannels(1)
    out.setsampwidth(2)
    out.setframerate(RATE)
    out.writeframes(b''.join(
        struct.pack('<h', int(max(-1, min(1, s)) * 32767)) for s in samples))
