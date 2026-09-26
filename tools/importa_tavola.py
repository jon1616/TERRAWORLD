# -*- coding: utf-8 -*-
"""Importa una tavola di animazione del Germogliato fatta con Nano Banana (26 set 2026) e ne fa i fotogrammi del gioco.

La tavola è una griglia di pose su magenta (per esempio 01_corsa.png: 8 pose, 4 colonne x 2 righe). Nano Banana non
rispetta sempre le regole del prompt: scrive il nome delle pose sotto le figure, disegna le linee della griglia, mette
un'ombra sotto i piedi e non tiene i piedi alla stessa altezza da una riga all'altra. Lo script:
 1. toglie il magenta (come `pixela.py`) e le linee della griglia (righe e colonne quasi tutte piene);
 2. taglia le celle e in ognuna tiene solo la figura: il pezzo più grande e ciò che lo tocca; le scritte e le ombre
    sotto i piedi sono pezzi staccati più in basso della figura e vengono buttati;
 3. allinea i fotogrammi: i piedi di ogni riga sulla stessa linea (la più bassa della riga, cioè il piede che
    appoggia), la testa alla stessa x (il corpo resta fermo e le gambe si muovono attorno); con `--aria` le pose
    indicate (in aria, come nel salto) si allineano invece con la cima della testa all'altezza di un personaggio in
    piedi, e le altre ciascuna con i propri piedi sul suolo;
 3b. la grandezza viene dalla LARGHEZZA DELLA TESTA (la parte alta dei capelli), che non cambia con la posa: una figura
    raccolta o accucciata è più bassa ma non va ingrandita; la testa del riferimento ridotto a 36 pixel dà la misura,
    così il Germogliato è grande uguale in tutte le tavole (per la corsa l'altezza dava 8,5 e la testa 8,7);
 4. ritaglia tutte le celle con la stessa finestra e le riduce con lo stesso fattore e la stessa tavolozza (quella del
    riferimento, `--riferimento`): i pixel piccoli cadono sulla stessa griglia in ogni fotogramma e i colori sono
    identici, così l'animazione non trema;
 5. scrive arte/germogliato/<nome>_<n>.png (misura del gioco) e le anteprime in prove/: la striscia ingrandita e la
    GIF animata.

Uso:  python tools/importa_tavola.py arte_ia/germogliato/01_corsa_v2.png --griglia 4x2 --nome corsa
      python tools/importa_tavola.py arte_ia/germogliato/03_salto.png --griglia 3x2 --nome salto --aria 2,3,4
      --alto N = invece della testa, la posa mediana alta N pixel (come la prima importazione della corsa).
"""
import argparse
import os
import sys

import numpy as np
from PIL import Image
from scipy import ndimage

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pixela  # noqa: E402

QUI = os.path.dirname(os.path.abspath(__file__))
RADICE = os.path.join(QUI, "..")
DST = os.path.join(RADICE, "arte", "germogliato")
PROVE = os.path.join(RADICE, "prove")
RIFERIMENTO = os.path.join(RADICE, "arte_ia", "germogliato", "00_profilo_fermo_v4.png")
TESTA = 0.3          # la parte alta della figura usata per allineare in orizzontale e per misurare la testa
ALTO = 36            # lo sprite in piedi, in pixel del gioco


def larghezza_testa(a: np.ndarray) -> int:
    """La riga più piena nella parte alta della figura: i capelli, larghi uguale in ogni posa."""
    m = a[:, :, 3] > 0.5
    ys = np.where(m.any(axis=1))[0]
    top, bottom = ys.min(), ys.max()
    return int(max(r.sum() for r in m[top:top + max(1, int((bottom - top) * TESTA))]))


def togli_griglia(a: np.ndarray) -> None:
    """Le linee della griglia: colonne e righe piene per quasi tutta la loro lunghezza."""
    m = a[:, :, 3] > 0.5
    a[:, m.mean(axis=0) > 0.8, 3] = 0.0
    a[m.mean(axis=1) > 0.8, :, 3] = 0.0


def figura(cell: np.ndarray) -> np.ndarray:
    """Tiene solo la figura della cella: il pezzo più grande e i pezzi che arrivano più in alto del suo fondo meno un
    decimo (capelli staccati, germoglio); via le scritte e le ombre, che stanno più in basso."""
    m = cell[:, :, 3] > 0.5
    lab, n = ndimage.label(m, structure=np.ones((3, 3)))
    if n == 0:
        return cell
    sizes = ndimage.sum(m, lab, range(1, n + 1))
    main = int(np.argmax(sizes)) + 1
    ys, xs = np.where(lab == main)
    top, bottom = ys.min(), ys.max()
    keep = np.zeros(n + 1, dtype=bool)
    keep[main] = True
    for k in range(1, n + 1):
        if k == main or sizes[k - 1] < 30:
            continue
        ky, kx = np.where(lab == k)
        # un pezzo della figura sta accanto al pezzo grande e comincia sopra i suoi piedi
        if ky.min() < bottom - (bottom - top) * 0.1 and kx.max() > xs.min() - 20 and kx.min() < xs.max() + 20:
            keep[k] = True
    out = cell.copy()
    out[~keep[lab], 3] = 0.0
    # l'ombra attaccata ai piedi: le righe sotto le suole molto più larghe delle suole e quasi nere
    return out


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("file")
    ap.add_argument("--griglia", default="4x2")
    ap.add_argument("--nome", required=True)
    ap.add_argument("--alto", type=int, default=0)
    ap.add_argument("--aria", default="", help="pose in aria (indici da 0, separati da virgole)")
    ap.add_argument("--riferimento", default=RIFERIMENTO)
    ap.add_argument("--fps", type=int, default=12)
    args = ap.parse_args()
    cols, rows = (int(v) for v in args.griglia.lower().split("x"))
    a = pixela.togli_magenta(Image.open(args.file))
    togli_griglia(a)
    H, W = a.shape[:2]
    ch, cw = H // rows, W // cols
    cells, boxes = [], []
    for r in range(rows):
        for c in range(cols):
            cell = figura(a[r * ch:(r + 1) * ch, c * cw:(c + 1) * cw].copy())
            m = cell[:, :, 3] > 0.5
            ys, xs = np.where(m)
            top = ys.min()
            head = m[top:top + int((ys.max() - top) * TESTA)]
            hx = np.where(head.any(axis=0))[0].mean()
            cells.append(cell)
            boxes.append((top, ys.max(), xs.min(), xs.max(), hx, r))
    # piedi: in ogni riga sulla linea più bassa della riga; testa: tutte alla x media
    base = {r: max(b[1] for b in boxes if b[5] == r) for r in range(rows)}
    goal_base = max(base.values())
    goal_hx = float(np.mean([b[4] for b in boxes]))
    aria = {int(v) for v in args.aria.split(",") if v.strip() != ""}
    # con pose in aria: ognuna a terra con i suoi piedi sul suolo; quelle in aria con la testa all'altezza della
    # posa a terra più alta (le gambe si raccolgono sotto il corpo, il corpo non sale nel disegno)
    stand = max((b[1] - b[0] + 1) for i, b in enumerate(boxes) if i not in aria) if aria else 0
    shifted = []
    pad = 40
    for i, (cell, b) in enumerate(zip(cells, boxes)):
        if not aria:
            dy = goal_base - base[b[5]]
        elif i in aria:
            dy = (goal_base - stand + 1) - b[0]
        else:
            dy = goal_base - b[1]
        dx = int(round(goal_hx - b[4]))
        big = np.zeros((ch + 2 * pad, cw + 2 * pad, 4), dtype=np.float32)
        big[pad + dy:pad + dy + ch, pad + dx:pad + dx + cw] = cell
        shifted.append(big)
    # una sola finestra per tutti
    union = np.zeros(shifted[0].shape[:2], dtype=bool)
    for s in shifted:
        union |= s[:, :, 3] > 0.5
    ys, xs = np.where(union)
    win = (ys.min(), ys.max() + 1, xs.min(), xs.max() + 1)
    frames_hi = [s[win[0]:win[1], win[2]:win[3]] for s in shifted]
    ref = pixela.ritaglia(pixela.togli_magenta(Image.open(args.riferimento)))
    pal, n_base = pixela.tavolozza([ref], 20, pixela.ACCENTI)
    if args.alto:
        heights = [b[1] - b[0] + 1 for b in boxes]
        f = float(np.median(heights)) / (args.alto - 2)
    else:
        testa = larghezza_testa(ref) / (ref.shape[0] / (ALTO - 2))    # la testa del riferimento, in pixel del gioco
        f = float(np.median([larghezza_testa(c) for c in cells])) / testa
    os.makedirs(DST, exist_ok=True)
    out = []
    for i, fr in enumerate(frames_hi):
        im = Image.fromarray(pixela.riduci(fr, f, pal, n_base), "RGBA")
        im.save(os.path.join(DST, "%s_%d.png" % (args.nome, i)))
        out.append(im)
    # tavolozza del personaggio (per le tavole che verranno e per il gioco)
    Image.fromarray(pal.astype(np.uint8).reshape(1, -1, 3), "RGB").save(os.path.join(DST, "tavolozza.png"))
    # anteprime: striscia ingrandita e GIF
    k = 8
    w, h = out[0].size
    strip = Image.new("RGBA", (len(out) * (w + 2) * k, h * k), (40, 70, 80, 255))
    for i, im in enumerate(out):
        strip.alpha_composite(im.resize((w * k, h * k), Image.NEAREST), (i * (w + 2) * k, 0))
    os.makedirs(PROVE, exist_ok=True)
    strip.save(os.path.join(PROVE, "germogliato_%s.png" % args.nome))
    gif = []
    for im in out:
        bg = Image.new("RGBA", (w * k, h * k), (40, 70, 80, 255))
        bg.alpha_composite(im.resize((w * k, h * k), Image.NEAREST))
        gif.append(bg.convert("P", palette=Image.ADAPTIVE))
    gif[0].save(os.path.join(PROVE, "germogliato_%s.gif" % args.nome), save_all=True, append_images=gif[1:],
                duration=int(1000 / args.fps), loop=0, disposal=2)
    print("%s: %d fotogrammi %dx%d (fattore %.1f), in arte/germogliato/; anteprime in prove/germogliato_%s.*" % (
        args.nome, len(out), w, h, f, args.nome))


if __name__ == "__main__":
    main()
