# -*- coding: utf-8 -*-
"""Importa una tavola di animazione di una creatura fatta con Nano Banana (7 ott 2026, prova con il Corvo di corteccia).

Come `importa_tavola.py` per il Germogliato, ma per una creatura qualunque: la tavola è una griglia di pose su magenta,
tutte rivolte a destra. Lo script:
 1. toglie il magenta e le linee della griglia, tiene in ogni cella la figura (`tavola.pezzi_griglia`);
 2. allinea le pose sull'OCCHIO (il colore d'accento più vivo e caldo della figura): il corpo resta fermo e ali, coda
    e testa si muovono attorno, così l'animazione non saltella;
 3. ritaglia tutte le pose con la stessa finestra, toglie il contorno scuro del disegno e le riduce con lo stesso
    fattore e la stessa tavolozza (i pixel piccoli cadono sulla stessa griglia: niente tremolio);
 4. scrive <cartella>/<nome>_<n>.png, la striscia ingrandita e le GIF dei gruppi di pose (--gruppi).

Per il gioco: --cartella arte/creature e --nome = la forma di `CreatureArt` (il primo campo di "art"); il punto
d'appoggio stampato va in `CreaturePosesData` con i nomi delle pose.

Uso:  python tools/importa_creatura.py arte_ia/creature/01_corvo_corteccia_v1.png --griglia 4x2 --nome corvo_corteccia \
          --lungo 21 --misura-da 1 --cartella sprite_esperimento/corvo_nuovo --gruppi volo:0-3,plana:4,sospeso:5,scatto:6-7
  --lungo N     = la posa --misura-da (indice da 0) sarà lunga N pixel senza contorno: dà la grandezza nel gioco.
"""
import argparse
import os
import sys

import numpy as np
from PIL import Image
from scipy import ndimage

sys.path.insert(0, os.path.dirname(__file__))
import pixela  # noqa: E402
import tavola  # noqa: E402


def occhio(a: np.ndarray, m: np.ndarray) -> tuple[float, float]:
    """Il centro dell'occhio: i pixel arancio-ambra (caldi, saturi, non gialli come il becco)."""
    r, g, b = a[:, :, 0], a[:, :, 1], a[:, :, 2]
    caldo = m & (r > 170) & (g > 70) & (g < 165) & (b < 90) & (r - g > 55)
    if caldo.sum() < 4:
        ys, xs = np.where(m)
        return float(ys.mean()), float(xs.max())
    lab, n = ndimage.label(caldo)
    big = 1 + int(np.argmax(ndimage.sum(caldo, lab, range(1, n + 1))))
    ys, xs = np.where(lab == big)
    return float(ys.mean()), float(xs.mean())


def senza_contorno(a: np.ndarray, spessore: float, soglia: float) -> np.ndarray:
    """`tavola.togli_contorno` senza il ritaglio finale (la finestra deve restare uguale per tutte le pose)."""
    lum = a[:, :, :3] @ np.array([0.3, 0.59, 0.11])
    fuori = a[:, :, 3] < 0.5
    scuro = (lum < soglia) & ~fuori
    lab, _ = ndimage.label(fuori | scuro)
    bordo = set(np.unique(np.concatenate([lab[0], lab[-1], lab[:, 0], lab[:, -1]]))) - {0}
    anello = np.isin(lab, list(bordo)) & scuro
    dist = ndimage.distance_transform_edt(np.pad(~fuori, 1))[1:-1, 1:-1]
    anello &= dist <= spessore
    b = a.copy()
    b[anello, 3] = 0.0
    return b


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("file")
    ap.add_argument("--griglia", default="4x2")
    ap.add_argument("--nome", required=True)
    ap.add_argument("--cartella", required=True)
    ap.add_argument("--lungo", type=int, default=21)
    ap.add_argument("--misura-da", type=int, default=0)
    ap.add_argument("--colori", type=int, default=10)
    ap.add_argument("--accenti", default="", help="colori fissi in più (occhio, vene), es. #E8902C,#2FA08C")
    ap.add_argument("--togli-polvere", action="store_true", help="toglie le nuvole di polvere e vapore staccate")
    ap.add_argument("--togli-linee", action="store_true", help="toglie la linea del suolo disegnata sotto i piedi")
    ap.add_argument("--vola", action="store_true",
                    help="chi vola: il punto d'appoggio è il centro anche con --ancora cella (l'occhio non si trova)")
    ap.add_argument("--luce", default="", help="colori che brillano al buio (maschera <nome>_<n>_luce.png)")
    ap.add_argument("--ancora", default="occhio", choices=["occhio", "cella"],
                    help="allinea le pose sull'occhio (chi vola) o sulla cella (chi salta: il fondo è il suolo)")
    ap.add_argument("--solo", type=int, default=0, help="usa solo le prime N pose (Nano Banana a volte ne aggiunge)")
    ap.add_argument("--schiarisci", type=float, default=1.0, help="moltiplica i colori di base (creature scure)")
    ap.add_argument("--scuro", type=float, default=30.0, help="luminosità sotto la quale un pixel è contorno")
    ap.add_argument("--gruppi", default="")
    ap.add_argument("--ms", type=int, default=110, help="millisecondi per fotogramma nelle GIF")
    args = ap.parse_args()
    col, righe = (int(v) for v in args.griglia.split("x"))
    os.makedirs(args.cartella, exist_ok=True)

    # lo sfondo e le linee della griglia (un magenta più scuro, anche agli angoli, dove si stima lo sfondo) diventano
    # tutti magenta pieno: altrimenti lo sfondo stimato sarebbe quello delle linee
    rgb = np.asarray(Image.open(args.file).convert("RGB")).astype(np.int32)
    r, g, b = rgb[:, :, 0], rgb[:, :, 1], rgb[:, :, 2]
    fam = (np.minimum(r, b) - g > 80) & (np.abs(r - b) < 70)
    rgb[fam] = (255, 0, 255)
    src = Image.fromarray(rgb.astype(np.uint8), "RGB")
    a = tavola.togli_magenta(src)
    if args.togli_linee:
        # la linea del suolo che Nano Banana disegna sotto i piedi anche se vietata: tratti scuri orizzontali lunghi
        # più di metà cella e alti pochi pixel (i contorni delle figure sono curvi, i loro tratti dritti sono corti)
        lum = a[:, :, :3] @ np.array([0.3, 0.59, 0.11])
        dark = (lum < 70) & (a[:, :, 3] > 0.5)
        # solo i tratti SOTTILI: un corpo scuro e largo (lo Spinoriccio) ha tratti lunghi ma spessi, e spariva
        thick = np.zeros(dark.shape, dtype=np.int32)
        for x in range(dark.shape[1]):
            col_d = dark[:, x]
            y = 0
            while y < len(col_d):
                if col_d[y]:
                    y1 = y
                    while y1 < len(col_d) and col_d[y1]:
                        y1 += 1
                    thick[y:y1, x] = y1 - y
                    y = y1
                else:
                    y += 1
        dark &= thick <= max(4, a.shape[0] // 100)
        cw0 = a.shape[1] / col
        for y in range(a.shape[0]):
            row = dark[y]
            x = 0
            while x < len(row):
                if row[x]:
                    x1 = x
                    while x1 < len(row) and row[x1]:
                        x1 += 1
                    if x1 - x > cw0 * 0.5:
                        a[y, x:x1, 3] = 0.0
                    x = x1
                else:
                    x += 1
    if args.togli_polvere:
        # nuvole di polvere e di vapore: macchie staccate chiare e poco sature (il gioco fa già la sua polvere)
        rgb3 = a[:, :, :3]
        lumv = rgb3 @ np.array([0.3, 0.59, 0.11])
        satv = rgb3.max(axis=2) - rgb3.min(axis=2)
        pale = (a[:, :, 3] > 0.5) & (lumv > 120) & (satv < 70)
        # (anche quando toccano le zampe: si tolgono i pixel, non le macchie; va bene per le creature scure)
        a[pale, 3] = 0.0
    pezzi = tavola.pezzi_griglia(a, col, righe)
    print("pose trovate: %d" % len(pezzi))
    pose = []
    if args.solo:
        pezzi = pezzi[:args.solo]
    ch, cw = a.shape[0] / righe, a.shape[1] / col
    for sy, sx, m in pezzi:
        full = np.zeros(a.shape[:2], dtype=bool)
        full[sy, sx] = m
        if args.ancora == "cella":
            # le creature che saltano: la posa resta dove Nano Banana l'ha messa nella sua cella (il fondo della cella
            # = il suolo), così i salti restano in alto e gli atterraggi a terra
            cy, cx = (sy.start + sy.stop) / 2, (sx.start + sx.stop) / 2
            ey, ex = (int(cy // ch) + 1) * ch, (int(cx // cw) + 0.5) * cw
        else:
            ey, ex = occhio(a, full)
        pose.append((full, ey, ex))
    # la finestra comune, con l'occhio nello stesso punto
    top = max(ey - np.where(f)[0].min() for f, ey, ex in pose)
    bot = max(np.where(f)[0].max() - ey for f, ey, ex in pose)
    lef = max(ex - np.where(f)[1].min() for f, ey, ex in pose)
    rig = max(np.where(f)[1].max() - ex for f, ey, ex in pose)
    pad = 4
    hh, ww = int(top + bot) + 2 * pad + 1, int(lef + rig) + 2 * pad + 1
    win = []
    for f, ey, ex in pose:
        oy, ox = int(round(ey - top)) - pad, int(round(ex - lef)) - pad
        out = np.zeros((hh, ww, 4), dtype=np.float32)
        for y in range(hh):
            yy = oy + y
            if 0 <= yy < a.shape[0]:
                x0, x1 = max(0, ox), min(a.shape[1], ox + ww)
                if x1 > x0:
                    seg = a[yy, x0:x1].copy()
                    seg[~f[yy, x0:x1], 3] = 0.0
                    out[y, x0 - ox:x1 - ox] = seg
        win.append(out)
    # il contorno del disegno: le creature scure (il corvo) hanno il corpo quasi nero, quindi conta solo il nero vero
    # (--scuro) e si toglie largo un pixel del gioco
    f = pixela.ritaglia(win[args.misura_da]).shape[1] / float(args.lungo + 2)
    spess = f * 1.1
    win = [senza_contorno(w, spess, args.scuro) for w in win]
    pal, n_base = pixela.tavolozza(win, args.colori, [x for x in args.accenti.split(",") if x])
    # le creature scure: il corpo quasi nero si confonde con il contorno del gioco (#1A1020); --schiarisci alza i
    # colori di base (non il contorno, che è l'ultimo dei colori di base, né gli accenti)
    if args.schiarisci != 1.0:
        pal[:n_base - 1] = np.clip(pal[:n_base - 1] * args.schiarisci, 0, 255)
    print("contorno del disegno: %.1f px, fattore: %.1f, tavolozza: %d colori" % (spess, f, len(pal)))
    small = [pixela.riduci(w, f, pal, n_base) for w in win]
    # la stessa finestra piccola per tutte: si ritaglia l'unione delle parti piene
    alpha = np.zeros(small[0].shape[:2], dtype=bool)
    for s in small:
        alpha |= s[:, :, 3] > 0
    ys, xs = np.where(alpha)
    crop = [s[ys.min():ys.max() + 1, xs.min():xs.max() + 1] for s in small]
    h, w = crop[0].shape[:2]
    print("misura nel gioco: %dx%d" % (w, h))
    imgs = []
    luce = [np.array([int(c[i:i + 2], 16) for i in (1, 3, 5)]) for c in args.luce.split(",") if c]
    for i, c in enumerate(crop):
        im = Image.fromarray(c, "RGBA")
        im.save(os.path.join(args.cartella, "%s_%d.png" % (args.nome, i + 1)))
        imgs.append(im)
        if luce:
            # le parti che brillano al buio (gli accenti indicati): la maschera di luce del gioco
            m = np.zeros(c.shape[:2], dtype=bool)
            for col in luce:
                m |= (np.abs(c[:, :, :3].astype(int) - col).sum(axis=2) < 40) & (c[:, :, 3] > 0)
            g = np.zeros_like(c)
            g[m] = c[m]
            Image.fromarray(g, "RGBA").save(os.path.join(args.cartella, "%s_%d_luce.png" % (args.nome, i + 1)))
    # il punto d'appoggio, per `CreaturePosesData`: chi cammina = i piedi della posa --misura-da (centro, sotto);
    # chi vola (--ancora occhio) = il centro della posa
    ys, xs = np.where(crop[args.misura_da][:, :, 3] > 0)
    ax = int(round((xs.min() + xs.max() + 1) / 2))
    ay = int(round((ys.min() + ys.max() + 1) / 2)) if args.ancora == "occhio" or args.vola else int(ys.max() + 1)
    print("punto d'appoggio: [%d, %d] (%s)" % (ax, ay, "centro" if args.ancora == "occhio" or args.vola else "piedi"))
    k = 8
    strip = Image.new("RGBA", ((w * k + 16) * len(imgs) + 16, h * k + 32), (24, 22, 32, 255))
    for i, im in enumerate(imgs):
        big = im.resize((w * k, h * k), Image.NEAREST)
        strip.paste(big, (16 + i * (w * k + 16), 16), big)
    # le anteprime del gioco (cartella arte/…) vanno in prove/, che il gioco non importa
    prev = "prove" if args.cartella.replace("\\", "/").startswith("arte") else args.cartella
    os.makedirs(prev, exist_ok=True)
    strip.save(os.path.join(prev, "%s_striscia.png" % args.nome))
    for g in [x for x in args.gruppi.split(",") if x]:
        nome, rng = g.split(":")
        if "-" in rng:
            i0, i1 = (int(v) for v in rng.split("-"))
            idx = list(range(i0, i1 + 1))
        else:
            idx = [int(rng)]
        frames = []
        for i in idx:
            bg = Image.new("RGBA", (w * k + 32, h * k + 32), (24, 22, 32, 255))
            big = imgs[i].resize((w * k, h * k), Image.NEAREST)
            bg.paste(big, (16, 16), big)
            frames.append(bg.convert("P", palette=Image.ADAPTIVE))
        frames[0].save(os.path.join(prev, "%s_%s.gif" % (args.nome, nome)), save_all=True,
                       append_images=frames[1:], duration=args.ms, loop=0, disposal=2)
    print("scritto in %s" % args.cartella)


if __name__ == "__main__":
    main()
