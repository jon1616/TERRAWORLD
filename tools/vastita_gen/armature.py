"""Le armature dei boss (Roadmap 44, voce 389; piano in VASTITA.md): i set «scritti a mano» dai boss.

Ogni Guardiano della spina (vigori 4-12), ogni capo errante, sfidante, superboss e capo degli eventi lascia le **sue spoglie**: tre pezzi
(elmo, corazza, gambali) della fase in cui lo si incontra, con i bonus del suo elemento, e il set intero ha un bonus e
un'**abilità** sua (una riga di `EffectsData`, con i «quando» del motore delle abilità). Si trovano, non si fabbricano:
un pezzo a scelta tra tre a ogni capo sconfitto o Sacchetto aperto (tabelle «armatura_<chi>», `FirmaDrops`).
La Scorza viene dalla tenacia del metallo della fase, un decimo sopra quella dei pezzi fabbricati.
"""
from vastita_gen.capi import CHALLENGERS, CHIEFS, SUPER
from vastita_gen.eventi import EVENTS
from vastita_gen.guardiani import GUARDIANS, firma_phase

TENACIA = [1.2, 2.0, 2.8, 3.8, 5.0, 6.0, 7.2, 8.4, 9.8, 10.5, 12.0, 14.0]      # i metalli della spina, grado 1-12
FOUND = 1.1
PIECES = [('elmo', 'Elmo', 1.0), ('corazza', 'Corazza', 1.6), ('gambali', 'Gambali', 1.0)]
PAL = {'': 'ardesia', 'luce': 'brillaluce', 'spora': 'fungo', 'linfa': 'lagunite', 'vuoto': 'vuotite', 'brace': 'tizzonite',
       'gelo': 'brina'}
# i due bonus di ogni elemento: (chiave, somma?, base, passo per fase)
ELEM = {'': [('regen', False, 0.06, 0.006), ('defense', True, 1.0, 0.25)],
        'luce': [('halo', False, 0.08, 0.006), ('luck', True, 0.03, 0.003)],
        'spora': [('thorns', True, 3.0, 0.8), ('regen', False, 0.06, 0.006)],
        'linfa': [('magic', False, 0.04, 0.004), ('linfa_regen', False, 0.08, 0.008)],
        'vuoto': [('damage', False, 0.03, 0.003), ('stealth', False, -0.06, -0.006)],
        'brace': [('damage', False, 0.03, 0.003), ('thorns', True, 3.0, 0.8)],
        'gelo': [('atk_speed', False, 0.03, 0.003), ('run', False, 0.04, 0.003)]}
WORDS = {'regen': 'la Vita ricresce', 'defense': 'Scorza', 'halo': 'alone', 'luck': 'fortuna', 'thorns': 'spine',
         'magic': 'incantesimi', 'linfa_regen': 'la Linfa ricresce', 'damage': 'danno', 'stealth': 'le creature ti vedono',
         'atk_speed': 'colpi più rapidi', 'run': 'corsa'}
# le abilità dei set: (quando, cosa, frase); i numeri «n»/«dmg»/«frac» crescono con la fase
ABILITIES = [
    ('ferita', {'do': 'stordisce', 't': 1.2, 'cool': 5.0, 'chance': 1.0}, 'chi ti ferisce resta stordito'),
    ('ferita', {'do': 'brucia', 't': 4.0, 'cool': 3.0, 'chance': 1.0}, 'chi ti ferisce prende fuoco'),
    ('ferita', {'do': 'gela', 't': 3.0, 'cool': 3.0, 'chance': 1.0}, 'chi ti ferisce gela'),
    ('ferita', {'do': 'fulmine', 'dmg': 1.0, 'cool': 3.0, 'chance': 1.0}, 'un fulmine cade su chi ti ferisce'),
    ('ferita', {'do': 'scudo', 'n': 5, 't': 3.0, 'cool': 8.0, 'chance': 1.0}, 'ferito, ti copri di Scorza'),
    ('ferita', {'do': 'riflesso', 'frac': 0.4, 'chance': 1.0}, 'parte della ferita torna a chi te l\'ha fatta'),
    ('salto', {'do': 'fulmine', 'dmg': 0.6, 'cool': 2.0}, 'saltando chiami un fulmine sulla creatura vicina'),
    ('salto_aria', {'do': 'onda', 'dmg': 0.6, 'pierce': 3}, 'il doppio salto lancia un\'onda'),
    ('atterraggio', {'do': 'scossa', 'r': 3.5, 't': 1.0, 'da': 3.0, 'cool': 3.0}, 'atterrando da in alto stordisci attorno'),
    ('scatto', {'do': 'scia', 't': 1.5, 'dmg': 0.4}, 'lo scatto lascia una scia che ferisce'),
    ('scatto', {'do': 'ombra', 'mult': 0.4, 't': 2.5, 'cool': 4.0}, 'dopo lo scatto svanisci per un attimo'),
    ('uccisione', {'do': 'scudo', 'n': 5, 't': 3.0}, 'ogni creatura sconfitta ti copre di Scorza'),
    ('uccisione', {'do': 'cura', 'frac': 0.0, 'min': 5}, 'ogni creatura sconfitta ti cura'),
    ('uccisione', {'do': 'scia', 't': 2.5, 'dmg': 0.35}, 'ogni creatura sconfitta fa crescere rovi attorno a te'),
    ('ogni', {'do': 'catena', 'n': 6, 'targets': 3, 'dmg': 0.5, 'r': 6}, 'ogni sei colpi la scossa salta su tre creature'),
    ('ogni', {'do': 'pioggia', 'n': 5, 'shards': 3, 'dmg': 0.4}, 'ogni cinque colpi cadono stelle'),
    ('colpo', {'do': 'sanguina', 'dps': 0.2, 't': 4.0, 'chance': 0.2}, 'a volte il colpo fa sanguinare'),
    ('colpo', {'do': 'vulnera', 't': 3.0, 'chance': 0.2}, 'a volte il colpo rende la creatura più fragile'),
]


def _of(name):
    """«Il Vecchio Zannarossa» → «del Vecchio Zannarossa»."""
    for art, prep in (('Il ', 'del '), ('La ', 'della '), ('Lo ', 'dello '), ("L'", "dell'"), ('I ', 'dei ')):
        if name.startswith(art):
            return prep + name[len(art):]
    return 'di ' + name


def _tier(p):
    return max(1, min(12, (p + 1) // 2))


def _val(key, p, k=1.0):
    k0, add, base, step = key
    v = (base + step * p) * k
    if add:
        return round(v, 3) if k0 == 'luck' else float(round(v))
    return round(1.0 + v, 3)


def _words(acc):
    out = []
    for k, v in acc.items():
        if k in ('defense', 'thorns'):
            out.append('%s +%d' % (WORDS[k], v))
        elif k == 'luck':
            out.append('%s +%d%%' % (WORDS[k], round(v * 100)))
        else:
            out.append('%s %+d%%' % (WORDS[k], round((v - 1.0) * 100)))
    return ', '.join(out)


def _ability(i, p):
    when, d, words = ABILITIES[i % len(ABILITIES)]
    e = dict(d)
    g = 1.0 + 0.04 * p
    for k in ('dmg', 'frac'):
        if k in e and e[k] > 0:
            e[k] = round(e[k] * g, 2)
    if 'n' in e and e['do'] in ('scudo',):
        e['n'] = int(round(e['n'] * (1.0 + 0.12 * p)))
    if 'min' in e:
        e['min'] = int(round(e['min'] * (1.0 + 0.25 * p)))
    e['when'] = when
    return e, words


def _sources():
    """(id, nome, elemento, fase, chi lo lascia)."""
    out = []
    for g in GUARDIANS:
        gid, v, name, elem = g[0], g[1], g[2], g[5]
        out.append((gid, name, elem, firma_phase(v), 'dal Sacchetto %s (Guardiano del vigore %d)' % (_of(name), v)))
    for cid, name, _body, _fly, elem, v, s in CHIEFS:
        p = max(1, min(23, 2 * v - 1 + s))
        out.append(('capo_' + cid, name, elem, p, 'da %s, il capo errante dei mondi di vigore %d' % (name, v)))
    for j, (bid, name, _body, _fly, elem, v, _needs) in enumerate(CHALLENGERS + SUPER):
        sup = j >= len(CHALLENGERS)
        out.append(('sfidante_' + bid, name, elem, min(23, 2 * v + 1),
                    'dal Sacchetto %s, %s chiamato al Cerchio' % (_of(name), 'il superboss' if sup else 'lo sfidante')))
    for ev in EVENTS:
        eid, boss, vmin = ev[0], ev[9], ev[10]
        out.append(('evento_' + eid, boss[0], boss[3], min(23, 2 * vmin), 'da %s, nell\'evento «%s»' % (boss[0], ev[1])))
    return out


def build():
    items, sets, loot, effects = {}, {}, {}, {}
    for i, (sid, name, elem, p, where) in enumerate(_sources()):
        ten = TENACIA[_tier(p) - 1] * FOUND
        a, b = ELEM[elem]
        pieces = []
        for k, (kind, noun, mult) in enumerate(PIECES):
            iid = 'spoglie_%s_%s' % (sid, kind)
            acc = {}
            if k in (0, 1):
                acc[a[0]] = _val(a, p)
            if k in (1, 2):
                acc[b[0]] = _val(b, p)
            items[iid] = {'name': '%s %s' % (noun, _of(name)), 'kind': kind, 'icon': [kind, PAL[elem]],
                          'fase': p, 'defense': max(1, round(ten * mult)), 'acc': acc,
                          'source': where,
                          'desc': 'Le spoglie %s: %s. Con gli altri due pezzi fa un set.' % (_of(name), _words(acc))}
            pieces.append(iid)
        eid = 'spoglie_%s_e0' % sid
        eff, words = _ability(i * 7 + 3, p)
        eff['name'] = 'Spoglie %s' % _of(name)
        eff['desc'] = words
        effects[eid] = eff
        bonus = {'defense': float(2 + p // 2), a[0]: _val(a, p, 1.5)}
        sets['spoglie_' + sid] = {'name': 'Spoglie %s' % _of(name), 'pieces': pieces, 'bonus': bonus,
                                  'desc': _words(bonus), 'effects': [eid]}
        loot['armatura_' + sid] = [{'item': x, 'min': 1, 'max': 1, 'chance': 1.0, 'group': 'pezzo'} for x in pieces]
    return [('armature.gd', 'Roadmap 44, voce 389: le spoglie dei boss (set di tre pezzi con la loro abilità)',
             {'items': items, 'sets': sets, 'loot': loot, 'effects': effects})]
