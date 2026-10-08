# -*- coding: utf-8 -*-
"""Mette nel gioco la tavola di Nano Banana di una creatura con un comando solo (8 ott 2026).

Prende l'immagine appena salvata in arte_ia/creature (quella più recente senza il numero davanti: l'utente la salva con
il nome che propone Nano Banana), le dà il nome giusto (NN_<id>_vN.png), la riduce con `tools/importa_creatura.py`
secondo la ricetta scritta da `tools/prompt_creatura.py`, trova il punto d'appoggio, scrive la riga in
`CreaturePosesData` e lancia la prova veloce (`tools/sprite.sh`): il foglio delle pose è in prove/sprite/<id>.png.

Uso:  python tools/installa_creatura.py                 la creatura in attesa (l'ultima del generatore) e l'ultima immagine
      python tools/installa_creatura.py spinoriccio [immagine.png]
      python tools/installa_creatura.py spinoriccio --senza-prova
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

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CREATURE = os.path.join(ROOT, "arte_ia", "creature")
PROMPT = os.path.join(CREATURE, "prompt")
ARTE = os.path.join(ROOT, "arte", "creature")
POSES_DATA = os.path.join(ROOT, "src", "data", "creature_poses_data.gd")
NAMED = re.compile(r"^\d\d_")


def newest_image() -> str:
    files = [f for f in glob.glob(os.path.join(CREATURE, "*")) if f.lower().endswith((".png", ".jpg", ".jpeg", ".webp"))
             and not NAMED.match(os.path.basename(f))]
    if not files:
        sys.exit("ATTENZIONE: in arte_ia/creature non c'è un'immagine nuova (senza il numero davanti)")
    return max(files, key=os.path.getmtime)


def final_name(cid: str, ext: str) -> str:
    """NN_<id>_vN: il numero della creatura se ha già una tavola, altrimenti il prossimo; la versione dopo l'ultima."""
    nums = {}
    for f in os.listdir(CREATURE):
        m = re.match(r"^(\d\d)_(.+)_v(\d+)\.", f)
        if m:
            nums.setdefault(m.group(2), []).append((int(m.group(1)), int(m.group(3))))
    if cid in nums:
        nn = nums[cid][0][0]
        v = max(x[1] for x in nums[cid]) + 1
    else:
        nn = max([x[0] for v in nums.values() for x in v] + [0]) + 1
        v = 1
    return "%02d_%s_v%d%s" % (nn, cid, v, ext.lower() if ext.lower() == ".png" else ".png")


def bbox(path: str) -> tuple[int, int, int, int]:
    a = np.asarray(Image.open(path).convert("RGBA"))[:, :, 3] > 0
    ys, xs = np.where(a)
    return int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1


def anchor(r: dict) -> tuple[list[int], int]:
    """Il punto d'appoggio nel fotogramma: i piedi della posa ferma, il centro di chi vola, il centro della palla di
    chi rotola (con quanto va sollevato perché la palla tocchi terra)."""
    key = r["key"]
    if r.get("roll_center") and "scatto" in r["poses"]:
        x0, y0, x1, y1 = bbox(os.path.join(ARTE, "%s_%d.png" % (key, r["poses"]["scatto"][0] + 1)))
        return [round((x0 + x1) / 2), round((y0 + y1) / 2)], round((y1 - y0) / 2)
    x0, y0, x1, y1 = bbox(os.path.join(ARTE, "%s_%d.png" % (key, r["misura_da"] + 1)))
    if r.get("fly"):
        return [round((x0 + x1) / 2), round((y0 + y1) / 2)], 0
    return [round((x0 + x1) / 2), y1], 0


def gd_value(v) -> str:
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, float):
        return ("%.1f" % v) if v == round(v, 1) else repr(v)
    if isinstance(v, dict):
        return "{" + ", ".join('"%s": %s' % (k, gd_value(x)) for k, x in v.items()) + "}"
    if isinstance(v, list):
        return "[" + ", ".join(gd_value(x) for x in v) + "]"
    return json.dumps(v, ensure_ascii=False)


def write_entry(r: dict, anc: list[int], lift: int) -> None:
    head = {"n": r["n"], "anchor": anc}
    if r.get("center"):
        head["center"] = True
    if lift:
        head["lift"] = lift
    if r.get("luce"):
        head["glow"] = True
    entry = '\t# %s (tavola di Nano Banana, tools/installa_creatura.py)\n\t"%s": {%s,\n\t\t"poses": %s,\n\t\t"fps": %s},\n' % (
        r["name"], r["key"], ", ".join('"%s": %s' % (k, gd_value(v)) for k, v in head.items()),
        gd_value(r["poses"]), gd_value(r["fps"]))
    with open(POSES_DATA, encoding="utf-8") as f:
        s = f.read()
    # una riga che c'era già si sostituisce (con il commento sopra, se l'aveva scritto questo strumento)
    pat = re.compile(r'(\t# [^\n]*\n)?\t"%s": \{"n".*?\n(?=\t"|\t#|\}\n)' % re.escape(r["key"]), re.S)
    if pat.search(s):
        s = pat.sub(lambda m: entry, s, count=1)
    else:
        end = s.index("\n}\n", s.index("const POSES"))
        s = s[:end + 1] + entry + s[end + 1:]
    with open(POSES_DATA, "w", encoding="utf-8", newline="\n") as f:
        f.write(s)


def main() -> None:
    sys.stdout.reconfigure(encoding="utf-8")       # le virgolette «» e le frecce nella console di Windows
    ap = argparse.ArgumentParser()
    ap.add_argument("id", nargs="?")
    ap.add_argument("immagine", nargs="?")
    ap.add_argument("--senza-prova", action="store_true")
    ap.add_argument("--specchia", action="store_true", help="Nano Banana l'ha girata a sinistra: si rigira")
    args = ap.parse_args()
    cid = args.id
    if not cid:
        with open(os.path.join(PROMPT, "_attesa.txt"), encoding="utf-8") as f:
            cid = f.read().strip()
    with open(os.path.join(PROMPT, cid + ".json"), encoding="utf-8") as f:
        r = json.load(f)
    src = args.immagine or newest_image()
    if not NAMED.match(os.path.basename(src)):
        dst = os.path.join(CREATURE, final_name(cid, os.path.splitext(src)[1]))
        if src.lower().endswith(".png"):
            os.replace(src, dst)
        else:
            Image.open(src).convert("RGB").save(dst)
            os.remove(src)
        src = dst
    print("tavola: %s" % os.path.relpath(src, ROOT))
    cols, rows = (int(x) for x in r["grid"].split("x"))
    cmd = [sys.executable, os.path.join(ROOT, "tools", "importa_creatura.py"), src, "--griglia", "%dx%d" % (cols, rows),
           "--solo", str(r["n"]), "--ancora", "cella", "--togli-linee", "--nome", r["key"], "--lungo", str(r["lungo"]),
           "--misura-da", str(r["misura_da"]), "--cartella", os.path.join("arte", "creature")]
    if r.get("fly"):
        cmd.append("--vola")
    if args.specchia:
        cmd.append("--specchia")
    if r.get("togli_polvere"):
        cmd.append("--togli-polvere")
    if r.get("accenti"):
        cmd += ["--accenti", ",".join(r["accenti"])]
    if r.get("luce"):
        cmd += ["--luce", ",".join(r["luce"])]
    if float(r.get("schiarisci", 1.0)) != 1.0:
        cmd += ["--schiarisci", str(r["schiarisci"])]
    out = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True, encoding="utf-8", errors="replace")
    print(out.stdout.strip())
    if out.returncode != 0:
        print(out.stderr[-2000:])
        sys.exit("ATTENZIONE: la riduzione non è riuscita")
    found = re.search(r"pose trovate: (\d+)", out.stdout)
    if found and int(found.group(1)) < r["n"]:
        print("ATTENZIONE: Nano Banana ha disegnato %s pose invece di %d: meglio rigenerare" % (found.group(1), r["n"]))
    anc, lift = anchor(r)
    write_entry(r, anc, lift)
    print("CreaturePosesData: «%s», punto d'appoggio %s%s" % (r["key"], anc, ", sollevata di %d" % lift if lift else ""))
    if not args.senza_prova:
        res = subprocess.run(["sh", "tools/sprite.sh", cid], cwd=ROOT, capture_output=True, text=True,
                             encoding="utf-8", errors="replace")
        print(res.stdout.strip())


if __name__ == "__main__":
    main()
