"""Il foglio delle sagome (voce 459): le mappe di prove/sagome/<sagoma>.png una sotto l'altra con il nome.
Le mappe si fanno con tools/mappe.gd -- --lista 7 --geni <gene> (e si copiano in prove/sagome/).
Uso: python tools/foglio_sagome.py  ->  prove/sagome.png"""
import os
from PIL import Image, ImageDraw

ORDER = ["continente", "arcipelago", "guscio", "canyon", "terrazze", "sprofondato", "pilastri"]
root = os.path.join(os.path.dirname(__file__), "..", "prove")
imgs = []
for n in ORDER:
    p = os.path.join(root, "sagome", n + ".png")
    if os.path.exists(p):
        im = Image.open(p).convert("RGB")
        im = im.resize((im.width // 2, im.height // 2), Image.NEAREST)
        imgs.append((n, im))
w = max(im.width for _, im in imgs)
h = sum(im.height + 4 for _, im in imgs)
out = Image.new("RGB", (w, h), (20, 20, 24))
d = ImageDraw.Draw(out)
y = 0
for n, im in imgs:
    out.paste(im, (0, y))
    d.text((8, y + 6), n, fill=(255, 255, 255))
    y += im.height + 4
out.save(os.path.join(root, "sagome.png"))
print("prove/sagome.png", out.size)
