"""Roadmap 34: tutte le foto di una cartella (predefinita prove/sfondi) in un foglio a 4 colonne, a un terzo della grandezza.
Uso: python tools/foglio_sfondi.py [cartella] [uscita]"""
import sys, os
from PIL import Image, ImageDraw
src = sys.argv[1] if len(sys.argv) > 1 else "prove/sfondi"
out = sys.argv[2] if len(sys.argv) > 2 else "prove/sfondi_foglio.png"
files = sorted(f for f in os.listdir(src) if f.endswith(".png"))
W, H, C = 533, 300, 4
rows = (len(files) + C - 1) // C
sheet = Image.new("RGB", (W * C, H * rows), (0, 0, 0))
d = ImageDraw.Draw(sheet)
for i, f in enumerate(files):
    im = Image.open(os.path.join(src, f)).convert("RGB").resize((W, H), Image.LANCZOS)
    x, y = (i % C) * W, (i // C) * H
    sheet.paste(im, (x, y))
    d.text((x + 6, y + 4), f[:-4], fill=(255, 220, 140))
sheet.save(out)
print(out)
