# -*- coding: utf-8 -*-
"""Taglia una tavola di Nano Banana (più oggetti su magenta) nei suoi pezzi e li porta alla misura del gioco
(Roadmap 13, voce 100: l'attrezzo comune di tutta la grafica).

Nano Banana non rispetta mai la griglia al pixel e aggiunge quasi sempre scritte (il nome sotto ogni oggetto) anche se
vietate. Quindi la tavola non si taglia a righello: si cercano i pezzi come macchie di colore separate dal magenta,
si scartano le scritte (macchie quasi tutte bianche e senza contorno scuro) e i granelli, e si leggono in ordine di
lettura (righe dall'alto, poi da sinistra). I nomi arrivano da --nomi, nello stesso ordine del prompt.

Ogni pezzo passa dalla stessa pixelatura del Germogliato (`pixela.riduci`: tavolozza comune a tutta la tavola, moda per
pixel, pulizia, contorno di 1 pixel del gioco). Il contorno scuro disegnato da Nano Banana si toglie prima di ridurre:
a 16 pixel sarebbe largo un pixel e mezzo e, con quello del gioco, la figura sparirebbe dentro il nero.

Uso:
  python tools/tavola.py arte_ia/interfaccia/01_prova_v1.png --nomi vita,linfa,scorza,brace,gelo,spora \
         --cartella arte/interfaccia --lato 16 [--colori 32] [--misure 12,16,20] [--tieni-contorno]
Scrive arte/<cartella>/<nome>.png (quadrato di --lato pixel, trasparente) e l'anteprima prove/arte_<tavola>.png:
ogni pezzo alle misure di --misure, ingrandito, su un fondo scuro come quello del gioco e su uno chiaro.
"""
import argparse
import os

import numpy as np
from PIL import Image, ImageDraw, ImageFont
from scipy import ndimage

import pixela

FONDO_SCURO = (22, 16, 30)
FONDO_CHIARO = (120, 104, 128)


def togli_magenta(im: Image.Image) -> np.ndarray:
    """Come `pixela.togli_magenta`, ma i residui di magenta si cercano solo vicino allo sfondo: dentro le figure i
    viola e i rosa (spore, cristalli) somigliano al magenta e sparivano (la spora della tavola di prova)."""
    a = pixela.togli_magenta(im)
    rgb = np.asarray(im.convert("RGB")).astype(np.float32)
    h, w = rgb.shape[:2]
    bg = np.stack([rgb[2, 2], rgb[2, w - 3], rgb[h - 3, 2], rgb[h - 3, w - 3]]).mean(axis=0)
    d = np.abs(rgb - bg).sum(axis=2)
    vero = np.clip((d - 70.0) / 110.0, 0.0, 1.0)
    sfondo = vero < 0.05
    vicino = ndimage.binary_dilation(sfondo, iterations=3)
    rimetti = (a[:, :, 3] == 0) & (vero > 0) & ~vicino
    a[rimetti, 3] = vero[rimetti]
    return a


def pezzi(a: np.ndarray, soglia_area: float = 0.004) -> list[tuple[slice, slice, np.ndarray]]:
    """Le macchie della tavola che sono oggetti: (righe, colonne, maschera) in ordine di lettura."""
    opaque = a[:, :, 3] > 0.5
    lab, n = ndimage.label(opaque)
    tot = opaque.size
    out = []
    rgb = a[:, :, :3]
    lum = rgb @ np.array([0.3, 0.59, 0.11])
    sat = rgb.max(axis=2) - rgb.min(axis=2)
    for i, sl in enumerate(ndimage.find_objects(lab), start=1):
        m = lab[sl] == i
        area = int(m.sum())
        if area < tot * soglia_area:
            continue
        # le scritte: pixel quasi tutti bianchi e grigi, senza scuri
        bianchi = ((lum[sl] > 190) & (sat[sl] < 50))[m].mean()
        scuri = (lum[sl] < 70)[m].mean()
        if bianchi > 0.45 and scuri < 0.08:
            continue
        out.append((sl[0], sl[1], m))
    # ordine di lettura: una riga nuova quando il centro scende oltre metà dell'altezza media dei pezzi
    if not out:
        return out
    alt = np.mean([p[0].stop - p[0].start for p in out])
    out.sort(key=lambda p: (p[0].start + p[0].stop) / 2)
    righe, cur, cy = [], [], None
    for p in out:
        y = (p[0].start + p[0].stop) / 2
        if cy is not None and y - cy > alt * 0.5:
            righe.append(cur)
            cur = []
        cur.append(p)
        cy = y if len(cur) == 1 else cy
    righe.append(cur)
    return [p for r in righe for p in sorted(r, key=lambda p: p[1].start)]


def togli_contorno(a: np.ndarray) -> np.ndarray:
    """Toglie l'anello scuro esterno disegnato da Nano Banana (i pixel scuri raggiungibili dal fuori passando solo
    per scuri). I dettagli scuri interni restano."""
    lum = a[:, :, :3] @ np.array([0.3, 0.59, 0.11])
    fuori = a[:, :, 3] < 0.5
    scuro = (lum < 75) & ~fuori
    lab, _ = ndimage.label(fuori | scuro)
    bordo = set(np.unique(np.concatenate([lab[0], lab[-1], lab[:, 0], lab[:, -1]]))) - {0}
    anello = np.isin(lab, list(bordo)) & scuro
    b = a.copy()
    b[anello, 3] = 0.0
    return pixela.ritaglia(b)


def quadrato(img: np.ndarray, lato: int) -> np.ndarray:
    """Mette la figura al centro di un quadrato trasparente di `lato` pixel (in basso se non è alta quanto il lato)."""
    out = np.zeros((lato, lato, 4), dtype=np.uint8)
    h, w = img.shape[:2]
    y0, x0 = (lato - h) // 2, (lato - w) // 2
    out[y0:y0 + h, x0:x0 + w] = img
    return out


def riduci_a(a: np.ndarray, lato: int, pal: np.ndarray, n_base: int) -> np.ndarray:
    """La figura dentro `lato` pixel compreso il contorno."""
    f = max(a.shape[0], a.shape[1]) / (lato - 2)
    return quadrato(pixela.riduci(a, f, pal, n_base)[:lato, :lato], lato)


def anteprima(figure: list[np.ndarray], nomi: list[str], misure: list[int], pal: np.ndarray, n_base: int,
              path: str) -> None:
    zoom = 4
    cella = max(misure) * zoom + 16
    font = ImageFont.truetype("arialbd.ttf", 14) if os.path.exists("C:/Windows/Fonts/arialbd.ttf") else None
    righe = len(figure)
    W = 110 + cella * len(misure) * 2
    H = 30 + righe * cella
    im = Image.new("RGB", (W, H), (60, 52, 66))
    d = ImageDraw.Draw(im)
    for j, m in enumerate(misure):
        for k, fondo in enumerate((FONDO_SCURO, FONDO_CHIARO)):
            d.text((110 + (j * 2 + k) * cella + 8, 8), "%d px%s" % (m, "" if k == 0 else " chiaro"),
                   fill=(230, 220, 200), font=font)
    for i, (a, nome) in enumerate(zip(figure, nomi)):
        y = 30 + i * cella
        d.text((8, y + cella // 2 - 8), nome, fill=(230, 220, 200), font=font)
        for j, m in enumerate(misure):
            px = Image.fromarray(riduci_a(a, m, pal, n_base), "RGBA").resize((m * zoom, m * zoom), Image.NEAREST)
            for k, fondo in enumerate((FONDO_SCURO, FONDO_CHIARO)):
                x = 110 + (j * 2 + k) * cella
                d.rectangle([x, y, x + cella - 6, y + cella - 6], fill=fondo)
                off = (cella - 6 - m * zoom) // 2
                im.paste(px, (x + off, y + off), px)
    im.save(path)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("file")
    ap.add_argument("--nomi", required=True, help="nomi dei pezzi in ordine di lettura, separati da virgole")
    ap.add_argument("--cartella", required=True, help="dove scrivere i png del gioco, es. arte/interfaccia")
    ap.add_argument("--lato", type=int, default=16)
    ap.add_argument("--colori", type=int, default=32)
    ap.add_argument("--misure", default="", help="misure dell'anteprima, es. 12,16,20 (vuoto = solo --lato)")
    ap.add_argument("--tieni-contorno", action="store_true", help="non togliere il contorno scuro del disegno")
    args = ap.parse_args()

    nomi = [n.strip() for n in args.nomi.split(",") if n.strip()]
    a = togli_magenta(Image.open(args.file))
    trovati = pezzi(a)
    if len(trovati) != len(nomi):
        print("ATTENZIONE: trovati %d pezzi, ma i nomi sono %d" % (len(trovati), len(nomi)))
    figure = []
    for ys, xs, m in trovati[:len(nomi)]:
        f = a[ys, xs].copy()
        f[~m, 3] = 0.0
        f = pixela.ritaglia(f)
        figure.append(f if args.tieni_contorno else togli_contorno(f))
    pal, n_base = pixela.tavolozza(figure, args.colori, [])
    os.makedirs(args.cartella, exist_ok=True)
    for f, nome in zip(figure, nomi):
        Image.fromarray(riduci_a(f, args.lato, pal, n_base), "RGBA").save(os.path.join(args.cartella, nome + ".png"))
    misure = [int(x) for x in args.misure.split(",") if x.strip()] or [args.lato]
    base = os.path.splitext(os.path.basename(args.file))[0]
    os.makedirs("prove", exist_ok=True)
    prev = os.path.join("prove", "arte_%s.png" % base)
    anteprima(figure, nomi[:len(figure)], misure, pal, n_base, prev)
    print("%d pezzi in %s (%d px), anteprima %s" % (len(figure), args.cartella, args.lato, prev))


if __name__ == "__main__":
    main()
