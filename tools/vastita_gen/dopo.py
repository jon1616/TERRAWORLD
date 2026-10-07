"""Il dopo senza fine (Roadmap 51, voci 409-410; piano in VASTITA.md).

- **Le fasi del dopo** (voce 409): oltre la spina, ogni cinque vigori (13, 18, 23, 28, 33, 38) una fase con il suo
  metallo (in `SpineData.METALS`, con carattere, set e gesto), **dieci armi** con due moduli rari ciascuna e il **Sacchetto
  del dopo** che i Guardiani generati lasciano in quei mondi (`FirmaDrops.bag`).
- **Le armi leggendarie** (voce 410): ventiquattro, quattro per fase del dopo: un nome, una storia breve (il canone della
  storia vera: i Seminatori sono i Guardiani), tre moduli e due effetti. Poche e preziose: dal Sacchetto del dopo (una
  volta su cinque) e dai capi dei mondi del dopo (`FirmaDrops.LEGEND`).
La forza segue la crescita lenta delle creature oltre la spina: il filo del metallo della fase sopra quello della fase 23.
"""
from vastita_gen.rari import FORMS, WEAPON_FX

METALS = [('aurorite', 271), ('sognite', 312), ('abissite', 359), ('memorite', 413), ('crepuscolite', 475), ('seminite', 546)]
FIRMA_23 = 9.0 * 1.16 ** 22 * 1.15            # il filo di un'arma firma della fase 23 (`FormsData.virtual_mat`)
RARE_MODS = [{'split': [4, 0.35], 'homing': 3.0}, {'bounce': 3, 'pierce': 2}, {'boom': [3.0, 0.5], 'ret': 0.5},
             {'wave': 12.0, 'split': [3, 0.4]}, {'homing': 4.0, 'pierce': 3}, {'ret': 0.6, 'bounce': 2},
             {'boom': [2.5, 0.6], 'homing': 2.5}, {'split': [5, 0.3], 'wave': 10.0}]
FORMS_AFTER = ['spadone', 'falcelunga', 'balestra', 'tomo', 'sfera', 'girandola', 'buccina', 'virgulto', 'scettro', 'egida',
               'lancia', 'arco', 'dischi', 'tamburo', 'semetorre', 'bipenne', 'cerbottana', 'flauto', 'martello', 'fionda']
LEGENDS = [
    ('Ultima Radice', 'spadone', 'La spada di chi piantò il primo mondo. Nessuno la riconosce più, nemmeno lei.'),
    ('Canto di chi resta', 'buccina', 'Suonava per chiamare i Seminatori a casa. Una sera non tornò nessuno.'),
    ('Occhio del Custode', 'sfera', 'Guardava i mondi dall\'alto. Ha visto il Seme Nero cadere e non ha chiuso le palpebre.'),
    ('Falce del lungo inverno', 'falcelunga', 'Mieteva ciò che il gelo aveva già preso. Non c\'era molto da mietere.'),
    ('Arco senza corda', 'arco', 'La corda si è spezzata in un mondo che non esiste più. Tira lo stesso.'),
    ('Scettro del primo branco', 'scettro', 'Le bestie lo seguivano quando i Seminatori avevano ancora un volto.'),
    ('Ramo che non secca', 'virgulto', 'Tagliato dall\'Albero-Madre quando era giovane. Lei se ne ricorda.'),
    ('Pagine del Giardiniere', 'tomo', 'Mancano le ultime. Qualcuno le ha strappate prima di diventare Guardiano.'),
    ('Scudo della promessa', 'egida', 'Doveva proteggere un mondo. Ha protetto chi lo ha distrutto.'),
    ('Girandola del vento fermo', 'girandola', 'Gira anche dove l\'aria non si muove più.'),
    ('Lancia del confine', 'lancia', 'Segnava dove finiva il Giardino. Il confine si è spostato; lei no.'),
    ('Tamburo del cuore spento', 'tamburo', 'Batte al ritmo di un Cuore che si è fermato da secoli.'),
    ('Balestra della sentinella', 'balestra', 'La sentinella aspettava il nemico dall\'esterno. Era già dentro.'),
    ('Dischi della semina', 'dischi', 'Con questi si spargevano i semi dei mondi. Ora si spargono altre cose.'),
    ('Seme-torre dell\'ultimo assedio', 'semetorre', 'Crebbe davanti a una porta che nessuno ha più aperto.'),
    ('Bipenne del boscaiolo cieco', 'bipenne', 'Tagliava alberi che non vedeva. Li sentiva cadere.'),
    ('Soffio della palude antica', 'cerbottana', 'Le spore che soffia erano vive prima del primo mondo.'),
    ('Flauto del sonno', 'flauto', 'Chi lo sente dorme. Chi lo suona, no: mai più.'),
    ('Maglio del Seminatore', 'martello', 'Ha forgiato le Aiuole. Ha forgiato anche la gabbia del Cuore.'),
    ('Fionda del bambino', 'fionda', 'L\'unica cosa piccola rimasta dei Seminatori. Pesa più di tutte.'),
    ('Lama dell\'Eco', 'spadone', 'Ha la tua stessa impugnatura. Non chiederti perché.'),
    ('Libro del Seme Nero', 'tomo', 'Le pagine sono bianche. Si scrivono da sole quando le leggi.'),
    ('Sfera del mondo spento', 'sfera', 'Dentro gira un mondo piccolo, al buio. Si sente ancora qualcuno.'),
    ('Ramo dell\'Albero Antico', 'virgulto', 'Il primo ramo del primo albero. Fiorisce ogni volta che qualcuno muore.'),
]


def build():
    items, effects, loot = {}, {}, {}
    used = set()
    for k, (metal, filo) in enumerate(METALS):
        pm = round(filo * 1.15 / FIRMA_23, 3)
        rows = []
        for i in range(10):
            f = FORMS_AFTER[(k * 3 + i) % len(FORMS_AFTER)]
            kind, noun, icon = FORMS[f]
            fi = (k * 7 + i * 5 + 1) % len(WEAPON_FX)
            while (f, fi) in used:
                fi = (fi + 1) % len(WEAPON_FX)
            used.add((f, fi))
            when, e, words = WEAPON_FX[fi]
            iid = 'dopo_%d_%d' % (k, i)
            nm = '%s %s' % (noun, {'aurorite': 'dell\'aurora', 'sognite': 'del sogno', 'abissite': 'dell\'abisso',
                                   'memorite': 'della memoria', 'crepuscolite': 'del crepuscolo', 'seminite': 'del Seminatore'}[metal])
            if i >= 5:
                nm += ' antico'
            eff = dict(e)
            eff['when'] = when
            eff['name'] = nm
            eff['desc'] = words
            effects[iid + '_e0'] = eff
            items[iid] = {'name': nm, 'kind': kind, 'form': f, 'fase': 23, 'firma': True, 'power_mult': round(pm * (1.0 + 0.02 * i), 3),
                          'icon': [icon, metal], 'effects': [iid + '_e0'], 'mods': dict(RARE_MODS[(k + i) % len(RARE_MODS)]),
                          'dopo': k + 1, 'source': 'il Sacchetto del dopo dei mondi di vigore %d-%d' % (13 + 5 * k, 17 + 5 * k),
                          'desc': 'Un\'arma del dopo: %s; i suoi colpi portano due moduli rari.' % words}
            rows.append({'item': iid, 'min': 1, 'max': 1, 'chance': 1.0, 'group': 'arma'})
        # le leggendarie di questa fase
        leg = []
        for j in range(4):
            li = k * 4 + j
            name, f, story = LEGENDS[li]
            kind, _noun, icon = FORMS[f]
            iid = 'leggenda_%d' % li
            fx = []
            for q in range(2):
                when, e, words = WEAPON_FX[(li * 3 + q * 11 + 4) % len(WEAPON_FX)]
                eff = dict(e)
                eff['when'] = when
                eff['name'] = name
                eff['desc'] = words
                effects['%s_e%d' % (iid, q)] = eff
                fx.append('%s_e%d' % (iid, q))
            mods = dict(RARE_MODS[li % len(RARE_MODS)])
            mods.update(RARE_MODS[(li + 3) % len(RARE_MODS)])
            items[iid] = {'name': name, 'kind': kind, 'form': f, 'fase': 23, 'firma': True, 'power_mult': round(pm * 1.3, 3),
                          'icon': [icon, 'iride'], 'effects': fx, 'mods': mods, 'leggendaria': True, 'dopo': k + 1,
                          'source': 'leggendaria: il Sacchetto del dopo e i capi dei mondi di vigore %d e oltre' % (13 + 5 * k),
                          'desc': story}
            leg.append(iid)
        loot['leggende_dopo_%d' % k] = [{'item': x, 'min': 1, 'max': 1, 'chance': 1.0, 'group': 'leggenda'} for x in leg]
        bag = 'sacchetto_dopo_%d' % k
        loot[bag] = rows + [{'item': x, 'min': 1, 'max': 1, 'chance': 0.2, 'group': 'leggenda'} for x in leg] + \
            [{'item': 'lingotto_' + metal, 'min': 12, 'max': 20, 'chance': 1.0},
             {'item': 'lumino', 'min': 900 + 300 * k, 'max': 1300 + 400 * k, 'chance': 1.0},
             {'item': 'linfa_antica', 'min': 1, 'max': 3, 'chance': 1.0}]
        items[bag] = {'name': 'Sacchetto del dopo %s' % ['I', 'II', 'III', 'IV', 'V', 'VI'][k], 'kind': 'sacchetto',
                      'icon': ['sacca', metal], 'table': bag, 'stack': 10,
                      'source': 'i Guardiani dei mondi di vigore %d-%d' % (13 + 5 * k, 17 + 5 * k),
                      'desc': 'Clic per aprirlo: un\'arma del dopo, i lingotti del suo metallo, Lumini, Linfa antica e, una volta su cinque, un\'arma leggendaria.'}
    return [('dopo.gd', 'Roadmap 51, voci 409-410: le armi del dopo, i Sacchetti del dopo e le armi leggendarie',
             {'items': items, 'effects': effects, 'loot': loot})]
