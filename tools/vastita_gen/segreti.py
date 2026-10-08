"""I semi segreti dei mondi (Roadmap 45, voce 397; piano in VASTITA.md).

Cinque geni rarissimi che non si trovano: nascono soltanto **innestando** due Semi che portano insieme una certa coppia
di geni (il campo «combo», letto da `Genome.mutation_chance`), come i seed segreti di Terraria. Il mondo che ne nasce è
**speciale** (la notte che non finisce, il mondo dei Seminatori, il mondo cavo, il mondo d'acqua, il mondo dei giganti)
e ha **tre oggetti propri**: negli scrigni delle sue rovine e delle sue strutture (tabella «segreto_<gene>»,
`PassRovine`), e il primo dal suo Cuore quando il Guardiano è risolto.
"""
from vastita_gen.accessori import ABILITIES
from vastita_gen.rari import FORMS, WEAPON_FX, _acc

SECRETS = [
    ('notte_infinita', 'tempo', 'La notte che non finisce', ['notte_eterna', 'senza_sole'],
     'il sole non c\'è più: solo ciò che brilla da sé, creature della notte ovunque, rare e generose',
     {'geodes': 2.5, 'crystal': 2.0}, {'eternal': True, 'sunless': True, 'danger': 0.6, 'rare': 2.0, 'lumini': 1.6},
     'nottilite', [('tomo', 'Libro della notte senza fine', 14), ('anello', ['halo', 'magic'], 'Anello della luce rubata', 22),
                   ('falcelunga', 'Falce dell\'ultima ora', 7)]),
    ('seminatori_vivi', 'rovine', 'Il mondo dei Seminatori', ['citta_sepolta', 'eco_seminatori'],
     'rovine ovunque, una città sotto ogni bioma e le voci dei Seminatori in ogni stanza',
     {'ruins': 4.0, 'city': True}, {'events': 1.5, 'lumini': 1.3},
     'sem', [('scettro', 'Scettro del Seminatore', 3), ('amuleto', ['luck', 'regen'], 'Sigillo del Seminatore vivo', 4),
             ('lancia', 'Lancia della prima Aiuola', 10)]),
    ('mondo_cavo', 'sottosuolo', 'Il mondo cavo', ['cuore_cavo', 'voragini'],
     'il mondo è vuoto dentro: caverne immense, pozzi senza fondo e il cuore di cristallo',
     {'big': -0.35, 'room': -0.15, 'worm': 2.0, 'shafts': 10.0, 'under': ['cuore_cavo']}, {'danger': 0.3},
     'cristallo', [('girandola', 'Girandola dell\'eco', 12), ('accessorio', ['jump', 'dig'], 'Corda del mondo cavo', 6),
                   ('martello', 'Maglio delle voragini', 13)]),
    ('mondo_acqua', 'forma', 'Il mondo d\'acqua', ['sommerso', 'abissale'],
     'un mare sopra tutto e sotto tutto, pioggia senza fine e pesci che nessuno ha visto',
     {'sea': True, 'pools': 4.0}, {'rain': 3.0},
     'lagunite', [('virgulto', 'Ramo di corallo vivo', 8), ('amuleto', ['regen', 'run'], 'Perla del mondo d\'acqua', 18),
                  ('balestra', 'Balestra della marea', 1)]),
    ('mondo_giganti', 'stirpi', 'Il mondo dei giganti', ['ancestrale', 'cacciatori'],
     'alberi altissimi, colline enormi e creature antiche dappertutto, che cacciano in branco',
     {'trees': 2.0, 'hills': 2.0}, {'danger': 1.0, 'rare': 3.0, 'lumini': 2.0},
     'radice', [('spadone', 'Spadone del gigante', 16), ('accessorio', ['damage', 'defense'], 'Zanna del gigante', 26),
                ('tamburo', 'Tamburo dei giganti', 20)]),
]
PHASE = 11
KIND_ICON = {'amuleto': 'amuleto', 'anello': 'anello', 'accessorio': 'cuore'}


def build():
    genes, items, loot, effects = {}, {}, {}, {}
    for si, (gid, cat, name, combo, desc, gen, run, pal, objs) in enumerate(SECRETS):
        rows = []
        for k, o in enumerate(objs):
            iid = 'segreto_%s_%d' % (gid, k)
            if o[0] in KIND_ICON:
                kind, keys, nm, ai = o
                acc, words = _acc(keys, PHASE + 2)
                when, e, aw = ABILITIES[ai]
                eff = dict(e)
                eff['when'] = when
                if 'chance' not in eff and when in ('colpo', 'ferita'):
                    eff['chance'] = 1.0
                eff['name'] = nm
                eff['desc'] = aw
                effects[iid + '_e0'] = eff
                items[iid] = {'name': nm, 'kind': kind, 'icon': [KIND_ICON[kind], pal], 'fase': PHASE + 2, 'acc': acc,
                              'effects': [iid + '_e0'], 'segreto': gid,
                              'source': 'solo nel mondo segreto «%s»: i suoi scrigni e il suo Cuore' % name,
                              'desc': '%s. %s.' % (words[0].upper() + words[1:], aw[0].upper() + aw[1:])}
            else:
                f, nm, fx = o
                kind, _noun, icon = FORMS[f]
                when, e, words = WEAPON_FX[fx]
                eff = dict(e)
                eff['when'] = when
                eff['name'] = nm
                eff['desc'] = words
                effects[iid + '_e0'] = eff
                items[iid] = {'name': nm, 'kind': kind, 'form': f, 'fase': PHASE + 2, 'firma': True, 'power_mult': 1.15,
                              'icon': [icon, pal], 'effects': [iid + '_e0'], 'segreto': gid,
                              'source': 'solo nel mondo segreto «%s»: i suoi scrigni e il suo Cuore' % name,
                              'desc': 'Arma del mondo segreto «%s»: %s.' % (name, words)}
            rows.append({'item': iid, 'min': 1, 'max': 1, 'chance': 1.0, 'group': 'segreto'})
        loot['segreto_' + gid] = rows
        genes[gid] = {'cat': cat, 'name': name, 'rar': 3, 'dom': 1, 'good': True, 'only': 'mutazione', 'segreto': True,
                      'vmin': 4, 'combo': combo, 'desc': desc, 'gen': gen, 'run': run}
    adj = {'notte_infinita': ['Senzalba', 'Senzalba'], 'seminatori_vivi': ['Abitato', 'Abitata'],
           'mondo_cavo': ['Cavo', 'Cava'], 'mondo_acqua': ['Annegato', 'Annegata'], 'mondo_giganti': ['Gigante', 'Gigante']}
    return [('segreti.gd', 'Roadmap 45, voce 397: i semi segreti dei mondi',
             {'genes': genes, 'items': items, 'loot': loot, 'effects': effects, 'gene_adj': adj})]
