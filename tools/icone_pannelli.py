"""Le quattro icone dei pulsanti che mancavano (Quaderno, Pilastri, Atlante, Arti), 16x16 come quelle di Nano Banana:
forme piene, luce da sinistra in alto, contorno scuro aggiunto da solo."""
import math
from PIL import Image

OUT = "arte/interfaccia/"
PAL = {
    "P": (232, 214, 170), "p": (201, 181, 152), "q": (160, 135, 112),
    "T": (96, 226, 206), "t": (52, 150, 138),
    "G": (244, 196, 96), "g": (196, 134, 62), "h": (130, 82, 52),
    "S": (168, 178, 192), "s": (120, 128, 150), "d": (82, 86, 110),
    "B": (104, 124, 176), "b": (72, 88, 134), "n": (52, 62, 100),
    "W": (155, 116, 99), "w": (105, 77, 79),
    "L": (178, 226, 190), "l": (104, 170, 140), "k": (66, 118, 104),
}
OUTLINE = (26, 16, 32, 255)


def from_rows(rows):
    im = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    for y, r in enumerate(rows):
        for x, ch in enumerate(r):
            if ch in PAL:
                im.putpixel((x, y), PAL[ch] + (255,))
    return im


def outline(im):
    out = im.copy()
    for y in range(16):
        for x in range(16):
            if im.getpixel((x, y))[3]:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < 16 and 0 <= ny < 16 and im.getpixel((nx, ny))[3] and im.getpixel((nx, ny))[:3] != OUTLINE[:3]:
                    out.putpixel((x, y), OUTLINE)
                    break
    return out


# Il Quaderno: un libro aperto con i segni dei Seminatori.
QUADERNO = [
    "................",
    "................",
    "..PPPPP..PPPPP..",
    ".PPPPPPpPPPPPPp.",
    ".PTTPPPpPPPTPPp.",
    ".PPTPPPpPPTTTPp.",
    ".PTTTPPpPPPTPPp.",
    ".PPPPPPpPPPPPPp.",
    ".PqqPPPpPPqqqPp.",
    ".PPPPPPpPPPPPPp.",
    ".PqqqPPpPPqqPPp.",
    ".PPPPPPpPPPPPPp.",
    ".qqqqqqpqqqqqqq.",
    ".GGGGGGhgggggggh",
    "................",
    "................",
]

# I pilastri: tre colonne che salgono, una gemma sopra la più alta.
PILASTRI = [
    "................",
    "................",
    "............G...",
    "...........GGg..",
    "............g...",
    "..........SSSSSs",
    "...........SSSs.",
    "......SSSSsSSSs.",
    ".......SSs.SSSs.",
    ".SSSSs.SSs.SSSs.",
    "..SSs..SSs.SSSs.",
    "..SSs..SSs.SSSs.",
    "..SSs..SSs.SSSs.",
    ".SSSSsSSSSsSSSSs",
    "GGGGGGGGGGGGGGGg",
    "................",
]


def atlante():
    im = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    for y in range(16):
        for x in range(16):
            dx, dy = x + 0.5 - 8, y + 0.5 - 8
            r = math.hypot(dx, dy)
            if r > 6.9:
                continue
            ax, ay = abs(dx), abs(dy)
            star = (ax <= (5.6 - ay) * 0.34 and ay < 5.6) or (ay <= (5.6 - ax) * 0.34 and ax < 5.6) or (abs(ax - ay) < 0.8 and r < 3.2)
            if r > 5.9:
                c = "g" if dx + dy > 0 else "G"
            elif star:
                c = "G" if (dx < 0 or dy < 0) and not (dx > 0 and dy > 0) else "g"
                if ax < 1 and ay < 1:
                    c = "P"
            else:
                c = "B" if dx + dy < -3 else ("b" if dx + dy < 4 else "n")
            im.putpixel((x, y), PAL[c] + (255,))
    return im


def arti():
    im = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    # due lame a foglia incrociate: punta in alto, impugnatura in basso
    for tip, end in (((2.5, 2.5), (13.5, 13.5)), ((13.5, 2.5), (2.5, 13.5))):
        for i in range(60):
            t = i / 59.0
            x = tip[0] + (end[0] - tip[0]) * t
            y = tip[1] + (end[1] - tip[1]) * t
            if t < 0.64:
                w = 0.8 + min(t, 0.64 - t) * 2.6
                col_hi, col_lo = "L", "l"
            elif t < 0.72:
                w = 1.9
                col_hi, col_lo = "G", "g"
            else:
                w = 0.85
                col_hi, col_lo = "W", "w"
            for yy in range(16):
                for xx in range(16):
                    ex, ey = xx + 0.5 - x, yy + 0.5 - y
                    if math.hypot(ex, ey) <= w:
                        # luce da sinistra in alto
                        side = (-ex - ey)
                        im.putpixel((xx, yy), PAL[col_hi if side >= 0 else col_lo] + (255,))
    return im


for name, img in (("quaderno", from_rows(QUADERNO)), ("pilastri", from_rows(PILASTRI)),
                  ("atlante", atlante()), ("arti", arti())):
    outline(img).save(OUT + "pannello_" + name + ".png")

# foglio di controllo: le nuove accanto alle vecchie
names = ["bisaccia", "mappa", "erbario", "semenzaio", "mandria", "opzioni", "quaderno", "pilastri", "atlante", "arti"]
sheet = Image.new("RGBA", (len(names) * 144, 144), (40, 30, 40, 255))
for i, n in enumerate(names):
    im = Image.open(OUT + "pannello_" + n + ".png").resize((128, 128), Image.NEAREST)
    sheet.paste(im, (i * 144 + 8, 8), im)
sheet.save(r"C:\Users\PRINCI~1\AppData\Local\Temp\claude\C--Users-Principale-Desktop-CLAUDE-TERRAWORLD\0bd54181-ffff-4f37-b7b8-1445b8bde805\scratchpad\icone2.png")
