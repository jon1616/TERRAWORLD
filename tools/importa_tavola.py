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
 2b. i colori della tavola si correggono perché la pelle abbia il colore del riferimento (luce diversa per tavola);
 3b. la grandezza viene dalla TESTA (l'altezza del ciuffo verde dei capelli), che non cambia con la posa: una figura
    raccolta o accucciata è più bassa ma non va ingrandita; la testa del riferimento ridotto a 36 pixel dà la misura,
    così il Germogliato è grande uguale in tutte le tavole;
 4. ritaglia tutte le celle con la stessa finestra e le riduce con lo stesso fattore e la stessa tavolozza (quella del
    riferimento, `--riferimento`): i pixel piccoli cadono sulla stessa griglia in ogni fotogramma e i colori sono
    identici, così l'animazione non trema;
 5. scrive arte/germogliato/<nome>_<n>.png (misura del gioco) e le anteprime in prove/: la striscia ingrandita e la
    GIF animata.

Pose con il pugno che tiene un attrezzo (il colpo): `--mano` dà la direzione del pugno di ogni posa sull'orologio
(gradi dall'alto in senso orario, il Germogliato guarda a destra); dalla spalla si cerca il pixel di pelle più lontano
in quella direzione (in cima al braccio teso c'è il pugno) e si scrive arte/germogliato/<nome>.json con la mano e
l'angolo del braccio di ogni posa, per l'attrezzo che il gioco disegna nel pugno. `--togli-grigi` toglie ciò che è
grigio chiaro (Nano Banana disegna attrezzi e scie anche se vietati) e le linee sottili staccate dal corpo;
`--piedi` allinea in orizzontale sui piedi (fermi nel colpo) invece che sulla testa (il pugno alzato la sposterebbe).

Uso:  python tools/importa_tavola.py arte_ia/germogliato/01_corsa_v2.png --griglia 4x2 --nome corsa
      python tools/importa_tavola.py arte_ia/germogliato/04_colpo.png --griglia 3x2 --nome colpo --piedi \
          --togli-grigi --mano=-30,0,45,90,135,165
      python tools/importa_tavola.py arte_ia/germogliato/03_salto.png --griglia 3x2 --nome salto --aria 2,3,4
      --alto N = invece della testa, la posa mediana alta N pixel (come la prima importazione della corsa).
"""
import argparse
import json
import math
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


def capelli(a: np.ndarray) -> np.ndarray:
    """I pixel verdi dei capelli (il verde supera il rosso; il germoglio giallo-verde no)."""
    r, g, b = a[:, :, 0], a[:, :, 1], a[:, :, 2]
    return (a[:, :, 3] > 0.5) & (g > r + 20) & (g >= b)


def larghezza_testa(a: np.ndarray) -> int:
    """La misura della testa: l'altezza del ciuffo verde dei capelli, dalla cima al fondo. È la misura più stabile tra
    le pose (la larghezza cambia con i capelli al vento nel salto, la parte alta della figura con un pugno alzato):
    corsa ~158, salto ~167, colpo ~155 pixel del disegno."""
    rows = np.where(capelli(a).any(axis=1))[0]
    return int(rows.max() - rows.min() + 1) if len(rows) else 0


def pelle(a: np.ndarray) -> np.ndarray:
    """I pixel della pelle: caldi ma meno saturi dell'ocra della tunica."""
    r, g, b = a[:, :, 0], a[:, :, 1], a[:, :, 2]
    # r - g > 20: il germoglio giallo-verde ha rosso e verde quasi uguali, la pelle no
    return (a[:, :, 3] > 0.5) & (r > 150) & (r - g > 20) & (g >= b) & (r - b > 55) & (r - b < 125) & (g - b > 25)


def tunica(a: np.ndarray) -> np.ndarray:
    r, g, b = a[:, :, 0], a[:, :, 1], a[:, :, 2]
    return (a[:, :, 3] > 0.5) & (r > 150) & (r > g) & (g > b) & (r - b >= 125)


def trova_pugno(a: np.ndarray, gradi: float) -> tuple[float, float, float]:
    """Il pugno nella direzione `gradi` (dall'alto, in senso orario) dalla spalla: (x, y, angolo misurato)."""
    # la spalla dalla geometria: al 40% tra la cima dei capelli e i piedi, al centro del busto a quell'altezza
    # (l'ocra della tunica cambia da una tavola all'altra e non basta a trovarla)
    hy = np.where(capelli(a).any(axis=1))[0]
    ty = np.where((a[:, :, 3] > 0.5).any(axis=1))[0]
    top = hy.min() if len(hy) else ty.min()
    sy0 = top + (ty.max() - top) * 0.40
    band = a[int(sy0) - 3:int(sy0) + 4, :, 3] > 0.5
    bx = np.where(band.any(axis=0))[0]
    # il busto: la mediana dei pixel pieni della fascia (il braccio teso è una striscia sottile e sposta poco)
    sh = np.array([float(np.median(bx)), float(sy0)])
    sy, sx = np.where(pelle(a))
    v = np.stack([sx - sh[0], sy - sh[1]], axis=1).astype(np.float32)
    th = math.radians(gradi)
    d = np.array([math.sin(th), -math.cos(th)], dtype=np.float32)
    proj = v @ d
    perp = np.abs(v[:, 0] * d[1] - v[:, 1] * d[0])
    ok = (proj > 0) & (perp < proj * 0.7)                    # entro ~35 gradi dalla direzione attesa
    if not ok.any():
        return float(sh[0]), float(sh[1]), gradi
    best = proj[ok].max()
    fist = ok & (proj > best - (ty.max() - top) * 0.12)
    hx, hy = float(sx[fist].mean()), float(sy[fist].mean())
    misurato = math.degrees(math.atan2(hx - sh[0], -(hy - sh[1])))
    return hx, hy, misurato


def togli_grigi(a: np.ndarray) -> None:
    """Via gli attrezzi e le scie che Nano Banana disegna anche se vietati: il grigio chiaro (il Germogliato non ne ha)
    e le linee sottili rimaste staccate dal corpo (il contorno della lama, le scie)."""
    rgb = a[:, :, :3]
    sat = rgb.max(axis=2) - rgb.min(axis=2)
    lum = rgb @ np.array([0.3, 0.59, 0.11])
    a[(sat < 40) & (lum > 90), 3] = 0.0
    m = a[:, :, 3] > 0.5
    spesso = ndimage.binary_dilation(ndimage.binary_opening(m, iterations=3), iterations=4)
    a[m & ~spesso, 3] = 0.0


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
    ap.add_argument("--testa-da", default="", help="pose su cui misurare la testa (indici; di solito una posa a terra "
                    "composta: in aria i capelli si alzano e si abbassano)")
    ap.add_argument("--piedi", action="store_true", help="allinea in orizzontale sui piedi invece che sulla testa")
    ap.add_argument("--togli-grigi", action="store_true")
    ap.add_argument("--mano", default="", help="direzione del pugno di ogni posa, gradi dall'alto in senso orario")
    args = ap.parse_args()
    cols, rows = (int(v) for v in args.griglia.lower().split("x"))
    a = pixela.togli_magenta(Image.open(args.file))
    ref = pixela.ritaglia(pixela.togli_magenta(Image.open(args.riferimento)))
    # ogni tavola di Nano Banana ha una luce un po' diversa (la pelle del colpo era #C79D66, quella del riferimento
    # #E1AB73): i colori di tutta la tavola si correggono perché la pelle abbia il colore del riferimento
    gain = np.clip(np.median(ref[:, :, :3][pelle(ref)], axis=0) / np.median(a[:, :, :3][pelle(a)], axis=0), 0.8, 1.25)
    a[:, :, :3] = np.clip(a[:, :, :3] * gain, 0, 255)
    togli_griglia(a)
    if args.togli_grigi:
        togli_grigi(a)
    H, W = a.shape[:2]
    ch, cw = H // rows, W // cols
    cells, boxes = [], []
    for r in range(rows):
        for c in range(cols):
            cell = figura(a[r * ch:(r + 1) * ch, c * cw:(c + 1) * cw].copy())
            m = cell[:, :, 3] > 0.5
            ys, xs = np.where(m)
            top = ys.min()
            if args.piedi:
                feet = m[ys.max() - int((ys.max() - top) * 0.12):ys.max() + 1]
                hx = np.where(feet.any(axis=0))[0].mean()
            else:
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
    ground = [(b[1] - b[0] + 1) for i, b in enumerate(boxes) if i not in aria]
    # tutte in aria (parete, planata, rampino): la misura è la mediana delle pose
    stand = (max(ground) if ground else int(np.median([b[1] - b[0] + 1 for b in boxes]))) if aria else 0
    moves = []
    for i, b in enumerate(boxes):
        if not aria:
            dy = goal_base - base[b[5]]
        elif i in aria:
            dy = (goal_base - stand + 1) - b[0]
        else:
            dy = goal_base - b[1]
        moves.append((int(dy), int(round(goal_hx - b[4]))))
    # il margine attorno alle celle: quanto serve agli spostamenti più grandi
    pad = max(max(abs(dy), abs(dx)) for dy, dx in moves) + 10
    shifted = []
    for cell, (dy, dx) in zip(cells, moves):
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
    pal, n_base = pixela.tavolozza([ref], 20, pixela.ACCENTI)
    if args.alto:
        heights = [b[1] - b[0] + 1 for b in boxes]
        f = float(np.median(heights)) / (args.alto - 2)
    else:
        testa = larghezza_testa(ref) / (ref.shape[0] / (ALTO - 2))    # la testa del riferimento, in pixel del gioco
        scelte = [int(v) for v in args.testa_da.split(",") if v.strip() != ""] or list(range(len(cells)))
        f = float(np.median([larghezza_testa(cells[i]) for i in scelte])) / testa
    os.makedirs(DST, exist_ok=True)
    # il pugno di ogni posa, in pixel dello sprite del gioco (+1: il contorno aggiunto dalla riduzione)
    mani = [float(v) for v in args.mano.split(",") if v.strip() != ""]
    if mani:
        info = []
        for fr, gradi in zip(frames_hi, mani):
            hx, hy, mis = trova_pugno(fr, gradi)
            info.append({"mano": [round(hx / f + 1, 1), round(hy / f + 1, 1)], "gradi": round(mis, 1)})
        with open(os.path.join(DST, "%s.json" % args.nome), "w", encoding="utf-8") as fh:
            json.dump(info, fh, indent=1)
        print("pugno: " + ", ".join("(%.0f, %.0f) %.0f°" % (i["mano"][0], i["mano"][1], i["gradi"]) for i in info))
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
