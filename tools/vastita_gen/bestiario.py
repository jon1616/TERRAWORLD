"""Le creature nuove della Roadmap 42 (voci 379-380; piano in VASTITA.md).

- **Le risvegliate** (voce 379): dopo il Risveglio del Cuore (campo «awake»: `CreaturesData.awake_on`) in ogni bioma di
  superficie quattro specie nuove, in ogni strato del sottosuolo quattro, in ogni bioma del sottosuolo e del cielo due.
  Sono più forti (grado 4) e usano i mattoni nuovi dei comportamenti (voce 378).
- **Le specie firma** (voce 380): in ogni bioma due (una nel sottosuolo e nel cielo) con una combinazione di
  comportamenti che c'è solo lì: la ragione di andare in quel bioma. Ci sono dall'inizio.
Ogni specie ha il suo disegno (una ricetta di `BodyArt`), la sua famiglia e un materiale; il trofeo (delle rare) serve
allo stendardo d'oro della famiglia (voce 381, `BannersData`).
"""

TIER = {1: (26, 8, 0), 2: (40, 11, 2), 3: (58, 14, 4), 4: (80, 18, 6)}

# dove: (id, campo, epiteto, elemento, tavolozza di 5, occhio, grado)
PLACES = [
    ('ambra', 'biomes', "d'ambra", 'luce', ['#3a2208', '#6a4214', '#a86e22', '#e0a838', '#fff0b0'], '#fff0a0', 2),
    ('brace', 'biomes', 'di brace', 'brace', ['#2a0c08', '#5a1a10', '#9a3018', '#e06030', '#ffd0a0'], '#ffe060', 3),
    ('brina', 'biomes', 'di brina', 'gelo', ['#1a2a3a', '#2c4a64', '#4c7aa0', '#8ec0e0', '#e8f8ff'], '#a0f0ff', 2),
    ('cenere', 'biomes', 'delle ceneri', 'brace', ['#241e20', '#40363a', '#6a5a5c', '#a08a88', '#e0d0c8'], '#ff9060', 3),
    ('foresta', 'biomes', 'della foresta', 'spora', ['#122a1e', '#1e4a32', '#2e7048', '#5aa868', '#b8e8a0'], '#ffe070', 1),
    ('funghi', 'biomes', 'dei funghi', 'spora', ['#24142e', '#42244e', '#6a3a7a', '#a868b0', '#f0c0f0'], '#80ffd0', 2),
    ('ghiacciaio', 'biomes', 'del ghiacciaio', 'gelo', ['#1c2838', '#30486a', '#5480a8', '#a0c8e8', '#f4fcff'], '#60e0ff', 3),
    ('iridato', 'biomes', "dell'iride", 'luce', ['#2a1838', '#4a3070', '#7058b0', '#b098e8', '#fff0ff'], '#ffffff', 3),
    ('palude', 'biomes', 'della palude', 'spora', ['#1a2214', '#2e3a20', '#4a5c30', '#7a8c4c', '#c8d090'], '#ffd050', 2),
    ('pietra', 'biomes', 'di pietra', 'gelo', ['#1e1e24', '#34343e', '#52525e', '#80808c', '#c8c8d0'], '#ffb050', 2),
    ('prati', 'biomes', 'dei prati', 'luce', ['#22300e', '#3c5218', '#5e7c24', '#94b040', '#e0f0a0'], '#ff9040', 1),
    ('rossa', 'biomes', 'della selva rossa', 'brace', ['#2a0e0e', '#4c1818', '#7a2a22', '#b04a34', '#f0a080'], '#ffe060', 2),
    ('stellare', 'biomes', 'delle stelle', 'luce', ['#121434', '#22285c', '#3a4490', '#7080d0', '#f0f0ff'], '#fff080', 3),
    ('sussurri', 'biomes', 'dei sussurri', 'vuoto', ['#1a1422', '#30243e', '#4e3c64', '#7a6496', '#d0c0f0'], '#c080ff', 3),
    ('torba', 'biomes', 'della torba', 'spora', ['#1e1610', '#36281c', '#54402c', '#7e6448', '#c8a888'], '#e0ff70', 2),
    ('vetro', 'biomes', 'di vetro', 'luce', ['#18282c', '#2a4a50', '#46767e', '#80b4b8', '#e8ffff'], '#ffffff', 3),
    ('s1', 'strata', 'del sottobosco', 'spora', ['#1e140e', '#38241a', '#5a3c28', '#8a6040', '#d0a878'], '#a0ff70', 2),
    ('s2', 'strata', 'delle caverne', 'gelo', ['#141a24', '#242e40', '#3a4a64', '#647aa0', '#b8c8e8'], '#ffa040', 3),
    ('s3', 'strata', 'delle profondità', 'linfa', ['#0a2020', '#103c3a', '#1a6460', '#3ea098', '#b0f0e0'], '#ffffff', 3),
    ('s4', 'strata', 'del Fondo', 'vuoto', ['#120a1c', '#221434', '#3a2458', '#6a48a0', '#d0b0ff'], '#ff70ff', 4),
    ('canto', 'under', 'delle grotte che cantano', 'luce', ['#20203a', '#363a66', '#56609a', '#90a0d8', '#f0f4ff'], '#fff0a0', 3),
    ('catacombe', 'under', 'delle catacombe', 'vuoto', ['#1c1818', '#322a2a', '#504444', '#807070', '#d0c4b8'], '#ff6040', 3),
    ('giungla', 'under', 'della giungla sepolta', 'spora', ['#0e2010', '#1a3a1c', '#2c5c2c', '#4e8c44', '#a8e080'], '#ffe040', 2),
    ('lago', 'under', 'del lago nero', 'linfa', ['#081820', '#102c3a', '#1c4a5e', '#36789a', '#a0d8f0'], '#c0ffff', 3),
    ('scogliere_cristallo', 'sky', 'delle scogliere', 'luce', ['#1a2a3a', '#2e4a64', '#4c78a0', '#8ab8e0', '#f0fcff'], '#ffffff', 3),
    ('firmamento', 'sky', 'del firmamento', 'luce', ['#0c0e2a', '#1a1e4c', '#30367a', '#6670c0', '#f0f0ff'], '#fff080', 4),
    ('mare_nubi', 'sky', 'del mare di nubi', 'gelo', ['#5a6680', '#7e8ca8', '#a4b4cc', '#d0dcec', '#ffffff'], '#3060a0', 3),
    ('radici_sospese', 'sky', 'delle radici sospese', 'spora', ['#1c2414', '#30401e', '#4c642e', '#7a9a4c', '#c8e090'], '#ffd060', 3),
    ('nidi_tempesta', 'sky', 'dei nidi di tempesta', 'luce', ['#1a1e2e', '#2c3248', '#464e6c', '#6c78a0', '#c8d4ff'], '#fffac0', 4),
    ('giardini_vento', 'sky', 'dei giardini del vento', 'gelo', ['#2a3a24', '#40583a', '#628458', '#94bc84', '#e8ffd8'], '#ffffff', 3),
]
OPP = {'brace': 'gelo', 'gelo': 'brace', 'spora': 'linfa', 'linfa': 'spora', 'vuoto': 'luce', 'luce': 'vuoto'}

NOUNS = {
    'quadrupede': [('Lupo', 'm'), ('Volpe', 'f'), ('Cinghiale', 'm'), ('Lince', 'f'), ('Tasso', 'm'), ('Cervo', 'm'),
                   ('Orso', 'm'), ('Faina', 'f'), ('Iena', 'f'), ('Daino', 'm'), ('Puma', 'm'), ('Lontra', 'f')],
    'uccello': [('Corvo', 'm'), ('Falco', 'm'), ('Civetta', 'f'), ('Gazza', 'f'), ('Airone', 'm'), ('Rondine', 'f'),
                ('Nibbio', 'm'), ('Upupa', 'f'), ('Allodola', 'f'), ('Picchio', 'm')],
    'insetto': [('Mantide', 'f'), ('Scarabeo', 'm'), ('Vespa', 'f'), ('Cicala', 'f'), ('Grillo', 'm'), ('Calabrone', 'm'),
                ('Formica', 'f'), ('Cervo volante', 'm'), ('Libellula', 'f'), ('Zecca', 'f')],
    'lumaca': [('Chiocciola', 'f'), ('Lumaca', 'f'), ('Limaccia', 'f')],
    'anfibio': [('Rospo', 'm'), ('Rana', 'f'), ('Salamandra', 'f'), ('Tritone', 'm')],
    'serpe': [('Serpe', 'f'), ('Vipera', 'f'), ('Anguilla', 'f'), ('Verme', 'm'), ('Biscia', 'f')],
    'fluttuante': [('Medusa', 'f'), ('Spirito', 'm'), ('Bolla', 'f'), ('Lanterna', 'f'), ('Fuoco fatuo', 'm')],
}
MAT = {'quadrupede': ('pelliccia', 'Pelliccia', 'seta'), 'uccello': ('piuma', 'Piuma', 'penna'),
       'insetto': ('elitra', 'Elitra', 'scaglia'), 'lumaca': ('bava', 'Bava', 'gel'), 'anfibio': ('pelle', 'Pelle', 'membrana'),
       'serpe': ('squama', 'Squama', 'scaglia'), 'fluttuante': ('essenza', 'Essenza', 'essenza')}
# combinazioni di comportamenti: chi cammina, chi vola (le risvegliate)
WALK = [['cammina', 'carica', 'arrampica'], ['cammina', 'tonfo'], ['molla', 'spine'], ['cammina', 'rotola'],
        ['cammina', 'raffica', 'balzo'], ['cammina', 'onda'], ['cammina', 'scudo', 'raffica'], ['cammina', 'specchio', 'carica'],
        ['cammina', 'arrampica', 'spine'], ['molla', 'raffica'], ['cammina', 'balzo', 'pioggia'], ['cammina', 'rotola', 'onda']]
FLY = [['vola', 'orbita', 'raffica'], ['vola', 'zigzag', 'spara'], ['vola', 'pioggia'], ['vola', 'raggio'],
       ['vola', 'zigzag', 'picchiata'], ['vola', 'orbita', 'spine'], ['vola', 'zigzag', 'raggio'], ['vola', 'orbita', 'pioggia']]
# le specie firma: combinazioni rare (una per bioma, scelte in ordine), e un tratto che dà il nome
SIGNATURE = [['vola', 'orbita', 'pioggia', 'specchio'], ['cammina', 'arrampica', 'raggio'], ['molla', 'tonfo'],
             ['cammina', 'rotola', 'spine'], ['vola', 'zigzag', 'raggio', 'specchio'], ['cammina', 'balzo', 'pioggia', 'arrampica'],
             ['molla', 'onda', 'specchio'], ['cammina', 'mimetico', 'raggio'], ['vola', 'orbita', 'richiamo'],
             ['cammina', 'sbuca', 'onda'], ['vola', 'deriva', 'pioggia'], ['cammina', 'guscio', 'spine'],
             ['cammina', 'ladro', 'balzo'], ['vola', 'picchiata', 'spine'], ['molla', 'raffica', 'specchio'],
             ['cammina', 'tonfo', 'richiamo'], ['vola', 'teletrasporto', 'raggio'], ['cammina', 'scudo', 'onda', 'arrampica'],
             ['vola', 'zigzag', 'raffica', 'orbita'], ['cammina', 'rotola', 'raffica'], ['vola', 'fotofobo', 'raggio'],
             ['cammina', 'divide', 'molla'], ['vola', 'orbita', 'raggio'], ['cammina', 'arrampica', 'tonfo'],
             ['vola', 'pioggia', 'teletrasporto'], ['cammina', 'specchio', 'spine', 'balzo'], ['vola', 'raffica', 'deriva'],
             ['molla', 'pioggia'], ['cammina', 'guaritore', 'raffica'], ['vola', 'zigzag', 'richiamo'],
             ['cammina', 'onda', 'balzo'], ['vola', 'orbita', 'raffica', 'specchio'], ['cammina', 'carica', 'specchio', 'onda'],
             ['molla', 'spine', 'richiamo'], ['vola', 'picchiata', 'pioggia'], ['cammina', 'rotola', 'arrampica', 'spine'],
             ['vola', 'raggio', 'spine'], ['cammina', 'tonfo', 'raffica'], ['vola', 'zigzag', 'pioggia', 'spine'],
             ['cammina', 'balzo', 'raggio'], ['molla', 'tonfo', 'spine'], ['vola', 'orbita', 'raggio', 'richiamo']]
TRAITS = [('che canta', 'che canta'), ('a due teste', 'a due teste'), ('dalle mille zampe', 'dalle mille zampe'),
          ('che ride', 'che ride'), ('senz\'ombra', 'senz\'ombra'), ('dal cuore acceso', 'dal cuore acceso'),
          ('che non dorme', 'che non dorme'), ('che ricorda', 'che ricorda'), ('dagli occhi di vetro', 'dagli occhi di vetro'),
          ('del filo d\'oro', 'del filo d\'oro'), ('che piange', 'che piange'), ('col mantello', 'col mantello'),
          ('che conta', 'che conta'), ('dal passo muto', 'dal passo muto')]
PARAMS = {'sight': 22, 'wave_every': 5.0, 'wave_n': 3, 'rain_every': 6.0, 'rain_n': 5, 'beam_every': 5.0, 'beam_n': 6,
          'ring_every': 4.5, 'ring_n': 8, 'spring': 360.0, 'spring_x': 120.0, 'spring_every': 1.1, 'roll_every': 5.0,
          'roll_speed': 240.0, 'roll_time': 1.4, 'slam_every': 6.0, 'slam_jump': 400.0, 'orbit_r': 6.0, 'orbit_speed': 0.18,
          'zig': 90.0, 'zig_rate': 3.0, 'burst_every': 4.0, 'burst_n': 3, 'hop_r': 3.0, 'hop_cool': 3.0, 'climb': 110.0,
          'charge': 230.0, 'charge_range': 10, 'charge_time': 0.7, 'charge_cool': 4.0, 'rate': 2.6, 'shot_speed': 200.0,
          'shot_grav': 120.0, 'dive_every': 5.0, 'dive_speed': 320.0, 'dive_time': 0.6, 'blink_every': 5.0,
          'summon_every': 9.0, 'summon_max': 2, 'mirror_n': 2, 'hover': 30.0, 'wobble': 40.0, 'windup': 0.9,
          'out_time': 4.0, 'heal_every': 5.0, 'heal': 0.15, 'heal_r': 9, 'steal': 3, 'turn': 1.0, 'flee': 10}
PLAN_FLY = {'uccello', 'fluttuante'}
SIZE = {'quadrupede': ([9, 7], 22, 16), 'uccello': ([7, 6], 18, 14), 'insetto': ([8, 6], 20, 15), 'lumaca': ([8, 6], 20, 14),
        'anfibio': ([7, 6], 18, 14), 'serpe': ([10, 5], 24, 11), 'fluttuante': ([7, 7], 16, 16)}
MARKS = ['strisce', 'macchie', 'punte', None]


def adj(g, m, f):
    return f if g == 'f' else m


def _shift(pal, k):
    """La tavolozza un po' più calda o più fredda per variare le specie di uno stesso posto."""
    out = []
    for h in pal:
        r, g_, b = int(h[1:3], 16), int(h[3:5], 16), int(h[5:7], 16)
        if k % 3 == 1:
            r, b = min(255, r + 18), max(0, b - 10)
        elif k % 3 == 2:
            r, b = max(0, r - 10), min(255, b + 18)
        out.append('#%02x%02x%02x' % (r, g_, b))
    return out


def species(place, k, kind):
    pid, field, epi, elem, pal, eye, tier = place
    awake = kind == 'risvegliata'
    if awake:
        tier = 4
    if field == 'sky':
        plan = ['uccello', 'fluttuante', 'insetto'][k % 3]
    elif field in ('strata', 'under'):
        plan = ['insetto', 'serpe', 'quadrupede', 'fluttuante', 'lumaca', 'anfibio'][(k + len(pid)) % 6]
    else:
        plan = ['quadrupede', 'uccello', 'insetto', 'anfibio', 'serpe', 'lumaca', 'fluttuante'][(k * 3 + len(pid)) % 7]
    fly = plan in PLAN_FLY or (plan == 'insetto' and k % 2 == 1)
    nouns = NOUNS[plan]
    noun, g = nouns[(k * 5 + len(pid) * 3) % len(nouns)]
    if awake:
        name = '%s %s %s' % (noun, adj(g, 'risvegliato', 'risvegliata'), epi)
        sid = 'ris_%s_%d' % (pid, k)
    else:
        tr = TRAITS[(k * 7 + len(pid) * 5) % len(TRAITS)]
        name = '%s %s %s' % (noun, epi, tr[0])
        sid = 'firma_%s_%d' % (pid, k)
    return sid, name, plan, fly, noun, g, tier, elem, pal, eye


def build():
    creatures, families, loot, items = {}, {}, {}, {}
    sig_i = 0
    seen_names = set()
    for place in PLACES:
        pid, field, epi, elem, pal, eye, tier0 = place
        n_awake = 4 if field in ('biomes', 'strata') else 2
        n_sig = 2 if field == 'biomes' else 1
        for kind, n in (('risvegliata', n_awake), ('firma', n_sig)):
            for k in range(n):
                sid, name, plan, fly, noun, g, tier, el, pl, ey = species(place, k, kind)
                if name in seen_names:
                    name = name + ' ' + ['maggiore', 'minore', 'antico'][k % 3]
                seen_names.add(name)
                hp, dmg, de = TIER[tier]
                if kind == 'firma':
                    beh = SIGNATURE[sig_i % len(SIGNATURE)]
                    sig_i += 1
                    fly = 'vola' in beh
                else:
                    beh = (FLY if fly else WALK)[(k * 5 + len(pid)) % len(FLY if fly else WALK)]
                half, w, h = SIZE[plan]
                if kind == 'firma':
                    half = [half[0] + 2, half[1] + 1]
                    w, h = w + 4, h + 2
                body = {'plan': plan, 'w': w, 'h': h, 'pal': _shift(pl, k), 'eye': ey}
                mk = MARKS[(k + len(pid)) % len(MARKS)]
                if mk:
                    body['marks'] = mk
                    body['mark'] = pl[4]
                if plan == 'uccello' or (plan == 'insetto' and fly):
                    body['wings'] = pl[2]
                if plan == 'quadrupede' and k % 2 == 0:
                    body['horns'] = 1
                if plan == 'quadrupede':
                    body['tail'] = True
                if el in ('luce', 'linfa', 'brace') and kind == 'firma':
                    body['glow'] = True
                p = dict(PARAMS)
                p['shot_damage'] = max(int(dmg * 0.7), 6)
                c = {'name': name, 'hp': int(hp * (1.4 if kind == 'firma' else 1.0)), 'damage': dmg, 'defense': de,
                     'knock': 0.3, 'half': half, 'speed': 70 + (k % 3) * 12, 'behaviors': beh, 'p': p,
                     'loot': sid, 'art': [sid, 0], 'body': body, 'affinity': {'weak': [OPP[el]], 'resist': [el]},
                     'trophy': sid + '_trofeo'}
                if fly:
                    c['fly'] = True
                if awake := (kind == 'risvegliata'):
                    c['awake'] = True
                if field == 'biomes':
                    c['strata'] = [0]
                    c['biomes'] = [pid]
                    c['weight'] = 3 if awake else 2
                elif field == 'strata':
                    c['strata'] = [int(pid[1])]
                    c['weight'] = 3
                elif field == 'under':
                    c['strata'] = []
                    c['under'] = pid
                    c['uw'] = 3 if awake else 2
                    c['weight'] = 0
                else:
                    c['strata'] = []
                    c['sky'] = pid
                    c['sw'] = 3 if awake else 2
                    c['weight'] = 0
                if el in ('luce', 'linfa'):
                    c['glow'] = True
                creatures[sid] = c
                fid = '%s_%s' % ('risvegliati' if awake else 'firma', pid)
                fname = ('Risvegliati %s' if awake else 'Creature firma %s') % epi
                if fid in families:
                    families[fid]['members'].append(sid)
                else:
                    families[fid] = {'name': fname, 'members': [sid], 'fem': False, 'role': 'predatore'}
                mk_id, mk_name, mk_icon = MAT[plan]
                mid = '%s_%s' % (mk_id, sid)
                items[mid] = {'name': '%s: %s' % (mk_name, name[0].lower() + name[1:]), 'kind': 'materiale',
                              'icon': [mk_icon, 'brillaluce' if awake else 'muschio'], 'stack': 99,
                              'used_for': 'lo stendardo della sua famiglia, e il commercio',
                              'desc': 'Ciò che lascia %s.' % (name[0].lower() + name[1:])}
                items[sid + '_trofeo'] = {'name': 'Trofeo: %s' % (name[0].lower() + name[1:]), 'kind': 'trofeo',
                                          'icon': ['corona', 'brillaluce' if awake else 'cristallo'],
                                          'desc': "Lo lasciano solo le creature rare di questa specie. Serve allo stendardo d'oro della sua famiglia."}
                loot[sid] = [{'item': mid, 'min': 1, 'max': 2, 'chance': 0.8},
                             {'item': 'lumino', 'min': 2, 'max': 6 if awake else 4, 'chance': 1.0}]
    header = ('Le creature della Roadmap 42 (voci 379-380): le risvegliate (dopo il Risveglio del Cuore) e le specie firma ' +
              'di ogni bioma, strato e cielo, con i mattoni nuovi dei comportamenti.')
    return [('bestiario.gd', header, {'creatures': creatures, 'families': families, 'loot': loot, 'items': items})]
