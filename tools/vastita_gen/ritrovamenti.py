"""I ritrovamenti (Roadmap 45, voci 392-393; piano in VASTITA.md).

- **Le casse dei biomi** (voce 392): ogni bioma (di superficie, del sottosuolo e del cielo) ha la sua cassa, che il
  generatore mette al posto di qualche scrigno delle rovine (o degli osservatori, per il cielo), con cinque oggetti suoi
  (tre armi, un accessorio, un attrezzo; la tabella «cassa_<bioma>»). La **cassa sigillata** del bioma ha tre oggetti
  più forti (fase sette più in là, «cassa_<bioma>_sigillata») e si apre solo con la **chiave del bioma**, che lasciano
  di rado le creature di quel bioma dopo il primo Guardiano (`Finds`).
- **I mimi** (voce 393): uno per bioma, una cassa che è una creatura (comportamento «mimetico»): uno scontro breve, e
  un bottino suo (un oggetto della cassa del bioma, a volte uno di quella sigillata).
Il campo «chests» del pacchetto allunga `ChestsData.FOUND`; «mimics» dice quale stazione è il mimo di quale bioma.
"""
import glob
import os
import re

from vastita_gen.accessori import ACC_KEYS, ABILITIES
from vastita_gen.rari import FORMS, MODS, RANGED, WEAPON_FX, _acc

ROOT = os.path.normpath(os.path.join(os.path.dirname(__file__), '..', '..'))
OF = {'ambra': 'delle', 'brace': 'delle', 'brina': 'dei', 'cenere': 'delle', 'scogliere_cristallo': 'delle',
      'firmamento': 'del', 'mare_nubi': 'del', 'radici_sospese': 'delle', 'nidi_tempesta': 'dei',
      'giardini_vento': 'dei', 'foresta': 'della', 'funghi': 'delle', 'ghiacciaio': 'dei', 'iridato': 'dei',
      'palude': 'delle', 'pietra': 'delle', 'prati': 'dei', 'rossa': 'delle', 'canto': 'delle', 'catacombe': 'delle',
      'giungla': 'delle', 'lago': 'dei', 'stellare': 'delle', 'sussurri': 'dei', 'torba': 'delle', 'vetro': 'dei',
      'selve_pensili': 'delle', 'fonti_sospese': 'delle'}
PAL = {'ambra': 'ambra', 'brace': 'tizzonite', 'brina': 'brina', 'cenere': 'cenere', 'scogliere_cristallo': 'celeste',
       'firmamento': 'stelle', 'mare_nubi': 'nuvola', 'radici_sospese': 'radice', 'nidi_tempesta': 'tempesta',
       'giardini_vento': 'vento', 'foresta': 'muschio', 'funghi': 'fungo', 'ghiacciaio': 'lagunite', 'iridato': 'iride',
       'palude': 'nodo', 'pietra': 'ardesia', 'prati': 'lucciola', 'rossa': 'radicite', 'canto': 'cristallo',
       'catacombe': 'sem', 'giungla': 'legno', 'lago': 'linfa', 'stellare': 'brillaluce', 'sussurri': 'nottilite',
       'torba': 'humus', 'vetro': 'pallidite', 'selve_pensili': 'muschio', 'fonti_sospese': 'lagunite'}
OPP = {'brace': 'gelo', 'gelo': 'brace', 'spora': 'linfa', 'linfa': 'spora', 'vuoto': 'luce', 'luce': 'vuoto'}
TOOLS = [('piccone', 'piccone', 'Piccone'), ('ascia', 'ascia', 'Ascia'), ('trivella', 'piccone', 'Trivella')]
WEAPON_ORDER = ['spada', 'arco', 'verga', 'girandola', 'buccina', 'virgulto', 'scettro', 'semebomba', 'lancia', 'fionda',
                'tomo', 'dischi', 'flauto', 'martello', 'cerbottana', 'sfera', 'tamburo', 'semetorre', 'falcelunga',
                'balestra', 'manopole', 'egida', 'randello', 'lanciaspore', 'pugnale', 'spadone', 'frusta', 'bipenne',
                'falcione']


def _biomes():
    out = []
    for f in sorted(glob.glob(os.path.join(ROOT, 'src', 'data', 'biomes', '*.gd'))):
        s = open(f, encoding='utf-8').read()
        bid = re.search(r'"id":\s*"([a-z_]+)"', s).group(1)
        name = re.search(r'"name":\s*"([^"]+)"', s).group(1)
        e = re.search(r'"elem":\s*"([a-z_]*)"', s)
        col = re.search(r'"color":\s*"(#[0-9a-fA-F]{6})"', s)
        base = os.path.basename(f)
        where = 'cielo' if base.startswith('cielo_') else ('sotto' if base.startswith('sotto_') else 'superficie')
        out.append((bid, name, e.group(1) if e else '', col.group(1) if col else '#a0a0a0', where))
    return out


def _shades(hexc):
    r, g, b = int(hexc[1:3], 16), int(hexc[3:5], 16), int(hexc[5:7], 16)
    out = []
    for k in (0.18, 0.32, 0.5, 0.75, 1.0):
        out.append('#%02x%02x%02x' % (int(r * k), int(g * k), int(b * k)))
    return out


def _of(bid, name):
    if name.startswith('Il '):
        return 'del ' + name[3:]
    return '%s %s' % (OF[bid], name)


def build():
    items, loot, effects, creatures, chests, mimics = {}, {}, {}, {}, [], []
    used = set()
    wi = 0
    for bi, (bid, name, elem, color, where) in enumerate(_biomes()):
        p1 = {'superficie': 3, 'sotto': 5, 'cielo': 6}[where]
        p2 = p1 + 7
        pal = PAL[bid]
        ofb = _of(bid, name)
        here = 'negli osservatori del cielo' if where == 'cielo' else 'nelle rovine'
        rows_open, rows_sealed = [], []
        for slot in range(8):
            sealed = slot >= 5
            p = p2 if sealed else p1
            iid = 'cassa_%s_%d' % (bid, slot)
            src = ('nella cassa sigillata %s (si apre con la sua chiave)' if sealed else 'nella cassa %s') % ofb
            src += ', ' + here + (' sotto quel bioma' if where != 'cielo' else '') + '; o da un mimo'
            if slot in (3, 7):
                # un accessorio
                k = bi * 31 + slot * 7
                while True:
                    kind = ['amuleto', 'anello', 'accessorio'][k % 3]
                    a, b = ACC_KEYS[k % len(ACC_KEYS)][0], ACC_KEYS[(k * 5 + 3) % len(ACC_KEYS)][0]
                    ai = (k * 3 + 1) % len(ABILITIES)
                    if a != b and ('a', kind, a, b, ai) not in used:
                        break
                    k += 1
                used.add(('a', kind, a, b, ai))
                acc, words = _acc([a, b], p)
                when, e, aw = ABILITIES[ai]
                eff = dict(e)
                eff['when'] = when
                if 'chance' not in eff and when in ('colpo', 'ferita'):
                    eff['chance'] = 1.0
                noun = {'amuleto': 'Talismano', 'anello': 'Anello', 'accessorio': 'Fermaglio'}[kind]
                nm = '%s %s' % (noun, ofb)
                eff['name'] = nm
                eff['desc'] = aw
                effects[iid + '_e0'] = eff
                icon = 'amuleto' if kind == 'amuleto' else ('anello' if kind == 'anello' else 'cuore')
                items[iid] = {'name': nm, 'kind': kind, 'icon': [icon, pal], 'fase': p, 'acc': acc,
                              'effects': [iid + '_e0'], 'source': src,
                              'desc': '%s. %s.' % (words[0].upper() + words[1:], aw[0].upper() + aw[1:])}
            elif slot == 4:
                f, kind, noun = TOOLS[bi % 3]
                nm = '%s %s' % (noun, ofb)
                fx = WEAPON_FX[(bi * 5) % len(WEAPON_FX)]
                eff = dict(fx[1])
                eff['when'] = fx[0]
                eff['name'] = nm
                eff['desc'] = fx[2]
                effects[iid + '_e0'] = eff
                items[iid] = {'name': nm, 'kind': kind, 'form': f, 'fase': p, 'firma': True,
                              'icon': [{'trivella': 'trivella'}.get(f, f), pal], 'effects': [iid + '_e0'], 'source': src,
                              'desc': 'L\'attrezzo %s: scava come i metalli della sua fase; %s.' % (ofb, fx[2])}
            else:
                # un'arma: forma, effetto e (se tira) un modulo, mai la stessa terna
                k = wi
                wi += 1
                while True:
                    f = WEAPON_ORDER[k % len(WEAPON_ORDER)]
                    fi = (k * 4 + k // len(WEAPON_ORDER)) % len(WEAPON_FX)
                    mi = (k * 5 + 1) % len(MODS) if f in RANGED else 0
                    if ('w', f, fi, mi) not in used:
                        break
                    k += 1
                used.add(('w', f, fi, mi))
                kind, noun, icon = FORMS[f]
                when, e, words = WEAPON_FX[fi]
                nm = '%s %s' % (noun, ofb)
                eff = dict(e)
                eff['when'] = when
                eff['name'] = nm
                eff['desc'] = words
                effects[iid + '_e0'] = eff
                it = {'name': nm, 'kind': kind, 'form': f, 'fase': p, 'firma': True, 'icon': [icon, pal],
                      'effects': [iid + '_e0'], 'source': src}
                mods, mw = MODS[mi]
                if mods:
                    it['mods'] = dict(mods)
                if elem:
                    it['elem'] = elem
                it['desc'] = 'Arma %s: %s%s.' % (ofb, words, ('; il colpo ' + mw) if mw else '')
                items[iid] = it
            (rows_sealed if sealed else rows_open).append({'item': iid, 'min': 1, 'max': 1, 'chance': 1.0, 'group': 'cassa'})
        loot['cassa_' + bid] = rows_open + [{'item': 'lumino', 'min': 10 * p1, 'max': 25 * p1, 'chance': 1.0}]
        loot['cassa_%s_sigillata' % bid] = rows_sealed + [{'item': 'lumino', 'min': 10 * p2, 'max': 25 * p2, 'chance': 1.0},
                                                         {'item': 'linfa_antica', 'min': 1, 'max': 1, 'chance': 0.5}]
        # la chiave del bioma
        items['chiave_' + bid] = {'name': 'Chiave %s' % ofb, 'kind': 'chiave', 'icon': ['chiave', pal], 'stack': 5, 'value': 80,
                                  'chiave_di': bid,
                                  'source': 'di rado, dalle creature %s, dopo il primo Guardiano risolto' % ofb,
                                  'desc': 'Apre la cassa sigillata %s (si consuma).' % ofb}
        chests.append({'id': 'cassa_' + bid, 'name': 'Cassa %s' % ofb, 'slots': 30, 'mat': pal, 'biome': bid,
                       'where': where})
        chests.append({'id': 'cassa_%s_sigillata' % bid, 'name': 'Cassa sigillata %s' % ofb, 'slots': 30, 'mat': pal,
                       'biome': bid, 'where': where, 'key': 'chiave_' + bid})
        # il mimo
        mid = 'mimo_' + bid
        sh = _shades(color)
        creatures[mid] = {'name': 'Mimo %s' % ofb, 'hp': 90 + 10 * p1, 'damage': 18 + 2 * p1, 'defense': 6, 'knock': 0.3,
                          'half': [8, 7], 'speed': 95, 'behaviors': ['mimetico', 'salta_verso'],
                          'p': {'look': 'cassa_' + bid, 'wake': 3.0, 'jump': 300.0, 'sight': 22}, 'loot': mid,
                          'art': [mid, 0], 'strata': [], 'weight': 0, 'elem': elem,
                          'body': {'plan': 'quadrupede', 'w': 18, 'h': 16, 'pal': sh, 'eye': '#ff4040', 'marks': 'punte',
                                   'mark': sh[4], 'glow': True},
                          'affinity': {'weak': [OPP[elem]] if elem else ['brace'], 'resist': [elem] if elem else []},
                          'trophy': mid + '_trofeo'}
        items[mid + '_trofeo'] = {'name': 'Trofeo: mimo %s' % ofb, 'kind': 'trofeo', 'icon': ['corona', pal],
                                  'desc': "Lo lasciano solo i mimi rari %s. Serve allo stendardo d'oro dei mimi." % ofb}
        loot[mid] = [dict(r, group='mimo') for r in rows_open] + \
            [dict(r, group='mimo_s', chance=0.3) for r in rows_sealed] + \
            [{'item': 'lumino', 'min': 15 * p1, 'max': 30 * p1, 'chance': 1.0}]
        mimics.append({'id': 'mimo_cassa_' + bid, 'creature': mid, 'chest': 'cassa_' + bid, 'biome': bid, 'where': where})
    families = {'mimi': {'name': 'Mimi', 'members': [m['creature'] for m in mimics], 'fem': False, 'role': 'predatore'}}
    return [('ritrovamenti.gd', 'Roadmap 45, voci 392-393: le casse dei biomi, le chiavi e i mimi',
             {'items': items, 'loot': loot, 'effects': effects, 'creatures': creatures, 'chests': chests, 'mimics': mimics,
              'families': families})]
