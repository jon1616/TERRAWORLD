"""La terra dei mondi (Roadmap 52; il confronto con i blocchi di Terraria in ROADMAP.md).

- **Le terre dei biomi** (voce 412): ogni bioma di superficie ha la sua terra sotto l'erba (al posto dell'humus) e quasi
  tutti la loro roccia nei primi strati; cinque terre comuni in sacche. Ogni terra ha un comportamento o un uso:
  sabbie, ceneri, limo e ghiaia **cadono** (`cade`, con la roccia che le regge sopra i vuoti: `support`), le nevi e la
  torba **attutiscono** le cadute (`soft` = quanto resta della ferita), i fanghi **appiccicano** (`stick` = la corsa), i
  ghiacci **scivolano** (`slip` = la presa sul pavimento), le terre grasse fanno crescere l'orto (`fertile`), la cenere
  calda **scalda** nel freddo (`warm`), la terra muta e il marmo pallido **non fanno rumore** ai passi (`quiet`), la
  pietra nera **regge le esplosioni** (`blast`), la pietra fossile nasconde **fossili** (`fossil`), alcune fanno luce
  (`emit`) o la lasciano passare (`pass`).
- Campi delle tessere (`tiles`, letti da `TileDefs`): name, hard, power, drop, pal, layer, specks, look (il disegno in
  `TerrainPainter`), kind (suolo, roccia, terra comune, minerale, gemma, blocco) e i campi del comportamento qui sopra.
- `soils`: {bioma: {suolo, roccia}} letto da `PassTerre`; `veins`: le sacche delle terre comuni per `PassMinerali`.
"""

import os
import re

T0 = 59                                   # il primo numero libero di tessera (le tessere arrivano a 58)
ROOT = os.path.normpath(os.path.join(os.path.dirname(__file__), '..', '..'))

# id, nome, bioma, tavolozza, look, durezza, forza, comportamento, descrizione dell'oggetto
SOILS = [
    ('sabbia_ambra', "Sabbia d'ambra", 'ambra', ["#5a3a14", "#8a5e22", "#b8862e", "#e0b250", "#f8dc8a"], 'sabbia', 0.18, 0,
     {'cade': True, 'support': 'arenaria_ambra'}, "Sabbia calda e dorata: senza appoggio frana. Al Baccello ardente diventa vetro."),
    ('sabbia_tagliente', "Sabbia tagliente", 'vetro', ["#4a4a38", "#6e6e52", "#9a9a74", "#c8c8a0", "#eef0d4"], 'sabbia', 0.18, 0,
     {'cade': True, 'support': 'arenaria_vetro'}, "Granelli di vetro che tagliano le dita: frana, e fonde in vetro più che ogni altra sabbia."),
    ('cenere_calda', "Cenere calda", 'brace', ["#1e1418", "#3a2224", "#5a302a", "#8a4a30", "#e07a3a"], 'brace', 0.2, 0,
     {'cade': True, 'support': 'basalto', 'warm': True}, "Cenere che cova la brace: frana, e chi le sta vicino non sente il freddo."),
    ('cenere_spenta', "Cenere spenta", 'cenere', ["#2a2628", "#423c3e", "#5e5658", "#7c7274", "#a49a9a"], 'sabbia', 0.18, 0,
     {'cade': True, 'support': 'tufo'}, "La cenere delle Cenerarie, fredda e leggera: frana appena le togli l'appoggio."),
    ('neve', "Neve", 'brina', ["#5a6a80", "#8aa0b8", "#b8cce0", "#dce8f4", "#f8fcff"], 'neve', 0.15, 0,
     {'soft': 0.35}, "Neve soffice dei Boschi di brina: chi ci cade sopra si fa poco male."),
    ('neve_dura', "Neve dura", 'ghiacciaio', ["#4a5e7a", "#7090b0", "#9ab8d4", "#c4dcee", "#ecf6ff"], 'neve', 0.25, 0,
     {'soft': 0.6}, "Neve battuta dal vento dei ghiacciai: attutisce le cadute, ma meno di quella fresca."),
    ('terriccio_micelio', "Terriccio di micelio", 'funghi', ["#2a1e1a", "#4a3428", "#6e4e3a", "#946c50", "#d8c8b0"], 'fibre', 0.2, 0,
     {'fertile': 1.3, 'soft': 0.7}, "Terra intrecciata di fili di fungo: morbida, e l'orto ci cresce più in fretta."),
    ('fango_spore', "Fango di spore", 'palude', ["#1e1424", "#32203a", "#4a3054", "#644470", "#8a64a0"], 'fango', 0.22, 0,
     {'stick': 0.55}, "Fango viola che si attacca ai piedi: ci si corre a fatica, e le creature pure."),
    ('zolla_torba', "Torba", 'torba', ["#140e0c", "#241a16", "#382820", "#4e3a2c", "#6a5240"], 'fibre', 0.18, 0,
     {'soft': 0.5, 'fertile': 1.2}, "Torba nera e molle delle Torbiere: attutisce le cadute e nutre l'orto."),
    ('terra_grassa', "Terra grassa", 'prati', ["#1a0e16", "#2e1824", "#462636", "#5e3648", "#7a4a5e"], 'fibre', 0.2, 0,
     {'fertile': 1.5}, "La terra più ricca che ci sia: l'orto piantato qui cresce una volta e mezza più in fretta."),
    ('terra_rossa', "Terra rossa", 'rossa', ["#3a1410", "#5e2018", "#8a3222", "#b44a30", "#e07050"], 'fibre', 0.3, 0,
     {}, "Terra argillosa delle Selve rosse: al Baccello ardente si cuoce in mattoni."),
    ('polvere_pietra', "Polvere di pietra", 'pietra', ["#3a3a40", "#55555e", "#72727c", "#92929c", "#babac4"], 'sabbia', 0.16, 0,
     {'cade': True, 'support': 'pietra_fossile'}, "La polvere delle Foreste pietrificate: frana, e pressata dà ciottoli da fionda."),
    ('terra_iridata', "Terra iridata", 'iridato', ["#2a1e3a", "#3e3a6a", "#3a6a8a", "#6aa0a0", "#c0e0c8"], 'stelle', 0.2, 0,
     {'emit': [0.12, 0.1, 0.2], 'fertile': 1.15}, "Terra che cambia colore: brilla appena, e l'orto la ama."),
    ('terra_stellata', "Terra stellata", 'stellare', ["#0e1028", "#1a1c44", "#2a2e64", "#44488a", "#f0e08a"], 'stelle', 0.2, 0,
     {'emit': [0.2, 0.18, 0.08]}, "Polvere di stelle mescolata alla terra: fa luce da sé, senza torce."),
    ('terra_muta', "Terra muta", 'sussurri', ["#2e2e34", "#46464e", "#62626a", "#80808a", "#a8a8b2"], 'neve', 0.22, 0,
     {'quiet': True}, "Terra pallida dei Boschi dei sussurri: i passi non fanno rumore, e le creature non sentono chi corre."),
]

ROCKS = [
    ('arenaria_ambra', "Arenaria d'ambra", 'ambra', ["#4a3018", "#6e4a24", "#946634", "#bc8a4a", "#e0b878"], 'strati', 0.35, 0, {},
     "Sabbia d'ambra stretta in pietra: regge la sabbia sopra le grotte."),
    ('arenaria_vetro', "Arenaria di vetro", 'vetro', ["#3e4038", "#5c6052", "#7e8470", "#a4aa94", "#d0d6c0"], 'strati', 0.35, 0,
     {'pass': 0.7}, "Pietra di vetro grezzo: lascia passare un po' di luce."),
    ('basalto', "Basalto", 'brace', ["#0e0c10", "#1c1a20", "#2c2a32", "#403e48", "#5c5a66"], 'colonne', 0.6, 35, {},
     "La roccia nera delle Lande di brace, a colonne: dura da scavare."),
    ('tufo', "Tufo", 'cenere', ["#4a3e34", "#665a4c", "#867866", "#a89a84", "#cabca6"], 'strati', 0.16, 0, {},
     "Cenere diventata pietra, leggera e porosa: si scava in un attimo."),
    ('ghiaccio_brina', "Ghiaccio di brina", 'brina', ["#2a4a6a", "#3e6a90", "#5a90b8", "#8ab8dc", "#d0ecff"], 'ghiaccio', 0.3, 0,
     {'slip': 0.16, 'pass': 0.8}, "Ghiaccio limpido: ci si scivola sopra, e la luce lo attraversa."),
    ('ghiaccio_antico', "Ghiaccio antico", 'ghiacciaio', ["#1a3a5a", "#28587e", "#3e7ea4", "#62a8cc", "#a8e8f8"], 'ghiaccio', 0.45, 0,
     {'slip': 0.12, 'pass': 0.8}, "Ghiaccio con la Linfa gelata dentro: liscissimo, ci si scivola sopra."),
    ('pietra_spugna', "Pietra spugnosa", 'funghi', ["#3a2a30", "#54404a", "#705862", "#90747e", "#b498a2"], 'fango', 0.25, 0,
     {'soft': 0.3}, "Pietra piena di buchi come una spugna: chi ci cade sopra quasi non si fa male."),
    ('limo', "Limo", 'palude', ["#262a22", "#3a4034", "#50584a", "#6a7462", "#8a967e"], 'fango', 0.2, 0,
     {'cade': True, 'support': 'pietra_spugna', 'stick': 0.75}, "Fango fine e pesante delle paludi: frana e appiccica."),
    ('calcare', "Calcare", 'prati', ["#5a5a62", "#7a7a84", "#9c9ca6", "#c0c0c8", "#e4e4ea"], 'strati', 0.35, 0, {},
     "La pietra chiara sotto i Prati di vento, tenera e facile da lavorare."),
    ('arenaria_rossa', "Arenaria rossa", 'rossa', ["#40160e", "#642418", "#8c3824", "#b45436", "#d8805a"], 'strati', 0.35, 0, {},
     "Pietra rossa a strati sotto le Selve: regge il peso della terra rossa."),
    ('pietra_fossile', "Pietra fossile", 'pietra', ["#3a3630", "#55504a", "#726c64", "#948c82", "#cfc4b0"], 'fossili', 0.4, 0,
     {'fossil': 0.06}, "Pietra piena di ossa antiche: scavandola, ogni tanto ne esce un fossile per il Museo."),
    ('madreperla', "Madreperla di terra", 'iridato', ["#3a3a4a", "#5a5a72", "#7e8aa0", "#a8c0c8", "#f0e8f8"], 'marmo', 0.4, 0,
     {'emit': [0.14, 0.12, 0.2]}, "Roccia lucente dei Prati iridati: brilla appena nel buio."),
    ('roccia_stelle', "Roccia di stelle", 'stellare', ["#0a0a1a", "#16162e", "#24244a", "#383870", "#e8d870"], 'stelle', 0.45, 35,
     {'emit': [0.24, 0.2, 0.08]}, "Una stella caduta e spenta a metà: fa luce da sé."),
    ('marmo_pallido', "Marmo pallido", 'sussurri', ["#6a6a70", "#8c8c92", "#b0b0b4", "#d4d4d6", "#f4f4f6"], 'marmo', 0.45, 0,
     {'quiet': True}, "Il marmo dei Seminatori: i passi ci si spengono sopra."),
]

# le terre comuni: in sacche (lette da `PassMinerali` come le vene), in tutti i biomi
COMMON = [
    ('argilla', "Argilla", ["#5a2e2a", "#7a4038", "#9a5848", "#ba7660", "#d8a088"], 'fango', 0.25, 0, {},
     "Argilla rossa nella terra: al Baccello ardente diventa un'anfora per spostare l'acqua.",
     {'in': [1], 'strata': [0], 'min_depth': 2, 'freq': 0.09, 'threshold': 0.55}),
    ('ghiaia', "Ghiaia", ["#2e3440", "#464e5c", "#62697a", "#828a9a", "#a8b0c0"], 'ghiaia', 0.2, 0,
     {'cade': True, 'support': None}, "Sassi tondi e sciolti: frana, e se ne tirano fuori ciottoli da fionda.",
     {'in': [3], 'strata': [0, 1], 'min_depth': 10, 'freq': 0.1, 'threshold': 0.6}),
    ('pietra_nera', "Pietra nera", ["#06060a", "#101016", "#1c1c24", "#2a2a34", "#3e3e4c"], 'colonne', 0.8, 35,
     {'blast': True}, "Roccia nerissima delle caverne: le esplosioni non la scalfiscono, e ci si fanno rifugi.",
     {'in': [3, 9], 'strata': [2, 3], 'min_depth': 150, 'freq': 0.08, 'threshold': 0.6}),
    ('calcite', "Calcite di Linfa", ["#1a3a3a", "#2a5a58", "#3e807a", "#62aca0", "#a8e8d8"], 'cristallo', 0.5, 35,
     {'emit': [0.08, 0.24, 0.22], 'pass': 0.6}, "Cristalli di calcite imbevuti di Linfa: fanno luce per sempre, senza torce.",
     {'in': [9], 'strata': [3], 'min_depth': 250, 'freq': 0.1, 'threshold': 0.6}),
    ('salgemma', "Salgemma", ["#5a4a52", "#806a74", "#a8909a", "#d0b8c0", "#f4e4ea"], 'cristallo', 0.4, 0, {},
     "Sale di roccia rosato: con un pesce al Paiolo fa una conserva che sazia il doppio.",
     {'in': [3], 'strata': [2], 'min_depth': 120, 'freq': 0.09, 'threshold': 0.62}),
]


# ---------------------------------------------------------------- voce 413: le vene del Risveglio e del dopo

def spine_metals():
    """I dodici metalli di `SpineData.METALS` (letti dal file: restano uguali da soli): id, grado, durezza, grezzo,
    nome del grezzo, tessere che li ospitano, strato, vigore, per quanti vigori."""
    src = open(os.path.join(ROOT, 'src', 'data', 'spine_data.gd'), encoding='utf-8').read()
    out = []
    for m in re.finditer(r'"(\w+)": \{"label".*?"tier": (\d+), "durezza": (\d+).*?"raw": \{"id": "(\w+)", "name": "([^"]+)", '
                         r'"shape": "\w+", "tiles": \[([0-9, ]+)\], "stratum": (\d),\s*"vigor": (\d+)(?:, "keep": (\d+))?', src, re.S):
        g = m.groups()
        out.append({'id': g[0], 'tier': int(g[1]), 'dur': int(g[2]), 'raw': g[3], 'raw_name': g[4],
                    'tiles': [int(x) for x in g[5].split(',')], 'stratum': int(g[6]), 'vigor': int(g[7]),
                    'keep': int(g[8]) if g[8] else 4})
    return out


def icon_pal(name):
    """La tavolozza di un materiale in `ItemIcons` (per le vene: lo stesso colore del lingotto)."""
    src = open(os.path.join(ROOT, 'src', 'art', 'item_icons.gd'), encoding='utf-8').read()
    m = re.search(r'^	"%s": (\[[^\]]*\])' % name, src, re.M)
    return eval(m.group(1))


VEIN_DUR_BEFORE = 85                      # la durezza del metallo stellare (grado 6): serve per la prima vena


def veins(start):
    """Le vene dei metalli della spina e del dopo: visibili, nei mondi del loro vigore, nelle rocce del loro grezzo.
    Prima del Risveglio del Cuore «dormono» (`dorme`: danno solo la roccia, `TileDefs.drop_of`)."""
    tiles, ores = {}, []
    ms = spine_metals()
    prev = VEIN_DUR_BEFORE
    for i, mt in enumerate(ms):
        tid = start + i
        last = i == len(ms) - 1
        tiles[tid] = {'name': 'Vena di %s' % mt['id'], 'hard': round(0.7 + 0.03 * (mt['tier'] - 7), 2), 'power': prev,
                      'drop': mt['raw'], 'pal': icon_pal(mt['id']), 'layer': 'vena_' + mt['id'], 'specks': 0, 'look': 'vena',
                      'kind': 'minerale', 'dorme': True}
        o = {'type': tid, 'min_depth': 20, 'strata': list(range(mt['stratum'], 5)),
             'in': [t for t in mt['tiles'] if t not in (5, 6, 7)] or [3], 'freq': 0.12, 'threshold': 0.6,
             'vmin': mt['vigor'], 'oct': 1}
        if not last:
            o['vmax'] = mt['vigor'] + mt['keep'] - 1
        ores.append(o)
        prev = mt['dur']
    return tiles, ores


# ---------------------------------------------------------------- voce 414: le gemme nella roccia

# id, nome, tavolozza (None = quella che ha già), rocce, strati, forza, nuova?, amuleto, effetto dell'anello, descrizione
GEMS = [
    ('candorina', "Candorina", ["#3a4a5a", "#7a90a8", "#c0d4e8", "#eef6ff", "#ffffff"], [3], [0, 1], 0, True,
     {'linfa_regen': 0.06}, 'aura_gelo', "Gemma bianca come la brina, la prima che si trova: tiene fresca la Linfa."),
    ('muschiata', "Muschiata", ["#0a2a1a", "#16573a", "#2a9a5a", "#6ad890", "#d0ffe0"], [8, 3], [1], 0, True,
     {'grow': 0.05, 'herd': 0.03}, 'spine_vive', "Gemma verde del Sottobosco, nata nelle radici: fa crescere ciò che cura chi la porta."),
    ('sanguinella', "Sanguinella", None, [3, 8], [1, 2], 0, False, None, None, None),
    ('brillaluce', "Brillaluce", None, [3], [2, 3], 35, False, None, None, None),
    ('lagunite', "Lagunite", None, [9], [3], 45, False, None, None, None),
    ('fiammina', "Fiammina", ["#3a1004", "#8a2a08", "#e0601a", "#ffb040", "#fff0b0"], [9, 10], [3, 4], 45, True,
     {'atk_speed': 0.03}, 'braciere_addosso', "Gemma arancio dove lo scisto tocca la vuotite: dentro ci arde una brace."),
    ('nottilite', "Nottilite", None, [10], [4], 55, False, None, None, None),
    ('ombrina', "Ombrina", ["#06060a", "#1a1a26", "#34344a", "#5a5a78", "#a0a0c8"], [10], [4], 55, True,
     {'dig': 0.05, 'luck': 0.01}, 'ombra_ferito', "Gemma fumosa del Fondo: chi la porta scava più in fretta e trova di più."),
]


def gems(start):
    """Otto gemme in vena: le quattro dei grappoli di prima e quattro nuove (con amuleti e anelli: campo «gems», unito a
    `JewelsData.GEMS`)."""
    tiles, ores, items, jew, pals = {}, [], {}, {}, {}
    icons = open(os.path.join(ROOT, 'src', 'art', 'item_icons.gd'), encoding='utf-8').read()
    for i, (gid, name, pal, hosts, strata, power, new, amulet, effect, desc) in enumerate(GEMS):
        tid = start + i
        p = pal or icon_pal(gid)
        tiles[tid] = {'name': 'Roccia di %s' % name.lower(), 'hard': 0.6, 'power': power, 'drop': gid, 'pal': p,
                      'layer': 'gemma_' + gid, 'specks': 0, 'look': 'gemma', 'kind': 'gemma', 'glow': True}
        ores.append({'type': tid, 'min_depth': 6, 'strata': strata, 'in': hosts, 'freq': 0.22, 'threshold': 0.77, 'oct': 1})
        if new:
            items[gid] = {'name': name, 'kind': 'materiale', 'icon': ['gemma', gid], 'desc': desc}
            jew[gid] = {'name': name.lower(), 'amulet': amulet, 'effect': effect}
            pals[gid] = p
    return tiles, ores, items, jew, pals


# ---------------------------------------------------------------- voce 415: i blocchi con una fisica e le corde

# id, nome, tavolozza, disegno, durezza, comportamento, ricetta (quanti, ingredienti, banco), quadrato, descrizione
BLOCKS = [
    ('cuscino_bava', "Cuscino di bava", ["#0e3a34", "#1e6a5a", "#3aa088", "#7ad8bc", "#d8fff0"], 'gel', 0.2,
     {'bounce': 0.85}, (2, {'gelatina': 3}, 'ceppo'), False,
     "Un blocco molle e lucido: chi ci cade sopra rimbalza in alto, senza farsi male."),
    ('resina_appiccicosa', "Resina appiccicosa", ["#3a2208", "#7a4a10", "#c08020", "#f0b840", "#fff0b0"], 'gel', 0.25,
     {'stick': 0.3}, (4, {'resina_dolce': 1, 'gelatina': 1}, 'ceppo'), False,
     "Resina che non si stacca: chi ci cammina sopra quasi si ferma, creature comprese. Per i corridoi delle difese."),
    ('grata_radice', "Grata di radice", ["#2a1a14", "#4a2e20", "#6e4630", "#946444", "#c08a60"], 'grata', 0.25,
     {'liq': True, 'pass': 0.9}, (4, {'legno': 2, 'fibra_radice': 1}, 'ceppo'), True,
     "Radici intrecciate a rete: ci si cammina sopra, ma l'acqua, la Linfa e la brace ci passano attraverso."),
    ('ghiaccio_levigato', "Ghiaccio levigato", ["#2a5070", "#4a80a8", "#7ab0d4", "#b8e0f4", "#f4fcff"], 'ghiaccio', 0.3,
     {'slip': 0.06, 'pass': 0.85}, (2, {'ghiaccio_brina': 2}, 'mola'), True,
     "Ghiaccio passato alla mola: liscio come l'aria, ci si scivola lontanissimo."),
    ('lastra_fragile', "Lastra fragile", ["#3a3430", "#5a524a", "#7a7066", "#9a9084", "#c0b6a8"], 'crepe', 0.12,
     {'fragile': 0.7}, (4, {'tufo': 2}, 'ceppo'), True,
     "Pietra piena di crepe: poco dopo che qualcosa ci sale sopra, crolla. Per le trappole a buca."),
    ('rovo_murato', "Rovo murato", ["#1a2410", "#2e3e1a", "#4a5e28", "#6e8a3a", "#b8d070"], 'spine', 0.35,
     {'spike': 12}, (2, {'fibra_radice': 3, 'ardesia': 2}, 'ceppo'), False,
     "Un blocco irto di spine: punge le creature che lo toccano. Al Germogliato non fa niente."),
    ('pietra_calda', "Pietra calda", ["#2a0e08", "#5a1e10", "#9a3a18", "#e0702a", "#ffd080"], 'brace', 0.5,
     {'warm': True, 'emit': [0.3, 0.12, 0.04]}, (2, {'basalto': 2, 'cenere_calda': 2}, 'baccello_ardente'), False,
     "Basalto che tiene la brace: scalda chi le sta vicino nel freddo, e fa un po' di luce."),
]

# le corde: decorazioni su cui ci si arrampica (`TileDefs.CLIMB_SPEED`), numero di decorazione, velocità, ricetta
CLIMBS = [
    ('corda', "Corda di fibra", 98, 1.0, ['seta', 'legno'], (6, {'fibra_radice': 2}, ''),
     "Clic: la appendi sotto un blocco; clic sulla corda la allunghi. Ci si arrampica tenendo Salto, si scende con Giù."),
    ('liana', "Liana", 99, 0.8, ['seta', 'muschio'], None,
     "Pende dai soffitti del Sottobosco: si arrampica come una corda, un po' più piano. Si riprende e si appende altrove."),
    ('catena', "Catena di legnoferro", 100, 1.5, ['seta', 'legnoferro'], (6, {'lingotto_legnoferro': 1}, 'maglio'),
     "Una catena di anelli: ci si arrampica una volta e mezza più in fretta che su una corda."),
]


# ---------------------------------------------------------------- voce 416: le passerelle

# tipo (il byte di `World.plats`; 1 è la Passerella di radice di sempre), id, nome, tavolozza, comportamento, ricetta,
# descrizione. Comportamenti: soft (quanto resta della ferita di una caduta), bounce, spike (alle creature), slip, jump.
PLATS = [
    (2, 'passerella_nuvola', "Passerella di nuvola", ["#7a90b0", "#b8cce4", "#e0ecf8", "#ffffff"], {'soft': 0.0},
     (2, {'nuvola': 2}, 'ceppo'), "Una passerella morbida come una nuvola: chi ci cade sopra non si fa niente."),
    (3, 'passerella_bava', "Passerella di bava", ["#1e6a5a", "#3aa088", "#7ad8bc", "#d8fff0"], {'bounce': 0.8},
     (2, {'gelatina': 1, 'legno': 1}, 'ceppo'), "Una passerella elastica: chi ci cade sopra rimbalza in alto."),
    (4, 'passerella_rovo', "Passerella di rovo", ["#2e3e1a", "#4a5e28", "#6e8a3a", "#b8d070"], {'spike': 8},
     (2, {'fibra_radice': 2, 'legno': 1}, 'ceppo'), "Una passerella irta di spine: punge le creature che ci camminano."),
    (5, 'passerella_ghiaccio', "Passerella di ghiaccio", ["#3e6a90", "#7ab0d4", "#b8e0f4", "#f4fcff"], {'slip': 0.1},
     (2, {'ghiaccio_brina': 1}, 'ceppo'), "Una passerella di ghiaccio: ci si scivola sopra lontano."),
    (6, 'passerella_vento', "Passerella del vento", ["#8a7a3a", "#c8b060", "#f0e0a0", "#fffff0"], {'jump': 1.45},
     (2, {'legno': 1, 'nuvola_tempesta': 1}, 'ceppo'), "Una passerella che soffia verso l'alto: saltandoci sopra si sale molto di più."),
]


def plats():
    out, items, recipes = {}, {}, []
    for kind, pid, name, pal, phys, rec, desc in PLATS:
        d = {'item': pid, 'name': name, 'pal': pal}
        d.update(phys)
        out[kind] = d
        items[pid] = {'name': name, 'kind': 'piattaforma', 'icon': ['piattaforma', pid], 'plat': kind, 'desc': desc}
        recipes.append({'out': pid, 'qty': rec[0], 'in': rec[1], 'station': rec[2]})
    return out, items, recipes


def blocks(start):
    tiles, items, recipes, pals = {}, {}, [], {}
    for i, (bid, name, pal, look, hard, phys, rec, square, desc) in enumerate(BLOCKS):
        tid = start + i
        t = {'name': name, 'hard': hard, 'power': 0, 'drop': bid, 'pal': pal, 'layer': 'blocco_' + bid, 'specks': 0,
             'look': look, 'kind': 'blocco'}
        if square:
            t['square'] = True
        t.update(phys)
        tiles[tid] = t
        items[bid] = {'name': name, 'kind': 'blocco', 'icon': ['zolla', bid], 'place': tid, 'desc': desc}
        pals[bid] = pal
        recipes.append({'out': bid, 'qty': rec[0], 'in': rec[1], 'station': rec[2]})
    climbs = {}
    for cid, name, decor, speed, icon, rec, desc in CLIMBS:
        items[cid] = {'name': name, 'kind': 'corda', 'icon': icon, 'stack': 999, 'decor': decor, 'desc': desc}
        climbs[decor] = {'item': cid, 'speed': speed}
        if rec:
            recipes.append({'out': cid, 'qty': rec[0], 'in': rec[1], 'station': rec[2]})
    return tiles, items, recipes, pals, climbs


def _tile(tid, iid, name, pal, look, hard, power, phys, kind, ids):
    t = {'name': name, 'hard': hard, 'power': power, 'drop': iid, 'pal': pal, 'layer': 'terra_' + iid,
         'specks': 0, 'look': look, 'kind': kind}
    for k, v in phys.items():
        if k == 'support':
            if v:
                t['support'] = ids[v]
        else:
            t[k] = v
    return t


def build():
    tiles, items, recipes, soils, ores, pals = {}, {}, [], {}, [], {}
    order = [r[0] for r in SOILS] + [r[0] for r in ROCKS] + [r[0] for r in COMMON]
    ids = {iid: T0 + i for i, iid in enumerate(order)}
    for iid, name, biome, pal, look, hard, power, phys, desc in SOILS:
        tiles[ids[iid]] = _tile(ids[iid], iid, name, pal, look, hard, power, phys, 'suolo', ids)
        soils.setdefault(biome, {})['suolo'] = ids[iid]
        items[iid] = {'name': name, 'kind': 'blocco', 'icon': ['zolla', iid], 'place': ids[iid], 'terra': True,
                      'desc': desc}
        pals[iid] = pal
    for iid, name, biome, pal, look, hard, power, phys, desc in ROCKS:
        tiles[ids[iid]] = _tile(ids[iid], iid, name, pal, look, hard, power, phys, 'roccia', ids)
        soils.setdefault(biome, {})['roccia'] = ids[iid]
        items[iid] = {'name': name, 'kind': 'blocco', 'icon': ['zolla', iid], 'place': ids[iid], 'desc': desc}
        pals[iid] = pal
    soils.setdefault('torba', {})['roccia'] = ids['argilla']
    for iid, name, pal, look, hard, power, phys, desc, ore in COMMON:
        tiles[ids[iid]] = _tile(ids[iid], iid, name, pal, look, hard, power, phys, 'comune', ids)
        items[iid] = {'name': name, 'kind': 'blocco', 'icon': ['zolla', iid], 'place': ids[iid], 'desc': desc}
        if iid == 'argilla':
            items[iid]['terra'] = True
        pals[iid] = pal
        o = dict(ore)
        o['type'] = ids[iid]
        o['oct'] = 1                      # le sacche: un'ottava di rumore basta (la passata costa metà)
        ores.append(o)
    vt, vo = veins(T0 + len(order))
    tiles.update(vt)
    ores += vo
    gt, go, gi, gj, gp = gems(T0 + len(order) + len(vt))
    tiles.update(gt)
    ores += go
    items.update(gi)
    pals.update(gp)
    pl, pi, pr = plats()
    items.update(pi)
    recipes += pr
    for kind, pid, name, pal, phys, rec, desc in PLATS:
        pals[pid] = pal
    bt, bi, br, bp, climbs = blocks(T0 + len(order) + len(vt) + len(gt))
    tiles.update(bt)
    items.update(bi)
    recipes += br
    pals.update(bp)
    # gli usi: le seconde strade per cose che ci sono già, e tre cose nuove (concime, anfora d'argilla, conserva)
    items['concime'] = {'name': "Concime", 'kind': 'concime', 'icon': ['polvere', 'terra_grassa'], 'stack': 99,
                        'desc': "Clic su una coltura: cresce di colpo, come se fosse passato un terzo del tempo che le manca."}
    items['anfora_argilla'] = {'name': "Anfora d'argilla", 'kind': 'contenitore', 'cap': 10, 'icon': ['vasetto', 'argilla'],
                               'stack': 1, 'desc': "Raccoglie fino a dieci celle di un liquido e le versa dove vuoi. La prima che si può fare."}
    items['pesce_sotto_sale'] = {'name': "Pesce sotto sale", 'kind': 'consumabile', 'icon': ['ciotola', 'salgemma'],
                                 'heal': 15, 'boon': ['sazio', 2400.0], 'boons': [['sazio', 2400.0]], 'stack': 30,
                                 'desc': "Cura 15 Vita; sazio per 40 minuti, il doppio di un piatto qualunque."}
    recipes += [
        {'out': 'vetro_resina', 'qty': 2, 'in': {'sabbia_ambra': 3}, 'station': 'baccello_ardente'},
        {'out': 'vetro_resina', 'qty': 3, 'in': {'sabbia_tagliente': 3}, 'station': 'baccello_ardente'},
        {'out': 'torcia', 'qty': 4, 'in': {'legno': 1, 'cenere_calda': 2}, 'station': ''},
        {'out': 'mattoni_ardesia', 'qty': 3, 'in': {'terra_rossa': 4}, 'station': 'baccello_ardente'},
        {'out': 'ciottolo', 'qty': 1, 'in': {'polvere_pietra': 4}, 'station': 'ceppo'},
        {'out': 'ciottolo', 'qty': 1, 'in': {'ghiaia': 2}, 'station': ''},
        {'out': 'concime', 'qty': 3, 'in': {'@terra': 5, '@raccolto': 1}, 'station': 'ceppo'},
        {'out': 'anfora_argilla', 'qty': 1, 'in': {'argilla': 8}, 'station': 'baccello_ardente'},
        {'out': 'pesce_sotto_sale', 'qty': 2, 'in': {'salgemma': 2, '@pesce': 1}, 'station': 'paiolo'},
    ]
    return [('terre.gd', 'Roadmap 52, voci 412-416: le terre dei biomi, le rocce e le terre comuni con i loro usi, le vene',
             {'tiles': tiles, 'veins': ores, 'soils': soils, 'icon_pals': pals, 'gems': gj, 'climbs': climbs, 'plats': pl, 'items': items, 'recipes': recipes})]
