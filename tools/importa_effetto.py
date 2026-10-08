# -*- coding: utf-8 -*-
"""Da una tavola di effetti di Nano Banana (8 ott 2026) ai fotogrammi del gioco.

Gli effetti si fanno disegnare BIANCHI e GRIGI su fondo NERO (non sul magenta: la luce sfumata sul magenta si sporca di
rosa): la luminosità diventa la trasparenza, il gioco li colora (rarità, elemento) e li somma alla scena come luce.
Per ogni cella: il nero tolto, la stessa finestra per tutti i fotogrammi (l'effetto non trema), ridotta a `--largo`
pixel. Scrive arte/effetti/<nome>_<n>.png (bianco, alfa = luce) e <nome>.json con la «base» (dove sta il piede della creatura,
in frazione dell'altezza: la riga più luminosa nel quarto basso, l'anello a terra).

Uso:  python tools/importa_effetto.py arte_ia/effetti/<tavola> --griglia 4x2 --nome alone_prova [--largo 96]
"""
import argparse
import json
import os
import sys

import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BLACK = 14          # il nero del JPEG non è mai zero
INSET = 0.02        # le linee grigie che Nano Banana mette tra le celle stanno sul bordo: si lascia un margine


def frames(path: str, cols: int, rows: int) -> list[np.ndarray]:
    lum = np.asarray(Image.open(path).convert("RGB")).astype(np.float32) @ np.array([0.3, 0.59, 0.11])
    h, w = lum.shape
    ch, cw = h / rows, w / cols
    out = []
    for r in range(rows):
        for c in range(cols):
            y0, y1 = int(r * ch + ch * INSET), int((r + 1) * ch - ch * INSET)
            x0, x1 = int(c * cw + cw * INSET), int((c + 1) * cw - cw * INSET)
            out.append(np.clip((lum[y0:y1, x0:x1] - BLACK) / (255 - BLACK), 0, 1))
    n = min(f.shape[0] for f in out), min(f.shape[1] for f in out)
    return [f[:n[0], :n[1]] for f in out]


def main() -> None:
    sys.stdout.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser()
    ap.add_argument("tavola")
    ap.add_argument("--griglia", default="4x2")
    ap.add_argument("--nome", required=True)
    ap.add_argument("--largo", type=int, default=96)
    ap.add_argument("--centro", action="store_true", help="scoppi: la finestra centrata sul centro della cella (il punto del colpo)")
    args = ap.parse_args()
    cols, rows = (int(x) for x in args.griglia.split("x"))
    fs = frames(args.tavola, cols, rows)
    union = np.max(fs, axis=0) > 0.04
    ys, xs = np.where(union)
    y0, y1, x0, x1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
    if args.centro:
        # lo scoppio nasce nel centro della cella: una finestra quadrata attorno al centro, che contiene tutto
        h, w = fs[0].shape
        r = int(max(h / 2 - y0, y1 - h / 2, w / 2 - x0, x1 - w / 2))
        y0, y1 = max(0, h // 2 - r), min(h, h // 2 + r)
        x0, x1 = max(0, w // 2 - r), min(w, w // 2 + r)
    # centrata in orizzontale: la creatura sta nel mezzo
    cx = (x0 + x1) / 2
    half = max(cx - x0, x1 - cx)
    x0, x1 = int(max(0, cx - half)), int(min(fs[0].shape[1], cx + half))
    crop = [f[y0:y1, x0:x1] for f in fs]
    hh = y1 - y0
    low = np.mean(crop, axis=0)[int(hh * 0.7):].sum(axis=1)
    base = (int(hh * 0.7) + int(np.argmax(low))) / hh
    k = args.largo / (x1 - x0)
    size = (args.largo, max(1, round(hh * k)))
    os.makedirs(os.path.join(ROOT, "arte", "effetti"), exist_ok=True)
    for i, f in enumerate(crop, start=1):
        a = np.asarray(Image.fromarray((f * 255).astype(np.uint8), "L").resize(size, Image.LANCZOS))
        rgba = np.dstack([np.full(a.shape, 255, np.uint8)] * 3 + [a])
        Image.fromarray(rgba, "RGBA").save(os.path.join(ROOT, "arte", "effetti", "%s_%d.png" % (args.nome, i)))
    info = {"n": len(crop), "size": list(size), "base": round(base, 3)}
    with open(os.path.join(ROOT, "arte", "effetti", args.nome + ".json"), "w", encoding="utf-8") as f:
        json.dump(info, f)
    print("%s: %s" % (args.nome, json.dumps(info)))


if __name__ == "__main__":
    main()
