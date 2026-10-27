#!/usr/bin/env python3
"""Lighten the dark-grey icons of the BlackBerry Hub for a dark background.

    python3 make_icons.py <assets> <out>

<assets>: a copy of /apps/sys.pim.messages.*/native/assets from the phone.
Picks every PNG whose opaque pixels are more than 25% dark grey (titlebar
shadows excluded) and maps its grey pixels black -> #a8a8a8 (white stays
white, shades keep their order); coloured pixels are untouched.
Writes the changed PNGs to <out> with the same layout. Needs Pillow.
"""
import os
import sys
from PIL import Image

BASE = 0xa8        # what black becomes
GREY = 30          # max(r,g,b) - min(r,g,b) below this: a grey pixel
DARK = 110         # a grey pixel darker than this counts as dark
MIN_DARK = 0.25    # share of dark-grey opaque pixels that selects an icon


def is_dark_icon(im):
    opaque = dark = 0
    for r, g, b, a in im.getdata():
        if a < 60:
            continue
        opaque += 1
        if max(r, g, b) - min(r, g, b) < GREY and max(r, g, b) < DARK:
            dark += 1
    return opaque and dark / opaque > MIN_DARK


def lighten(im):
    px = []
    for r, g, b, a in im.getdata():
        if a and max(r, g, b) - min(r, g, b) < GREY:
            r = g = b = BASE + (r + g + b) // 3 * (255 - BASE) // 255
        px.append((r, g, b, a))
    im.putdata(px)
    return im


def main(src, dst):
    n = 0
    for dp, _, fs in os.walk(src):
        for f in sorted(fs):
            if not f.endswith('.png') or 'shadow' in f:
                continue
            p = os.path.join(dp, f)
            im = Image.open(p).convert('RGBA')
            if not is_dark_icon(im):
                continue
            out = os.path.join(dst, os.path.relpath(p, src))
            os.makedirs(os.path.dirname(out), exist_ok=True)
            lighten(im).save(out, optimize=True)
            n += 1
    print(f"{n} icons written to {dst}")


if __name__ == '__main__':
    main(*sys.argv[1:3])
