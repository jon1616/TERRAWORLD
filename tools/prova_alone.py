# -*- coding: utf-8 -*-
"""Il confronto dell'alone delle rare (8 ott 2026): per alcune creature vere, l'alone di oggi (il contorno acceso di
`Ancient.ring`) accanto a quello nuovo di Nano Banana (`arte/effetti/<nome>_<n>.png`) nei colori delle rarità di
`AncientData.RARITIES`, sommato alla scena come luce, a pixel del mondo e ingrandito ×3 come in gioco. Più una gif.
Uso:  python tools/prova_alone.py [--nome alone_prova] [--largo 1.8]
"""
import argparse
import os

import numpy as np
from PIL import Image
from scipy import ndimage

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
Z = 3
BG = np.array([22, 18, 30], np.float32)
RARE = {"antica": (1.6, 1.1, 0.4), "ancestrale": (1.3, 0.6, 2.0), "capobranco": (0.45, 1.15, 0.5), "iridata": (1.7, 1.7, 1.7)}
CREATURES = ["lupo_lunare_1", "cervo_brina_1", "grumo_1", "capo_cinghiale_1"]


def creature(n: str) -> np.ndarray:
    return np.asarray(Image.open(os.path.join(ROOT, "arte", "creature", n + ".png")).convert("RGBA")).astype(np.float32)


def ring(c: np.ndarray) -> np.ndarray:
    on = c[:, :, 3] > 128
    return (ndimage.binary_dilation(on) & ~on).astype(np.float32)


def scene(c: np.ndarray, aura: np.ndarray | None, col, old: bool, base: float, k: float) -> np.ndarray:
    """La creatura (pixel ×Z) con l'alone dietro, su una scena scura; l'alone sommato come luce."""
    ch, cw = c.shape[:2]
    W, H = int(cw * 2.6) + 8, int(ch * 2.6) + 8
    img = np.tile(BG, (H, W, 1))
    fx, fy = (W - cw) // 2, H - 6 - ch           # angolo della creatura; i piedi a H-6
    col = np.array(col, np.float32)
    if old:
        r = ring(c)
        img[fy:fy + ch, fx:fx + cw] += r[:, :, None] * col * 120
    elif aura is not None:
        aw = max(4, round(cw * k))
        ah = round(aura.shape[0] * aw / aura.shape[1])
        a = np.asarray(Image.fromarray((aura * 255).astype(np.uint8), "L").resize((aw, ah), Image.LANCZOS)) / 255.0
        ax, ay = (W - aw) // 2, H - 6 - round(ah * base)
        y0, x0 = max(0, ay), max(0, ax)
        sub = a[y0 - ay:y0 - ay + H - y0, x0 - ax:x0 - ax + W - x0]
        img[y0:y0 + sub.shape[0], x0:x0 + sub.shape[1]] += sub[:, :, None] * col * 150
    al = c[:, :, 3:4] / 255
    img[fy:fy + ch, fx:fx + cw] = img[fy:fy + ch, fx:fx + cw] * (1 - al) + c[:, :, :3] * al
    out = Image.fromarray(img.clip(0, 255).astype(np.uint8), "RGB")
    return np.asarray(out.resize((W * Z, H * Z), Image.NEAREST))


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--nome", default="alone_prova")
    ap.add_argument("--largo", type=float, default=1.8)
    ap.add_argument("--base", type=float, default=0.811)
    args = ap.parse_args()
    fr = []
    i = 1
    while os.path.exists(os.path.join(ROOT, "arte", "effetti", "%s_%d.png" % (args.nome, i))):
        fr.append(np.asarray(Image.open(os.path.join(ROOT, "arte", "effetti", "%s_%d.png" % (args.nome, i))))[:, :, 3] / 255.0)
        i += 1
    rows = []
    for n in CREATURES:
        c = creature(n)
        cells = [scene(c, None, RARE["antica"], True, args.base, args.largo)]
        cells += [scene(c, fr[j], RARE["antica"], False, args.base, args.largo) for j in (1, 3, 5)]
        cells += [scene(c, fr[3], RARE[r], False, args.base, args.largo) for r in ("ancestrale", "capobranco", "iridata")]
        h = max(x.shape[0] for x in cells)
        cells = [np.pad(x, ((h - x.shape[0], 0), (0, 6), (0, 0)), constant_values=10) for x in cells]
        rows.append(np.concatenate(cells, axis=1))
    w = max(r.shape[1] for r in rows)
    rows = [np.pad(r, ((0, 6), (0, w - r.shape[1]), (0, 0)), constant_values=10) for r in rows]
    os.makedirs(os.path.join(ROOT, "prove", "effetti"), exist_ok=True)
    Image.fromarray(np.concatenate(rows, axis=0)).save(os.path.join(ROOT, "prove", "effetti", "confronto_alone.png"))
    for n, rar in (("lupo_lunare_1", "antica"), ("cervo_brina_1", "ancestrale")):
        c = creature(n)
        gif = [Image.fromarray(scene(c, f, RARE[rar], False, args.base, args.largo)) for f in fr]
        gif[0].save(os.path.join(ROOT, "prove", "effetti", "alone_%s.gif" % rar), save_all=True, append_images=gif[1:],
                    duration=110, loop=0)
    print("prove/effetti/confronto_alone.png, alone_antica.gif, alone_ancestrale.gif")


if __name__ == "__main__":
    main()
