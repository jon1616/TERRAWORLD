# -*- coding: utf-8 -*-
"""Il generatore dei prompt di Nano Banana per le icone (8 ott 2026, stile «A» scelto dall'utente: icone dipinte,
uniformi, belle). Prende le prossime 12 forme d'icona senza il disegno nuovo (in ordine: la più usata prima, da
`arte_ia/icone/forme.json`, fatto da `tools/scheda_icone.gd`), con la loro descrizione scritta a mano
(`arte_ia/icone/aspetti.json`: «en» = il nome in inglese, «desc» = com'è fatta, con [GREY] sulle parti del materiale),
e scrive il prompt (già negli appunti) e il lotto per `tools/installa_icone.py`.

Uso:  python tools/prompt_icone.py                 il prossimo lotto
      python tools/prompt_icone.py --forme zolla,seme --nome rifare_01     un lotto scelto a mano
      python tools/prompt_icone.py --mancano         le forme del prossimo lotto senza descrizione
"""
import argparse
import json
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ICONE = os.path.join(ROOT, "arte_ia", "icone")
PROMPT = os.path.join(ICONE, "prompt")

STYLE = """[STYLE SHEET «Roots and Sap» — INVENTORY ICONS] A cohesive set of {n} game inventory icons for a 2D fantasy game whose world is made of living roots, sap and amber. Beautiful HAND-PAINTED digital illustration style (NOT pixel art, NOT 3D render, NOT photo): bold clean readable shapes, soft painterly shading with 3 tones per colour, a gentle highlight, light always coming from the TOP-LEFT, and one thick dark outline (#14101a) around every object. Organic, slightly whimsical shapes: things look grown, carved or woven from roots, bark, leaves and resin, never industrial. Long objects (weapons, tools, staffs) are drawn DIAGONALLY from bottom-left to top-right, all at the same angle.
Solid flat magenta #FF00FF background everywhere. EXACTLY {rows} rows and 4 columns: {n} equal square cells, ONE object per cell, centred, filling about 80% of the cell, no shadows on the ground, NO text, NO labels, NO names under the objects, no numbers, no grid lines, no frames, no extra objects.
VERY IMPORTANT, the colour rule: the parts made of the item's MATERIAL (metal, stone, fabric, crystal, glass, liquid — marked [GREY] below) must be painted ONLY in NEUTRAL GREYS (from dark grey to almost white, with no tint at all, not brown, not blue), because the game recolours them for each material. All other parts keep their own fixed colours from this palette: dark plum-brown root wood (#4a2c34, #6a4048), warm leather (#7a4a2a), leaf green (#3aa08a), glowing turquoise sap (#5ff0e0), amber (#ffb040)."""


def load(path: str, default):
    if not os.path.exists(path):
        return default
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def todo() -> list[str]:
    forme = load(os.path.join(ICONE, "forme.json"), [])
    skip = set(load(os.path.join(ICONE, "aspetti.json"), {}).get("_salta", []))
    return [r["shape"] for r in forme
            if not os.path.exists(os.path.join(ROOT, "arte", "icone48", r["shape"] + ".png")) and r["shape"] not in skip]


def clipboard(text: str) -> None:
    tmp = os.path.join(PROMPT, "_appunti.txt")
    with open(tmp, "w", encoding="utf-8") as f:
        f.write(text)
    subprocess.run(["powershell", "-NoProfile", "-Command",
                    "Get-Content -Raw -Encoding UTF8 '%s' | Set-Clipboard" % tmp], capture_output=True)


def main() -> None:
    sys.stdout.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser()
    ap.add_argument("--forme", default="")
    ap.add_argument("--nome", default="")
    ap.add_argument("--mancano", action="store_true")
    ap.add_argument("--no-appunti", action="store_true")
    args = ap.parse_args()
    os.makedirs(PROMPT, exist_ok=True)
    asp = load(os.path.join(ICONE, "aspetti.json"), {})
    shapes = [s.strip() for s in args.forme.split(",") if s.strip()] or todo()[:12]
    if not shapes:
        sys.exit("Tutte le forme hanno il disegno nuovo.")
    missing = [s for s in shapes if s not in asp]
    if args.mancano or missing:
        print("forme senza descrizione in arte_ia/icone/aspetti.json: %s" % ", ".join(missing or shapes))
        forme = {r["shape"]: r for r in load(os.path.join(ICONE, "forme.json"), [])}
        for s in (missing or shapes):
            r = forme.get(s, {})
            print("  %s (%s oggetti): %s; es. %s" % (s, r.get("count", "?"), ", ".join(r.get("kinds", [])),
                                                   "; ".join(r.get("examples", [])[:4])))
        if missing:
            sys.exit(1)
        return
    n = len(shapes)
    rows = (n + 3) // 4
    lines = [STYLE.format(n=n, rows=rows)]
    for r in range(rows):
        cells = []
        for i in range(r * 4, min(n, r * 4 + 4)):
            a = asp[shapes[i]]
            cells.append("%d %s — %s" % (i + 1, a["en"].upper(), a["desc"]))
        lines.append("Row %d: %s." % (r + 1, "; ".join(cells)))
    prompt = "\n".join(lines)
    nums = [int(m.group(1)) for f in os.listdir(PROMPT) for m in [re.match(r"^lotto_(\d+)\.json$", f)] if m]
    lotto = args.nome or "lotto_%02d" % (max(nums + [0]) + 1)
    with open(os.path.join(PROMPT, lotto + ".txt"), "w", encoding="utf-8") as f:
        f.write(prompt)
    with open(os.path.join(PROMPT, lotto + ".json"), "w", encoding="utf-8") as f:
        json.dump({"lotto": lotto, "grid": "4x%d" % rows, "shapes": shapes}, f, ensure_ascii=False, indent=1)
    if not args.no_appunti:
        clipboard(prompt)
        with open(os.path.join(PROMPT, "_attesa.txt"), "w", encoding="utf-8") as f:
            f.write(lotto)
    print("%s: %s%s" % (lotto, ", ".join(shapes), "" if args.no_appunti else " (prompt negli appunti)"))
    print("restano %d forme senza il disegno nuovo" % (len(todo()) - (0 if args.forme else len(shapes))))


if __name__ == "__main__":
    main()
