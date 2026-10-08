# -*- coding: utf-8 -*-
"""Mette nel gioco una tavola di icone di Nano Banana con un comando solo (8 ott 2026, stile «A»: icone dipinte).

Prende l'immagine appena salvata in arte_ia/icone (la più recente senza il numero davanti), le dà il nome giusto,
la taglia nelle sue celle (via il magenta, le scritte che Nano Banana aggiunge sempre) e per ogni forma scrive:
  arte/icone48/<forma>.png  l'icona DIPINTA a 48 pixel per l'interfaccia (i grigi quasi neutri resi neutri: il gioco
                            li colora con il materiale, `IconTemplates.make_ui`);
  arte/forme/<forma>.png    la stessa ridotta a pixel art da 16 per il mondo (attrezzo in mano, oggetti a terra).
Poi il foglio di controllo prove/icone/<lotto>.png (`tools/scheda_icone.gd --foglio`).

Uso:  python tools/installa_icone.py                       il lotto in attesa (l'ultimo del generatore), l'ultima immagine
      python tools/installa_icone.py lotto_01 [immagine]   (le forme del lotto sono in arte_ia/icone/prompt/<lotto>.json)
      python tools/installa_icone.py lotto_01 immagine --salta zolla    forme venute male da non installare
"""
import argparse
import glob
import json
import os
import re
import subprocess
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(__file__))
import pixela  # noqa: E402
import prova_icone  # noqa: E402
import tavola  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ICONE = os.path.join(ROOT, "arte_ia", "icone")
PROMPT = os.path.join(ICONE, "prompt")
GODOT = r"C:\Users\Principale\Desktop\GODOT\Godot_v4.6.1-stable_win64_console.exe"
NAMED = re.compile(r"^\d\d_")


def newest_image() -> str:
    files = [f for f in glob.glob(os.path.join(ICONE, "*")) if f.lower().endswith((".png", ".jpg", ".jpeg", ".webp"))
             and not NAMED.match(os.path.basename(f))]
    if not files:
        sys.exit("ATTENZIONE: in arte_ia/icone non c'è un'immagine nuova (senza il numero davanti)")
    return max(files, key=os.path.getmtime)


def final_name(lotto: str, ext: str) -> str:
    nums = [int(m.group(1)) for f in os.listdir(ICONE) for m in [re.match(r"^(\d\d)_", f)] if m]
    same = [f for f in os.listdir(ICONE) if re.match(r"^\d\d_%s_v(\d+)\." % re.escape(lotto), f)]
    if same:
        nn = same[0][:2]
        v = max(int(re.search(r"_v(\d+)\.", f).group(1)) for f in same) + 1
        return "%s_%s_v%d%s" % (nn, lotto, v, ext)
    return "%02d_%s_v1%s" % (max(nums + [0]) + 1, lotto, ext)


def neutral_greys(img: Image.Image) -> Image.Image:
    """I grigi quasi neutri (Nano Banana e il JPEG li sporcano di un filo di colore) diventano grigi veri: il gioco
    riconosce la parte del materiale dai grigi neutri (`IconTemplates._is_grey`, scarto al più 0,07)."""
    a = np.asarray(img.convert("RGBA")).astype(np.float32)
    rgb = a[:, :, :3]
    sat = rgb.max(axis=2) - rgb.min(axis=2)
    lum = rgb @ np.array([0.3, 0.59, 0.11])
    m = (a[:, :, 3] > 0) & (sat <= 30) & (lum > 45)
    a[m, 0] = a[m, 1] = a[m, 2] = lum[m]
    return Image.fromarray(a.clip(0, 255).astype(np.uint8), "RGBA")


def grey_part(img: Image.Image) -> float:
    """Quanta parte della figura prende il colore del materiale (i grigi neutri, come `IconTemplates._is_grey`)."""
    a = np.asarray(img.convert("RGBA")).astype(np.float32)
    on = a[:, :, 3] > 128
    rgb = a[:, :, :3]
    grey = on & (rgb.max(axis=2) - rgb.min(axis=2) <= 18) & (rgb @ np.array([0.3, 0.59, 0.11]) > 41)
    return grey.sum() / max(1, on.sum())


def soft_small(big: Image.Image) -> Image.Image:
    """La versione da 16 pixel ridotta dall'icona dipinta con una media (alfa premoltiplicato), per gli oggetti sottili
    (ghirlanda, chiave, rampino: lotto 7): la pixelatura li faceva quasi tutti di contorno nero."""
    a = np.asarray(big.convert("RGBA")).astype(np.float32)
    pm = a.copy()
    pm[..., :3] *= a[..., 3:4] / 255
    sm = np.asarray(Image.fromarray(pm.clip(0, 255).astype(np.uint8)).resize((16, 16), Image.BOX)).astype(np.float32)
    al = sm[..., 3:4]
    rgb = np.where(al > 0, sm[..., :3] * 255 / np.maximum(al, 1), 0)
    out = np.concatenate([rgb, np.where(al > 70, 255, 0)], axis=2)
    return neutral_greys(Image.fromarray(out.clip(0, 255).astype(np.uint8), "RGBA"))


def main() -> None:
    sys.stdout.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser()
    ap.add_argument("lotto", nargs="?")
    ap.add_argument("immagine", nargs="?")
    ap.add_argument("--salta", default="", help="forme da non installare (venute male), separate da virgole")
    args = ap.parse_args()
    lotto = args.lotto
    if not lotto:
        with open(os.path.join(PROMPT, "_attesa.txt"), encoding="utf-8") as f:
            lotto = f.read().strip()
    with open(os.path.join(PROMPT, lotto + ".json"), encoding="utf-8") as f:
        r = json.load(f)
    names = r["shapes"]
    cols, rows = (int(x) for x in r["grid"].split("x"))
    src = args.immagine or newest_image()
    if not NAMED.match(os.path.basename(src)):
        dst = os.path.join(ICONE, final_name(lotto, os.path.splitext(src)[1].lower()))
        os.replace(src, dst)
        src = dst
    print("tavola: %s" % os.path.relpath(src, ROOT))
    figs = prova_icone.figures(src, cols, rows)
    if len(figs) != len(names):
        print("ATTENZIONE: %d icone trovate invece di %d: controlla la tavola (forse va rigenerata)" % (len(figs), len(names)))
    skip = {x.strip() for x in args.salta.split(",") if x.strip()}
    pal, n_base = pixela.tavolozza(figs, 16, [])
    os.makedirs(os.path.join(ROOT, "arte", "icone48"), exist_ok=True)
    done = []
    for name, f in zip(names, figs):
        if name in skip:
            continue
        big = neutral_greys(prova_icone.painted(f, 48))
        big.save(os.path.join(ROOT, "arte", "icone48", name + ".png"))
        small = neutral_greys(Image.fromarray(tavola.riduci_a(pixela.ritaglia(f), 16, pal, n_base), "RGBA"))
        if grey_part(small) < 0.5 * grey_part(big):
            small = soft_small(big)      # oggetto sottile: il contorno scuro della pixelatura copriva tutto
            print("  %s: versione del mondo dalla riduzione morbida (oggetto sottile)" % name)
        small.save(os.path.join(ROOT, "arte", "forme", name + ".png"))
        done.append(name)
    print("installate: %s" % ", ".join(done))
    subprocess.run([GODOT, "--headless", "--path", ROOT, "--import"], capture_output=True, timeout=300)
    res = subprocess.run([GODOT, "--headless", "--path", ROOT, "--script", "res://tools/scheda_icone.gd", "--",
                          "--foglio", ",".join(done), lotto], capture_output=True, text=True, encoding="utf-8",
                         errors="replace", timeout=300)
    print("\n".join(l for l in res.stdout.splitlines() if "foglio" in l or "ERROR" in l))


if __name__ == "__main__":
    main()
