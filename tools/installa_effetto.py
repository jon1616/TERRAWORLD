# -*- coding: utf-8 -*-
"""Mette nel gioco una tavola di effetti con un comando solo (8 ott 2026): prende l'immagine appena salvata in
arte_ia/effetti (la più recente senza il numero davanti), le dà il nome (NN_<effetto>_vN), la importa
(`tools/importa_effetto.py`) e, per gli aloni, fa la prova nel gioco su quattro creature di forme diverse
(`tools/sprite.sh <creature> <grado>` → prove/sprite/<id>_<grado>.png).
Uso:  python tools/installa_effetto.py [effetto] [immagine]       (l'effetto in attesa è in prompt/_attesa.txt)
"""
import glob
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DIR = os.path.join(ROOT, "arte_ia", "effetti")
NAMED = re.compile(r"^\d\d_")
SHAPES = "lupo_lunare,cervo_brina,grumo_muschio,capo_cinghiale"     # basso e largo, alto, piccolo, grosso


def main() -> None:
    sys.stdout.reconfigure(encoding="utf-8")
    nome = sys.argv[1] if len(sys.argv) > 1 else open(os.path.join(DIR, "prompt", "_attesa.txt"), encoding="utf-8").read().strip()
    src = sys.argv[2] if len(sys.argv) > 2 else None
    if src is None:
        files = [f for f in glob.glob(os.path.join(DIR, "*")) if f.lower().endswith((".png", ".jpg", ".jpeg", ".webp"))
                 and not NAMED.match(os.path.basename(f))]
        if not files:
            sys.exit("ATTENZIONE: in arte_ia/effetti non c'è un'immagine nuova")
        src = max(files, key=os.path.getmtime)
    if not NAMED.match(os.path.basename(src)):
        nums = [int(f[:2]) for f in os.listdir(DIR) if NAMED.match(f)]
        same = [f for f in os.listdir(DIR) if re.match(r"^\d\d_%s_v\d+\." % re.escape(nome), f)]
        v = 1 + max([int(re.search(r"_v(\d+)\.", f).group(1)) for f in same] + [0])
        nn = same[0][:2] if same else "%02d" % (max(nums + [0]) + 1)
        dst = os.path.join(DIR, "%s_%s_v%d%s" % (nn, nome, v, os.path.splitext(src)[1].lower()))
        os.replace(src, dst)
        src = dst
    print("tavola: %s" % os.path.relpath(src, ROOT))
    subprocess.run([sys.executable, os.path.join(ROOT, "tools", "importa_effetto.py"), src, "--nome", nome], check=True)
    if nome.startswith("alone_"):
        res = subprocess.run(["sh", "tools/sprite.sh", SHAPES, nome[len("alone_"):]], cwd=ROOT, capture_output=True,
                             text=True, encoding="utf-8", errors="replace", timeout=400)
        print("\n".join(l for l in res.stdout.splitlines() if "alone" in l or "ERROR" in l or "ATTENZIONE" in l))


if __name__ == "__main__":
    main()
