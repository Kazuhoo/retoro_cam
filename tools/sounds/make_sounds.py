#!/usr/bin/env python3
"""効果音を合成して Resources/Sounds/ に書き出す（どこから実行してもよい）"""
import math
import random
import struct
import wave
from pathlib import Path

RATE = 44100
OUT = Path(__file__).resolve().parents[2] / "Resources" / "Sounds"


def click(duration, tone, noise, decay, gain=1.0):
    """減衰するノイズと短い音程を混ぜた「カチッ」"""
    count = int(RATE * duration)
    return [
        gain * math.exp(-i / RATE * decay)
        * (noise * random.uniform(-1, 1) + tone_mix(i, tone))
        for i in range(count)
    ]


def tone_mix(i, tone):
    return 0.5 * math.sin(2 * math.pi * tone * i / RATE)


def mix(*parts):
    """(開始秒, サンプル) を重ねる"""
    length = max(int(start * RATE) + len(samples) for start, samples in parts)
    out = [0.0] * length
    for start, samples in parts:
        offset = int(start * RATE)
        for i, value in enumerate(samples):
            out[offset + i] += value
    return out


def low_pass(samples, amount):
    out, last = [], 0.0
    for value in samples:
        last += amount * (value - last)
        out.append(last)
    return out


def paper(duration, grains, level):
    """紙やアルミがこすれる音：短いノイズの粒を並べる"""
    out = [0.0] * int(RATE * duration)
    for _ in range(grains):
        start = random.randrange(len(out))
        size = random.randint(60, 700)
        strength = random.uniform(0.3, 1.0) * level
        for i in range(size):
            if start + i >= len(out):
                break
            out[start + i] += strength * math.exp(-i / size * 4) * random.uniform(-1, 1)
    return out


def write(name, samples):
    peak = max(abs(v) for v in samples) or 1
    scale = 0.8 / peak
    fade = min(200, len(samples))
    for i in range(fade):
        samples[-1 - i] *= i / fade
    with wave.open(str(OUT / f"{name}.wav"), "wb") as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(RATE)
        out.writeframes(b"".join(struct.pack("<h", int(v * scale * 32767)) for v in samples))


def main():
    random.seed(1996)
    OUT.mkdir(parents=True, exist_ok=True)
    write("wind_tick", low_pass(click(0.035, 2600, 0.8, 190), 0.6))
    write("wind_complete", mix((0, low_pass(click(0.05, 1500, 0.9, 110), 0.55)),
                               (0.035, low_pass(click(0.07, 700, 0.7, 70), 0.35))))
    write("flash_switch", mix((0, low_pass(click(0.03, 3200, 0.8, 220), 0.7)),
                              (0.028, low_pass(click(0.04, 1100, 0.6, 150), 0.45))))
    write("envelope_flap", low_pass(paper(0.28, 90, 0.7), 0.3))
    write("pack_tear", low_pass(paper(0.42, 420, 0.9), 0.75))


if __name__ == "__main__":
    main()
