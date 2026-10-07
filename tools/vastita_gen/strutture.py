"""Le strutture dei biomi (Roadmap 45, voce 394; piano in VASTITA.md).

Per ogni bioma (26) e ogni grado della partita (4: i vigori 1-3, 4-6, 7-9, 10 e oltre) una struttura disegnata come i
luoghi scritti a mano (`PlacesData`, stessa legenda): villaggi abbandonati, nidi giganti, templi, fucine sepolte, navi
nel cielo. Ognuna ha due stanze: l'anticamera con il leggio e la stanza del tesoro, con lo scrigno (il bottino delle
rovine, gli oggetti della cassa del bioma e un'arma firma della fase). E una **sorpresa**: un enigma (la porta del
tesoro si apre con leve, bracieri, piastre o cristalli, come i luoghi) oppure un **guardiano**, una creatura antica del
bioma che si sveglia entrando (`Finds.guard`). Le mette `PassStrutture` (al più `PER_WORLD` per mondo, del grado del
mondo e dei biomi che ci sono).
"""
import random

from vastita_gen.ritrovamenti import _biomes, _of

WALL = {'ambra': 'a', 'vetro': 'g', 'canto': 'c', 'scogliere_cristallo': 'c', 'ghiacciaio': 'c', 'stellare': 'a',
        'brace': '#', 'cenere': '#', 'catacombe': '#', 'pietra': '#', 'giungla': 'r', 'foresta': 'r', 'rossa': 'r',
        'radici_sospese': 'r', 'sussurri': 'v', 'firmamento': 'a', 'iridato': 'g'}
# i quattro gradi: per dove sta il bioma, quale struttura
KINDS = {'superficie': ['villaggio', 'nido', 'tempio', 'fucina'], 'sotto': ['nido', 'tempio', 'fucina', 'nido_grande'],
         'cielo': ['nave', 'nave', 'nave', 'nave']}
NAMES = {'villaggio': 'Il villaggio abbandonato', 'nido': 'Il nido gigante', 'tempio': 'Il tempio', 'fucina': 'La fucina sepolta',
         'nido_grande': 'La tana antica', 'nave': 'La nave di radice'}
BANNER = {'villaggio': 'Case vuote, e nessuno a cui chiedere', 'nido': 'Qualcosa vive qui, e non vuole ospiti',
          'tempio': 'Un altare, e un segno raschiato via', 'fucina': 'Le incudini dei Seminatori, fredde da secoli',
          'nido_grande': 'La tana di qualcosa di molto vecchio', 'nave': 'Una nave ancorata al nulla'}
LORE = {'villaggio': ['Le porte sono aperte e i letti fatti. Chi abitava qui è uscito un mattino e non è tornato.',
                      'Sul tavolo, piatti per tre. Il quarto posto è stato apparecchiato e poi tolto.'],
        'nido': ['Ossa pulite e radici rosicchiate. Qualcosa ha fatto il nido nelle stanze dei Seminatori.',
                 'Le pareti sono graffiate dall\'interno.'],
        'tempio': ['Sull\'altare, il segno di un Seme. Qualcuno l\'ha raschiato via con le unghie.',
                   'Una preghiera incisa sulla soglia: «Che il Cuore non si svegli». Sotto, più nuova: «Troppo tardi».'],
        'fucina': ['Le incudini sono fredde. Su una, l\'impronta di una mano più grande di una mano.',
                   'Qui forgiavano gli attrezzi per curare i mondi. L\'ultimo è rimasto a metà.'],
        'nido_grande': ['La tana è più vecchia del mondo che la contiene.', 'Chi l\'ha scavata dorme ancora, ma male.'],
        'nave': ['Una nave di radice, ancorata al nulla. I Seminatori viaggiavano così tra i mondi, prima delle Aiuole.',
                 'Il timone è legato. Chi l\'ha legato non voleva che la nave tornasse indietro.']}
ENIGMA = {'villaggio': 'leve', 'tempio': 'cristalli', 'fucina': 'bracieri', 'nave': 'piastre'}
GUARD = ('nido', 'nido_grande')
PER_WORLD = 4


def _room_pair(wc, h, w1, w2, enigma, rng, mech=3, maglio=False):
    """Due stanze: l'anticamera (leggio, meccanismi) e il tesoro (scrigno), divise da una porta o da un passaggio."""
    W = w1 + w2 + 3
    g = [[wc] * W for _ in range(h)]
    for r in range(1, h - 1):
        for c in range(1, W - 1):
            if c != w1 + 1:
                g[r][c] = '.'
    for r in (h - 3, h - 2):
        g[r][0] = '.'                                  # l'ingresso, a sinistra
        g[r][w1 + 1] = 'D' if enigma else '.'          # la porta del tesoro (o un passaggio)
    g[h - 2][2] = 'L'
    if enigma:
        for k in range(mech):
            g[h - 2][5 + 2 * k] = str(k + 1)
    if maglio:
        g[h - 2][w1 - 2] = 'M'
    g[h - 2][w1 + 2 + w2 // 2 - 1] = 'S'
    # rune e qualche crepa nel muro di sopra
    for c in range(2, W - 2):
        if rng.random() < 0.08:
            g[0][c] = '.'
    return g


def _rows(g):
    return [''.join(r) for r in g]


def _villaggio(wc, rng, enigma):
    g = _room_pair(wc, 7, 12, 8, enigma, rng)
    W = len(g[0])
    roof = []
    for k in range(3, 0, -1):
        pad = k * 2
        roof.append([' '] * pad + [wc] * (W - 2 * pad) + [' '] * pad)
    return _rows(roof + g)


def _tempio(wc, rng, enigma):
    g = _room_pair(wc, 8, 13, 8, enigma, rng)
    W = len(g[0])
    for c in range(4, 12, 4):
        for r in (1, 2):
            g[r][c] = '#'                              # colonne appese al soffitto
    steps = [[' '] * 4 + ['#'] * (W - 8) + [' '] * 4, [' '] * 2 + ['#'] * (W - 4) + [' '] * 2]
    return _rows(steps + g)


def _fucina(wc, rng, enigma):
    g = _room_pair('#', 8, 14, 8, enigma, rng, maglio=True)
    for r in range(len(g)):
        for c in range(len(g[0])):
            if g[r][c] == '#' and rng.random() < 0.22:
                g[r][c] = 'v' if wc == '#' else wc
    return _rows(g)


def _nido(wc, rng, big):
    h = 9 if big else 7
    g = _room_pair('r', h, 14 if big else 11, 9 if big else 7, False, rng)
    W = len(g[0])
    # le radici crescono dentro: stalattiti e un bordo irregolare
    for c in range(1, W - 1):
        if g[1][c] == '.' and rng.random() < 0.35:
            g[1][c] = 'r'
    ring = [[' ' if rng.random() < 0.3 else 'r' for _ in range(W)]]
    return _rows(ring + g + [[' ' if rng.random() < 0.3 else 'r' for _ in range(W)]])


def _nave(wc, rng, enigma):
    g = _room_pair('r', 6, 12, 8, enigma, rng)
    W = len(g[0])
    for r in (h for h in range(len(g))):
        g[r][0] = 'r' if g[r][0] != '.' else '.'
    mast = []
    for k in range(5):
        row = [' '] * W
        row[W // 3] = 'r'
        if k in (1, 2):
            for c in range(W // 3 + 1, W // 3 + 6):
                row[c] = 'g'                       # la vela di resina
        mast.append(row)
    deck = ['='] * W
    hull = [[' '] + ['r'] * (W - 2) + [' '], [' ', ' '] + ['r'] * (W - 4) + [' ', ' '],
            [' '] * 4 + ['r'] * (W - 8) + [' '] * 4]
    return _rows(mast + [deck] + g[1:] + hull)


def build():
    places, grids = {}, {}
    for bi, (bid, name, elem, color, where) in enumerate(_biomes()):
        ofb = _of(bid, name)
        for tier, kind in enumerate(KINDS[where]):
            sid = 'str_%s_%d' % (bid, tier)
            rng = random.Random(sid)
            wc = WALL.get(bid, '=' if kind == 'villaggio' else '#')
            guard = kind in GUARD or (kind == 'nave' and tier % 2 == 1)
            enigma = not guard
            if kind == 'villaggio':
                grid = _villaggio(wc, rng, enigma)
            elif kind == 'tempio':
                grid = _tempio(wc, rng, enigma)
            elif kind == 'fucina':
                grid = _fucina(wc, rng, enigma)
            elif kind in ('nido', 'nido_grande'):
                grid = _nido(wc, rng, kind == 'nido_grande')
            else:
                grid = _nave(wc, rng, enigma)
            assert len(set(len(r) for r in grid)) == 1, sid
            surface = kind in ('villaggio', 'tempio') and where == 'superficie'
            strata = [0, 0] if where == 'cielo' else ([1, 2] if kind in ('nido', 'tempio') else [3, 4])
            p = {'name': '%s %s' % (NAMES[kind], ofb), 'strata': [] if surface else strata, 'genes': [],
                 'struttura': True, 'biome': bid, 'where': where, 'tier': tier, 'kind': kind,
                 'banner': BANNER[kind], 'color': color, 'unique': '',
                 'lore': LORE[kind][tier % len(LORE[kind])],
                 'enigma': {'tipo': ENIGMA.get(kind, 'leve') if enigma else 'nessuno'}}
            if surface:
                p['surface'] = True
            if guard:
                p['guard'] = True
            places[sid] = p
            grids[sid] = grid
    return [('strutture.gd', 'Roadmap 45, voce 394: le strutture dei biomi (disegni come i luoghi scritti a mano)',
             {'places': places, 'grids': grids})]
