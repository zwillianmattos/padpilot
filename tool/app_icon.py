"""PadPilot app icon: violet squircle, white gamepad with accent buttons."""
import sys
from PIL import Image, ImageDraw, ImageFilter, ImageChops

SS = 2  # supersampling
N = 1024 * SS
out_dir = sys.argv[1]

def rrect_mask(box, r):
    m = Image.new("L", (N, N), 0)
    ImageDraw.Draw(m).rounded_rectangle(box, r, fill=255)
    return m

# macOS grid: 824 px body centered in 1024 canvas, ~185 px corner radius.
inset = 100 * SS
body_box = (inset, inset, N - inset, N - inset)
body = rrect_mask(body_box, 185 * SS)

# Diagonal gradient violet.
top, bottom = (151, 113, 255), (72, 33, 196)
grad = Image.new("RGB", (N, N))
gp = grad.load()
for y in range(N):
    for x in range(0, N, 1):
        t = (x * 0.35 + y * 0.65) / N
        gp[x, y] = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
icon = Image.new("RGBA", (N, N), (0, 0, 0, 0))

# Soft drop shadow under the body.
shadow = Image.new("RGBA", (N, N), (0, 0, 0, 0))
shadow.putalpha(body.filter(ImageFilter.GaussianBlur(18 * SS)).point(lambda v: int(v * 0.45)))
shadow = ImageChops.offset(shadow, 0, 14 * SS)
icon.alpha_composite(shadow)

layer = Image.new("RGBA", (N, N), (0, 0, 0, 0))
layer.paste(grad, (0, 0), body)
icon.alpha_composite(layer)

# Top highlight for depth.
hl = Image.new("L", (N, N), 0)
ImageDraw.Draw(hl).ellipse((-N * 0.2, -N * 0.75, N * 1.2, N * 0.42), fill=34)
hl = ImageChops.multiply(hl, body)
white = Image.new("RGBA", (N, N), (255, 255, 255, 0))
white.putalpha(hl.filter(ImageFilter.GaussianBlur(90 * SS)))
icon.alpha_composite(white)

# Gamepad silhouette (unit coords scaled to the body).
def U(v): return int(v * N)
pad = Image.new("L", (N, N), 0)
d = ImageDraw.Draw(pad)
d.rounded_rectangle((U(0.24), U(0.36), U(0.76), U(0.60)), U(0.11), fill=255)
for cx in (0.335, 0.665):
    d.ellipse((U(cx - 0.105), U(0.47), U(cx + 0.105), U(0.69)), fill=255)
d.rounded_rectangle((U(0.24), U(0.44), U(0.42), U(0.66)), U(0.08), fill=255)
d.rounded_rectangle((U(0.58), U(0.44), U(0.76), U(0.66)), U(0.08), fill=255)
pad = pad.filter(ImageFilter.GaussianBlur(0.6 * SS))

# Glyph shadow, then white glyph.
gs = Image.new("RGBA", (N, N), (30, 10, 90, 0))
gs.putalpha(ImageChops.offset(pad, 0, 10 * SS).filter(ImageFilter.GaussianBlur(14 * SS)).point(lambda v: int(v * 0.35)))
icon.alpha_composite(gs)
glyph = Image.new("RGBA", (N, N), (255, 255, 255, 0))
glyph.putalpha(pad)
icon.alpha_composite(glyph)

# D-pad and face buttons in the accent colour.
acc = (98, 58, 222, 255)
d = ImageDraw.Draw(icon)
cx, cy, a, b = U(0.345), U(0.48), U(0.075), U(0.024)
d.rounded_rectangle((cx - a, cy - b, cx + a, cy + b), U(0.008), fill=acc)
d.rounded_rectangle((cx - b, cy - a, cx + b, cy + a), U(0.008), fill=acc)
bx, by, r, o = U(0.655), U(0.48), U(0.026), U(0.052)
for dx, dy, col in ((0, -o, (255, 184, 64, 255)), (o, 0, (255, 92, 110, 255)), (0, o, (64, 210, 140, 255)), (-o, 0, (80, 170, 255, 255))):
    d.ellipse((bx + dx - r, by + dy - r, bx + dx + r, by + dy + r), fill=col)
# Small pilot chevron between the grips.
d.polygon([(U(0.47), U(0.405)), (U(0.53), U(0.405)), (U(0.50), U(0.44))], fill=acc)

final = icon.resize((1024, 1024), Image.LANCZOS)
final.save(f"{out_dir}/icon_1024_preview.png")
for size in (16, 32, 64, 128, 256, 512, 1024):
    final.resize((size, size), Image.LANCZOS).save(f"{out_dir}/app_icon_{size}.png", optimize=True)
