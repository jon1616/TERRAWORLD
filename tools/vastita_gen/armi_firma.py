"""Le armi firma (voce 370, Roadmap 40; piano in VASTITA.md).

Per ogni fase della spina (1-23) dieci armi uniche fuori dalla tabella forma × materiale: una per stile, più una
seconda di mischia e una seconda a distanza. Ognuna ha:
- una forma (i valori li fa il gioco: `FormsData.firma_stats`, la forma nella sua fase, un po' sopra il metallo);
- un nome suo (un nome della forma e un epiteto della fase, entrambi scritti a mano qui sotto);
- un elemento e una tavolozza secondo il tema della fase;
- uno o due effetti scelti da una libreria (`EFFECTS`, in partita da `Effects`), con la forza che cresce piano con la
  fase; le armi che tirano anche i loro moduli di volo (`MODS`);
- da dove viene: la tabella «firma_f<fase>» (uno a scelta tra le dieci), che tirano i Guardiani, i Signori, i
  Custodi, i capi delle maree e gli scrigni delle rovine secondo la fase del posto (`FirmaDrops`).
Nessuna arma firma è uguale a un'altra (forma, effetti e moduli insieme): il generatore lo controlla.
"""

STYLE_SLOTS = ['mischia', 'mischia', 'distanza', 'linfa', 'evocazione', 'lancio', 'canto', 'cura', 'radice', 'distanza']
STYLE_FORMS = {
    'mischia': ['spada', 'pugnale', 'spadone', 'lancia', 'martello', 'falcione', 'frusta', 'falcelunga', 'manopole',
                'egida', 'bipenne', 'randello'],
    'distanza': ['arco', 'fionda', 'balestra', 'cerbottana', 'lanciaspore'],
    'linfa': ['verga', 'tomo', 'sfera'],
    'evocazione': ['scettro'],
    'lancio': ['dischi', 'girandola'],
    'canto': ['buccina', 'flauto', 'tamburo'],
    'cura': ['virgulto'],
    'radice': ['semetorre', 'semebomba'],
}
FORM_KIND = {'spada': 'spada', 'pugnale': 'spada', 'spadone': 'spada', 'lancia': 'spada', 'martello': 'spada',
             'falcione': 'spada', 'frusta': 'spada', 'falcelunga': 'spada', 'manopole': 'spada', 'egida': 'spada',
             'bipenne': 'spada', 'randello': 'spada', 'arco': 'arco', 'fionda': 'arco', 'balestra': 'arco',
             'cerbottana': 'arco', 'lanciaspore': 'arco', 'verga': 'bastone', 'tomo': 'bastone', 'sfera': 'bastone',
             'scettro': 'evocatore', 'dischi': 'lancio', 'girandola': 'lancio', 'buccina': 'strumento',
             'flauto': 'strumento', 'tamburo': 'strumento', 'virgulto': 'ramo', 'semetorre': 'semeguerra',
             'semebomba': 'semeguerra'}
RANGED = {'arco', 'fionda', 'balestra', 'cerbottana', 'lanciaspore', 'verga', 'tomo', 'sfera', 'dischi', 'girandola',
          'buccina', 'flauto', 'virgulto', 'semetorre', 'semebomba'}
ICON = {'martello': 'mazza'}
# i nomi delle forme (tre per forma, si alternano)
NOUNS = {
    'spada': ['Lama', 'Spada', 'Fendente'], 'pugnale': ['Pugnale', 'Spina', 'Morso'],
    'spadone': ['Spadone', 'Grande lama', 'Mietitrice'], 'lancia': ['Lancia', 'Picca', 'Asta'],
    'martello': ['Maglio', 'Martello', 'Mazza'], 'falcione': ['Falce', 'Falcetto', 'Roncola'],
    'frusta': ['Frusta', 'Sferza', 'Liana'], 'falcelunga': ['Falce lunga', 'Mietitore', 'Arco di lama'],
    'manopole': ['Manopole', 'Pugni', 'Nocche'], 'egida': ['Egida', 'Scudo', 'Brocchiere'],
    'bipenne': ['Bipenne', 'Scure', 'Ascia gemella'], 'randello': ['Randello', 'Clava', 'Bastone ferrato'],
    'arco': ['Arco', 'Arco lungo', 'Arco ricurvo'], 'fionda': ['Fionda', 'Frombola', 'Tirasassi'],
    'balestra': ['Balestra', 'Trafiggitrice', 'Arbalesta'], 'cerbottana': ['Cerbottana', 'Soffio', 'Canna da soffio'],
    'lanciaspore': ['Lanciaspore', 'Bocca di spore', 'Soffione'], 'verga': ['Verga', 'Bacchetta', 'Ramo di Linfa'],
    'tomo': ['Tomo', 'Libro', 'Erbario'], 'sfera': ['Sfera', 'Globo', 'Occhio'], 'scettro': ['Scettro', 'Richiamo', 'Bastone del branco'],
    'dischi': ['Dischi', 'Ruote', 'Lune'], 'girandola': ['Girandola', 'Ritorno', 'Ala ricurva'],
    'buccina': ['Buccina', 'Corno', 'Conchiglia'], 'flauto': ['Flauto', 'Zufolo', 'Canna'],
    'tamburo': ['Tamburo', 'Timpano', 'Rombo'], 'virgulto': ['Virgulto', 'Germoglio', 'Ramo di Rugiada'],
    'semetorre': ['Seme-torre', 'Seme di guardia', 'Ghianda di guerra'], 'semebomba': ['Seme-bomba', 'Baccello', 'Noce di fuoco'],
}
PLURAL_NOUNS = {'Manopole', 'Pugni', 'Nocche', 'Dischi', 'Ruote', 'Lune'}
# fase: (tema per la descrizione, elemento, tavolozze, dieci epiteti: complementi, così vanno con ogni nome)
PHASES = {
    1: ('le prime radici', '', ['radicite', 'muschio'],
        ['delle prime radici', 'del germoglio', 'del muschio', 'del primo mattino', 'della terra smossa',
         'dei primi passi', 'della radice bassa', 'del sottobosco', 'della lanterna', 'del seme caduto']),
    2: ('il Nodo Avvizzito', 'spora', ['nodo', 'humus'],
        ['del Nodo', 'della muffa', 'del legno malato', 'della radice storta', 'dell\'avvizzito',
         'della corteccia nera', 'del Cuore stanco', 'del primo Guardiano', 'della linfa spenta', 'del nodo spezzato']),
    3: ('il legnoferro', '', ['legnoferro', 'ardesia'],
        ['del legnoferro', 'delle Caverne', 'dell\'ardesia', 'della vena dura', 'della galleria',
         'del minatore', 'della roccia blu', 'della lunga discesa', 'del pozzo', 'dell\'eco di pietra']),
    4: ('la Regina delle Spore', 'spora', ['fungo', 'nottilite'],
        ['della Regina', 'delle spore', 'dello sciame', 'del velo viola', 'della palude',
         'del polline nero', 'dell\'alveare', 'della fungaia', 'del ronzio', 'della seconda corona']),
    5: ('l\'ambra', 'luce', ['ambra', 'brillaluce'],
        ['dell\'ambra', 'della luce fossile', 'della goccia d\'oro', 'del tempo fermo', 'della resina antica',
         'dell\'insetto prigioniero', 'del tramonto', 'della lucciola', 'del miele', 'della colonna d\'ambra']),
    6: ('il Colosso d\'Ardesia', 'gelo', ['ardesia', 'scisto'],
        ['del Colosso', 'della montagna', 'del passo pesante', 'della frana', 'della pietra che batte',
         'del terzo Guardiano', 'della valanga', 'del gigante', 'della roccia viva', 'del masso']),
    7: ('la Linfa', 'linfa', ['linfa', 'lagunite'],
        ['della Linfa', 'della sorgente', 'del lago chiaro', 'della goccia viva', 'della vena turchese',
         'del fiume sotterraneo', 'della marea bassa', 'del cristallo', 'della risacca', 'dell\'acqua che canta']),
    8: ('il Risveglio del Cuore', 'luce', ['cristallo', 'iride'],
        ['del Risveglio', 'del Cuore desto', 'del battito', 'del quarto Cuore', 'della radice nuova',
         'dell\'alba', 'del primo battito', 'della soglia', 'del sonno spezzato', 'della Linfa del Cuore']),
    9: ('la vuotite', 'vuoto', ['vuotite', 'nottilite'],
        ['del Vuoto', 'della vuotite', 'dell\'abisso', 'del silenzio', 'della notte senza stelle',
         'del bordo del mondo', 'del niente', 'dell\'eco muta', 'della caduta', 'del Fondo']),
    10: ('i Giardini perduti', 'linfa', ['muschio', 'lucciola'],
         ['dei Giardini perduti', 'del Giardino sommerso', 'del Giardino di ferro', 'del Giardino selvatico',
          'del Giardino muto', 'dell\'Albero dimenticato', 'del cervo di rovo', 'della serra sepolta',
          'del giardiniere perduto', 'della quarta cura']),
    11: ('lo stellare', 'luce', ['stelle', 'celeste'],
         ['delle stelle', 'della stella caduta', 'del cratere', 'della notte chiara', 'della cometa',
          'del firmamento', 'della polvere di stelle', 'dell\'osservatorio', 'della costellazione', 'del cielo alto']),
    12: ('le rocce risvegliate', 'brace', ['tizzonite', 'brace'],
         ['delle rocce sveglie', 'della brace', 'della vena calda', 'del fiume di brace', 'della cenere',
          'del vulcano', 'della fucina', 'del tizzone', 'del calore antico', 'della terra che pulsa']),
    13: ('la corallite', 'linfa', ['corallite', 'sanguinella'],
         ['del corallo', 'della barriera', 'del mare di Linfa', 'della conchiglia', 'dell\'onda rosa',
          'della scogliera', 'del fondale', 'della perla', 'della marea alta', 'dell\'abisso rosa']),
    14: ('il Seme Nero', 'vuoto', ['nottilite', 'nodo'],
         ['del Seme Nero', 'del guscio spezzato', 'dell\'Avvizzitore', 'della crepa', 'della Bocca',
          'della scelta', 'della linfa nera', 'dell\'ombra lunga', 'del seme maledetto', 'del perdono']),
    15: ('la sanguinite', 'brace', ['sanguinite', 'tizzonite'],
         ['del sangue', 'della sanguinite', 'del cuore rosso', 'della vena pulsante', 'della ferita',
          'del guerriero', 'della furia', 'della battaglia', 'del sacrificio', 'del giuramento']),
    16: ('i mondi lontani', 'gelo', ['brina', 'pallidite'],
         ['dei mondi lontani', 'del viandante', 'della radice viandante', 'della strada lunga', 'del confine',
          'dell\'ultimo portale', 'della brina eterna', 'del ghiacciaio', 'della tormenta', 'del lungo inverno']),
    17: ('il cuorelegno', 'spora', ['cuorelegno', 'legno'],
         ['del cuorelegno', 'della radice gigante', 'dell\'Albero antico', 'del bosco vivo', 'della corteccia d\'oro',
          'del tronco cavo', 'della linfa dura', 'dell\'anello del tempo', 'del ramo maestro', 'della chioma']),
    18: ('le radici del cosmo', 'luce', ['cielo', 'iride'],
         ['delle radici del cosmo', 'dell\'Albero-Madre', 'del Giardino dei Semi', 'della radice infinita',
          'del cosmo', 'della volta', 'della via lattea', 'del seminatore', 'del mondo intero', 'della rete dei mondi']),
    19: ('l\'eterite', 'gelo', ['eterite', 'nuvola'],
         ['dell\'etere', 'dell\'eterite', 'del vento alto', 'della nuvola', 'del respiro del cielo',
          'della tempesta', 'del fulmine', 'del cielo sottile', 'della quota', 'dell\'aria pura']),
    20: ('il Primo Mondo', 'luce', ['folgorite', 'tempesta'],
         ['del Primo Mondo', 'del principio', 'del primo giorno', 'della prima luce', 'del mondo intatto',
          'dell\'Albero Antico', 'della radura', 'del mosaico', 'del primo seme', 'del tempo prima']),
    21: ('l\'astrite', 'luce', ['astrite', 'stelle'],
         ['dell\'astrite', 'degli astri', 'della stella del mattino', 'della costellazione nascosta', 'del cielo profondo',
          'dell\'orbita', 'della luna', 'del sole nero', 'della galassia', 'del cielo che cade']),
    22: ('l\'ultimo Seminatore', 'vuoto', ['sem', 'nottilite'],
         ['dell\'ultimo Seminatore', 'di Maesh', 'dei Seminatori', 'della promessa', 'del custode del seme',
          'dell\'ultimo canto', 'della memoria', 'del sonno lungo', 'dell\'addio', 'del ricordo']),
    23: ('la primambra', 'luce', ['primambra', 'brillaluce'],
         ['della primambra', 'del Seme Primo', 'della prima linfa', 'dell\'Albero d\'oro', 'dell\'eternità',
          'della fine', 'del nuovo inizio', 'del Giardiniere', 'del Giardino eterno', 'della luce prima']),
}

# la libreria degli effetti: (id della ricetta, campi). «k» = parametri che crescono con la fase (moltiplicati).
EFFECTS = [
    ('brucia', {'when': 'colpo', 'chance': 0.4, 'do': 'brucia', 't': 4.0}, 'un colpo su tre o più incendia a lungo'),
    ('gela', {'when': 'colpo', 'chance': 0.35, 'do': 'gela', 't': 2.5}, 'spesso gela la creatura'),
    ('stordisce', {'when': 'colpo', 'chance': 0.2, 'do': 'stordisce', 't': 0.6}, 'un colpo su cinque stordisce'),
    ('schegge', {'when': 'colpo', 'chance': 0.25, 'do': 'schegge', 'n': 4, 'dmg': 0.4}, 'un colpo su quattro lancia quattro schegge'),
    ('catena', {'when': 'ogni', 'n': 5, 'do': 'catena', 'targets': 3, 'dmg': 0.6, 'r': 7}, 'ogni quinto colpo un fulmine salta su tre creature'),
    ('cura', {'when': 'colpo', 'chance': 1.0, 'do': 'cura', 'frac': 0.05}, 'ogni colpo rende il 5% del danno in Vita'),
    ('lumini', {'when': 'colpo', 'chance': 0.12, 'do': 'lumini', 'n': 1}, 'a volte il colpo fa cadere un Lumino'),
    ('corsa', {'when': 'uccisione', 'do': 'corsa', 'mult': 1.3, 't': 3.0}, 'dopo ogni creatura sconfitta corri più svelto'),
    ('ombra', {'when': 'uccisione', 'do': 'ombra', 'mult': 0.6, 't': 4.0}, 'dopo ogni creatura sconfitta le altre ti vedono meno'),
    ('onda', {'when': 'ogni', 'n': 4, 'do': 'onda', 'dmg': 0.8, 'pierce': 3}, 'ogni quarto colpo un\'onda vola dritta e attraversa'),
    ('sanguina', {'when': 'colpo', 'chance': 0.3, 'do': 'sanguina', 't': 3.0, 'dps': 0.3}, 'un colpo su tre fa sanguinare'),
    ('scoppio', {'when': 'ogni', 'n': 4, 'do': 'scoppio', 'r': 3, 'dmg': 0.7}, 'ogni quarto colpo scoppia e ferisce attorno'),
    ('trapassa', {'when': 'colpo', 'chance': 0.35, 'do': 'trapassa', 'len': 3, 'dmg': 0.5}, 'spesso passa a chi sta dietro'),
    ('scossa', {'when': 'ogni', 'n': 7, 'do': 'scossa', 'r': 3, 't': 0.7}, 'ogni settimo colpo stordisce tutto attorno'),
    ('tira', {'when': 'colpo', 'chance': 0.2, 'do': 'tira'}, 'a volte tira la creatura verso di te'),
    ('linfa', {'when': 'uccisione', 'do': 'linfa', 'n': 3}, 'ogni creatura sconfitta ti rende Linfa'),
    ('pioggia', {'when': 'ogni', 'n': 5, 'do': 'pioggia', 'shards': 4, 'dmg': 0.5}, 'ogni quinto colpo piovono stelle'),
    ('avvelena', {'when': 'colpo', 'chance': 0.45, 'do': 'avvelena', 't': 5.0}, 'spesso avvelena'),
    ('vulnera', {'when': 'colpo', 'chance': 0.3, 'do': 'vulnera', 't': 3.0}, 'un colpo su tre rende la creatura vulnerabile'),
    ('riflesso', {'when': 'ferita', 'chance': 1.0, 'do': 'riflesso', 'frac': 0.4}, 'chi ti ferisce riceve il 40% del colpo'),
    ('furia', {'when': 'se', 'cond': 'vita_bassa', 'do': 'danno', 'mult': 1.4}, 'con poca Vita colpisce il 40% più forte'),
    ('notte', {'when': 'se', 'cond': 'notte', 'do': 'danno', 'mult': 1.25}, 'di notte colpisce il 25% più forte'),
    ('profondo', {'when': 'se', 'cond': 'sottoterra', 'do': 'danno', 'mult': 1.2}, 'sotto terra colpisce il 20% più forte'),
    ('sole', {'when': 'se', 'cond': 'superficie', 'do': 'danno', 'mult': 1.2}, 'in superficie colpisce il 20% più forte'),
    ('fermo', {'when': 'se', 'cond': 'fermo', 'do': 'danno', 'mult': 1.3}, 'stando fermi colpisce il 30% più forte'),
    ('acqua', {'when': 'se', 'cond': 'acqua', 'do': 'danno', 'mult': 1.4}, 'nell\'acqua colpisce il 40% più forte'),
    ('quiete', {'when': 'se', 'cond': 'fermo', 'do': 'rigenera', 'mult': 2.0}, 'stando fermi la Vita ricresce il doppio'),
    ('brace_notte', {'when': 'colpo', 'cond': 'notte', 'chance': 0.6, 'do': 'brucia', 't': 4.0}, 'di notte quasi ogni colpo incendia'),
    ('catena_fondo', {'when': 'colpo', 'cond': 'sottoterra', 'chance': 0.3, 'do': 'catena', 'targets': 2, 'dmg': 0.6, 'r': 6},
     'sotto terra un colpo su tre salta su altre due creature'),
    ('gelo_sole', {'when': 'colpo', 'cond': 'superficie', 'chance': 0.5, 'do': 'gela', 't': 3.0}, 'in superficie un colpo su due gela'),
    ('furia_scoppio', {'when': 'colpo', 'cond': 'vita_bassa', 'chance': 0.5, 'do': 'scoppio', 'r': 3, 'dmg': 0.8},
     'con poca Vita un colpo su due scoppia attorno'),
]
# le frazioni del danno («dmg», «frac») crescono un poco con la fase: le armi firma tarde sono anche più ricche
GROW = ('dmg', 'frac')
MODS = [{}, {'bounce': 2}, {'split': [3, 0.35]}, {'boom': [2.0, 0.45]}, {'ret': 0.5}, {'wave': 10.0, 'speed': 1.2},
        {'pierce': 2}, {'homing': 3.0}, {'split': [2, 0.5], 'homing': 2.0}, {'bounce': 1, 'pierce': 1},
        {'boom': [1.5, 0.35], 'homing': 2.0}, {'ret': 0.45, 'pierce': 1}]


def _up(t):
    return t[:1].upper() + t[1:]


def _eff(base, phase):
    e = dict(base)
    for k in GROW:
        if k in e:
            e[k] = round(e[k] * (1.0 + 0.02 * (phase - 1)), 3)
    return e


def build():
    items, effects, loot = {}, {}, {}
    seen = set()
    style_count = {}
    n = len(EFFECTS)
    for p in range(1, 24):
        theme, elem, pals, epithets = PHASES[p]
        table = []
        for slot, style in enumerate(STYLE_SLOTS):
            forms = STYLE_FORMS[style]
            k = style_count.get(style, 0)
            style_count[style] = k + 1
            form = forms[(k * 5 + p) % len(forms)] if len(forms) > 1 else forms[0]
            # gli effetti: uno (due per la mischia e per chi non tira), scelti girando la libreria
            e1 = (p * 7 + slot * 11) % n
            e2 = (p * 13 + slot * 5 + 3) % n
            fxs = [e1] if form in RANGED else [e1, e2 if e2 != e1 else (e2 + 1) % n]
            mods = MODS[(p * 3 + slot * 7) % len(MODS)] if form in RANGED else {}
            sig = (form, tuple(sorted(fxs)), tuple(sorted((a, str(b)) for a, b in mods.items())))
            while sig in seen:
                fxs = [(x + 1) % n for x in fxs]
                sig = (form, tuple(sorted(fxs)), tuple(sorted((a, str(b)) for a, b in mods.items())))
            seen.add(sig)
            iid = 'firma_f%d_%d' % (p, slot)
            noun = NOUNS[form][(p + slot) % 3]
            name = '%s %s' % (noun, epithets[slot])
            eff_ids = []
            descs = []
            for j, ei in enumerate(fxs):
                rid, body, desc = EFFECTS[ei]
                eid = '%s_e%d' % (iid, j)
                e = _eff(body, p)
                e['name'] = name if j == 0 else '%s (2)' % name
                e['desc'] = desc
                effects[eid] = e
                eff_ids.append(eid)
                descs.append(desc)
            pal = pals[slot % len(pals)]
            it = {'name': name, 'kind': FORM_KIND[form], 'form': form, 'fase': p, 'firma': True,
                  'icon': [ICON.get(form, form), pal], 'effects': eff_ids,
                  'source': 'una delle armi firma della fase %d (%s): Guardiani, Signori, Custodi, capi delle maree e scrigni delle rovine di quella fase' % (p, theme),
                  'desc': 'Arma firma della fase %d, %s: si trova, non si fabbrica. %s.' % (p, theme, _up('; '.join(descs)))}
            if elem:
                it['elem'] = elem
            if mods:
                it['mods'] = mods
            if noun in PLURAL_NOUNS:
                it['plural'] = True
            items[iid] = it
            table.append({'item': iid, 'min': 1, 'max': 1, 'chance': 1.0, 'group': 'firma'})
        loot['firma_f%d' % p] = table
    header = ('Le armi firma (voce 370): dieci armi uniche per ogni fase della spina, una per stile più due, ' +
              'con un nome, un elemento, effetti e moduli loro. Le tabelle «firma_f<fase>» le tirano `FirmaDrops` e gli scrigni.')
    recipes = build_lines(items, effects)
    return [('armi_firma.gd', header, {'items': items, 'effects': effects, 'loot': loot, 'recipes': recipes})]


# --- voce 371: le linee d'arma -------------------------------------------------------------------------------------
# Per ogni stile una linea di sei passi al Maglio dei Seminatori: ogni passo fonde il passo prima con due armi firma di
# quello stile (di due fasi della sua fascia) e lingotti del metallo della fascia; ne prende gli effetti. Il sesto è
# l'arma suprema dello stile, come la Zenith di Terraria: tutte le armi firma della linea in una.
LINES = {
    'mischia': ('spada', 'Lama', 'f', 'La Radice del mondo'),
    'distanza': ('arco', 'Arco', 'm', 'L\'Arco del firmamento'),
    'linfa': ('verga', 'Verga', 'f', 'La Verga dell\'Albero-Madre'),
    'evocazione': ('scettro', 'Scettro', 'm', 'Lo Scettro del Giardino'),
    'lancio': ('girandola', 'Girandola', 'f', 'La Girandola delle stagioni'),
    'canto': ('buccina', 'Buccina', 'f', 'La Buccina dei Seminatori'),
    'cura': ('virgulto', 'Virgulto', 'm', 'Il Virgulto del Seme Primo'),
    'radice': ('semetorre', 'Seme', 'm', 'Il Seme del primo bosco'),
}
STEP_NAMES = [('intrecciata', 'intrecciato'), ('delle due radici', 'delle due radici'), ('dei tre Cuori', 'dei tre Cuori'),
              ('dei quattro Giardini', 'dei quattro Giardini'), ('delle cinque stelle', 'delle cinque stelle')]
STEP_BARS = ['legnoferro', 'linfa', 'stellare', 'sanguinite', 'eterite', 'primambra']
STEP_PAL = ['legnoferro', 'linfa', 'stelle', 'sanguinite', 'eterite', 'primambra']
SUPREME = {'when': 'ogni', 'n': 3, 'do': 'pioggia', 'shards': 6, 'dmg': 0.6}


def build_lines(items, effects):
    recipes = []
    by_style = {}
    for iid, it in items.items():
        style = next(s for s, fs in STYLE_FORMS.items() if it['form'] in fs)
        by_style.setdefault(style, []).append((it['fase'], iid))
    for style, (form, noun, g, supreme) in LINES.items():
        pool = sorted(by_style[style])
        prev = ''
        for k in range(1, 7):
            lo, hi = 4 * k - 3, min(4 * k, 23)
            band = [iid for (p, iid) in pool if lo <= p <= hi] or [iid for (p, iid) in pool if p >= lo]
            pick = [band[0], band[-1]] if len(band) > 1 else band * 2
            pick = list(dict.fromkeys(pick))
            lid = 'linea_%s_%d' % (style, k)
            fx = []
            if prev:
                fx.append(items[prev]['effects'][0])
            for f in pick:
                fx.append(items[f]['effects'][0])
            name = supreme if k == 6 else '%s %s' % (noun, STEP_NAMES[k - 1][0 if g == 'f' else 1])
            if k == 6:
                effects['%s_suprema' % lid] = dict(SUPREME, name=supreme, desc='ogni terzo colpo piovono sei stelle')
                fx.append('%s_suprema' % lid)
            it = {'name': name, 'kind': FORM_KIND[form], 'form': form, 'fase': min(4 * k + 1, 23), 'firma': True,
                  'power_mult': 1.0 + 0.05 * k + (0.15 if k == 6 else 0.0),
                  'icon': [ICON.get(form, form), STEP_PAL[k - 1]], 'effects': fx, 'linea': style,
                  'source': 'al Maglio dei Seminatori, fondendo armi firma (linea %s, passo %d di 6)' % (style, k),
                  'desc': ('L\'arma suprema dello stile: tutte le armi firma della linea in una. ' if k == 6 else
                           'Un passo della linea dello stile (%d di 6): porta gli effetti delle armi che l\'hanno fatta. ' % k)
                  + 'Si fa al Maglio dei Seminatori.'}
            if style != 'mischia' and form in RANGED:
                it['mods'] = MODS[(k * 5) % len(MODS)]
            items[lid] = it
            ins = {f: 1 for f in pick}
            if prev:
                ins[prev] = 1
            ins['lingotto_' + STEP_BARS[k - 1]] = 4 + 2 * k
            recipes.append({'out': lid, 'qty': 1, 'in': ins, 'station': 'maglio'})
            prev = lid
    return recipes
