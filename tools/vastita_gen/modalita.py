"""La difficoltà come contenuto (Roadmap 49, voce 405; piano in VASTITA.md).

Tre modalità scelte alla creazione del Giardino (`ModesData`): Normale, **Radice dura** e **Vuoto**. Le due più dure
danno **oggetti propri**:
- Radice dura (e Vuoto): trenta accessori e dodici armi che escono solo dai Sacchetti e dai capi in quelle modalità
  (tabella «modo_dura»);
- Vuoto: dieci accessori del Vuoto (tabella «modo_vuoto») e un **cimelio** per ogni boss (57): trovato una volta, dà un
  piccolo bonus per sempre (lo somma `GearEffects` dall'Erbario).
"""
from vastita_gen.accessori import ABILITIES, ACC_KEYS
from vastita_gen.capi import CHALLENGERS, CHIEFS, SUPER
from vastita_gen.eventi import EVENTS
from vastita_gen.guardiani import GUARDIANS, SPINE
from vastita_gen.rari import FORMS, WEAPON_FX, _acc

CIMELIO = [('luck', 0.01), ('regen', 1.02), ('damage', 1.01), ('defense', 1.0), ('run', 1.01), ('magic', 1.01),
           ('atk_speed', 1.01), ('halo', 1.03), ('linfa_regen', 1.02), ('thorns', 1.0), ('dig', 1.02), ('jump', 1.01)]
WEAPONS = ['spadone', 'falcelunga', 'balestra', 'sfera', 'girandola', 'tamburo', 'virgulto', 'scettro', 'bipenne', 'lanciaspore',
           'frusta', 'semebomba']
NOUNS = ['della radice dura', 'del Giardiniere ostinato', 'della prova', 'del lungo inverno', 'della pazienza', 'del sentiero stretto']


def _bosses():
    out = []
    for gid, nm, _v, _pal in SPINE[:3]:
        out.append((gid, nm))
    for g in GUARDIANS:
        out.append((g[0], g[2]))
    for c in CHIEFS:
        out.append(('capo_' + c[0], c[1]))
    for c in CHALLENGERS + SUPER:
        out.append(('sfidante_' + c[0], c[1]))
    for e in EVENTS:
        out.append(('evento_' + e[0], e[9][0]))
    return out


def build():
    items, effects, loot = {}, {}, {}
    dura, vuoto = [], []
    # 1. gli accessori e le armi della Radice dura
    for k in range(30):
        p = 4 + (k % 18)
        kind = ['amuleto', 'anello', 'accessorio'][k % 3]
        a = ACC_KEYS[(k * 5 + 1) % len(ACC_KEYS)][0]
        b = ACC_KEYS[(k * 7 + 4) % len(ACC_KEYS)][0]
        if a == b:
            b = ACC_KEYS[(k * 7 + 5) % len(ACC_KEYS)][0]
        acc, words = _acc([a, b], p + 2)
        when, e, aw = ABILITIES[(k * 11 + 3) % len(ABILITIES)]
        iid = 'dura_acc_%d' % k
        nm = '%s %s' % ({'amuleto': 'Nodo', 'anello': 'Anello', 'accessorio': 'Legaccio'}[kind], NOUNS[k % len(NOUNS)])
        if k >= len(NOUNS):
            nm += ' %s' % ['II', 'III', 'IV', 'V', 'VI'][(k // len(NOUNS) - 1) % 5]
        eff = dict(e)
        eff['when'] = when
        if 'chance' not in eff and when in ('colpo', 'ferita'):
            eff['chance'] = 1.0
        eff['name'] = nm
        eff['desc'] = aw
        effects[iid + '_e0'] = eff
        items[iid] = {'name': nm, 'kind': kind, 'icon': [{'amuleto': 'amuleto', 'anello': 'anello', 'accessorio': 'cuore'}[kind], 'radice'],
                      'fase': p, 'acc': acc, 'effects': [iid + '_e0'], 'modo': 1,
                      'source': 'solo in Radice dura o nel Vuoto: dai Sacchetti dei boss e dai capi',
                      'desc': '%s. %s.' % (words[0].upper() + words[1:], aw[0].upper() + aw[1:])}
        dura.append(iid)
    for k, f in enumerate(WEAPONS):
        p = 5 + k * 1.5
        kind, noun, icon = FORMS[f]
        when, e, words = WEAPON_FX[(k * 3 + 5) % len(WEAPON_FX)]
        iid = 'dura_arma_%d' % k
        nm = '%s %s' % (noun, NOUNS[k % len(NOUNS)])
        eff = dict(e)
        eff['when'] = when
        eff['name'] = nm
        eff['desc'] = words
        effects[iid + '_e0'] = eff
        items[iid] = {'name': nm, 'kind': kind, 'form': f, 'fase': int(p), 'firma': True, 'power_mult': 1.12, 'icon': [icon, 'radice'],
                      'effects': [iid + '_e0'], 'modo': 1, 'source': 'solo in Radice dura o nel Vuoto: dai Sacchetti dei boss e dai capi',
                      'desc': 'Un\'arma che si guadagna solo nelle modalità dure: %s.' % words}
        dura.append(iid)
    loot['modo_dura'] = [{'item': i, 'min': 1, 'max': 1, 'chance': 1.0, 'group': 'dura'} for i in dura]
    # 2. gli accessori del Vuoto
    for k in range(10):
        p = 10 + k
        kind = ['amuleto', 'anello', 'accessorio'][k % 3]
        a = ACC_KEYS[(k * 3 + 2) % len(ACC_KEYS)][0]
        b = ACC_KEYS[(k * 5 + 7) % len(ACC_KEYS)][0]
        if a == b:
            b = ACC_KEYS[(k * 5 + 8) % len(ACC_KEYS)][0]
        acc, words = _acc([a, b], p + 4)
        when, e, aw = ABILITIES[(k * 13 + 6) % len(ABILITIES)]
        iid = 'vuoto_acc_%d' % k
        nm = '%s del Vuoto %s' % ({'amuleto': 'Occhio', 'anello': 'Cerchio', 'accessorio': 'Velo'}[kind], ['che ascolta', 'che morde', 'paziente',
                                                                                                      'muto', 'affamato', 'cieco', 'freddo',
                                                                                                      'antico', 'vicino', 'ultimo'][k])
        eff = dict(e)
        eff['when'] = when
        if 'chance' not in eff and when in ('colpo', 'ferita'):
            eff['chance'] = 1.0
        eff['name'] = nm
        eff['desc'] = aw
        effects[iid + '_e0'] = eff
        items[iid] = {'name': nm, 'kind': kind, 'icon': [{'amuleto': 'amuleto', 'anello': 'anello', 'accessorio': 'cuore'}[kind], 'vuotite'],
                      'fase': p, 'acc': acc, 'effects': [iid + '_e0'], 'modo': 2, 'source': 'solo nella modalità del Vuoto: dai boss',
                      'desc': '%s. %s.' % (words[0].upper() + words[1:], aw[0].upper() + aw[1:])}
        vuoto.append(iid)
    loot['modo_vuoto'] = [{'item': i, 'min': 1, 'max': 1, 'chance': 1.0, 'group': 'vuoto'} for i in vuoto]
    # 3. i cimeli dei boss
    for k, (bid, name) in enumerate(_bosses()):
        key, v = CIMELIO[k % len(CIMELIO)]
        val = round(v + 0.01 * (k % 3), 3) if key not in ('defense', 'thorns') else float(1 + k % 3)
        if key in ('regen', 'damage', 'run', 'magic', 'atk_speed', 'halo', 'linfa_regen', 'dig', 'jump') and val < 1.0:
            val = 1.01
        iid = 'cimelio_' + bid
        nn = name[0].lower() + name[1:]
        items[iid] = {'name': 'Cimelio: %s' % nn, 'kind': 'cimelio', 'icon': ['corona', 'vuotite'], 'cimelio': {key: val}, 'modo': 2,
                      'source': 'solo nella modalità del Vuoto: %s, la prima volta' % nn,
                      'desc': 'Trovato una volta, dà per sempre un piccolo bonus (anche se lo lasci nella cassa).'}
    effects['furia_cura'] = {'name': 'Furia del Giardiniere', 'when': 'colpo', 'chance': 1.0, 'do': 'cura', 'frac': 0.05,
                             'desc': 'ogni colpo ti cura del 5% del danno'}
    boons = {'furia_giardiniere': {'name': 'Furia del Giardiniere', 'acc': {'damage': 1.5, 'atk_speed': 1.2, 'run': 1.1},
                                   'effects': ['furia_cura']}}
    return [('modalita.gd', 'Roadmap 49, voce 405: gli oggetti delle modalità dure e i cimeli dei boss',
             {'items': items, 'effects': effects, 'loot': loot, 'boons': boons})]
