# -*- coding: utf-8 -*-
"""Porta un'illustrazione intera di Nano Banana (sfondi, schermate) o una scritta su magenta (il logo) alla misura del
gioco, in pixel grossi come il resto (Roadmap 13, voce 103).

- `--sfondo`: l'immagine intera (senza magenta) si riduce a `--largo` pixel con la media dei colori (una scena grande
  non ha le linee sottili che la moda deve salvare) e si porta a `--colori` colori; nel gioco si ingrandisce senza
  sfumare fino a riempire lo schermo (400 px × 4 = 1600).
- `--logo`: la figura su magenta passa dalla stessa pixelatura delle tavole (`tavola.py`), larga `--largo` pixel.

Uso:
  python tools/illustrazione.py --sfondo arte_ia/titolo/01_sfondo_v1.jpg arte/titolo/sfondo.png --largo 400
  python tools/illustrazione.py --logo arte_ia/titolo/02_logo_v1.png arte/titolo/logo.png --largo 150
  python tools/illustrazione.py --prova-menu arte/titolo/sfondo.png arte/titolo/logo.png    (-> prove/arte_menu.png)
"""
import argparse
import os

import numpy as np
from PIL import Image

import pixela
import tavola

SCHERMO = (1600, 900)


def riduci_con_luci(im: Image.Image, largo: int, alto: int) -> Image.Image:
    """Riduzione a media di riquadri 4×4, ma un pixel dove almeno un quinto del riquadro è luce (baccelli d'ambra,
    lucciole, Linfa) prende il colore di quella luce: con la sola media le luci piccole si mescolavano al buio attorno
    e si spegnevano (i baccelli dell'Albero-Madre diventavano rosso scuro)."""
    k = 4
    a = np.asarray(im.resize((largo * k, alto * k), Image.LANCZOS)).astype(np.float32)
    b = a.reshape(alto, k, largo, k, 3).transpose(0, 2, 1, 3, 4).reshape(alto, largo, k * k, 3)
    media = b.mean(axis=2)
    lum = b @ np.array([0.3, 0.59, 0.11], dtype=np.float32)
    luce = lum > np.maximum(150.0, (media @ np.array([0.3, 0.59, 0.11], dtype=np.float32))[..., None] + 50.0)
    quota = luce.mean(axis=2)
    somma = (b * luce[..., None]).sum(axis=2) / np.maximum(luce.sum(axis=2), 1)[..., None]
    out = np.where((quota >= 0.2)[..., None], somma, media)
    return Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), "RGB")


def sfondo(src: str, dst: str, largo: int, colori: int) -> Image.Image:
    im = Image.open(src).convert("RGB")
    alto = round(largo * im.height / im.width)
    # 16:9 esatto: si taglia l'avanzo in basso (il cielo e l'albero stanno in alto)
    alto_voluto = round(largo * 9 / 16)
    small = riduci_con_luci(im, largo, alto)
    if alto > alto_voluto:
        small = small.crop((0, 0, largo, alto_voluto))
    elif alto < alto_voluto:
        pieno = Image.new("RGB", (largo, alto_voluto), small.getpixel((0, alto - 1)))
        pieno.paste(small, (0, 0))
        small = pieno
    small = small.quantize(colors=colori, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).convert("RGB")
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    small.save(dst)
    return small


def logo(src: str, dst: str, largo: int, colori: int) -> Image.Image:
    a = pixela.ritaglia(tavola.togli_magenta(Image.open(src)))
    a = tavola.togli_contorno(a, tavola.spessore_contorno([a]))
    pal = np.vstack([pixela.tavolozza([a], colori, [])[0]])
    out = pixela.riduci(a, a.shape[1] / (largo - 2), pal, len(pal))
    im = Image.fromarray(out, "RGBA")
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    im.save(dst)
    return im


def prova_menu(sf: str, lg: str) -> None:
    """Come apparirebbe il menu: sfondo e logo ingranditi dello stesso fattore, il logo in alto al centro."""
    s = Image.open(sf).convert("RGB")
    k = SCHERMO[0] // s.width
    big = s.resize((s.width * k, s.height * k), Image.NEAREST)
    l = Image.open(lg).convert("RGBA")
    l = l.resize((l.width * k, l.height * k), Image.NEAREST)
    # il menu nella metà sinistra (il cielo vuoto), l'albero libero a destra: logo in alto a sinistra e, sotto, il
    # posto dei pulsanti (riquadro scuro, solo per vedere lo spazio)
    x0 = round(big.width * 0.26) - l.width // 2
    big.paste(l, (x0, round(big.height * 0.09)), l)
    ov = Image.new("RGBA", big.size, (0, 0, 0, 0))
    from PIL import ImageDraw
    d = ImageDraw.Draw(ov)
    cx = round(big.width * 0.26)
    for i in range(4):
        y = round(big.height * 0.38) + i * 62
        d.rounded_rectangle([cx - 200, y, cx + 200, y + 46], 8, fill=(20, 14, 28, 200), outline=(142, 240, 216, 255))
    big = Image.alpha_composite(big.convert("RGBA"), ov).convert("RGB")
    os.makedirs("prove", exist_ok=True)
    big.save("prove/arte_menu.png")
    print("prove/arte_menu.png %dx%d (×%d)" % (big.width, big.height, k))


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--sfondo", nargs=2, metavar=("DA", "A"))
    ap.add_argument("--logo", nargs=2, metavar=("DA", "A"))
    ap.add_argument("--prova-menu", nargs=2, metavar=("SFONDO", "LOGO"))
    ap.add_argument("--largo", type=int, default=400)
    ap.add_argument("--colori", type=int, default=128)
    args = ap.parse_args()
    if args.sfondo:
        im = sfondo(args.sfondo[0], args.sfondo[1], args.largo, args.colori)
        print("%s %dx%d" % (args.sfondo[1], im.width, im.height))
    if args.logo:
        im = logo(args.logo[0], args.logo[1], args.largo, min(args.colori, 16))
        print("%s %dx%d" % (args.logo[1], im.width, im.height))
    if args.prova_menu:
        prova_menu(*args.prova_menu)


if __name__ == "__main__":
    main()
