"""Roadmap 33: le scene fisse prima e dopo, affiancate (prove/volto_prima/ e prove/volto/) in prove/volto_confronto.png.
Uso: python tools/confronto_volto.py
Anche per altre foto (Roadmap 34): python tools/confronto_volto.py prove/sfondi_prima prove/sfondi prove/sfondi_confronto.png"""
import os
import sys
from PIL import Image, ImageDraw
A, B, OUT = (sys.argv[1:4] if len(sys.argv) >= 4 else ("prove/volto_prima", "prove/volto", "prove/volto_confronto.png"))
files = sorted(f for f in os.listdir(B) if f.endswith(".png") and os.path.exists(os.path.join(A, f)))
W, H = 800, 450
sheet = Image.new("RGB", (W * 2 + 12, (H + 8) * len(files)), (8, 12, 14))
d = ImageDraw.Draw(sheet)
for i, f in enumerate(files):
    y = i * (H + 8)
    for k, src in enumerate((A, B)):
        im = Image.open(os.path.join(src, f)).convert("RGB").resize((W, H), Image.LANCZOS)
        sheet.paste(im, (k * (W + 12), y))
        d.text((k * (W + 12) + 8, y + 6), ("PRIMA  " if k == 0 else "DOPO  ") + f[:-4], fill=(255, 220, 140))
sheet.save(OUT)
print(OUT)
