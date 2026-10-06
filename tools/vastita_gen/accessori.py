"""Gli accessori e il movimento (Roadmap 43, voci 383-388; piano in VASTITA.md).

- **Accessori firma** (voce 383): sei per fase (1-23). Due bonus che crescono con la fase e un'**abilità** (un effetto
  del motore `Abilities`: scatta saltando, atterrando, scattando, raccogliendo, volando, agganciando, o dai colpi),
  tutte diverse. Cadono con le armi firma (`FirmaDrops`, tabelle «accessori_f<fase>») e negli scrigni delle rovine.
- **Le linee dell'Officina** (voce 384): trenta linee di quattro passi al Maglio, una per funzione (movimento, raccolta,
  difesa, luce, pesca, mandria, stili…): ogni passo fonde il precedente con un accessorio firma della sua fascia e ne
  prende l'abilità; il quarto è il più forte.
- **Ali** (voce 385): due per ogni fase dispari dalla 3 (una veloce, una lunga), ognuna con la sua abilità in volo.
- **Rampini** (voce 386): uno per fase dalla 2, sempre più lunghi e svelti, ognuno con un'abilità all'aggancio.
- **Animaletti** (voce 388): quarantotto, con un dono (luce, attirare gli oggetti, Linfa, o un bonus piccolo);
  cadono dai capi erranti e dagli eventi (tabella «animaletti», `FirmaDrops`).
"""
from vastita_gen.armi_firma import PHASES

ACC_KEYS = [('damage', False, 0.03, 0.004, 'danno'), ('atk_speed', False, 0.03, 0.003, 'colpi più rapidi'),
            ('defense', True, 2.0, 0.5, 'Scorza'), ('regen', False, 0.08, 0.008, 'la Vita ricresce'),
            ('run', False, 0.04, 0.003, 'corsa'), ('jump', False, 0.03, 0.002, 'salto'),
            ('luck', True, 0.02, 0.002, 'fortuna'), ('magic', False, 0.04, 0.004, 'incantesimi'),
            ('linfa_regen', False, 0.08, 0.008, 'la Linfa ricresce'), ('thorns', True, 3.0, 0.8, 'spine'),
            ('halo', False, 0.06, 0.005, 'alone'), ('dig', False, 0.06, 0.006, 'scavo')]
KEYS = {k[0]: k for k in ACC_KEYS}

# le abilità: (quando, cosa e parametri, frase). I numeri «n»/«dmg» crescono con la fase in `_ability`.
ABILITIES = [
    ('salto', {'do': 'scia', 't': 1.5, 'dmg': 0.25}, 'saltando lasci una scia che ferisce chi ti sta attorno'),
    ('salto', {'do': 'scudo', 'n': 4, 't': 2.0}, 'saltando ti copri di Scorza per un attimo'),
    ('salto', {'do': 'slancio', 'n': 1}, 'ogni salto dà uno Slancio'),
    ('salto_aria', {'do': 'onda', 'dmg': 0.7, 'pierce': 3}, 'il doppio salto lancia un\'onda davanti'),
    ('salto_aria', {'do': 'pioggia', 'shards': 4, 'dmg': 0.5}, 'il doppio salto chiama una pioggia di stelle'),
    ('salto_aria', {'do': 'magnete', 'mult': 2.5, 't': 4.0}, 'il doppio salto attira gli oggetti da lontano'),
    ('atterraggio', {'do': 'scossa', 'r': 3, 't': 0.7, 'da': 3}, 'atterrando da in alto stordisci chi è vicino'),
    ('atterraggio', {'do': 'scoppio', 'r': 3, 'dmg': 0.8, 'da': 3}, 'atterrando da in alto scoppia tutto attorno'),
    ('atterraggio', {'do': 'cura', 'frac': 0.25, 'da': 4}, 'atterrando da in alto ti curi un poco'),
    ('scatto', {'do': 'scia', 't': 1.0, 'dmg': 0.4}, 'lo scatto lascia una scia che ferisce'),
    ('scatto', {'do': 'scudo', 'n': 6, 't': 1.5}, 'dopo uno scatto sei coperto di Scorza'),
    ('scatto', {'do': 'mira'}, 'lo scatto rende pronta la Mira ferma'),
    ('scatto', {'do': 'ombra', 'mult': 0.5, 't': 3.0}, 'dopo uno scatto le creature ti vedono meno'),
    ('raccolta', {'do': 'linfa', 'n': 1, 'cool': 2.0}, 'raccogliere ti rende un po\' di Linfa'),
    ('raccolta', {'do': 'magnete', 'mult': 2.0, 't': 3.0, 'cool': 6.0}, 'raccogliendo attiri gli altri oggetti'),
    ('raccolta', {'do': 'corsa', 'mult': 1.2, 't': 2.0, 'cool': 3.0}, 'raccogliendo corri più svelto per un attimo'),
    ('volo', {'do': 'pioggia', 'shards': 3, 'dmg': 0.4}, 'in volo cadono stelle sotto di te'),
    ('volo', {'do': 'catena', 'targets': 2, 'dmg': 0.5, 'r': 7}, 'in volo un fulmine salta sulle creature vicine'),
    ('volo', {'do': 'cura', 'frac': 0.1}, 'in volo la Vita ricresce'),
    ('aggancio', {'do': 'scossa', 'r': 3, 't': 0.6}, 'agganciando la roccia stordisci chi è vicino'),
    ('aggancio', {'do': 'ispira', 'n': 2}, 'ogni aggancio dà Ispirazione'),
    ('aggancio', {'do': 'scudo', 'n': 5, 't': 2.0}, 'agganciando ti copri di Scorza'),
    ('colpo', {'do': 'gela', 't': 2.0, 'chance': 0.25}, 'un colpo su quattro gela'),
    ('colpo', {'do': 'brucia', 't': 3.0, 'chance': 0.25}, 'un colpo su quattro incendia'),
    ('ogni', {'do': 'catena', 'n': 6, 'targets': 2, 'dmg': 0.5, 'r': 6}, 'ogni sesto colpo un fulmine salta'),
    ('uccisione', {'do': 'scudo', 'n': 5, 't': 3.0}, 'dopo ogni creatura sconfitta ti copri di Scorza'),
    ('uccisione', {'do': 'slancio', 'n': 2}, 'ogni creatura sconfitta dà due Slanci'),
    ('ferita', {'do': 'scia', 't': 2.0, 'dmg': 0.3, 'chance': 1.0}, 'ferito, lasci una scia per due secondi'),
    ('ferita', {'do': 'mira', 'chance': 1.0}, 'ferito, la Mira ferma è subito pronta'),
    ('uccisione', {'do': 'ispira', 'n': 2}, 'ogni creatura sconfitta dà Ispirazione'),
]
GROW = ('n', 'dmg', 'frac')
NOUNS = {'amuleto': ['Ciondolo', 'Medaglione', 'Talismano', 'Amuleto'],
         'anello': ['Anello', 'Cerchio', 'Vera', 'Sigillo'],
         'accessorio': ['Fascia', 'Bracciale', 'Cinta', 'Fermaglio', 'Spilla', 'Ghirlanda']}
KINDS = ['accessorio', 'amuleto', 'anello', 'accessorio', 'amuleto', 'accessorio']
METAL = {1: 'radicite', 2: 'legnoferro', 3: 'ambra', 4: 'linfa', 5: 'vuoto', 6: 'stellare', 7: 'corallite', 8: 'sanguinite',
         9: 'cuorelegno', 10: 'eterite', 11: 'astrite', 12: 'primambra'}
PAL = {1: 'radicite', 2: 'legnoferro', 3: 'ambra', 4: 'linfa', 5: 'vuotite', 6: 'stelle', 7: 'corallite', 8: 'sanguinite',
       9: 'cuorelegno', 10: 'eterite', 11: 'astrite', 12: 'primambra'}


def tier(p):
    return max(1, min((p + 1) // 2, 12))


def _ability(i, p, tag):
    when, body, desc = ABILITIES[i % len(ABILITIES)]
    e = dict(body)
    for k in GROW:
        if k in e:
            e[k] = round(e[k] * (1.0 + 0.035 * (p - 1)), 3) if k != 'n' else max(1, int(round(e[k] * (1.0 + 0.04 * (p - 1)))))
    e['when'] = when
    e['name'] = tag
    e['desc'] = desc
    return e, desc


def _acc(keys, p, k=1.0):
    out, words = {}, []
    for key in keys:
        _id, add, base, grow, word = KEYS[key]
        v = (base + grow * p) * k
        if add:
            out[key] = round(v, 2)
            words.append('+%s %s' % (('%g' % round(v, 2)).replace('.', ','), word))
        else:
            out[key] = round(1.0 + v, 3)
            words.append('%s +%d%%' % (word, round(v * 100)))
    return out, ', '.join(words)


def _up(t):
    return t[:1].upper() + t[1:]


# le linee dell'Officina: (id, nome, i due bonus, abilità finale)
LINES = [
    ('passo', 'Passo del vento', ['run', 'jump'], 0), ('volo', 'Ala del Giardiniere', ['jump', 'run'], 4),
    ('scavo', 'Mano del minatore', ['dig', 'luck'], 14), ('fortuna', 'Quadrifoglio di Linfa', ['luck', 'halo'], 15),
    ('scorza', 'Corteccia viva', ['defense', 'regen'], 1), ('spine', 'Rovo che morde', ['thorns', 'defense'], 27),
    ('vita', 'Linfa che ricresce', ['regen', 'linfa_regen'], 18), ('luce', 'Lanterna del cammino', ['halo', 'run'], 16),
    ('lama', 'Filo del fendente', ['damage', 'atk_speed'], 26), ('furia', 'Cuore che batte', ['atk_speed', 'damage'], 2),
    ('linfa', 'Goccia del sapiente', ['magic', 'linfa_regen'], 17), ('canto', 'Eco del canto', ['magic', 'regen'], 20),
    ('tuffo', 'Tonfo del masso', ['defense', 'damage'], 7), ('scatto', 'Lampo d\'ombra', ['run', 'atk_speed'], 9),
    ('rampino', 'Presa salda', ['jump', 'defense'], 19), ('raccolta', 'Cesta che chiama', ['luck', 'dig'], 13),
    ('mira', 'Occhio fermo', ['damage', 'luck'], 11), ('gelo', 'Brina in tasca', ['defense', 'magic'], 22),
    ('fuoco', 'Brace in tasca', ['damage', 'thorns'], 23), ('stelle', 'Polvere di stelle', ['luck', 'magic'], 16),
    ('ombra', 'Mantello dell\'ombra', ['run', 'damage'], 12), ('guardia', 'Scudo del Giardino', ['defense', 'thorns'], 21),
    ('rugiada', 'Rugiada del mattino', ['regen', 'halo'], 8), ('vortice', 'Vortice del vento', ['jump', 'atk_speed'], 5),
    ('miniera', 'Lume del profondo', ['dig', 'halo'], 6), ('caccia', 'Zanna del cacciatore', ['damage', 'run'], 25),
    ('quiete', 'Sasso quieto', ['regen', 'defense'], 28), ('magnete', 'Calamita di radice', ['luck', 'run'], 10),
    ('cielo', 'Piuma del cielo', ['jump', 'halo'], 3), ('cuore', 'Seme del cuore', ['regen', 'damage'], 29),
]
BANDS = [(1, 6), (7, 12), (13, 18), (19, 23)]
ROMAN = ['I', 'II', 'III', 'IV']

# gli animaletti: (forma del disegno, tinta, nome)
PET_ART = ['grumo', 'falena', 'strisciaradice', 'scarabeo', 'sputaspore', 'vagavuoto', 'corvo', 'spinoriccio',
           'lucciola', 'tessiradice', 'talpone', 'saltafungo', 'ala_ardesia', 'chiocciola', 'serpe', 'campanula',
           'guizzalinfa', 'cervo_brina', 'gufo_gelo', 'salamandra', 'fatuo_cenere', 'pecora_muschio', 'cornoradice',
           'lepre_linfa', 'bruco_lanterna', 'ape_lume', 'formica_resina', 'pipistrello', 'libellula_brina', 'volpe_ambra',
           'lince_ardesia', 'pesce']
PET_NAMES = ['Batuffolo', 'Fiammella', 'Radichetta', 'Scarabocchio', 'Sbuffo', 'Ombretta', 'Corvino', 'Riccetto',
             'Lumino', 'Filino', 'Scavetto', 'Saltello', 'Ardesino', 'Lentezza', 'Biscia', 'Campanella', 'Guizzo',
             'Cerbiatto', 'Civettina', 'Brace', 'Fuocherello', 'Lanetta', 'Cornetto', 'Leprotto', 'Brucolino', 'Ronzio',
             'Formichina', 'Pipistrello', 'Libellina', 'Volpino', 'Lincetta', 'Pesciolino']
PET_TINT = ['Color(1.2, 1.4, 1.2)', 'Color(1.4, 1.1, 0.8)', 'Color(1.1, 1.0, 1.4)', 'Color(0.9, 1.3, 1.4)',
            'Color(1.4, 1.3, 0.9)', 'Color(1.3, 0.9, 1.2)']
PET_GIFTS = [{'light': 'Color(1.3, 1.4, 0.7)'}, {'magnet': 2.0}, {'linfa': 1.25}, {'acc': {'luck': 0.04}},
             {'acc': {'regen': 1.1}}, {'acc': {'run': 1.04}}, {'acc': {'dig': 1.08}}, {'acc': {'defense': 2.0}},
             {'light': 'Color(0.8, 1.2, 1.5)'}, {'magnet': 2.6}, {'acc': {'halo': 1.12}}, {'acc': {'jump': 1.04}}]
PET_WORDS = {'light': 'fa luce attorno', 'magnet': 'attira gli oggetti da lontano', 'linfa': 'la Linfa ricresce più in fretta',
             'luck': 'un poco di fortuna', 'regen': 'la Vita ricresce un poco più in fretta', 'run': 'corsa un poco più svelta',
             'dig': 'scavo un poco più svelto', 'defense': '+2 Scorza', 'halo': 'alone un poco più grande',
             'jump': 'salto un poco più alto'}


def build():
    items, effects, loot, recipes, wings, pets = {}, {}, {}, [], {}, {}
    n_ab = len(ABILITIES)
    # 1. gli accessori firma
    by_phase = {}
    seen = set()
    for p in range(1, 24):
        theme, _elem, pals, epithets = PHASES[p]
        table = []
        for k in range(6):
            kind = KINDS[k]
            a = ACC_KEYS[(p * 5 + k * 7) % len(ACC_KEYS)]
            b = ACC_KEYS[(p * 3 + k * 11 + 4) % len(ACC_KEYS)]
            if b[0] == a[0]:
                b = ACC_KEYS[(ACC_KEYS.index(a) + 1) % len(ACC_KEYS)]
            ai = (p * 7 + k * 13) % n_ab
            while (a[0], b[0], ai) in seen:
                ai = (ai + 1) % n_ab
            seen.add((a[0], b[0], ai))
            iid = 'acc_f%d_%d' % (p, k)
            noun = NOUNS[kind][(p + k) % len(NOUNS[kind])]
            name = '%s %s' % (noun, epithets[(k + 4) % 10])
            acc, words = _acc([a[0], b[0]], p)
            eff, adesc = _ability(ai, p, name)
            effects[iid + '_e0'] = eff
            items[iid] = {'name': name, 'kind': kind, 'icon': ['amuleto' if kind == 'amuleto' else ('anello' if kind == 'anello' else 'cuore'),
                                                               pals[k % len(pals)]],
                          'fase': p, 'acc': acc, 'effects': [iid + '_e0'],
                          'source': 'con le armi firma della fase %d: capi, Guardiani, scrigni delle rovine' % p,
                          'desc': '%s. %s.' % (_up(words), _up(adesc))}
            table.append({'item': iid, 'min': 1, 'max': 1, 'chance': 1.0, 'group': 'acc'})
            by_phase.setdefault(p, []).append(iid)
        loot['accessori_f%d' % p] = table
    # 2. le linee dell'Officina
    for li, (lid, lname, keys, ab) in enumerate(LINES):
        prev = ''
        for s, (lo, hi) in enumerate(BANDS):
            p = hi
            pick = by_phase[lo + (li % (hi - lo + 1))][li % 6]
            oid = 'officina_%s_%d' % (lid, s + 1)
            acc, words = _acc(keys, p, 1.25 + 0.05 * s)
            fx = [items[pick]['effects'][0]]
            if prev:
                fx = items[prev]['effects'][:2] + fx
            if s == 3:
                e, d = _ability(ab, 23, lname)
                effects[oid + '_e0'] = e
                fx.append(oid + '_e0')
            items[oid] = {'name': '%s %s' % (lname, ROMAN[s]), 'kind': 'accessorio', 'icon': ['cuore', PAL[tier(p)]],
                          'fase': p, 'acc': acc, 'effects': fx, 'linea': lid,
                          'source': "all'Officina del Maglio: la linea «%s», passo %d di 4" % (lname, s + 1),
                          'desc': '%s. Porta le abilità degli accessori che l\'hanno fatto.' % _up(words)}
            ins = {pick: 1, 'lingotto_' + METAL[tier(p)]: 4 + 2 * s}
            if prev:
                ins[prev] = 1
            recipes.append({'out': oid, 'qty': 1, 'in': ins, 'station': 'maglio'})
            prev = oid
    # 3. le ali: due per ogni fase dispari dalla 3
    prev_w = 'ali_foglia'
    for p in range(3, 24, 2):
        t = tier(p)
        for v, (vname, sk, tk, rk) in enumerate([('veloci', 1.1, 0.85, 1.0), ('lunghe', 0.95, 1.25, 0.92)]):
            wid = 'ali_f%d_%s' % (p, vname)
            ai = (p * 3 + v * 5) % n_ab
            when_ok = ['volo', 'salto_aria', 'scatto']
            while ABILITIES[ai][0] not in when_ok:
                ai = (ai + 1) % n_ab
            name = 'Ali %s %s' % (vname, PHASES[p][3][(v * 3 + 2) % 10])
            eff, adesc = _ability(ai, p, name)
            effects[wid + '_e0'] = eff
            wings[wid] = {'name': name, 'speed': round((1.05 + 0.022 * p) * sk, 3), 'rise': round((90 + 8.5 * p) * rk, 1),
                          'time': round((0.5 + 0.13 * p) * tk, 2), 'recharge': round(0.9 + 0.03 * p, 2), 'mat': PAL[t],
                          'color': '#c0d0ff', 'in': {prev_w: 1, 'lingotto_' + METAL[t]: 6 + p // 2, 'seta_radice': 8},
                          'station': 'maglio', 'effects': [wid + '_e0'],
                          'desc': '%s. %s.' % ('Svelte ma brevi' if v == 0 else 'Lunghe ma meno svelte', _up(adesc))}
        prev_w = 'ali_f%d_veloci' % p
    # 4. i rampini: uno per fase dalla 2
    prev_r = 'radice_uncino'
    for p in range(2, 24):
        t = tier(p)
        rid = 'rampino_f%d' % p
        ai = (p * 7 + 3) % n_ab
        while ABILITIES[ai][0] not in ('aggancio', 'salto', 'scatto'):
            ai = (ai + 1) % n_ab
        name = 'Rampino %s' % PHASES[p][3][7]
        eff, adesc = _ability(ai, p, name)
        effects[rid + '_e0'] = eff
        rng_ = 11 + p
        spd = 330 + 22 * p
        items[rid] = {'name': name, 'kind': 'rampino', 'icon': ['uncino', PAL[t]], 'fase': p,
                      'hook': {'range': rng_, 'speed': float(spd)}, 'effects': [rid + '_e0'],
                      'desc': 'Clic: il rampino vola verso il mouse e si aggancia alla roccia. Portata %d, velocità %d. %s.' % (
                          rng_, spd, _up(adesc))}
        recipes.append({'out': rid, 'qty': 1, 'in': {prev_r: 1, 'lingotto_' + METAL[t]: 5 + p // 2, 'seta_radice': 4},
                        'station': 'maglio'})
        prev_r = rid
    # 5. gli animaletti
    pet_loot = []
    for i in range(48):
        art = PET_ART[i % len(PET_ART)]
        nm = PET_NAMES[i % len(PET_NAMES)] + ('' if i < len(PET_NAMES) else ' ' + ['delle stelle', 'di brina', 'di brace',
                                                                                   'del Vuoto', 'di Linfa', 'd\'ambra'][i % 6])
        gift = dict(PET_GIFTS[i % len(PET_GIFTS)])
        pid = 'pet_%d' % i
        pd = {'name': nm, 'art': [art, 0], 'tint': PET_TINT[i % len(PET_TINT)],
              'fly': art in ('falena', 'corvo', 'lucciola', 'ala_ardesia', 'campanula', 'gufo_gelo', 'fatuo_cenere',
                             'ape_lume', 'pipistrello', 'libellula_brina', 'vagavuoto')}
        pd.update(gift)
        pets[pid] = pd
        key = list(gift.keys())[0]
        word = PET_WORDS[key] if key != 'acc' else PET_WORDS[list(gift['acc'].keys())[0]]
        items['vasetto_' + pid] = {'name': 'Vasetto: %s' % nm, 'kind': 'compagno', 'icon': ['vasetto', ['muschio', 'brina', 'brace',
                                                                                                 'vuotite', 'lagunite', 'ambra'][i % 6]],
                                   'pet': pid, 'source': 'i capi erranti e i capi degli eventi (raro)',
                                   'desc': 'Clic: %s esce e ti segue; %s.' % (nm, word)}
        pet_loot.append({'item': 'vasetto_' + pid, 'min': 1, 'max': 1, 'chance': 1.0, 'group': 'pet'})
    loot['animaletti'] = pet_loot
    header = ('Gli accessori e il movimento (Roadmap 43, voci 383-388): accessori firma con le abilità, le linee ' +
              "dell'Officina, ali, rampini, animaletti.")
    return [('accessori.gd', header, {'items': items, 'effects': effects, 'loot': loot, 'recipes': recipes,
                                      'wings': wings, 'pets': pets})]
