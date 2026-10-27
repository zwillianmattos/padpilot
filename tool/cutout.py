"""Turn a product shot on white into a transparent PNG.

Background = near-white pixels connected to the image border. Inside it,
brightness maps to alpha over black, so soft shadows survive as real
translucent shadows that work on light and dark backgrounds.
"""
import sys
from collections import deque
from PIL import Image, ImageFilter

src, dst = sys.argv[1], sys.argv[2]
img = Image.open(src).convert("RGB")
w, h = img.size
px = img.load()
lum = [[0] * w for _ in range(h)]
for y in range(h):
    for x in range(w):
        r, g, b = px[x, y]
        lum[y][x] = (r * 299 + g * 587 + b * 114) // 1000

SEED = int(sys.argv[4]) if len(sys.argv) > 4 else 248  # flood starts only from (near) pure white
FLOOR = 165  # never flood into anything darker than this
STEP = int(sys.argv[3]) if len(sys.argv) > 3 else 3  # max brightness change between neighbours: smooth shadows pass, hard edges stop
bg = [[False] * w for _ in range(h)]
q = deque()
for x in range(w):
    q.append((x, 0)); q.append((x, h - 1))
for y in range(h):
    q.append((0, y)); q.append((w - 1, y))
for x, y in list(q):
    if lum[y][x] >= SEED:
        bg[y][x] = True
q = deque((x, y) for x, y in q if bg[y][x])
while q:
    x, y = q.popleft()
    for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
        if 0 <= nx < w and 0 <= ny < h and not bg[ny][nx]:
            l = lum[ny][nx]
            if l >= FLOOR and abs(l - lum[y][x]) <= STEP:
                bg[ny][nx] = True
                q.append((nx, ny))

out = Image.new("RGBA", (w, h))
o = out.load()
for y in range(h):
    for x in range(w):
        if bg[y][x]:
            # 255 → fully transparent, darker shadow → more opaque black.
            a = int((255 - lum[y][x]) / (255 - FLOOR) * 110)
            o[x, y] = (0, 0, 0, max(0, min(110, a)))
        else:
            r, g, b = px[x, y]
            o[x, y] = (r, g, b, 255)

# Soften the cut edge by one pixel.
alpha = out.getchannel("A")
edge = alpha.filter(ImageFilter.GaussianBlur(0.7))
out.putalpha(Image.eval(edge, lambda v: v))
out.save(dst, optimize=True)
