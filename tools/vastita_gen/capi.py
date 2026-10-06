"""I capi erranti, i boss facoltativi e i superboss del dopo (voci 375-377, Roadmap 41; piano in VASTITA.md).

- **Capi erranti** (voce 375): due per ogni vigore dei mondi della spina (1-12), uno più in alto e uno più in basso. Si
  incontrano esplorando, una volta per mondo, nello strato giusto dei mondi del loro vigore (fino a due vigori dopo):
  li fa comparire `Chiefs`. Ognuno lascia cose sue (la tabella «capo_<id>»): la sua arma, due gioielli, il suo
  materiale (per chiamare i boss facoltativi), il trofeo.
- **Boss facoltativi** (voce 376): dieci sfidanti che si chiamano al Cerchio dei Seminatori con un'esca costruita dai
  materiali dei capi. Combattono con la forza di un vigore in più del loro posto; lasciano il loro Sacchetto, con armi
  firma della fase dopo e il loro gioiello.
- **Superboss del dopo** (voce 377): tre, per i mondi oltre il dodicesimo vigore, con l'equipaggiamento finale.
"""
import math

OPP = {'brace': 'gelo', 'gelo': 'brace', 'spora': 'linfa', 'linfa': 'spora', 'vuoto': 'luce', 'luce': 'vuoto'}
PAL = {'luce': 'brillaluce', 'spora': 'fungo', 'linfa': 'lagunite', 'vuoto': 'vuotite', 'brace': 'tizzonite', 'gelo': 'brina'}
# i comportamenti dei capi secondo il corpo (volo / a terra): [base, furia]
FLY = [(['vola', 'ventaglio'], ['scatto']), (['vola', 'scatto'], ['evoca']), (['vola', 'spara'], ['teletrasporto'])]
WALK = [(['cammina', 'carica'], ['spara']), (['cammina', 'salta_verso'], ['carica']), (['cammina', 'spara'], ['salta_verso'])]
PARAMS = {'fan_rate': 2.6, 'fan_n': 5, 'fan_spread': 0.9, 'shot_speed': 190.0, 'shot_grav': 120.0, 'shot_damage': 14,
          'dash_every': 5.5, 'dash_speed': 290.0, 'dash_time': 0.5, 'summon_every': 9.0, 'summon_max': 2,
          'rate': 2.4, 'blink_every': 5.0, 'charge': 270.0, 'charge_range': 18, 'charge_time': 0.9, 'charge_cool': 4.0,
          'jump': 300.0, 'sight': 40, 'leash': 30, 'phase2': 0.5}

# capi: (id, nome, corpo, volo, elemento, vigore, strato)
CHIEFS = [
    ('cinghiale', 'Il Vecchio Zannarossa', 'cinghiale_rovo', False, '', 1, 0),
    ('ragno', 'La Madre delle gallerie', 'ragno_giungla', False, 'spora', 1, 2),
    ('cervo', 'Il Cervo dalle corna di ferro', 'cervo_rovo', False, '', 2, 0),
    ('talpa', 'La Talpa cieca', 'talpone', False, 'vuoto', 2, 3),
    ('gufo', 'Il Gufo dei sette occhi', 'gufo_gelo', True, 'gelo', 3, 1),
    ('scorpione', 'Lo Scorpione di vetro', 'scorpione_vetro', False, 'luce', 3, 3),
    ('falco', 'Il Falco della brace', 'falco_brace', True, 'brace', 4, 0),
    ('golem', 'Il Golem del muschio antico', 'golem_muschio', False, 'spora', 4, 3),
    ('lince', "La Lince d'ardesia", 'lince_ardesia', False, 'gelo', 5, 2),
    ('medusa', 'La Medusa delle grotte', 'medusa_grotta', True, 'linfa', 5, 4),
    ('orso', 'Il Grande Orso di corteccia', 'orso_corteccia', False, '', 6, 0),
    ('mietivuoto', 'Il Mietivuoto', 'mietivuoto', False, 'vuoto', 6, 4),
    ('lupo', 'Il Lupo della luna', 'lupo_lunare', False, 'luce', 7, 0),
    ('salamandra', 'La Salamandra di Linfa', 'salamandra_linfa', True, 'linfa', 7, 3),
    ('gargolla', 'La Gargolla muta', 'gargolla', True, 'vuoto', 8, 2),
    ('verme', 'Il Verme delle dune', 'verme_dune', False, 'brace', 8, 4),
    ('aquila', "L'Aquila della tempesta", 'aquila_tempesta', True, 'luce', 9, 0),
    ('sentinella', 'La Sentinella di cristallo', 'sentinella_cristallo', False, 'gelo', 9, 3),
    ('fenice', 'La Fenice di cenere', 'fenice_cenere', True, 'brace', 10, 1),
    ('spirito', 'Lo Spirito delle catacombe', 'spirito_catacomba', True, 'vuoto', 10, 4),
    ('balena', 'La Balena delle stelle', 'balena_stelle', True, 'luce', 11, 0),
    ('brucacristalli', 'Il Brucacristalli antico', 'brucacristalli', False, 'linfa', 11, 3),
    ('drago', "Il Draghetto d'eco cresciuto", 'draghetto_eco', True, 'gelo', 12, 2),
    ('ombra', "L'Ombra della parola", 'ombra_parola', True, 'vuoto', 12, 4),
]
STYLE_FORMS = ['spada', 'arco', 'verga', 'girandola', 'buccina', 'virgulto', 'semebomba', 'scettro', 'lancia', 'fionda',
               'tomo', 'dischi', 'flauto', 'martello', 'cerbottana', 'sfera', 'tamburo', 'semetorre', 'falcelunga',
               'balestra', 'manopole', 'egida', 'randello', 'lanciaspore']
FORM_KIND = {'spada': 'spada', 'lancia': 'spada', 'martello': 'spada', 'falcelunga': 'spada', 'manopole': 'spada',
             'egida': 'spada', 'randello': 'spada', 'arco': 'arco', 'fionda': 'arco', 'balestra': 'arco',
             'cerbottana': 'arco', 'lanciaspore': 'arco', 'verga': 'bastone', 'tomo': 'bastone', 'sfera': 'bastone',
             'scettro': 'evocatore', 'girandola': 'lancio', 'dischi': 'lancio', 'buccina': 'strumento',
             'flauto': 'strumento', 'tamburo': 'strumento', 'virgulto': 'ramo', 'semebomba': 'semeguerra',
             'semetorre': 'semeguerra'}
ICON = {'martello': 'mazza'}
# i gioielli: (chiave di GearEffects, additivo?, valore di base, crescita per fase, parola)
ACC_KEYS = [('damage', False, 0.03, 0.004, 'danno'), ('atk_speed', False, 0.03, 0.003, 'colpi più rapidi'),
            ('defense', True, 2.0, 0.5, 'Scorza'), ('regen', False, 0.08, 0.008, 'la Vita ricresce'),
            ('run', False, 0.04, 0.003, 'corsa'), ('jump', False, 0.03, 0.002, 'salto'),
            ('luck', True, 0.02, 0.002, 'fortuna'), ('magic', False, 0.04, 0.004, 'incantesimi'),
            ('linfa_regen', False, 0.08, 0.008, 'la Linfa ricresce'), ('thorns', True, 3.0, 0.8, 'spine'),
            ('halo', False, 0.06, 0.005, 'alone'), ('dig', False, 0.06, 0.006, 'scavo')]
GEM_NAMES = [('Zanna', 'amuleto'), ('Anello', 'anello'), ('Ciondolo', 'amuleto'), ('Cerchio', 'anello'),
             ('Pendente', 'amuleto'), ('Sigillo', 'anello')]
# effetti propri delle armi dei capi (libreria di `armi_firma.py`, ripetuta qui in breve)
WEAPON_FX = [
    {'when': 'colpo', 'chance': 0.35, 'do': 'brucia', 't': 4.0, 'desc': 'spesso incendia'},
    {'when': 'colpo', 'chance': 0.3, 'do': 'gela', 't': 2.5, 'desc': 'spesso gela'},
    {'when': 'ogni', 'n': 5, 'do': 'catena', 'targets': 3, 'dmg': 0.6, 'r': 7, 'desc': 'ogni quinto colpo un fulmine salta su tre creature'},
    {'when': 'colpo', 'chance': 0.4, 'do': 'avvelena', 't': 5.0, 'desc': 'spesso avvelena'},
    {'when': 'ogni', 'n': 4, 'do': 'scoppio', 'r': 3, 'dmg': 0.7, 'desc': 'ogni quarto colpo scoppia attorno'},
    {'when': 'colpo', 'chance': 1.0, 'do': 'cura', 'frac': 0.05, 'desc': 'ogni colpo rende Vita'},
    {'when': 'colpo', 'chance': 0.3, 'do': 'vulnera', 't': 3.0, 'desc': 'spesso rende vulnerabile'},
    {'when': 'ogni', 'n': 5, 'do': 'pioggia', 'shards': 4, 'dmg': 0.5, 'desc': 'ogni quinto colpo piovono stelle'},
]
MODS = [{'bounce': 2}, {'split': [3, 0.35]}, {'boom': [2.0, 0.45]}, {'ret': 0.5}, {'homing': 3.0}, {'pierce': 2}]

# boss facoltativi: (id, nome, corpo, volo, elemento, vigore, esca: [capi i cui materiali servono])
CHALLENGERS = [
    ('re_rovi', 'Il Re dei rovi', 'cinghiale_rovo', False, 'spora', 2, ['cinghiale', 'cervo']),
    ('vedova', 'La Vedova di pietra', 'ragno_giungla', False, 'vuoto', 3, ['ragno', 'talpa']),
    ('occhio', "L'Occhio senza palpebra", 'gufo_stellare', True, 'luce', 4, ['gufo', 'scorpione']),
    ('fornace', 'La Fornace che cammina', 'golem_muschio', False, 'brace', 5, ['falco', 'golem']),
    ('abisso', "La Madre dell'abisso", 'medusa_grotta', True, 'vuoto', 6, ['lince', 'medusa']),
    ('antico', "L'Antico della foresta", 'orso_corteccia', False, 'spora', 7, ['orso', 'mietivuoto']),
    ('eclisse', "La Bestia dell'eclissi", 'lupo_lunare', False, 'vuoto', 8, ['lupo', 'salamandra']),
    ('campana', 'La Campana di cristallo', 'sentinella_cristallo', False, 'gelo', 9, ['gargolla', 'verme']),
    ('rogo', 'Il Rogo che vola', 'fenice_cenere', True, 'brace', 10, ['aquila', 'sentinella']),
    ('silenzio', 'Il Silenzio', 'ombra_seminatore', True, 'vuoto', 11, ['fenice', 'spirito']),
]
SUPER = [
    ('stella_nera', 'La Stella nera', 'balena_stelle', True, 'vuoto', 15, ['balena', 'brucacristalli']),
    ('radice_vuoto', 'La Radice del Vuoto', 'tessivuoto', False, 'vuoto', 18, ['drago', 'ombra']),
    ('primo_sogno', 'Il Primo Sogno', 'ombra_seminatore', True, 'luce', 21, ['drago', 'ombra', 'balena']),
]
BARS = {1: 'radicite', 2: 'legnoferro', 3: 'ambra', 4: 'linfa', 5: 'vuoto', 6: 'stellare', 7: 'corallite', 8: 'sanguinite',
        9: 'cuorelegno', 10: 'eterite', 11: 'astrite', 12: 'primambra'}


NOUN = {'spada': 'Lama', 'arco': 'Arco', 'verga': 'Verga', 'girandola': 'Girandola', 'buccina': 'Corno',
        'virgulto': 'Ramo', 'semebomba': 'Seme', 'scettro': 'Scettro', 'lancia': 'Lancia', 'fionda': 'Fionda', 'tomo': 'Libro',
        'dischi': 'Dischi', 'flauto': 'Flauto', 'martello': 'Maglio', 'cerbottana': 'Soffio', 'sfera': 'Occhio',
        'tamburo': 'Tamburo', 'semetorre': 'Ghianda', 'falcelunga': 'Falce', 'balestra': 'Balestra', 'manopole': 'Pugni',
        'egida': 'Scudo', 'randello': 'Clava', 'lanciaspore': 'Bocca'}
WORDS = {k[0]: (k[1], k[4]) for k in ACC_KEYS}


def di(short):
    for a, b in (('il ', 'del '), ('lo ', 'dello '), ('la ', 'della '), ("l'", "dell'")):
        if short.startswith(a):
            return b + short[len(a):]
    return 'di ' + short


def words_of(acc):
    out = []
    for key, val in acc.items():
        add, word = WORDS[key]
        if add:
            out.append('+%s %s' % (('%g' % val).replace('.', ','), word))
        else:
            out.append('%s +%d%%' % (word, round((val - 1.0) * 100)))
    return ', '.join(out)


def phase_of(v, s):
    return max(1, min(2 * v - 1 + s, 23))


def _gem(cid, short, ph, k, effects_used):
    noun, kind = GEM_NAMES[k % len(GEM_NAMES)]
    a = ACC_KEYS[(ph * 5 + k * 7 + len(cid)) % len(ACC_KEYS)]
    b = ACC_KEYS[(ph * 3 + k * 11 + 4 + len(cid) * 2) % len(ACC_KEYS)]
    if b[0] == a[0]:
        b = ACC_KEYS[(ACC_KEYS.index(a) + 1) % len(ACC_KEYS)]
    acc, words = {}, []
    for (key, add, base, grow, word) in (a, b):
        val = base + grow * ph
        if add:
            acc[key] = round(val, 2)
            words.append('+%s %s' % (('%g' % round(val, 2)).replace('.', ','), word))
        else:
            acc[key] = round(1.0 + val, 3)
            words.append('%s +%d%%' % (word, round(val * 100)))
    return kind, acc, '%s %s' % (noun, short), ', '.join(words)


# la taratura (fattore del danno di ogni creatura), scritta da `tools/tara_capi.py` con `tools/boss.gd`
import json
import os
_TK = os.path.join(os.path.dirname(__file__), 'capi_taratura.json')
TUNE = json.load(open(_TK, encoding='utf-8')) if os.path.exists(_TK) else {}


def _creature(name, body, fly, elem, hp, dmg, idx, boss=False, cid=''):
    base, fury = (FLY if fly else WALK)[idx % 3]
    p = dict(PARAMS)
    k = float(TUNE.get(cid, 1.0))
    dmg = max(int(round(dmg * k)), 4)
    p['shot_damage'] = max(int(dmg * 0.6), 4)
    e = elem or ['brace', 'gelo', 'spora', 'linfa', 'vuoto', 'luce'][idx % 6]
    return {'name': name, 'hp': hp, 'damage': dmg, 'defense': 8 + idx % 6, 'knock': 0.6, 'body': body, 'speed_k': 1.15,
            'fly': fly, 'behaviors': base, 'fury': fury, 'p': p, 'strata': [], 'weight': 0, 'glow': True, 'boss': boss,
            'elem': e, 'weak': [OPP[e]], 'resist': [e], 'base': body, 'affinity': {'weak': [OPP[e]], 'resist': [e]},
            'art_mods': {'elem': e, 'scale': 3.0 if boss else 2.0, 'temper': 'feroce', 'glow_body': True}}


def build():
    creatures, items, loot, recipes, effects, calls, chiefs = {}, {}, {}, [], {}, {}, []
    for i, (cid, name, body, fly, elem, v, s) in enumerate(CHIEFS):
        crid = 'capo_' + cid
        ph = phase_of(v, s)
        short = name[0].lower() + name[1:]
        cr = _creature(name, body, fly, elem, 260, 18, i, cid=crid)
        cr['loot'] = crid
        cr['chief'] = True
        cr['boss'] = True                      # (la furia a metà Vita, la musica, la barra)
        cr['p']['phase2'] = 0.5
        creatures[crid] = cr
        chiefs.append({'id': cid, 'creature': crid, 'vigor': v, 'stratum': s})
        pal = PAL[cr['elem']]
        # la sua arma
        form = STYLE_FORMS[i % len(STYLE_FORMS)]
        wid = 'arma_capo_' + cid
        fx = dict(WEAPON_FX[(i * 3 + v) % len(WEAPON_FX)])
        fdesc = fx.pop('desc')
        fx['name'] = '%s' % name
        fx['desc'] = fdesc
        effects[wid + '_e0'] = fx
        w = {'name': '%s %s' % (NOUN.get(form, 'Arma'), di(short)),
             'kind': FORM_KIND[form], 'form': form, 'fase': min(ph + 1, 23), 'firma': True, 'elem': cr['elem'],
             'icon': [ICON.get(form, form), pal], 'effects': [wid + '_e0'],
             'source': '%s, un capo errante (la prima volta di sicuro, poi a volte)' % short,
             'desc': "L'arma di %s, un capo errante: %s. Si trova, non si fabbrica." % (short, fdesc)}
        if form not in ('spada', 'lancia', 'martello', 'falcelunga', 'manopole', 'egida', 'randello'):
            w['mods'] = MODS[i % len(MODS)]
        items[wid] = w
        # due gioielli
        gems = []
        for k in range(2):
            kind, acc, gname, words = _gem(cid, short, ph, i * 2 + k, effects)
            gid = 'gioiello_capo_%s_%d' % (cid, k)
            items[gid] = {'name': '%s %s' % (gname.split(' ', 1)[0], di(short)), 'kind': kind, 'icon': ['amuleto' if kind == 'amuleto' else 'anello', pal],
                          'fase': ph, 'acc': acc, 'source': '%s, un capo errante' % short,
                          'desc': 'Un gioiello %s: %s.' % (di(short), words)}
            gems.append(gid)
        mat = 'reliquia_capo_' + cid
        items[mat] = {'name': 'Reliquia %s' % di(short), 'kind': 'materiale', 'icon': ['scaglia', pal], 'stack': 99, 'fase': ph,
                      'value': 30 * v, 'source': '%s, un capo errante' % short,
                      'used_for': "le esche dei boss facoltativi, al Cerchio dei Seminatori",
                      'desc': 'Ciò che resta %s. Al Cerchio, con altre reliquie, chiama un boss facoltativo.' % di(short)}
        tro = 'trofeo_capo_' + cid
        items[tro] = {'name': 'Trofeo %s' % di(short), 'kind': 'trofeo', 'icon': ['corona', pal], 'fase': ph, 'value': 120 * v,
                      'source': '%s, un capo errante (raro)' % short, 'desc': 'Una piccola immagine di %s, per il Museo.' % short}
        loot[crid] = [{'item': wid, 'min': 1, 'max': 1, 'chance': 1.0, 'first': True},
                      {'item': wid, 'min': 1, 'max': 1, 'chance': 0.2},
                      {'item': gems[0], 'min': 1, 'max': 1, 'chance': 0.5, 'group': 'gioiello'},
                      {'item': gems[1], 'min': 1, 'max': 1, 'chance': 0.5, 'group': 'gioiello'},
                      {'item': mat, 'min': 2, 'max': 4, 'chance': 1.0},
                      {'item': tro, 'min': 1, 'max': 1, 'chance': 0.1},
                      {'item': 'lumino', 'min': 20 * v, 'max': 40 * v, 'chance': 1.0}]
    # i boss facoltativi e i superboss: esca al Cerchio, Sacchetto con le armi firma della fase dopo
    for j, (bid, name, body, fly, elem, v, needs) in enumerate(CHALLENGERS + SUPER):
        sup = j >= len(CHALLENGERS)
        crid = 'sfidante_' + bid
        short = name[0].lower() + name[1:]
        hp = 2400 if sup else 1700
        cr = _creature(name, body, fly, elem, hp, 30 if sup else 26, j + 3, boss=True, cid=crid)
        cr['loot'] = 'guardiano_spina'
        cr['phase_elem'] = OPP[cr['elem']]
        creatures[crid] = cr
        pal = PAL[cr['elem']]
        ph = min(2 * v + 1, 23)
        esca = 'esca_' + bid
        items[esca] = {'name': 'Esca %s' % di(short), 'kind': 'richiamo', 'icon': ['seme', pal], 'stack': 10, 'fase': min(ph - 1, 23),
                       'desc': 'Al Cerchio dei Seminatori chiama %s, un boss %s. Combatte come in un mondo di vigore %d o più.' % (
                           short, 'del dopo' if sup else 'facoltativo', v)}
        ins = {'reliquia_capo_' + n: 4 for n in needs}
        ins['lingotto_' + BARS[min(v, 12)]] = 6
        if sup:
            ins['linfa_antica'] = 3
        recipes.append({'out': esca, 'qty': 1, 'in': ins, 'station': 'arena'})
        calls[esca] = {'creature': crid, 'free': True, 'vigor': v, 'loot': {'lumino': [100 * v, 160 * v]}}
        bag = 'sacchetto_' + crid
        gem = 'gioiello_' + bid
        kind, acc, gname, words = _gem(bid, short, min(ph + (4 if sup else 1), 26), j * 5, effects)
        if sup:
            acc = {k: (round(1.0 + (val - 1.0) * 1.6, 3) if val > 1.0 and k not in ('defense', 'thorns', 'luck') else round(val * 1.6, 2))
                   for k, val in acc.items()}
        items[gem] = {'name': ('Cuore %s' if sup else 'Gioiello %s') % di(short), 'kind': kind,
                      'icon': ['amuleto' if kind == 'amuleto' else 'anello', pal], 'fase': min(ph, 23), 'acc': acc,
                      'source': 'il Sacchetto %s' % di(short), 'desc': 'Il gioiello %s: %s.' % (di(short), words_of(acc))}
        tro = 'trofeo_' + bid
        items[tro] = {'name': 'Trofeo %s' % di(short), 'kind': 'trofeo', 'icon': ['corona', pal], 'fase': min(ph, 23),
                      'value': 250 * v, 'source': 'il Sacchetto di %s (raro)' % short, 'desc': 'Una piccola immagine di %s.' % short}
        items[bag] = {'name': 'Sacchetto %s' % di(short), 'kind': 'sacchetto', 'icon': ['sacca', pal], 'stack': 20,
                      'fase': min(ph, 23), 'table': bag, 'source': '%s, al Cerchio dei Seminatori' % short,
                      'desc': 'Lo lascia %s. Aprilo con il clic: armi firma della fase %d, il suo gioiello, lingotti, a volte il trofeo.' % (short, ph)}
        t = [{'item': 'firma_f%d_%d' % (ph, k), 'min': 1, 'max': 1, 'chance': 1.0, 'group': 'arma'} for k in range(10)]
        t += [{'item': 'firma_f%d_%d' % (ph, k), 'min': 1, 'max': 1, 'chance': 0.5 if sup else 0.3, 'group': 'arma2'} for k in range(10)]
        t += [{'item': gem, 'min': 1, 'max': 1, 'chance': 1.0, 'first': True}, {'item': gem, 'min': 1, 'max': 1, 'chance': 0.25},
              {'item': tro, 'min': 1, 'max': 1, 'chance': 0.15},
              {'item': 'lingotto_' + BARS[min(v + 1, 12)], 'min': 6, 'max': 12, 'chance': 1.0}]
        loot[bag] = t
    # voce 377: la corsa dei Guardiani (`BossRush`): il Corno si fa al Cerchio con i dodici Richiami
    spine = ['nodo', 'regina', 'colosso', 'falena', 'tessitore', 'marea', 'mietistelle', 'ospite', 'salamandra', 'bufera',
             'giardiniere', 'eco']
    items['corno_corsa'] = {'name': 'Corno della corsa', 'kind': 'richiamo', 'icon': ['seme', 'brillaluce'], 'stack': 5, 'fase': 23,
                            'desc': "Al Cerchio dei Seminatori chiama i dodici Guardiani della spina, uno dopo l'altro. Chi li batte tutti senza appassire vince la corsa."}
    ins = {'richiamo_' + g: 1 for g in spine}
    ins['lumino'] = 500
    recipes.append({'out': 'corno_corsa', 'qty': 1, 'in': ins, 'station': 'arena'})
    items['corona_corsa'] = {'name': 'Corona della corsa', 'kind': 'amuleto', 'icon': ['corona', 'primambra'], 'fase': 23,
                             'acc': {'damage': 1.12, 'atk_speed': 1.08, 'defense': 12, 'regen': 1.2},
                             'source': 'la prima corsa dei Guardiani vinta',
                             'desc': 'Per chi ha battuto i dodici Guardiani di fila: danno +12%, colpi +8% più rapidi, +12 Scorza, la Vita ricresce di più.'}
    loot['premio_corsa'] = [{'item': 'corona_corsa', 'min': 1, 'max': 1, 'chance': 1.0, 'first': True},
                            {'item': 'firma_f23_%d' % 0, 'min': 1, 'max': 1, 'chance': 1.0, 'group': 'a'}] +         [{'item': 'firma_f23_%d' % k, 'min': 1, 'max': 1, 'chance': 1.0, 'group': 'a'} for k in range(1, 10)] +         [{'item': 'linfa_antica', 'min': 4, 'max': 6, 'chance': 1.0}, {'item': 'lumino', 'min': 2500, 'max': 3500, 'chance': 1.0}]
    header = ('I capi erranti (24), i boss facoltativi (10) e i superboss del dopo (3), con le loro armi, i gioielli, ' +
              'le reliquie, i trofei, le esche e i Sacchetti (voci 375-377).')
    return [('capi.gd', header, {'creatures': creatures, 'items': items, 'loot': loot, 'recipes': recipes,
                                 'effects': effects, 'calls': calls, 'chiefs': chiefs})]
