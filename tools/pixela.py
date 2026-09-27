# -*- coding: utf-8 -*-
"""Trasforma un disegno ad alta risoluzione fatto con Nano Banana (su magenta #FF00FF) in uno sprite in pixel art
della misura del gioco (26 set 2026: Nano Banana disegna bene in grande ma non sa disegnare a pixel grossi; quando
gli si chiede di ridisegnare più piccolo restituisce la stessa immagine).

Come lavora un pixel artist e non una semplice riduzione (la media dei colori rende tutto sfocato e sbiadito):
 1. toglie il magenta, anche dai bordi sfumati;
 2. riduce i colori della figura a una tavolozza di pochi colori (k-medie); le tavole delle animazioni usano tutte
    la tavolozza del riferimento (vedi `importa_tavola.py`), così i fotogrammi non «tremolano» di colore;
 3. ogni pixel piccolo prende il colore che DOMINA nel suo riquadro (la moda), non la media; i colori scuri, quelli
    luminosi e quelli rari nella figura vincono anche con meno spazio, perché altrimenti i dettagli piccoli e le
    linee sottili sparirebbero; i colori d'accento (occhio, perlina, foglia sulla guancia) sono fissi in tavolozza
    e prendono il pixel appena ne coprono una parte visibile, ma solo i pixel davvero del loro colore;
 4. pulisce i pixel isolati (rumore delle sfumature del disegno grande) e aggiunge un contorno scuro di 1 pixel.

Uso:  python tools/pixela.py arte_ia/germogliato/00_profilo_fermo_v4.png --alto 36 [--colori 20] [--anteprima]
Scrive accanto al file <nome>_px.png (misura vera, trasparente) e, con --anteprima, <nome>_px_x8.png ingrandito.
Le funzioni `togli_magenta`, `tavolozza` e `riduci` servono anche a `importa_tavola.py`.
"""
import argparse
import os

import numpy as np
from PIL import Image

OUTLINE = (26, 16, 32)          # #1A1020, il contorno del gioco
ACCENT_SHARE = 0.12             # quota di un riquadro oltre cui un colore d'accento prende il pixel
ACCENT_NEAR = 40.0              # distanza di colore (RGB) entro cui un pixel appartiene a un accento
# gli accenti del Germogliato (dal riferimento 00_profilo_fermo_v4): l'occhio d'oro, la perlina turchese, la foglia
# sulla guancia
ACCENTI = ["#f0d048", "#0c90a8", "#609c6c"]


def togli_magenta(im: Image.Image) -> np.ndarray:
    """RGBA in float (alfa 0-1): sfondo stimato dagli angoli, bordi sfumati ripuliti, residui di magenta tolti."""
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
    c = px[rng.choice(len(px), k, replace=False)].copy()
    for _ in range(giri):
        lab = ((px[:, None, :] - c[None, :, :]) ** 2).sum(axis=2).argmin(axis=1)
        for i in range(k):
            sel = px[lab == i]
            if len(sel):
                c[i] = sel.mean(axis=0)
    return c


def tavolozza(figure: list[np.ndarray], colori: int, accenti: list[str]) -> tuple[np.ndarray, int]:
    """La tavolozza (colori di base dalle figure + accenti in fondo) e quanti sono quelli di base."""
    px = np.concatenate([a[:, :, :3][a[:, :, 3] > 0.9] for a in figure])
    # i quasi neri del contorno del disegno si prendevano 6 colori su 20 (e mancava l'ocra chiaro della tunica): fuori
    # dal calcolo, e un solo scuro per loro, quello del contorno del gioco
    lum = px @ np.array([0.3, 0.59, 0.11])
    px = px[lum > 45]
    pal = kmedie(px[:: max(1, len(px) // 40000)], colori - 1)
    pal = np.vstack([pal, np.array([OUTLINE], dtype=np.float32)])
    acc = np.array([[int(h[i:i + 2], 16) for i in (1, 3, 5)] for h in accenti], dtype=np.float32).reshape(-1, 3)
    return np.vstack([pal, acc]), len(pal)


def _indici(rgb: np.ndarray, pal: np.ndarray, n_base: int) -> np.ndarray:
    flat = rgb.reshape(-1, 3)
    idx = np.empty(len(flat), dtype=np.int32)
    for s in range(0, len(flat), 200000):
        d2 = ((flat[s:s + 200000, None, :] - pal[None]) ** 2).sum(axis=2)
        near = d2.argmin(axis=1)
        # un accento prende solo i pixel davvero del suo colore: altrimenti l'ambra dell'occhio si prendeva anche
        # le foglie gialle del germoglio e la parte chiara della tunica
        far = (near >= n_base) & (d2[np.arange(len(near)), near] > ACCENT_NEAR ** 2)
        near[far] = d2[far, :n_base].argmin(axis=1)
        idx[s:s + 200000] = near
    return idx.reshape(rgb.shape[:2])


def riduci(a: np.ndarray, f: float, pal: np.ndarray, n_base: int, scuro_min: float = 0.0) -> np.ndarray:
    """Riduce la figura `a` (RGBA float) di un fattore `f` (pixel grandi per pixel piccolo) con la tavolozza data.
    Restituisce RGBA uint8 con il contorno (1 pixel in più su ogni lato)."""
    h_in = max(1, round(a.shape[0] / f))
    w_in = max(1, round(a.shape[1] / f))
    rgb = a[:, :, :3]
    opaque = a[:, :, 3] > 0.9
    idx = _indici(rgb, pal, n_base)
    # peso dei colori nella moda: gli estremi (molto scuri, molto chiari o saturi) contano di più
    lum = pal @ np.array([0.3, 0.59, 0.11])
    sat = pal.max(axis=1) - pal.min(axis=1)
    # il peso in più dei colori scuri serve quando un pixel piccolo copre molti pixel grandi (le linee sottili si
    # perderebbero); nelle tavole, con celle piccole, il contorno del disegno è già largo mezzo pixel e vincerebbe
    # ovunque (la tunica diventava marrone): il peso scende con il fattore di riduzione
    scuro = 1.5 * float(np.clip((f - 8.0) / 12.0, 0.0, 1.0))
    # i ritratti (tools/tavola.py --dettagli): occhi e bocca sono linee scure sottili che la moda perdeva
    scuro = max(scuro, scuro_min)
    peso = 1.0 + scuro * (lum < 60) + 1.2 * (lum > 190) + 0.8 * (sat > 120)
    # i colori rari della figura sono dettagli messi apposta: contano di più, altrimenti in un riquadro perdono sempre
    # contro il colore che li circonda
    freq = np.bincount(idx[opaque], minlength=len(pal)).astype(np.float32) + 1.0
    peso *= np.clip(np.sqrt(np.median(freq) / freq), 1.0, 4.0)
    out = np.zeros((h_in, w_in, 4), dtype=np.uint8)
    for y in range(h_in):
        y0, y1 = int(y * f), max(int((y + 1) * f), int(y * f) + 1)
        for x in range(w_in):
            x0, x1 = int(x * f), max(int((x + 1) * f), int(x * f) + 1)
            cell_op = opaque[y0:y1, x0:x1]
            if cell_op.size == 0 or cell_op.mean() < 0.45:
                continue
            raw = np.bincount(idx[y0:y1, x0:x1][cell_op], minlength=len(pal)).astype(np.float32)
            best = int((raw * peso).argmax())
            # un accento vince il suo pixel appena ne copre una parte visibile (l'occhio è grande 1-2 pixel)
            share = raw[n_base:] / max(raw.sum(), 1.0)
            if len(share) and share.max() >= ACCENT_SHARE:
                best = n_base + int(share.argmax())
            out[y, x, :3] = pal[best].astype(np.uint8)
            out[y, x, 3] = 255
    # pulizia: un pixel che non somiglia a nessuno dei 4 vicini è rumore della riduzione (le sfumature del disegno
    # grande), prende il colore più comune attorno. Gli accenti restano: sono piccoli apposta.
    acc_set = {tuple(c.astype(np.uint8)) for c in pal[n_base:]}
    for _ in range(2):
        src = out.copy()
        for y in range(h_in):
            for x in range(w_in):
                if src[y, x, 3] == 0 or tuple(src[y, x, :3]) in acc_set:
                    continue
                near = [tuple(src[yy, xx, :3]) for yy, xx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1))
                        if 0 <= yy < h_in and 0 <= xx < w_in and src[yy, xx, 3] > 0]
                if len(near) >= 3 and tuple(src[y, x, :3]) not in near:
                    best = max(set(near), key=near.count)
                    if near.count(best) >= 2:
                        out[y, x, :3] = best
    # il contorno: attorno alla sagoma, 1 pixel
    big = np.zeros((h_in + 2, w_in + 2, 4), dtype=np.uint8)
    big[1:-1, 1:-1] = out
    m = big[:, :, 3] > 0
    ring = np.zeros_like(m)
    ring[1:, :] |= m[:-1, :]
    ring[:-1, :] |= m[1:, :]
    ring[:, 1:] |= m[:, :-1]
    ring[:, :-1] |= m[:, 1:]
    ring &= ~m
    big[ring] = (*OUTLINE, 255)
    return big


def ritaglia(a: np.ndarray) -> np.ndarray:
    ys, xs = np.where(a[:, :, 3] > 0.5)
    return a[ys.min():ys.max() + 1, xs.min():xs.max() + 1]


def pixela(path: str, alto: int, colori: int, accenti: list[str]) -> tuple[Image.Image, np.ndarray]:
    a = ritaglia(togli_magenta(Image.open(path)))
    pal, n_base = tavolozza([a], colori, accenti)
    # la figura dentro il contorno: alta `alto` - 2 pixel (il contorno ne aggiunge uno sopra e uno sotto)
    big = riduci(a, a.shape[0] / (alto - 2), pal, n_base)
    return Image.fromarray(big, "RGBA"), pal


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("file")
    ap.add_argument("--alto", type=int, default=36)
    ap.add_argument("--colori", type=int, default=20)
    ap.add_argument("--anteprima", action="store_true")
    ap.add_argument("--accenti", default=",".join(ACCENTI), help="colori d'accento separati da virgole (#rrggbb)")
    args = ap.parse_args()
    im, pal = pixela(args.file, args.alto, args.colori, [h.strip() for h in args.accenti.split(",") if h.strip()])
    base = os.path.splitext(args.file)[0]
    im.save(base + "_px.png")
    if args.anteprima:
        im.resize((im.width * 8, im.height * 8), Image.NEAREST).save(base + "_px_x8.png")
    print("%s_px.png: %dx%d, %d colori" % (base, im.width, im.height, len(pal)))


if __name__ == "__main__":
    main()
