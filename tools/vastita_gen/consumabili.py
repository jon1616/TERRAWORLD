"""Consumabili, pesca e cucina (Roadmap 46, voci 398-400; piano in VASTITA.md).

- **Le pozioni** (voce 398): quaranta linee di effetti a tempo (corsa, salto, scavo, respiro, pesca, mandria, gli otto
  stili, i ripari dei rigori, le viste dei tesori, delle creature e delle trappole…) in tre gradi, minore, normale e
  maggiore: più forti e più lunghe salendo, con ingredienti di fasi più alte (dall'elenco `materiali.json`, scritto da
  `tools/materiali.gd`). Gli effetti sono dati (campo «boons»: "acc" come gli accessori, "effects", "special"), li
  applica `Boons` con `GearEffects` ed `Effects`. Le **pozioni di cura** in sei gradi (la Vita massima cresce con la
  partita: la pozione da 50 non bastava più). Le **fiale per l'arma** (si versano sull'arma: per qualche minuto i colpi
  bruciano, gelano, avvelenano…). Le **pozioni di stazione**: si posano e si toccano, un effetto lungo un'ora.
- **Il cibo a gradi** (voce 399): novanta piatti nuovi dell'orto, della mandria e della pesca, in tre gradi di sazietà
  (Sazio, Ben nutrito, Rifocillato: più forti con ingredienti più avanti) con un effetto in più.
- **Le casse da pesca** (voce 400): una per bioma (abboccano nel suo stagno: due oggetti suoi) e quattro per grado del
  mondo; **i premi del Pescatore** a collezione delle gare vinte.
"""
import json
import os

from vastita_gen.accessori import ABILITIES
from vastita_gen.rari import FORMS, WEAPON_FX, _acc
from vastita_gen.ritrovamenti import PAL as BIOME_PAL, _biomes, _of

HERE = os.path.dirname(__file__)
GRADES = [('minore', 0), ('', 1), ('maggiore', 2)]
SECS = [300, 600, 900]
# le linee: (id, nome, acc al grado 0 / passo per grado, special, tavolozza)
LINES = [
    ('corsa', 'della corsa', {'run': (1.12, 0.06)}, '', 'vento'),
    ('salto', 'del salto', {'jump': (1.12, 0.06)}, '', 'nuvola'),
    ('alone', 'dell\'alone', {'halo': (1.3, 0.2)}, '', 'brillaluce'),
    ('ricrescita', 'della ricrescita', {'regen': (1.4, 0.3)}, '', 'muschio'),
    ('scavo', 'dello scavatore', {'dig': (1.25, 0.15)}, '', 'ardesia'),
    ('ombra', 'dell\'ombra', {'stealth': (0.8, -0.1)}, '', 'nottilite'),
    ('forza', 'della forza', {'damage': (1.08, 0.04)}, '', 'sanguinite'),
    ('rapidita', 'della rapidità', {'atk_speed': (1.08, 0.04)}, '', 'eterite'),
    ('linfa', 'della Linfa che torna', {'linfa_regen': (1.4, 0.3)}, '', 'lagunite'),
    ('incanto', 'dell\'incanto', {'magic': (1.08, 0.04)}, '', 'cristallo'),
    ('respiro', 'del respiro lungo', {'respiro': (1.6, 0.6)}, '', 'linfa'),
    ('pesca', 'del pescatore', {'fish_wait': (0.85, -0.07), 'fish_luck': (0.1, 0.08)}, '', 'seta'),
    ('crescita', 'della crescita', {'grow': (1.2, 0.15)}, '', 'fungo'),
    ('mandria', 'della mandria', {'herd': (1.2, 0.15)}, '', 'radice'),
    ('scatto', 'dello scatto', {'dash': (True, 0), 'dash_cd': (0.85, -0.07)}, '', 'pallidite'),
    ('mischia', 'del guerriero', {'st_mischia': (1.08, 0.05)}, '', 'radicite'),
    ('distanza', 'dell\'arciere', {'st_distanza': (1.08, 0.05)}, '', 'legnoferro'),
    ('st_linfa', 'del sapiente', {'st_linfa': (1.08, 0.05)}, '', 'iride'),
    ('evocazione', 'del branco', {'st_evocazione': (1.08, 0.05)}, '', 'humus'),
    ('lancio', 'del lanciatore', {'st_lancio': (1.08, 0.05)}, '', 'tempesta'),
    ('canto', 'del cantore', {'st_canto': (1.08, 0.05)}, '', 'lucciola'),
    ('cura', 'della rugiada', {'st_cura': (1.08, 0.05)}, '', 'brina'),
    ('radice', 'del seminatore', {'st_radice': (1.08, 0.05)}, '', 'legno'),
    ('fortuna', 'della buona sorte', {'luck': (0.15, 0.1)}, '', 'ambra'),
    ('rovo', 'del rovo', {'thorns': (8, 6)}, '', 'nodo'),
    ('guscio', 'del guscio', {'defense': (4, 3)}, '', 'scisto'),
    ('balzo', 'del balzo', {'air_jumps': (1, 0)}, '', 'celeste'),
    ('piuma', 'della piuma', {'glide': (True, 0), 'fall_safe': (True, 0)}, '', 'nuvola'),
    ('ragno', 'del ragno', {'wall': (True, 0)}, '', 'fungo'),
    ('caldo', 'del fresco', {'caldo': (0.5, 0.25)}, '', 'brina'),
    ('freddo', 'del tepore', {'fresco': (0.5, 0.25)}, '', 'brace'),
    ('filtro', 'del respiro puro', {'filtro': (0.5, 0.25)}, '', 'cenere'),
    ('quota', 'dell\'aria alta', {'quota': (0.5, 0.25)}, '', 'cielo'),
    ('sete', 'della fonte', {'acqua': (0.5, 0.25)}, '', 'linfa'),
    ('passo', 'del passo sicuro', {'passo': (True, 0), 'run': (1.04, 0.02)}, '', 'stelle'),
    ('pesce_grande', 'delle prede grandi', {'fish_size': (0.1, 0.08)}, '', 'lagunite'),
    ('vento', 'del vento amico', {'vento': (0.7, -0.15)}, '', 'vento'),
    ('tesori', 'dei tesori', {}, 'tesori', 'ambra'),
    ('creature', 'delle creature', {}, 'creature', 'sanguinella'),
    ('trappole', 'delle trappole', {}, 'trappole', 'tizzonite'),
]
WORDS = {'run': 'corsa', 'jump': 'salto', 'halo': 'alone', 'regen': 'la Vita ricresce', 'dig': 'scavo',
         'stealth': 'le creature ti vedono', 'damage': 'danno', 'atk_speed': 'colpi più rapidi',
         'linfa_regen': 'la Linfa ricresce', 'magic': 'incantesimi', 'respiro': 'respiro', 'fish_wait': 'attesa della pesca',
         'fish_luck': 'fortuna della pesca', 'grow': 'crescita dell\'orto', 'herd': 'esperienza della mandria',
         'dash': 'la schivata', 'dash_cd': 'attesa della schivata', 'st_mischia': 'danno in mischia',
         'st_distanza': 'danno a distanza', 'st_linfa': 'danno della Linfa', 'st_evocazione': 'danno degli alleati',
         'st_lancio': 'danno dei lanci', 'st_canto': 'danno del canto', 'st_cura': 'danno e cure della Rugiada',
         'st_radice': 'danno delle piante', 'luck': 'fortuna', 'thorns': 'spine', 'defense': 'Scorza',
         'air_jumps': 'salti in aria', 'glide': 'planata', 'fall_safe': 'nessun danno dalle cadute', 'wall': 'ti arrampichi sulle pareti',
         'caldo': 'riparo dal caldo', 'fresco': 'riparo dal freddo', 'filtro': 'riparo dalla polvere',
         'quota': 'riparo dall\'aria sottile', 'acqua': 'riparo dalla sete', 'passo': 'passo sicuro sulle terre dure',
         'fish_size': 'pesci più grandi', 'vento': 'il vento ti spinge'}
SPECIAL_WORDS = {'tesori': 'gli scrigni e le casse vicine brillano nel buio e compaiono sulla mappa',
                 'creature': 'le creature vicine brillano nel buio',
                 'trappole': 'le trappole e i pericoli vicini brillano nel buio e compaiono sulla mappa'}
ADD = ('luck', 'thorns', 'defense', 'air_jumps', 'caldo', 'fresco', 'filtro', 'quota', 'acqua', 'fish_luck', 'fish_size')
HEAL = [('pozione_cura_forte', 'Pozione di cura forte', 120, 5), ('pozione_cura_grande', 'Pozione di cura grande', 170, 9),
        ('pozione_cura_viva', 'Pozione di cura viva', 240, 13), ('pozione_cura_cuore', 'Pozione del Cuore', 330, 17),
        ('pozione_cura_prima', 'Pozione della prima Linfa', 450, 21)]
FLASKS = [('brace', 'brucia', {'do': 'brucia', 't': 3.0}, 'tizzonite', 'i colpi bruciano'),
          ('gelo', 'gela', {'do': 'gela', 't': 2.5}, 'brina', 'i colpi gelano'),
          ('veleno', 'avvelena', {'do': 'avvelena', 't': 5.0}, 'fungo', 'i colpi avvelenano'),
          ('linfa', 'cura', {'do': 'cura', 'frac': 0.05}, 'lagunite', 'ogni colpo ti cura un poco'),
          ('luce', 'pioggia', {'do': 'pioggia', 'shards': 2, 'dmg': 0.3}, 'brillaluce', 'a volte cadono stelle'),
          ('vuoto', 'vulnera', {'do': 'vulnera', 't': 3.0}, 'vuotite', 'i colpi rendono fragili'),
          ('spora', 'sanguina', {'do': 'sanguina', 'dps': 0.15, 't': 4.0}, 'nodo', 'i colpi fanno sanguinare')]
STATIONS = [('fonte_vigore', 'Fonte del vigore', 'forza', '#ff8a6a'), ('fonte_passo', 'Fonte del passo', 'corsa', '#8ad8ff'),
            ('fonte_rugiada', 'Fonte della rugiada', 'ricrescita', '#9fe070'), ('fonte_linfa_viva', 'Fonte della Linfa viva', 'linfa', '#5cf0d8'),
            ('fonte_sorte', 'Fonte della sorte', 'fortuna', '#ffd060'), ('fonte_guscio', 'Fonte del guscio', 'guscio', '#c0a080'),
            ('fonte_pescatore', 'Fonte del pescatore', 'pesca', '#70c0f0'), ('fonte_tesori', 'Fonte dei tesori', 'tesori', '#f0c060')]


def _mats():
    return json.load(open(os.path.join(HERE, 'materiali.json'), encoding='utf-8'))


def _val(k, base, step, g):
    if isinstance(base, bool):
        return True
    v = base + step * g
    if k in ADD:
        return round(v, 3) if isinstance(v, float) and k not in ('thorns', 'defense', 'air_jumps') else float(round(v))
    return round(v, 3)


def _words(acc):
    out = []
    for k, v in acc.items():
        w = WORDS[k]
        if v is True:
            out.append(w)
        elif k in ('thorns', 'defense', 'air_jumps'):
            out.append('%s +%d' % (w, v))
        elif k in ADD:
            out.append('%s +%d%%' % (w, round(v * 100)))
        else:
            out.append('%s %+d%%' % (w, round((v - 1.0) * 100)))
    return ', '.join(out)


def _ingredients(mats):
    """Gli ingredienti delle pozioni per grado: materiali (non cibi, non pozioni) delle fasi giuste."""
    pools = [[], [], []]
    for mid, d in sorted(mats.items()):
        if d['kind'] != 'materiale' or d['boon'] or d['heal'] or mid.startswith(('essenza_', 'lingotto_', 'segreto_', 'cassa_')):
            continue
        p = int(d['phase'])
        if 1 <= p <= 4:
            pools[0].append(mid)
        elif 5 <= p <= 10:
            pools[1].append(mid)
        elif 11 <= p <= 20:
            pools[2].append(mid)
    return pools


def build():
    mats = _mats()
    pools = _ingredients(mats)
    items, recipes, effects, boons, stations, loot = {}, [], {}, {}, {}, {}
    # 1. le pozioni a tempo
    for li, (lid, lname, acc0, special, pal) in enumerate(LINES):
        for g, (gw, gk) in enumerate(GRADES):
            bid = 'bz_%s_%d' % (lid, g)
            acc = {k: _val(k, v[0], v[1], g) for k, v in acc0.items()}
            nm = 'Pozione %s%s' % (lname, (' ' + gw) if gw else '')
            words = SPECIAL_WORDS[special] if special else _words(acc)
            boons[bid] = {'name': nm, 'acc': acc}
            if special:
                boons[bid]['special'] = special
            iid = 'pz_%s_%d' % (lid, g)
            items[iid] = {'name': nm, 'kind': 'consumabile', 'icon': ['pozione', pal], 'boon': [bid, float(SECS[g])], 'stack': 30,
                          'desc': 'Per %d minuti: %s.' % (SECS[g] // 60, words)}
            pool = pools[g]
            a = pool[(li * 7 + g * 3) % len(pool)]
            b = pool[(li * 11 + g * 5 + 3) % len(pool)]
            ins = {'gelatina': 1}
            ins[a] = 2
            if b != a:
                ins[b] = 1
            if g == 2:
                ins['linfa_antica'] = 1
            recipes.append({'out': iid, 'qty': 2, 'in': ins, 'station': 'alambicco'})
    # 2. le pozioni di cura in gradi
    for k, (iid, nm, heal, ph) in enumerate(HEAL):
        g = 0 if ph <= 4 else (1 if ph <= 10 else 2)
        pool = pools[g]
        a = pool[(k * 13 + 1) % len(pool)]
        items[iid] = {'name': nm, 'kind': 'consumabile', 'icon': ['pozione', ['sanguinella', 'radicite', 'sanguinite', 'primambra', 'iride'][k]],
                      'heal': heal, 'stack': 30, 'fase': ph,
                      'desc': 'Ridà %d Vita, subito (poi un po\' di attesa prima di un\'altra pozione).' % heal}
        ins = {a: 2, 'gelatina': 1}
        if k == 0:
            ins['pozione_radice'] = 1
        else:
            ins[HEAL[k - 1][0]] = 1
        recipes.append({'out': iid, 'qty': 2, 'in': ins, 'station': 'alambicco'})
    # 3. le fiale per l'arma
    for fi, (fid, what, e, pal, words) in enumerate(FLASKS):
        for g in range(2):
            bid = 'bz_fiala_%s_%d' % (fid, g)
            eid = 'fiala_%s_%d' % (fid, g)
            eff = dict(e)
            eff['when'] = 'colpo'
            eff['chance'] = 0.35 + 0.25 * g
            eff['name'] = 'Fiala %s' % fid
            eff['desc'] = '%s (%d%% dei colpi)' % (words, round(eff['chance'] * 100))
            effects[eid] = eff
            boons[bid] = {'name': 'Arma unta: %s' % fid, 'acc': {}, 'effects': [eid]}
            iid = 'fiala_arma_%s_%d' % (fid, g)
            items[iid] = {'name': 'Fiala %s%s' % ({'brace': 'di brace', 'gelo': 'di gelo', 'veleno': 'di veleno', 'linfa': 'di Linfa',
                                                   'luce': 'di luce', 'vuoto': 'di vuoto', 'spora': 'di spore'}[fid],
                                                  ' forte' if g else ''),
                          'kind': 'consumabile', 'icon': ['goccia', pal], 'boon': [bid, float(300 + 300 * g)], 'stack': 30,
                          'desc': 'Si versa sull\'arma: per %d minuti %s (%d%% dei colpi).' % (5 + 5 * g, words, round(eff['chance'] * 100))}
            pool = pools[g + 1 if g else 0]
            a = pool[(fi * 17 + g) % len(pool)]
            recipes.append({'out': iid, 'qty': 2, 'in': {a: 2, 'gelatina': 2}, 'station': 'alambicco'})
    # 4. le pozioni di stazione: un'ora, toccandole
    for si, (sid, nm, line, color) in enumerate(STATIONS):
        bid = 'bz_%s_2' % line
        stations[sid] = {'name': nm, 'size': [1, 2], 'item': sid, 'light': True, 'boon': [bid, 3600.0], 'brew': color}
        items[sid] = {'name': nm, 'kind': 'stazione', 'icon': ['pozione', 'iride'], 'place': sid, 'stack': 5,
                      'desc': 'Una fonte da posare: toccandola, per un\'ora l\'effetto della %s.' % items['pz_%s_2' % line]['name']}
        pool = pools[2]
        recipes.append({'out': sid, 'qty': 1, 'in': {'pz_%s_2' % line: 5, pool[(si * 19) % len(pool)]: 4, 'linfa_antica': 2},
                        'station': 'alambicco'})
    # 5. il cibo a gradi
    dishes = _dishes(mats)
    for did, d in dishes.items():
        items[did] = d['item']
        recipes.append(d['recipe'])
    boons['ben_nutrito'] = {'name': 'Ben nutrito', 'acc': {'damage': 1.08, 'run': 1.08, 'regen': 1.4, 'defense': 2.0}}
    boons['rifocillato'] = {'name': 'Rifocillato', 'acc': {'damage': 1.12, 'run': 1.1, 'regen': 1.6, 'defense': 4.0,
                                                           'atk_speed': 1.05}}
    # 6. le casse da pesca dei biomi e dei gradi
    crates, angler = _crates(items, effects, loot)
    return [('consumabili.gd', 'Roadmap 46, voci 398-400: pozioni, fiale, fonti, piatti a gradi, casse da pesca',
             {'items': items, 'recipes': recipes, 'effects': effects, 'boons': boons, 'stations': stations, 'loot': loot,
              'crates': crates, 'angler': angler})]


def _dishes(mats):
    crops = sorted(k for k, d in mats.items() if d['crop'])
    fish = sorted(k for k, d in mats.items() if d['fish'])
    herd = sorted(k for k, d in mats.items() if d['herd'])
    forms = [('Zuppa di %s e %s', 'zuppa'), ('Spiedo di %s con %s', 'spiedo'), ('Stufato di %s e %s', 'stufato'),
             ('Torta di %s e %s', 'torta'), ('Insalata di %s e %s', 'insalata'), ('Brodo di %s con %s', 'brodo')]
    extra_boons = ['bz_corsa_0', 'bz_scavo_0', 'bz_respiro_0', 'bz_pesca_0', 'bz_forza_0', 'bz_ricrescita_0', 'bz_alone_0',
                   'bz_linfa_0', 'bz_guscio_0', 'bz_fortuna_0', 'bz_caldo_0', 'bz_freddo_0', 'bz_quota_0', 'bz_sete_0']
    out = {}
    used = set()
    k = 0
    n = 0
    while n < 90 and k < 5000:
        k += 1
        a = (fish + herd)[(k * 7) % len(fish + herd)]
        b = crops[(k * 13 + k // 7) % len(crops)]
        if (a, b) in used:
            continue
        used.add((a, b))
        pa, pb = int(mats[a]['phase']), int(mats[b]['phase'])
        ph = max(pa, pb)
        g = 0 if ph <= 4 else (1 if ph <= 9 else 2)
        tpl, short = forms[k % len(forms)]
        nm = tpl % (mats[a]['name'][0].lower() + mats[a]['name'][1:], mats[b]['name'][0].lower() + mats[b]['name'][1:])
        did = 'piatto_%s_%d' % (short, n)
        sat = ['sazio', 'ben_nutrito', 'rifocillato'][g]
        sat_name = ['sazio', 'ben nutrito', 'rifocillato'][g]
        eb = extra_boons[k % len(extra_boons)]
        bl = [[sat, 1200.0 + 300 * g], [eb, 600.0]]
        heal = [20, 45, 80][g]
        out[did] = {'item': {'name': nm, 'kind': 'consumabile', 'icon': ['ciotola', ['muschio', 'ambra', 'primambra'][g]],
                             'heal': heal, 'boon': bl[0], 'boons': bl, 'stack': 30, 'fase': ph,
                             'desc': 'Cura %d Vita; %s per %d minuti, e un effetto in più per dieci.' % (heal, sat_name, (1200 + 300 * g) // 60)},
                    'recipe': {'out': did, 'qty': 1, 'in': {a: 1, b: 2}, 'station': 'paiolo', 'ricettario': True}}
        n += 1
    return out


def _crates(items, effects, loot):
    crates = []
    for bi, (bid, name, elem, color, where) in enumerate(_biomes()):
        if where != 'superficie':
            continue
        ofb = _of(bid, name)
        pal = BIOME_PAL[bid]
        cid = 'cassa_pesca_' + bid
        rows = []
        # un accessorio della pesca con un'abilità, e un arpione
        k = bi * 3 + 2
        when, e, aw = ABILITIES[(bi * 5 + 7) % len(ABILITIES)]
        acc, words = _acc(['luck', 'regen'], 6)
        acc['fish_luck'] = round(0.08 + 0.01 * (bi % 5), 3)
        iid = 'pesca_%s_amuleto' % bid
        eff = dict(e)
        eff['when'] = when
        if 'chance' not in eff and when in ('colpo', 'ferita'):
            eff['chance'] = 1.0
        eff['name'] = 'Amo %s' % ofb
        eff['desc'] = aw
        effects[iid + '_e0'] = eff
        items[iid] = {'name': 'Amo d\'osso %s' % ofb, 'kind': 'amuleto', 'icon': ['amuleto', pal], 'fase': 6, 'acc': acc,
                      'effects': [iid + '_e0'], 'source': 'nella cassa da pesca %s' % ofb,
                      'desc': '%s, fortuna della pesca +%d%%. %s.' % (words[0].upper() + words[1:], round(acc['fish_luck'] * 100),
                                                                   aw[0].upper() + aw[1:])}
        rows.append({'item': iid, 'min': 1, 'max': 1, 'chance': 1.0, 'group': 'pesca'})
        wid = 'pesca_%s_arpione' % bid
        fx = WEAPON_FX[(bi * 3 + 1) % len(WEAPON_FX)]
        eff = dict(fx[1])
        eff['when'] = fx[0]
        eff['name'] = 'Arpione %s' % ofb
        eff['desc'] = fx[2]
        effects[wid + '_e0'] = eff
        items[wid] = {'name': 'Arpione %s' % ofb, 'kind': 'spada', 'form': 'lancia', 'fase': 5, 'firma': True,
                      'icon': ['lancia', pal], 'effects': [wid + '_e0'], 'source': 'nella cassa da pesca %s' % ofb,
                      'desc': 'L\'arpione dei pescatori %s: %s.' % (ofb, fx[2])}
        rows.append({'item': wid, 'min': 1, 'max': 1, 'chance': 1.0, 'group': 'pesca'})
        rows.append({'item': 'lumino', 'min': 10, 'max': 30, 'chance': 1.0})
        rows.append({'item': 'perla_stagno', 'min': 1, 'max': 2, 'chance': 0.4})
        loot[cid] = rows
        items[cid] = {'name': 'Cassa da pesca %s' % ofb, 'kind': 'cassetta', 'icon': ['cesta', pal], 'stack': 30, 'crate': [1, 2],
                      'table': cid, 'source': 'pescando negli stagni %s, al posto di un pesce' % ofb,
                      'desc': 'Pescata negli stagni %s: due oggetti che si trovano solo qui. Clic per aprirla.' % ofb}
        crates.append({'id': cid, 'biome': bid})
    # le casse dei gradi del mondo (vigore 4-6, 7-9, 10-12, oltre)
    for t, (lo, nm, pal) in enumerate([(4, 'Cassa da pesca di corallo', 'corallite'), (7, 'Cassa da pesca di cuorelegno', 'cuorelegno'),
                                       (10, 'Cassa da pesca d\'astrite', 'astrite'), (13, 'Cassa da pesca di primambra', 'primambra')]):
        cid = 'cassa_pesca_v%d' % (t + 1)
        ph = min(23, 2 * lo + 1)
        loot[cid] = [{'item': 'lumino', 'min': 30 * lo, 'max': 60 * lo, 'chance': 1.0},
                     {'item': 'linfa_antica', 'min': 1, 'max': 2, 'chance': 0.6},
                     {'item': 'essenza_cresta', 'min': 1, 'max': 1, 'chance': 0.25}]
        items[cid] = {'name': nm, 'kind': 'cassetta', 'icon': ['scrigno', pal], 'stack': 30, 'crate': [3, 4], 'table': cid,
                      'firma_f': ph, 'source': 'pescando nei mondi dal vigore %d, al posto di un pesce' % lo,
                      'desc': 'Pescata nei mondi dal vigore %d: Lumini, Linfa antica e a volte un\'arma firma. Clic per aprirla.' % lo}
        crates.append({'id': cid, 'vigor': lo})
    # i premi del Pescatore: a collezione delle gare vinte
    angler = []
    for k, (n, nm, acc) in enumerate([(3, 'Cappello del pescatore', {'fish_luck': 0.1, 'fish_wait': 0.9}),
                                      (8, 'Galleggiante d\'ambra', {'fish_luck': 0.15, 'fish_size': 0.1}),
                                      (15, 'Rete leggera', {'fish_double': 0.1, 'fish_wait': 0.85}),
                                      (25, 'Amuleto della marea calma', {'fish_luck': 0.25, 'fish_size': 0.2, 'luck': 0.05}),
                                      (40, 'Corona del Pescatore', {'fish_luck': 0.35, 'fish_double': 0.15, 'fish_wait': 0.8})]):
        iid = 'premio_pescatore_%d' % k
        items[iid] = {'name': nm, 'kind': 'accessorio' if k % 2 == 0 else 'amuleto', 'icon': ['cuore' if k % 2 == 0 else 'amuleto', 'lagunite'],
                      'acc': acc, 'fase': 3 + 3 * k, 'source': 'il premio del Pescatore per %d gare vinte' % n,
                      'desc': 'Il Pescatore lo dona a chi ha vinto %d gare del giorno.' % n}
        angler.append({'n': n, 'item': iid})
    return crates, angler
