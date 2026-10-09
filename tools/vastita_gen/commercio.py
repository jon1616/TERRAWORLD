"""Il commercio e gli abitanti (Roadmap 48, voce 404; piano in VASTITA.md).

Ogni abitante vende, oltre alle merci di sempre, ciò che è adatto al **momento** (`ShopsData`):
- alla **fase** del mondo (quattro fasce: vigori 1-3, 4-6, 7-9, 10 e oltre): dieci merci del suo mestiere per fascia;
- alla **stagione** (tre per stagione), alla **notte** (quattro) e durante un **evento** (tre).
Le merci si scelgono dal catalogo (`catalogo.json`, scritto da `tools/catalogo.gd`) secondo il mestiere dell'abitante e
la fase dell'oggetto; niente unici, armi firma, rari, spoglie, trofei o reliquie (quelli si trovano).
Il **Mercante dei mondi** arriva nel Giardino un giorno sì e uno no, con merci **a rotazione** (dieci al giorno): una
parte dal catalogo delle fasi alte, una parte **solo sue** (venti oggetti unici: armi con un effetto e accessori con
un'abilità, da migliaia di Lumini).
"""
import hashlib
import json
import os

from vastita_gen.accessori import ABILITIES
from vastita_gen.rari import FORMS, WEAPON_FX, _acc

HERE = os.path.dirname(__file__)
# il mestiere di ogni abitante: i tipi d'oggetto (e le forme) che vende
TRADES = {
    'viandante': {'kinds': ['consumabile', 'munizione', 'materiale'], 'max_value': 400},
    'erborista': {'kinds': ['consumabile', 'seme', 'coltura'], 'prefix': ['pz_', 'pozione', 'fiala_arma', 'seme', 'piatto']},
    'forgiatore': {'kinds': ['spada', 'elmo', 'corazza', 'gambali', 'materiale'], 'prefix': ['lingotto_', 'spada_', 'elmo_', 'corazza_',
                                                                                      'gambali_', 'spadone_', 'martello_', 'lancia_']},
    'vecchia_radice': {'kinds': ['seme', 'fiala', 'essenza', 'coltura']},
    'mercante_semi': {'kinds': ['seme_mondo', 'fiala', 'seme']},
    'mandriano': {'kinds': ['legame', 'compagno', 'materiale'], 'prefix': ['laccio', 'frutto', 'istinto', 'pietra_', 'ciondolo', 'vasetto',
                                                                          'boccone', 'pet_', 'sella', 'basto']},
    'pescatore': {'kinds': ['canna', 'consumabile', 'materiale'], 'prefix': ['canna_', 'esca', 'pz_pesca', 'pz_pesce', 'piatto_']},
    'collezionista': {'kinds': ['curiosita', 'ricordo', 'tintura', 'mappa']},
    'pellegrino': {'kinds': ['richiamo', 'esca_signore', 'progetto_sem', 'chiave']},
    'musicista': {'kinds': ['strumento']},
    'palombara': {'kinds': ['consumabile', 'canna', 'accessorio'], 'prefix': ['pz_respiro', 'pz_sete', 'canna_', 'pz_pesca', 'fiala_arma_linfa']},
    'fabbro_radici': {'kinds': ['piccone', 'ascia', 'rampino', 'guanti', 'stivali']},
    'guardaboschi': {'kinds': ['arco', 'munizione', 'lancio']},
    'cantastorie': {'kinds': ['ramo', 'semeguerra', 'curiosita']},
    'cacciatore': {'kinds': ['spada', 'evocatore', 'bastone', 'consumabile'], 'prefix': ['falcelunga_', 'manopole_', 'egida_', 'bipenne_',
                                                                                      'randello_', 'scettro_', 'tomo_', 'sfera_', 'verga_', 'fiala_arma']},
    'tessitrice': {'kinds': ['stazione', 'blocco'], 'max_value': 3000},
    'innestatrice': {'kinds': ['fiala', 'essenza']},
    'cartografo': {'kinds': ['mappa', 'bisaccia', 'accessorio', 'chiave']},
    'mercante_mondi': {'kinds': []},
}
BANDS = [(1, 5), (6, 11), (12, 17), (18, 23)]
# ciò che si trova o si fabbrica apposta e non si vende (materiali dei richiami, accessori firma e dell'Officina…)
NOT_SOLD = ('reliquia_', 'officina_', 'acc_f', 'ali_f', 'rampino_f', 'pesca_', 'cassa_', 'merce_', 'chiave_', 'premio_')


def _h(s):
    return int(hashlib.md5(s.encode('utf-8')).hexdigest(), 16)


def _qty(d):
    if d['stack'] <= 1:
        return 1
    if d['kind'] == 'munizione':
        return 50
    if d['kind'] in ('materiale', 'blocco'):
        return 10
    return 3


def _pool(cat, npc):
    t = TRADES[npc]
    out = []
    for iid, d in cat.items():
        if d['special'] or d['value'] <= 0 or d['kind'] not in t['kinds'] or iid.startswith(NOT_SOLD):
            continue
        if d['kind'] in ('stazione',) and not iid.startswith(('macch', 'rete', 'filo', 'pinza', 'cassa', 'fonte')):
            if not d.get('place'):
                continue
        if 'prefix' in t and d['kind'] in ('materiale', 'consumabile', 'spada', 'elmo', 'corazza', 'gambali', 'accessorio', 'canna',
                                           'bastone', 'evocatore', 'legame', 'compagno') and not iid.startswith(tuple(t['prefix'])):
            continue
        if d['value'] > t.get('max_value', 1 << 30):
            continue
        out.append(iid)
    out.sort(key=lambda i: _h(npc + i))
    return out


def build():
    cat = json.load(open(os.path.join(HERE, 'catalogo.json'), encoding='utf-8'))
    shops = {}
    total = 0
    for npc in TRADES:
        if npc == 'mercante_mondi':
            continue
        pool = _pool(cat, npc)
        used = set()
        bands = []
        for lo, hi in BANDS:
            sel = [i for i in pool if lo <= max(cat[i]['phase'], 1) <= hi and i not in used][:10]
            if len(sel) < 10:                    # (un mestiere con poche cose di quella fascia: le più vicine)
                sel += [i for i in pool if i not in used and i not in sel][:10 - len(sel)]
            used.update(sel)
            bands.append([[i, _qty(cat[i])] for i in sel])
        rest = [i for i in pool if i not in used]
        seasons = []
        for s in range(4):
            sel = rest[s * 3:(s + 1) * 3]
            seasons.append([[i, _qty(cat[i])] for i in sel])
        night = [[i, _qty(cat[i])] for i in rest[12:16]]
        event = [[i, _qty(cat[i])] for i in rest[16:19]]
        shops[npc] = {'bands': bands, 'seasons': seasons, 'night': night, 'event': event}
        total += sum(len(b) for b in bands) + sum(len(s) for s in seasons) + len(night) + len(event)
    items, effects, merchant = _merchant(cat)
    total += len(merchant['pool']) + len(merchant['uniques'])
    print('voci nei negozi (oltre alle merci di sempre): %d' % total)
    return [('commercio.gd', 'Roadmap 48, voce 404: le merci degli abitanti secondo il momento e il Mercante dei mondi',
             {'shops': shops, 'merchant': merchant, 'items': items, 'effects': effects})]


def _merchant(cat):
    pool = [i for i, d in cat.items() if not d['special'] and d['value'] >= 300 and d['kind'] in
            ('accessorio', 'amuleto', 'anello', 'consumabile', 'essenza', 'fiala', 'seme_mondo', 'stazione', 'rampino', 'canna')
            and not d['gen']]
    pool.sort(key=lambda i: _h('mercante' + i))
    pool = pool[:80]
    items, effects = {}, {}
    uniques = []
    forms = ['spadone', 'falcelunga', 'balestra', 'tomo', 'girandola', 'buccina', 'virgulto', 'scettro', 'egida', 'cerbottana']
    names = ['dell\'oltremondo', 'del viaggiatore', 'delle strade lontane', 'del cielo straniero', 'dei mondi spenti',
             'del primo mercato', 'delle carovane', 'del porto di radice', 'della bilancia', 'del baratto']
    for k in range(20):
        iid = 'merce_unica_%d' % k
        ph = 8 + (k % 10) * 1
        if k < 10:
            f = forms[k]
            kind, noun, icon = FORMS[f]
            when, e, words = WEAPON_FX[(k * 5 + 2) % len(WEAPON_FX)]
            eff = dict(e)
            eff['when'] = when
            nm = '%s %s' % (noun, names[k])
            eff['name'] = nm
            eff['desc'] = words
            effects[iid + '_e0'] = eff
            items[iid] = {'name': nm, 'kind': kind, 'form': f, 'fase': ph, 'firma': True, 'power_mult': 1.1,
                          'icon': [icon, 'iride'], 'effects': [iid + '_e0'], 'value': 1500 + 400 * k, 'merce': True,
                          'source': 'il Mercante dei mondi, un giorno sì e uno no nel Giardino (solo da lui)',
                          'desc': 'Viene da un mondo che non conosci: %s.' % words}
        else:
            j = k - 10
            kind = ['amuleto', 'anello', 'accessorio'][j % 3]
            keys = [['luck', 'run'], ['magic', 'linfa_regen'], ['damage', 'defense'], ['regen', 'halo'], ['atk_speed', 'jump'],
                    ['dig', 'luck'], ['thorns', 'regen'], ['run', 'jump'], ['magic', 'damage'], ['defense', 'luck']][j]
            acc, words = _acc(keys, ph + 4)
            when, e, aw = ABILITIES[(j * 7 + 4) % len(ABILITIES)]
            eff = dict(e)
            eff['when'] = when
            if 'chance' not in eff and when in ('colpo', 'ferita'):
                eff['chance'] = 1.0
            nm = '%s %s' % ({'amuleto': 'Medaglione', 'anello': 'Sigillo', 'accessorio': 'Fibbia'}[kind], names[j])
            eff['name'] = nm
            eff['desc'] = aw
            effects[iid + '_e0'] = eff
            items[iid] = {'name': nm, 'kind': kind, 'icon': [{'amuleto': 'amuleto', 'anello': 'anello', 'accessorio': 'cuore'}[kind], 'iride'],
                          'fase': ph + 4, 'acc': acc, 'effects': [iid + '_e0'], 'value': 2000 + 600 * j, 'merce': True,
                          'source': 'il Mercante dei mondi, un giorno sì e uno no nel Giardino (solo da lui)',
                          'desc': '%s. %s.' % (words[0].upper() + words[1:], aw[0].upper() + aw[1:])}
        uniques.append(iid)
    return items, effects, {'pool': [[i, _qty(cat[i])] for i in pool], 'uniques': uniques}
