"""Roadmap 33: il foglio delle scene fisse (prove/volto/*.png) in una griglia 3×3 a metà grandezza.
Uso: python tools/foglio_volto.py [cartella] [uscita]   (predefiniti: prove/volto, prove/volto_foglio.png)"""
import sys, os
from PIL import Image, ImageDraw
src = sys.argv[1] if len(sys.argv) > 1 else "prove/volto"
out = sys.argv[2] if len(sys.argv) > 2 else "prove/volto_foglio.png"
files = sorted(f for f in os.listdir(src) if f.endswith(".png"))
W, H = 800, 450
sheet = Image.new("RGB", (W * 3, H * 3), (0, 0, 0))
d = ImageDraw.Draw(sheet)
for i, f in enumerate(files[:9]):
    im = Image.open(os.path.join(src, f)).convert("RGB").resize((W, H), Image.LANCZOS)
    x, y = (i % 3) * W, (i // 3) * H
    sheet.paste(im, (x, y))
    d.text((x + 8, y + 6), f[:-4], fill=(255, 220, 140))
sheet.save(out)
print(out)
