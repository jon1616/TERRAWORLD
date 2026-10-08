# -*- coding: utf-8 -*-
"""Il prompt di Nano Banana per una tavola di effetti (8 ott 2026): 8 fotogrammi in ciclo, bianchi e grigi su fondo nero
(il gioco li colora e li somma come luce: `tools/importa_effetto.py`, `Halo`). La descrizione di ogni effetto sta in
`arte_ia/effetti/aspetti.json` («desc»: cosa si vede; «loop»: come si muove nel ciclo). Il prompt va negli appunti e il
nome in `prompt/_attesa.txt` per `tools/installa_effetto.py`.
Uso:  python tools/prompt_effetto.py alone_ancestrale
"""
import json
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DIR = os.path.join(ROOT, "arte_ia", "effetti")
PROMPT = os.path.join(DIR, "prompt")

STYLE = """[EFFECT SPRITE SHEET — «Roots and Sap» 2D side-view fantasy game] A looping animated {what}, 8 frames for a game sprite sheet. Beautiful HAND-PAINTED glowing light effect (NOT pixel art, NOT 3D, NOT photo), seen from the SIDE like the rest of the game.
{desc}
VERY IMPORTANT, the colour rule: the whole effect is painted ONLY in WHITE and NEUTRAL GREYS (pure luminous white core, soft grey glow fading out), with NO colour at all, because the game will tint it. Brightness = intensity of the light.
Solid flat pure BLACK #000000 background everywhere (no gradient, no vignette, no stars). EXACTLY 2 rows and 4 columns: 8 equal square cells, one frame per cell, the effect centred in each cell at the SAME size and position in every frame, filling about 80% of the cell width. The 8 frames form a smooth seamless LOOP: {loop} Frame 8 flows back into frame 1. NO text, NO labels, NO numbers, NO grid lines, NO frames, NO creature, nothing else."""


def main() -> None:
    sys.stdout.reconfigure(encoding="utf-8")
    nome = sys.argv[1]
    with open(os.path.join(DIR, "aspetti.json"), encoding="utf-8") as f:
        a = json.load(f)[nome]
    text = STYLE.format(what=a["what"], desc=a["desc"], loop=a["loop"])
    if a.get("burst"):
        # uno scoppio (i colpi): una sequenza che nasce e svanisce, non un ciclo
        text = text.replace("A looping animated", "An animated").replace(
            "The 8 frames form a smooth seamless LOOP: ", "The 8 frames are ONE short explosion from start to end, in reading order: "
        ).replace(" Frame 8 flows back into frame 1.", "")
    os.makedirs(PROMPT, exist_ok=True)
    with open(os.path.join(PROMPT, nome + ".txt"), "w", encoding="utf-8") as f:
        f.write(text)
    tmp = os.path.join(PROMPT, "_appunti.txt")
    with open(tmp, "w", encoding="utf-8") as f:
        f.write(text)
    subprocess.run(["powershell", "-NoProfile", "-Command",
                    "Get-Content -Raw -Encoding UTF8 '%s' | Set-Clipboard" % tmp], capture_output=True)
    with open(os.path.join(PROMPT, "_attesa.txt"), "w", encoding="utf-8") as f:
        f.write(nome)
    print("%s: prompt negli appunti" % nome)


if __name__ == "__main__":
    main()
