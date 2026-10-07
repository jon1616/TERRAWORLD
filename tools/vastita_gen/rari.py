"""I rari dei nemici (Roadmap 45, voce 395; piano in VASTITA.md).

Ogni specie (l'elenco in `specie.json`, scritto da `tools/specie.gd`) ha **un oggetto raro** che lascia da 1/150 a 1/50:
un'arma con un effetto suo (una forma di uno stile, i valori della fase della specie come le armi firma) o un accessorio
con un'abilità. Il motivo per cacciare una creatura anche quando si è più forti. Nessuna coppia forma × effetto (o
accessorio × abilità) si ripete. Il campo «raro_di» dice di chi è: lo legge `Rares`, che lo fa cadere.
"""
import hashlib
import json
import os

from vastita_gen.accessori import ACC_KEYS, ABILITIES

HERE = os.path.dirname(__file__)
PAL = {'': 'ardesia', 'luce': 'brillaluce', 'spora': 'fungo', 'linfa': 'lagunite', 'vuoto': 'vuotite', 'brace': 'tizzonite',
       'gelo': 'brina'}
# le forme delle armi rare: forma → (tipo, nome, icona)
FORMS = {
    'spada': ('spada', 'Lama', 'spada'), 'pugnale': ('spada', 'Zanna', 'pugnale'), 'spadone': ('spada', 'Spadone', 'spadone'),
    'lancia': ('spada', 'Corno', 'lancia'), 'martello': ('spada', 'Maglio', 'mazza'), 'falcione': ('spada', 'Falce', 'falcione'),
    'frusta': ('spada', 'Coda', 'frusta'), 'falcelunga': ('spada', 'Falce lunga', 'falcelunga'),
    'manopole': ('spada', 'Artigli', 'manopole'), 'egida': ('spada', 'Guscio', 'egida'), 'bipenne': ('spada', 'Ascia', 'bipenne'),
    'randello': ('spada', 'Osso', 'randello'), 'arco': ('arco', 'Arco', 'arco'), 'balestra': ('arco', 'Balestra', 'balestra'),
    'fionda': ('arco', 'Fionda', 'fionda'), 'cerbottana': ('arco', 'Soffio', 'cerbottana'),
    'lanciaspore': ('arco', 'Bocca', 'lanciaspore'), 'verga': ('bastone', 'Verga', 'verga'), 'tomo': ('bastone', 'Libro', 'tomo'),
    'sfera': ('bastone', 'Occhio', 'sfera'), 'scettro': ('evocatore', 'Scettro', 'scettro'),
    'dischi': ('lancio', 'Scaglie', 'dischi'), 'girandola': ('lancio', 'Girandola', 'girandola'),
    'buccina': ('strumento', 'Corno da richiamo', 'buccina'), 'flauto': ('strumento', 'Flauto', 'flauto'),
    'tamburo': ('strumento', 'Tamburo', 'tamburo'), 'virgulto': ('ramo', 'Ramo', 'virgulto'),
    'semebomba': ('semeguerra', 'Seme', 'semebomba'), 'semetorre': ('semeguerra', 'Ghianda', 'semetorre'),
}
RANGED = ('arco', 'balestra', 'fionda', 'cerbottana', 'lanciaspore', 'verga', 'tomo', 'sfera', 'dischi', 'girandola',
          'buccina', 'flauto')
MODS = [({}, ''), ({'bounce': 1}, 'rimbalza'), ({'split': [3, 0.35]}, 'si divide in tre'), ({'pierce': 2}, 'trapassa'),
        ({'homing': 2.0}, 'insegue'), ({'wave': 10.0}, 'ondeggia')]
# gli effetti delle armi rare (righe di `EffectsData`): (quando, cosa, frase)
WEAPON_FX = [
    ('colpo', {'do': 'brucia', 't': 3.0, 'chance': 0.3}, 'un colpo su tre incendia'),
    ('colpo', {'do': 'gela', 't': 2.5, 'chance': 0.3}, 'un colpo su tre gela'),
    ('colpo', {'do': 'avvelena', 't': 5.0, 'chance': 0.3}, 'un colpo su tre avvelena'),
    ('colpo', {'do': 'stordisce', 't': 0.8, 'chance': 0.15}, 'a volte stordisce'),
    ('colpo', {'do': 'vulnera', 't': 3.0, 'chance': 0.25}, 'a volte rende la creatura più fragile'),
    ('colpo', {'do': 'sanguina', 'dps': 0.2, 't': 4.0, 'chance': 0.25}, 'a volte fa sanguinare'),
    ('colpo', {'do': 'tira', 'chance': 0.2}, 'a volte tira la creatura verso di te'),
    ('colpo', {'do': 'cura', 'frac': 0.05, 'chance': 1.0}, 'ogni colpo ti cura un poco'),
    ('colpo', {'do': 'schegge', 'n': 4, 'dmg': 0.35, 'chance': 0.2}, 'a volte partono quattro schegge'),
    ('colpo', {'do': 'lumini', 'n': 1, 'chance': 0.1}, 'a volte fa cadere un Lumino'),
    ('ogni', {'do': 'catena', 'n': 5, 'targets': 3, 'dmg': 0.5, 'r': 6}, 'ogni cinque colpi la scossa salta su tre creature'),
    ('ogni', {'do': 'pioggia', 'n': 6, 'shards': 3, 'dmg': 0.4}, 'ogni sei colpi cadono stelle'),
    ('ogni', {'do': 'scoppio', 'n': 4, 'r': 3, 'dmg': 0.5}, 'ogni quattro colpi uno scoppio attorno alla creatura'),
    ('ogni', {'do': 'onda', 'n': 5, 'dmg': 0.6, 'pierce': 3}, 'ogni cinque colpi un\'onda vola davanti'),
    ('ogni', {'do': 'fulmine', 'n': 7, 'dmg': 0.9}, 'ogni sette colpi un fulmine'),
    ('ogni', {'do': 'linfa', 'n': 6, 'n_linfa': 2}, 'ogni sei colpi ritrovi 2 Linfa'),
    ('uccisione', {'do': 'cura', 'frac': 0.0, 'min': 6}, 'ogni creatura sconfitta ti cura'),
    ('uccisione', {'do': 'scudo', 'n': 5, 't': 3.0}, 'ogni creatura sconfitta ti copre di Scorza'),
    ('uccisione', {'do': 'corsa', 'mult': 1.3, 't': 3.0}, 'ogni creatura sconfitta ti fa correre più svelto'),
    ('uccisione', {'do': 'lumini', 'n': 2}, 'ogni creatura sconfitta lascia Lumini in più'),
    ('colpo', {'do': 'trapassa', 'len': 4.0, 'dmg': 0.5, 'chance': 0.25}, 'a volte il colpo passa anche a chi sta dietro'),
]
ACC_NOUNS = {'amuleto': ['Zanna', 'Occhio', 'Cuore', 'Dente'], 'anello': ['Anello', 'Cerchio'],
             'accessorio': ['Piuma', 'Scaglia', 'Corno', 'Artiglio', 'Pelliccia', 'Guscio']}


def _h(s):
    return int(hashlib.md5(s.encode('utf-8')).hexdigest(), 16)


def _phase(d):
    if d['awake']:
        st = min(d['strata']) if d['strata'] else 0
        return min(23, 9 + st + (2 if d['sky'] else 0))
    hp = d['hp']
    p = 1 if hp <= 20 else 2 if hp <= 32 else 3 if hp <= 50 else 4 if hp <= 75 else 5 if hp <= 110 else 6
    if d['sky']:
        p += 1
    if d['perduto']:
        p = max(p, 11)
    return p


def _of(name):
    return 'di ' + name[0].lower() + name[1:]


def _acc(keys, p):
    acc, words = {}, []
    for k in keys:
        _k, add, base, step, w = ACC_KEYS[[a[0] for a in ACC_KEYS].index(k)]
        v = base + step * p
        if add:
            acc[k] = round(v, 3) if k == 'luck' else float(round(v))
            words.append('%s +%s' % (w, ('%d%%' % round(v * 100)) if k == 'luck' else '%d' % round(v)))
        else:
            acc[k] = round(1.0 + v, 3)
            words.append('%s +%d%%' % (w, round(v * 100)))
    return acc, ', '.join(words)


def build():
    species = json.load(open(os.path.join(HERE, 'specie.json'), encoding='utf-8'))
    items, effects = {}, {}
    used = set()
    forms = list(FORMS)
    for sid in sorted(species):
        d = species[sid]
        p = _phase(d)
        h = _h(sid)
        chance = 0.02 if d['weight'] <= 2 else (0.0067 if d['weight'] >= 8 else 0.01)
        iid = 'raro_' + sid
        pal = PAL.get(d['elem'], 'ardesia')
        if h % 5 < 3:
            # un'arma: forma, effetto e (se tira) un modulo, mai la stessa terna
            k = h
            while True:
                f = forms[k % len(forms)]
                fx = (k // 7) % len(WEAPON_FX)
                mi = (k // 13) % len(MODS) if f in RANGED else 0
                if (f, fx, mi) not in used:
                    break
                k += 1
            used.add((f, fx, mi))
            kind, noun, icon = FORMS[f]
            when, e, words = WEAPON_FX[fx]
            eff = dict(e)
            eff['when'] = when
            eff['name'] = '%s %s' % (noun, _of(d['name']))
            eff['desc'] = words
            effects[iid + '_e0'] = eff
            it = {'name': '%s %s' % (noun, _of(d['name'])), 'kind': kind, 'form': f, 'fase': p, 'firma': True,
                  'icon': [icon, pal], 'effects': [iid + '_e0'], 'raro_di': sid, 'raro_p': chance}
            mods, mw = MODS[mi]
            if mods:
                it['mods'] = dict(mods)
            if d['elem']:
                it['elem'] = d['elem']
            it['source'] = 'raro: lo lascia %s (circa una volta su %d)' % (d['name'], round(1 / chance))
            it['desc'] = 'L\'arma rara %s: %s%s.' % (_of(d['name']), words, ('; il colpo ' + mw) if mw else '')
        else:
            # un accessorio: due bonus e un'abilità, mai la stessa terna
            k = h
            while True:
                kind = ['amuleto', 'anello', 'accessorio'][k % 3]
                a = ACC_KEYS[(k // 3) % len(ACC_KEYS)][0]
                b = ACC_KEYS[(k // 37) % len(ACC_KEYS)][0]
                ai = (k // 11) % len(ABILITIES)
                if a != b and (kind, a, b, ai) not in used:
                    break
                k += 1
            used.add((kind, a, b, ai))
            acc, words = _acc([a, b], p)
            when, e, aw = ABILITIES[ai]
            eff = dict(e)
            eff['when'] = when
            if 'chance' not in eff and when in ('colpo', 'ferita'):
                eff['chance'] = 1.0
            noun = ACC_NOUNS[kind][(k // 5) % len(ACC_NOUNS[kind])]
            eff['name'] = '%s %s' % (noun, _of(d['name']))
            eff['desc'] = aw
            effects[iid + '_e0'] = eff
            icon = 'amuleto' if kind == 'amuleto' else ('anello' if kind == 'anello' else 'cuore')
            it = {'name': '%s %s' % (noun, _of(d['name'])), 'kind': kind, 'icon': [icon, pal], 'fase': p, 'acc': acc,
                  'effects': [iid + '_e0'], 'raro_di': sid, 'raro_p': chance,
                  'source': 'raro: lo lascia %s (circa una volta su %d)' % (d['name'], round(1 / chance)),
                  'desc': 'Il raro %s: %s. %s.' % (_of(d['name']), words, aw[0].upper() + aw[1:])}
        items[iid] = it
    return [('rari.gd', 'Roadmap 45, voce 395: un oggetto raro per ogni specie', {'items': items, 'effects': effects})]
