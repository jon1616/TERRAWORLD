# -*- coding: utf-8 -*-
"""Il confronto degli stili delle icone (8 ott 2026, l'utente: «uniformiamo lo stile, lo voglio bello, non per forza in
pixel art»). Da una tavola di Nano Banana a griglia fa per ogni icona due versioni e le mette dentro caselle della
Bisaccia (56 px, icona a 48 come nel gioco), colorate in tre materiali come fa `IconTemplates` (i grigi prendono la
tavolozza del materiale):
  A — dipinta: l'icona ridotta a 48 pixel con un filtro morbido, come è disegnata;
  B — pixel art: ridotta a 16 pixel con la pixelatura delle altre tavole e ingrandita ×3 (com'è oggi).
Uso:  python tools/prova_icone.py arte_ia/icone/<tavola>.png --griglia 4x3 [--uscita prove/icone/confronto_stile.png]
"""
import argparse
import os
import sys

import numpy as np
from scipy import ndimage
from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(__file__))
import pixela  # noqa: E402
import tavola  # noqa: E402

PALS = {
    "radicite": ["#5a2414", "#963a22", "#cc6034", "#f8a070"],
    "legnoferro": ["#3a4250", "#6a7688", "#a2b0c2", "#dce6f2"],
    "ambra": ["#6a4a0c", "#b0861c", "#eec04a", "#fff2a8"],
}


def hexrgb(h: str) -> np.ndarray:
    return np.array([int(h[i:i + 2], 16) for i in (1, 3, 5)], dtype=np.float32)


def tint(img: Image.Image, pal: list[str]) -> Image.Image:
    """I grigi neutri prendono la tavolozza del materiale alla stessa altezza (come `IconTemplates._tinted`)."""
    a = np.asarray(img.convert("RGBA")).astype(np.float32)
    rgb = a[:, :, :3]
    sat = rgb.max(axis=2) - rgb.min(axis=2)
    lum = rgb @ np.array([0.3, 0.59, 0.11]) / 255.0
    grey = (a[:, :, 3] > 128) & (sat <= 18) & (lum > 0.16)
    if not grey.any():
        return img
    lo, hi = lum[grey].min(), max(lum[grey].max(), lum[grey].min() + 0.01)
    p = np.array([hexrgb(c) for c in pal])
    t = (lum - lo) / (hi - lo)
    pos = np.clip(t, 0, 1) * (len(p) - 1)
    i0 = np.floor(pos).astype(int).clip(0, len(p) - 1)
    i1 = (i0 + 1).clip(0, len(p) - 1)
    f = (pos - i0)[:, :, None]
    col = p[i0] * (1 - f) + p[i1] * f
    out = a.copy()
    out[grey, :3] = col[grey]
    return Image.fromarray(out.clip(0, 255).astype(np.uint8), "RGBA")


def togli_scritte(rgb: np.ndarray, cols: int, rows: int) -> None:
    """Le parole bianche che Nano Banana scrive sopra o sotto le figure (anche quando gli si dice di no) e che a volte le
    toccano: in ogni cella una fascia di righe con molto bianco puro, alta come una riga di testo, vicino al bordo in
    alto o in basso. Il bianco della fascia e il contorno scuro delle lettere diventano magenta (8 ott 2026, lotto 3)."""
    h, w = rgb.shape[:2]
    lum = rgb @ np.array([0.3, 0.59, 0.11])
    sat = rgb.max(axis=2) - rgb.min(axis=2)
    white = (lum > 235) & (sat < 25)
    ch, cw = h / rows, w / cols
    for r in range(rows):
        for c in range(cols):
            y0, y1, x0, x1 = int(r * ch), int((r + 1) * ch), int(c * cw), int((c + 1) * cw)
            wb = white[y0:y1, x0:x1]
            on = np.where(wb.sum(axis=1) > 8)[0]
            runs, start = [], None
            for i, y in enumerate(on):
                if start is None:
                    start = y
                if i + 1 == len(on) or on[i + 1] > y + 3:
                    runs.append((start, y + 1))
                    start = None
            for a0, a1 in runs:
                tall = a1 - a0
                edge = a1 <= (y1 - y0) * 0.3 or a0 >= (y1 - y0) * 0.7
                xs = np.where(wb[a0:a1].any(axis=0))[0]
                if not (6 <= tall <= (y1 - y0) * 0.2 and edge and xs.size and xs.max() - xs.min() > cw * 0.25):
                    continue
                b0, b1 = max(0, a0 - 5), min(y1 - y0, a1 + 5)
                band = wb[b0:b1]
                near = ndimage.binary_dilation(band, iterations=6)
                sub = rgb[y0 + b0:y0 + b1, x0:x1]
                kill = near & (band | (lum[y0 + b0:y0 + b1, x0:x1] < 110))
                sub[kill] = (255, 0, 255)


def figures(path: str, cols: int, rows: int) -> list[np.ndarray]:
    rgb = np.asarray(Image.open(path).convert("RGB")).astype(np.int32)
    r, g, b = rgb[:, :, 0], rgb[:, :, 1], rgb[:, :, 2]
    fam = ((np.minimum(r, b) - g > 80) | ((np.minimum(r, b) - g > 30) & (np.minimum(r, b) > 2.2 * g + 20))) \
        & (np.abs(r - b) < 70)
    rgb[fam] = (255, 0, 255)
    togli_scritte(rgb, cols, rows)
    # le linee nere della griglia (lotto 12: celle disuguali, linee unite fra loro): righe e colonne scure per lunghi tratti
    dark = (rgb @ np.array([0.3, 0.59, 0.11])) < 70
    for y in np.where(dark.mean(axis=1) > 0.6)[0]:
        rgb[y, dark[y]] = (255, 0, 255)
    for x in np.where(dark.mean(axis=0) > 0.4)[0]:
        rgb[dark[:, x], x] = (255, 0, 255)
    a = tavola.togli_magenta(Image.fromarray(rgb.astype(np.uint8), "RGB"))
    out = []
    for sy, sx, m in tavola.pezzi_griglia(a, cols, rows):
        f = a[sy, sx].copy()
        f[~m, 3] = 0.0
        out.append(f)
    return out


def painted(f: np.ndarray, size: int = 48) -> Image.Image:
    im = Image.fromarray((f * [1, 1, 1, 255]).clip(0, 255).astype(np.uint8), "RGBA")
    w, h = im.size
    k = (size - 2) / max(w, h)
    im = im.resize((max(1, round(w * k)), max(1, round(h * k))), Image.LANCZOS)
    out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    out.paste(im, ((size - im.width) // 2, (size - im.height) // 2), im)
    return out


def pixel(f: np.ndarray, pal, n_base) -> Image.Image:
    small = tavola.riduci_a(pixela.ritaglia(f), 16, pal, n_base)
    return Image.fromarray(small, "RGBA").resize((48, 48), Image.NEAREST)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("file")
    ap.add_argument("--griglia", default="4x3")
    ap.add_argument("--uscita", default="prove/icone/confronto_stile.png")
    args = ap.parse_args()
    cols, rows = (int(x) for x in args.griglia.split("x"))
    figs = figures(args.file, cols, rows)
    pal, n_base = pixela.tavolozza(figs, 16, [])
    vers = [("A dipinta 48", [painted(f) for f in figs]), ("B pixel 16", [pixel(f, pal, n_base) for f in figs])]
    slot = 56
    cell_w = 3 * (slot + 4) + 14                # tre materiali per icona, uno accanto all'altro
    cell_h = slot + 14
    vw = cols * cell_w
    W = len(vers) * (vw + 30) + 10
    H = 40 + rows * cell_h
    sheet = Image.new("RGBA", (W, H), (20, 16, 25, 255))
    d = ImageDraw.Draw(sheet)
    for v, (name, ims) in enumerate(vers):
        x0 = 10 + v * (vw + 30)
        d.text((x0, 12), name, fill=(232, 220, 190, 255))
        for i, im in enumerate(ims):
            cx = x0 + (i % cols) * cell_w
            cy = 34 + (i // cols) * cell_h
            for m, matn in enumerate(PALS):
                x = cx + m * (slot + 4)
                d.rounded_rectangle([x, cy, x + slot - 1, cy + slot - 1], radius=6, fill=(32, 38, 43, 255),
                                    outline=(58, 160, 138, 255), width=2)
                sheet.alpha_composite(tint(im, PALS[matn]), (x + 4, cy + 4))
    os.makedirs(os.path.dirname(args.uscita), exist_ok=True)
    sheet.save(args.uscita)
    # una seconda immagine grande: le icone dipinte in legnoferro ×2, per guardare il disegno da vicino
    big = Image.new("RGBA", (cols * 112 + 16, rows * 112 + 16), (20, 16, 25, 255))
    for i, im in enumerate(vers[0][1]):
        t = tint(im, PALS["legnoferro"]).resize((96, 96), Image.LANCZOS)
        big.alpha_composite(t, (16 + (i % cols) * 112, 16 + (i // cols) * 112))
    big.save(args.uscita.replace(".png", "_vicino.png"))
    print("confronto: %s (%d icone)" % (args.uscita, len(figs)))


if __name__ == "__main__":
    main()
