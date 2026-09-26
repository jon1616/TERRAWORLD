# -*- coding: utf-8 -*-
"""Il Germogliato fermo che respira, fatto dallo sprite di riferimento come farebbe un pixel artist (26 set 2026).

A 36 pixel il respiro vale un pixel: le quattro pose disegnate da Nano Banana (02_fermo.png) cambiavano tra loro molto
di più (perlina che compare e sparisce, braccio e busto di forme diverse) e l'animazione tremolava invece di
respirare. Qui si parte da una sola posa, il riferimento approvato ridotto con `pixela.py`, e si spostano pochi pixel:
 0. la posa com'è;
 1. inspirare: testa e busto (tutto sopra la vita) salgono di 1 pixel, i piedi restano fermi;
 2. pieno: come 1, e il germoglio si piega di 1 pixel indietro;
 3. espirare con un battito di ciglia: di nuovo giù, l'occhio chiuso (i pixel d'oro diventano una lineetta scura).

Uso:  python tools/respiro.py [--riferimento arte_ia/germogliato/00_profilo_fermo_v4.png] [--alto 36]
Scrive arte/germogliato/fermo_<n>.png e le anteprime prove/germogliato_fermo_respiro.png/.gif.
"""
import argparse
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pixela  # noqa: E402
from importa_tavola import DST, PROVE, RIFERIMENTO  # noqa: E402

VITA = 0.52          # dove comincia la parte che respira, dall'alto (frazione dell'altezza): sopra la cintura
GERMOGLIO = 0.12     # la parte alta con il germoglio


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--riferimento", default=RIFERIMENTO)
    ap.add_argument("--alto", type=int, default=36)
    ap.add_argument("--fps", type=int, default=4)
    args = ap.parse_args()
    ref = pixela.ritaglia(pixela.togli_magenta(Image.open(args.riferimento)))
    pal, n_base = pixela.tavolozza([ref], 20, pixela.ACCENTI)
    base = pixela.riduci(ref, ref.shape[0] / (args.alto - 2), pal, n_base)
    h, w = base.shape[:2]
    # una riga di spazio in cima, per il busto che sale
    b = np.zeros((h + 1, w, 4), dtype=np.uint8)
    b[1:] = base
    h += 1
    cut = int(h * VITA)

    def su(img: np.ndarray) -> np.ndarray:
        out = img.copy()
        out[:cut - 1] = img[1:cut]          # tutto sopra la vita sale di un pixel
        out[cut - 1] = img[cut - 1]         # la riga della vita resta: il busto si allunga, non si stacca
        return out

    def germoglio_indietro(img: np.ndarray) -> np.ndarray:
        out = img.copy()
        top = int(h * GERMOGLIO)
        rows = [y for y in range(top) if img[y, :, 3].any()]
        for y in rows[: max(1, len(rows) // 2)]:   # solo la punta: le foglie si piegano, il gambo resta
            out[y] = 0
            out[y, :-1] = img[y, 1:]
        return out

    def occhio_chiuso(img: np.ndarray) -> np.ndarray:
        out = img.copy()
        gold = np.array([int(pixela.ACCENTI[0][i:i + 2], 16) for i in (1, 3, 5)], dtype=np.int32)
        eye = (np.abs(img[:, :, :3].astype(np.int32) - gold).sum(axis=2) < 30) & (img[:, :, 3] > 0)
        ys, xs = np.where(eye)
        for y, x in zip(ys, xs):
            # la palpebra ha il colore della pelle, che sta davanti all'occhio (il Germogliato guarda a destra)
            xx = x + 1
            while xx < w - 1 and eye[y, xx]:
                xx += 1
            out[y, x, :3] = img[y, xx, :3]
        if len(ys):
            # e sotto, la lineetta scura delle ciglia chiuse
            low = ys.max()
            for x in xs[ys == low]:
                out[low, x, :3] = pixela.OUTLINE
        return out

    frames = [b, su(b), germoglio_indietro(su(b)), occhio_chiuso(b)]
    os.makedirs(DST, exist_ok=True)
    for i, fr in enumerate(frames):
        Image.fromarray(fr, "RGBA").save(os.path.join(DST, "fermo_%d.png" % i))
    k = 8
    strip = Image.new("RGBA", (len(frames) * (w + 2) * k, h * k), (40, 70, 80, 255))
    gif = []
    for i, fr in enumerate(frames):
        im = Image.fromarray(fr, "RGBA").resize((w * k, h * k), Image.NEAREST)
        strip.alpha_composite(im, (i * (w + 2) * k, 0))
        bg = Image.new("RGBA", (w * k, h * k), (40, 70, 80, 255))
        bg.alpha_composite(im)
        gif.append(bg.convert("P", palette=Image.ADAPTIVE))
    strip.save(os.path.join(PROVE, "germogliato_fermo_respiro.png"))
    # il respiro è lento: il fotogramma neutro dura di più, il battito di ciglia poco
    durate = [int(1000 / args.fps) * d for d in (3, 2, 2, 1)]
    gif[0].save(os.path.join(PROVE, "germogliato_fermo_respiro.gif"), save_all=True, append_images=gif[1:],
                duration=durate, loop=0, disposal=2)
    print("fermo: 4 fotogrammi %dx%d dal riferimento, in arte/germogliato/; anteprime in prove/germogliato_fermo_respiro.*" % (w, h))


if __name__ == "__main__":
    main()
