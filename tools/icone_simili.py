# -*- coding: utf-8 -*-
"""Le icone degli oggetti identiche o quasi (29 set 2026: giocando, l'utente ne ha viste alcune uguali).

Prima: Godot_console.exe --headless --path . --script res://tools/icone.gd   (scrive prove/icone/atlante.png e indice.txt)
Poi:   python tools/icone_simili.py [--soglia 6]

- IDENTICHE: stessi pixel. Si dividono in due casi: stessa forma e stesso materiale dichiarati (due oggetti diversi con
  la stessa icona per scelta dei dati) oppure dati diversi che danno lo stesso disegno (una forma che il codice non
  conosce e disegna come un'altra, un materiale senza tavolozza).
- QUASI UGUALI: stessa sagoma e colori vicini (una differenza di colore sotto la soglia su quasi tutti i pixel), cioè
  a occhio nella Bisaccia non si distinguono. Il caso tipico: stessa forma con due materiali dalle tavolozze simili.
Scrive prove/icone/doppie.txt e il foglio prove/icone/doppie.png (ogni gruppo in fila, ingrandito ×3, con i nomi).
"""
import argparse
import os
from collections import defaultdict

import numpy as np
from PIL import Image, ImageDraw, ImageFont

CARTELLA = os.path.join("prove", "icone")


def carica():
    atl = np.asarray(Image.open(os.path.join(CARTELLA, "atlante.png")).convert("RGBA")).astype(np.int16)
    righe = [l.split("|") for l in open(os.path.join(CARTELLA, "indice.txt"), encoding="utf-8").read().splitlines()]
    per_riga = atl.shape[1] // 16
    icone = []
    for r in righe:
        n = int(r[0])
        y, x = (n // per_riga) * 16, (n % per_riga) * 16
        icone.append(atl[y:y + 16, x:x + 16].copy())
    return righe, np.stack(icone)


def gruppi(chiavi):
    g = defaultdict(list)
    for i, k in enumerate(chiavi):
        g[k].append(i)
    return [v for v in g.values() if len(v) > 1]


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--soglia", type=float, default=6.0,
                    help="differenza media di colore (0-255) sotto cui due icone con la stessa sagoma sono «quasi uguali»")
    args = ap.parse_args()
    righe, ic = carica()
    n = len(righe)
    alpha = ic[:, :, :, 3] > 127
    # icone vuote (nessun pixel): da segnalare a parte
    vuote = [i for i in range(n) if not alpha[i].any()]

    # 1. identiche: stessi byte
    chiavi = [ic[i].tobytes() for i in range(n)]
    identiche = gruppi(chiavi)
    stessa_spec, spec_diverse = [], []
    for g in identiche:
        specs = {(righe[i][3], righe[i][4]) for i in g}
        (stessa_spec if len(specs) == 1 else spec_diverse).append(g)

    # 2. quasi uguali: tra i rappresentanti unici, stessa sagoma (maschera alfa) e colore medio vicino
    uniche = sorted({chiavi[i]: i for i in range(n)}.values())
    per_sagoma = defaultdict(list)
    for i in uniche:
        per_sagoma[alpha[i].tobytes()].append(i)
    quasi = []
    for membri in per_sagoma.values():
        if len(membri) < 2:
            continue
        m = alpha[membri[0]]
        col = ic[membri][:, :, :, :3][:, m].astype(np.float32)        # (k, pixel, 3)
        # unione a catena: i e j nello stesso gruppo se la differenza media per pixel è sotto la soglia
        k = len(membri)
        padre = list(range(k))

        def trova(a):
            while padre[a] != a:
                padre[a] = padre[padre[a]]
                a = padre[a]
            return a
        for a in range(k):
            d = np.abs(col[a + 1:] - col[a]).mean(axis=(1, 2)) if a + 1 < k else []
            for off, v in enumerate(d):
                if v < args.soglia:
                    padre[trova(a)] = trova(a + 1 + off)
        grp = defaultdict(list)
        for a in range(k):
            grp[trova(a)].append(membri[a])
        quasi += [g for g in grp.values() if len(g) > 1]
    # un gruppo «quasi» porta con sé anche i doppioni identici dei suoi membri
    fratelli = defaultdict(list)
    for i in range(n):
        fratelli[chiavi[i]].append(i)
    quasi = [[j for i in g for j in fratelli[chiavi[i]]] for g in quasi]

    def nome(i):
        r = righe[i]
        return "%s (%s · %s · %s)" % (r[2], r[1], r[3], r[4])

    out = ["Icone degli oggetti: %d; disegni diversi: %d" % (n, len(uniche)), ""]
    out.append("IDENTICHE con forma e materiale diversi (il disegno non distingue dati diversi): %d gruppi" % len(spec_diverse))
    for g in sorted(spec_diverse, key=len, reverse=True):
        out.append("  - " + " | ".join(nome(i) for i in g))
    out.append("")
    out.append("IDENTICHE con la stessa forma e lo stesso materiale (oggetti diversi con la stessa icona per i dati): "
               "%d gruppi, %d oggetti" % (len(stessa_spec), sum(len(g) for g in stessa_spec)))
    for g in sorted(stessa_spec, key=len, reverse=True):
        out.append("  - [%s · %s] " % (righe[g[0]][3], righe[g[0]][4]) + " | ".join(righe[i][2] for i in g))
    out.append("")
    out.append("QUASI UGUALI (stessa sagoma, colori quasi uguali, soglia %.0f): %d gruppi" % (args.soglia, len(quasi)))
    for g in sorted(quasi, key=len, reverse=True):
        out.append("  - " + " | ".join(nome(i) for i in g))
    if vuote:
        out.append("")
        out.append("ICONE VUOTE: " + ", ".join(nome(i) for i in vuote))
    open(os.path.join(CARTELLA, "doppie.txt"), "w", encoding="utf-8").write("\n".join(out))

    # il foglio: prima i gruppi con dati diversi, poi i quasi uguali, poi quelli con gli stessi dati
    try:
        font = ImageFont.truetype("arial.ttf", 11)
    except OSError:
        font = None
    sezioni = [("Identiche, dati diversi", spec_diverse), ("Quasi uguali", quasi), ("Identiche, stessi dati", stessa_spec)]
    z, cella, max_col = 3, 16 * 3 + 110, 8
    altezza = 0
    for _, gs in sezioni:
        altezza += 24 + sum(((len(g) + max_col - 1) // max_col) * (16 * z + 30) for g in gs)
    foglio = Image.new("RGB", (max_col * cella + 20, max(altezza + 20, 40)), (36, 28, 44))
    d = ImageDraw.Draw(foglio)
    y = 10
    for titolo, gs in sezioni:
        d.text((10, y), "%s (%d gruppi)" % (titolo, len(gs)), fill=(255, 210, 120), font=font)
        y += 24
        for g in gs:
            for k, i in enumerate(g):
                if k and k % max_col == 0:
                    y += 16 * z + 30
                x = 10 + (k % max_col) * cella
                im = Image.fromarray(ic[i].astype(np.uint8), "RGBA").resize((16 * z, 16 * z), Image.NEAREST)
                foglio.paste(im, (x, y), im)
                d.text((x, y + 16 * z + 2), righe[i][2][:18], fill=(230, 220, 200), font=font)
            y += 16 * z + 30
    foglio.save(os.path.join(CARTELLA, "doppie.png"))
    print("\n".join(out[:1]))
    print("identiche con dati diversi: %d gruppi · identiche con gli stessi dati: %d gruppi · quasi uguali: %d gruppi"
          % (len(spec_diverse), len(stessa_spec), len(quasi)))
    print("elenco in prove/icone/doppie.txt, foglio in prove/icone/doppie.png")


if __name__ == "__main__":
    main()
