"""La fabbricazione profonda (Roadmap 50, voci 406-408; piano in VASTITA.md).

- **Le stazioni** (voce 406): cinque famiglie di banchi in quattro gradi (venti stazioni): il Distillatore di Linfa, la
  Forgia del Cuore, l'Armeria dei Seminatori, il Banco del gioielliere e lo Scrittoio del cartografo. Ogni grado si
  costruisce dal grado prima e da un metallo del Risveglio, e fa anche le ricette dei gradi sotto (campo «also»). Ogni
  famiglia apre ricette sue: le armi, le armature e gli accessori delle fasi 12-19 (il buco della partita), le essenze e
  la Linfa antica distillate, le chiavi dei biomi e le mappe.
- **Gli ingredienti a gruppi** (voce 407): «@pesce», «@gemma», «@essenza_creatura», «@trofeo_creatura», «@raccolto»,
  «@minerale» (`GroupsData`): qualsiasi oggetto del gruppo va bene.
- **Più strade per lo stesso oggetto** (voce 408): le chiavi dei biomi, la Linfa antica, le essenze della forgia e le
  cure hanno una seconda ricetta (dalla pesca, dalla caccia, dall'orto).
"""
from vastita_gen.accessori import ABILITIES, ACC_KEYS
from vastita_gen.rari import FORMS, MODS, RANGED, WEAPON_FX, _acc
from vastita_gen.ritrovamenti import _biomes

TIERS = [('corallite', 'I', 12), ('sanguinite', 'II', 14), ('cuorelegno', 'III', 16), ('eterite', 'IV', 18)]
FAMILIES = [
    ('distillatore', 'Distillatore di Linfa', '#5cf0d8'),
    ('forgia_cuore', 'Forgia del Cuore', '#ff8a4a'),
    ('armeria', 'Armeria dei Seminatori', '#c0a080'),
    ('gioielliere', 'Banco del gioielliere', '#f0c060'),
    ('scrittoio', 'Scrittoio del cartografo', '#8ad8ff'),
]
WEAPON_FORMS = ['spadone', 'lancia', 'arco', 'balestra', 'tomo', 'sfera', 'girandola', 'buccina', 'virgulto', 'semetorre',
                'falcelunga', 'manopole', 'egida', 'fionda', 'scettro', 'dischi', 'flauto', 'tamburo', 'semebomba', 'bipenne']
TIER_NAMES = ['di corallo vivo', 'di sangue del Cuore', 'di legno del Cuore', 'd\'etere']
PIECES = [('elmo', 'Elmo', 1.0), ('corazza', 'Corazza', 1.6), ('gambali', 'Gambali', 1.0)]
TENACIA = {12: 8.4, 14: 9.8, 16: 10.5, 18: 12.0}
ARMOR_SETS = [('vena', 'della vena', [('damage', False, 0.06, 0.004), ('atk_speed', False, 0.05, 0.003)],
               {'when': 'ogni', 'do': 'catena', 'n': 5, 'targets': 3, 'dmg': 0.6, 'r': 7}, 'ogni cinque colpi la scossa salta su tre creature'),
              ('radice', 'della radice', [('defense', True, 3.0, 0.4), ('regen', False, 0.1, 0.01)],
               {'when': 'ferita', 'chance': 1.0, 'do': 'scudo', 'n': 12, 't': 4.0, 'cool': 9.0}, 'ferito, ti copri di Scorza per quattro secondi')]


def _station_id(fam, t):
    return '%s_%d' % (fam, t + 1)


def build():
    items, recipes, effects, stations, sets = {}, [], {}, {}, {}
    # 1. le stazioni
    for fam, fname, color in FAMILIES:
        for t, (metal, roman, _ph) in enumerate(TIERS):
            sid = _station_id(fam, t)
            stations[sid] = {'name': '%s %s' % (fname, roman), 'size': [2, 2], 'item': sid, 'light': True,
                             'bench': [fam, t + 1], 'brew_color': color,
                             'also': [_station_id(fam, k) for k in range(t)]}
            items[sid] = {'name': '%s %s' % (fname, roman), 'kind': 'stazione', 'icon': ['incudine', metal], 'place': sid, 'stack': 9,
                          'desc': 'Un banco di grado %s: fa le sue ricette e quelle dei gradi sotto.' % roman}
            ins = {'lingotto_' + metal: 12, '@gemma': 2 + t}
            if t == 0:
                ins['legno'] = 30
                st = 'maglio'
            else:
                ins[_station_id(fam, t - 1)] = 1
                st = _station_id(fam, t - 1)
            recipes.append({'out': sid, 'qty': 1, 'in': ins, 'station': st})
    # 2. la Forgia del Cuore: quaranta armi delle fasi 12-19 (dieci per grado)
    used = set()
    for t, (metal, roman, ph) in enumerate(TIERS):
        for k in range(10):
            i = t * 10 + k
            f = WEAPON_FORMS[i % len(WEAPON_FORMS)]
            kind, noun, icon = FORMS[f]
            fi = (i * 4 + 2) % len(WEAPON_FX)
            mi = (i * 3 + 1) % len(MODS) if f in RANGED else 0
            while (f, fi) in used:
                fi = (fi + 1) % len(WEAPON_FX)
            used.add((f, fi))
            when, e, words = WEAPON_FX[fi]
            iid = 'forgiata_%s_%d' % (metal, k)
            nm = '%s %s' % (noun, TIER_NAMES[t])
            eff = dict(e)
            eff['when'] = when
            eff['name'] = nm
            eff['desc'] = words
            effects[iid + '_e0'] = eff
            it = {'name': nm, 'kind': kind, 'form': f, 'fase': ph + (k % 2), 'firma': True, 'icon': [icon, metal],
                  'effects': [iid + '_e0'], 'source': 'alla Forgia del Cuore %s' % roman,
                  'desc': 'Forgiata al Cuore: %s%s.' % (words, ('; il colpo ' + MODS[mi][1]) if MODS[mi][1] else '')}
            if MODS[mi][0]:
                it['mods'] = dict(MODS[mi][0])
            items[iid] = it
            recipes.append({'out': iid, 'qty': 1, 'in': {'lingotto_' + metal: 10, '@essenza_creatura': 2, '@gemma': 2, '@parte_rara': 3},
                            'station': _station_id('forgia_cuore', t)})
    # 3. l'Armeria: due set di tre pezzi per grado, con la loro abilità
    for t, (metal, roman, ph) in enumerate(TIERS):
        for si, (sk, sname, keys, ab, aw) in enumerate(ARMOR_SETS):
            pieces = []
            for kind, noun, mult in PIECES:
                iid = 'armeria_%s_%s_%s' % (metal, sk, kind)
                acc = {}
                for key, add, base, step in keys:
                    v = base + step * ph
                    acc[key] = float(round(v)) if add else round(1.0 + v * (0.5 if kind != 'corazza' else 0.8), 3)
                items[iid] = {'name': '%s %s %s' % (noun, sname, TIER_NAMES[t]), 'kind': kind, 'icon': [kind, metal], 'fase': ph + 1,
                              'defense': max(1, round(TENACIA[ph] * 1.05 * mult)), 'acc': acc, 'source': 'all\'Armeria dei Seminatori %s' % roman,
                              'desc': 'Un pezzo dell\'Armeria: con gli altri due fa un set con la sua abilità.'}
                pieces.append(iid)
                recipes.append({'out': iid, 'qty': 1, 'in': {'lingotto_' + metal: int(8 * mult) + 4, '@trofeo_creatura': 1, '@minerale': 6, '@parte_rara': 2},
                                'station': _station_id('armeria', t)})
            eid = 'armeria_%s_%s_e0' % (metal, sk)
            eff = dict(ab)
            eff['n'] = eff['n'] + (t if eff['do'] == 'scudo' else 0)
            eff['name'] = 'Set %s %s' % (sname, TIER_NAMES[t])
            eff['desc'] = aw
            effects[eid] = eff
            sets['armeria_%s_%s' % (metal, sk)] = {'name': 'Armeria %s %s' % (sname, TIER_NAMES[t]), 'pieces': pieces,
                                                   'bonus': {'defense': float(4 + 2 * t)}, 'desc': 'Scorza +%d' % (4 + 2 * t),
                                                   'effects': [eid]}
    # 4. il gioielliere: cinque accessori per grado
    for t, (metal, roman, ph) in enumerate(TIERS):
        for k in range(5):
            i = t * 5 + k
            kind = ['amuleto', 'anello', 'accessorio', 'amuleto', 'anello'][k]
            a = ACC_KEYS[(i * 5 + 3) % len(ACC_KEYS)][0]
            b = ACC_KEYS[(i * 7 + 1) % len(ACC_KEYS)][0]
            if a == b:
                b = ACC_KEYS[(i * 7 + 2) % len(ACC_KEYS)][0]
            acc, words = _acc([a, b], ph + 2)
            when, e, aw = ABILITIES[(i * 9 + 5) % len(ABILITIES)]
            iid = 'gioiello_%s_%d' % (metal, k)
            nm = '%s %s' % ({'amuleto': 'Pendente', 'anello': 'Vera', 'accessorio': 'Spilla'}[kind], TIER_NAMES[t])
            if k >= 3:
                nm += ' lavorato'
            eff = dict(e)
            eff['when'] = when
            if 'chance' not in eff and when in ('colpo', 'ferita'):
                eff['chance'] = 1.0
            eff['name'] = nm
            eff['desc'] = aw
            effects[iid + '_e0'] = eff
            items[iid] = {'name': nm, 'kind': kind, 'icon': [{'amuleto': 'amuleto', 'anello': 'anello', 'accessorio': 'cuore'}[kind], metal],
                          'fase': ph + 1, 'acc': acc, 'effects': [iid + '_e0'], 'source': 'al Banco del gioielliere %s' % roman,
                          'desc': '%s. %s.' % (words[0].upper() + words[1:], aw[0].upper() + aw[1:])}
            recipes.append({'out': iid, 'qty': 1, 'in': {'lingotto_' + metal: 4, '@gemma': 4, '@essenza_creatura': 1, '@parte_rara': 2},
                            'station': _station_id('gioielliere', t)})
    # 5. il Distillatore (voce 408: seconde strade) e lo Scrittoio
    d1 = _station_id('distillatore', 0)
    recipes.append({'out': 'linfa_antica', 'qty': 1, 'in': {'@essenza_creatura': 2, 'gelatina': 4}, 'station': d1})
    recipes.append({'out': 'linfa_antica', 'qty': 1, 'in': {'@pesce': 6, '@raccolto': 6}, 'station': _station_id('distillatore', 1)})
    for k, ess in enumerate(['essenza_cresta', 'essenza_fuso', 'essenza_eco', 'essenza_molla', 'essenza_corteccia', 'essenza_rugiada',
                             'essenza_branco', 'essenza_coro']):
        recipes.append({'out': ess, 'qty': 1, 'in': {'@essenza_creatura': 3, '@trofeo_creatura': 1},
                        'station': _station_id('distillatore', 1 + k % 3)})
    for k, cure in enumerate(['pozione_cura_grande', 'pozione_cura_viva', 'pozione_cura_cuore', 'pozione_cura_prima']):
        recipes.append({'out': cure, 'qty': 2, 'in': {'@pesce': 2 + k, '@raccolto': 2 + k, 'gelatina': 2},
                        'station': _station_id('distillatore', k)})
    for bi, (bid, _n, _e, _c, _w) in enumerate(_biomes()):
        recipes.append({'out': 'chiave_' + bid, 'qty': 1, 'in': {'@trofeo_creatura': 2, '@minerale': 10, 'tavoletta_seminatori': 1},
                        'station': _station_id('scrittoio', bi % 4)})
    recipes.append({'out': 'mappa_seminatori', 'qty': 1, 'in': {'tavoletta_seminatori': 3, '@gemma': 1}, 'station': _station_id('scrittoio', 0)})
    return [('fabbricazione.gd', 'Roadmap 50, voci 406-408: le stazioni a gradi, le loro ricette, le seconde strade',
             {'items': items, 'recipes': recipes, 'effects': effects, 'stations': stations, 'sets': sets})]
