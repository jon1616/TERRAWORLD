# -*- coding: utf-8 -*-
"""Trasforma un disegno ad alta risoluzione fatto con Nano Banana (su magenta #FF00FF) in uno sprite in pixel art
della misura del gioco (26 set 2026: Nano Banana disegna bene in grande ma non sa disegnare a pixel grossi; quando
gli si chiede di ridisegnare più piccolo restituisce la stessa immagine).

Come lavora un pixel artist e non una semplice riduzione (la media dei colori rende tutto sfocato e sbiadito):
 1. toglie il magenta, anche dai bordi sfumati;
 2. riduce i colori della figura a una tavolozza di pochi colori (k-medie), la stessa per tutti i fotogrammi se si
    passa --tavolozza (così le animazioni non «tremolano» di colore);
 3. ogni pixel piccolo prende il colore che DOMINA nel suo riquadro (la moda), non la media; i colori scuri e quelli
    luminosi (occhio, venature) vincono anche con meno spazio, perché altrimenti le linee sottili sparirebbero;
 4. aggiunge un contorno scuro di 1 pixel attorno alla sagoma.

Uso:  python tools/pixela.py arte_ia/germogliato/00_profilo_fermo.png --alto 46 [--colori 16] [--anteprima]
Scrive accanto al file <nome>_px.png (misura vera, trasparente) e, con --anteprima, <nome>_px_x8.png ingrandito.
"""
import argparse
import os

import numpy as np
from PIL import Image

OUTLINE = (26, 16, 32)          # #1A1020, il contorno del gioco
ACCENT_SHARE = 0.12             # quota di un riquadro oltre cui un colore d'accento prende il pixel
# gli accenti del Germogliato: l'occhio d'ambra, la perlina turchese e il verde del germoglio (presi dal disegno)
ACCENTI = ["#f0c060", "#1898a0", "#84b45c"]


def togli_magenta(im: Image.Image) -> np.ndarray:
    a = np.asarray(im.convert("RGB")).astype(np.float32)
    h, w = a.shape[:2]
    bg = np.stack([a[2, 2], a[2, w - 3], a[h - 3, 2], a[h - 3, w - 3]]).mean(axis=0)
    d = np.abs(a - bg).sum(axis=2)
    alpha = np.clip((d - 70.0) / 110.0, 0.0, 1.0)
    rgb = a.copy()
    part = (alpha > 0) & (alpha < 1)
    al = alpha[part][:, None]
    rgb[part] = np.clip((rgb[part] - (1 - al) * bg) / al, 0, 255)
    # i residui di magenta sui bordi (rosso e blu molto più alti del verde, simili tra loro): sono sfondo, non figura
    r, g, b = rgb[:, :, 0], rgb[:, :, 1], rgb[:, :, 2]
    fringe = (np.minimum(r, b) - g > 45) & (np.abs(r - b) < 70)
    alpha[fringe] = 0.0
    return np.dstack([rgb, alpha])


def kmedie(px: np.ndarray, k: int, giri: int = 25) -> np.ndarray:
    rng = np.random.default_rng(7)
    c = px[rng.choice(len(px), k, replace=False)]
    for _ in range(giri):
        lab = ((px[:, None, :] - c[None, :, :]) ** 2).sum(axis=2).argmin(axis=1)
        for i in range(k):
            sel = px[lab == i]
            if len(sel):
                c[i] = sel.mean(axis=0)
    return c


def pixela(path: str, alto: int, colori: int, tavolozza: str | None, accenti: list[str]) -> tuple[Image.Image, np.ndarray]:
    a = togli_magenta(Image.open(path))
    fig = a[:, :, 3] > 0.5
    ys, xs = np.where(fig)
    a = a[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
    # la figura dentro il contorno: alta `alto` - 2 pixel (il contorno ne aggiunge uno sopra e uno sotto)
    h_in = alto - 2
    f = a.shape[0] / h_in
    w_in = max(1, round(a.shape[1] / f))
    rgb = a[:, :, :3]
    opaque = a[:, :, 3] > 0.9
    if tavolozza:
        pal = np.asarray(Image.open(tavolozza).convert("RGB")).reshape(-1, 3).astype(np.float32)
        pal = np.unique(pal, axis=0)
    else:
        sample = rgb[opaque][:: max(1, opaque.sum() // 40000)]
        pal = kmedie(sample, colori)
    # i colori d'accento (occhio, perlina, germoglio...): fissi in tavolozza, così la riduzione non li assorbe
    acc = np.array([[int(h[i:i + 2], 16) for i in (1, 3, 5)] for h in accenti], dtype=np.float32).reshape(-1, 3)
    n_base = len(pal)
    pal = np.vstack([pal, acc])
    # indice di tavolozza di ogni pixel grande
    flat = rgb.reshape(-1, 3)
    idx = np.empty(len(flat), dtype=np.int32)
    for s in range(0, len(flat), 200000):
        idx[s:s + 200000] = ((flat[s:s + 200000, None, :] - pal[None]) ** 2).sum(axis=2).argmin(axis=1)
    idx = idx.reshape(rgb.shape[:2])
    # peso dei colori nella moda: gli estremi (molto scuri, molto chiari o saturi) contano di più
    lum = pal @ np.array([0.3, 0.59, 0.11])
    sat = pal.max(axis=1) - pal.min(axis=1)
    peso = 1.0 + 1.5 * (lum < 60) + 1.2 * (lum > 190) + 0.8 * (sat > 120)
    # i colori rari della figura (l'occhio d'ambra, la perlina turchese, le venature, il germoglio) sono dettagli
    # messi apposta: contano di più, altrimenti in un riquadro perdono sempre contro il colore che li circonda
    freq = np.bincount(idx[opaque], minlength=len(pal)).astype(np.float32) + 1.0
    peso *= np.clip(np.sqrt(np.median(freq) / freq), 1.0, 4.0)
    out = np.zeros((h_in, w_in, 4), dtype=np.uint8)
    for y in range(h_in):
        y0, y1 = int(y * f), max(int((y + 1) * f), int(y * f) + 1)
        for x in range(w_in):
            x0, x1 = int(x * f), max(int((x + 1) * f), int(x * f) + 1)
            cell_op = opaque[y0:y1, x0:x1]
            if cell_op.mean() < 0.45:
                continue
            raw = np.bincount(idx[y0:y1, x0:x1][cell_op], minlength=len(pal)).astype(np.float32)
            cnt = raw * peso
            best = int(cnt.argmax())
            # un accento vince il suo pixel appena ne copre una parte visibile (l'occhio è grande 2 pixel su 46)
            share = raw[n_base:] / max(raw.sum(), 1.0)
            if len(share) and share.max() >= ACCENT_SHARE:
                best = n_base + int(share.argmax())
            out[y, x, :3] = pal[best].astype(np.uint8)
            out[y, x, 3] = 255
    # il contorno: attorno alla sagoma, 1 pixel
    big = np.zeros((alto, w_in + 2, 4), dtype=np.uint8)
    big[1:-1, 1:-1] = out
    m = big[:, :, 3] > 0
    ring = np.zeros_like(m)
    ring[1:, :] |= m[:-1, :]
    ring[:-1, :] |= m[1:, :]
    ring[:, 1:] |= m[:, :-1]
    ring[:, :-1] |= m[:, 1:]
    ring &= ~m
    big[ring] = (*OUTLINE, 255)
    return Image.fromarray(big, "RGBA"), pal


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("file")
    ap.add_argument("--alto", type=int, default=46)
    ap.add_argument("--colori", type=int, default=16)
    ap.add_argument("--tavolozza", default=None, help="PNG i cui colori sono la tavolozza da usare")
    ap.add_argument("--anteprima", action="store_true")
    ap.add_argument("--accenti", default=",".join(ACCENTI), help="colori d'accento separati da virgole (#rrggbb)")
    args = ap.parse_args()
    im, pal = pixela(args.file, args.alto, args.colori, args.tavolozza,
                     [h.strip() for h in args.accenti.split(",") if h.strip()])
    base = os.path.splitext(args.file)[0]
    im.save(base + "_px.png")
    if args.anteprima:
        im.resize((im.width * 8, im.height * 8), Image.NEAREST).save(base + "_px_x8.png")
    print("%s_px.png: %dx%d, %d colori" % (base, im.width, im.height, len(pal)))


if __name__ == "__main__":
    main()
