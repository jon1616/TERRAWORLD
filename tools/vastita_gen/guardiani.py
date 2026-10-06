"""I Guardiani della spina e i loro tesori (voci 373-374, Roadmap 41; piano in VASTITA.md).

- Nove Guardiani scritti a mano per i mondi di vigore 4-12 (prima erano generati dal seme): un corpo preso da una
  specie (il disegno della specie, ingrandito, del colore dell'elemento), due fasi (a metà Vita arriva la «furia»:
  attacchi nuovi, e l'elemento cambia), un'arena che cambia per alcuni (pilastri, maree, correnti). Sono pezzi senza
  nome dei Seminatori (il canone in UNIVERSO.md): gli abitanti li chiamano con un soprannome.
- Per ognuno dei dodici Guardiani della spina (i tre di prima compresi) un **Sacchetto** (come i Treasure Bag): una o
  due armi firma della sua fase, il suo accessorio (raro dopo il primo), il trofeo (raro), il suo Richiamo, i lingotti
  del metallo della fase. Anche uno per i Guardiani generati del dopo.
"""

# id: (vigore, nome, corpo, volo, elemento, elemento della seconda fase, comportamenti, furia, parametri,
#      colore, frase del risveglio)
GUARDIANS = [
    ('falena', 4, 'La Falena del primo buio', 'falena_firmamento', True, 'luce', 'vuoto',
     ['vola', 'ventaglio', 'scatto'], ['evoca', 'teletrasporto'],
     {'fan_rate': 2.4, 'fan_n': 7, 'fan_spread': 1.1, 'shot_speed': 170.0, 'shot_grav': 40.0, 'shot_damage': 19,
      'dash_every': 5.5, 'dash_speed': 310.0, 'dash_time': 0.5, 'summon_every': 9.0, 'summon_max': 3,
      'summon': 'falena_brace', 'blink_every': 5.0},
     '#fff08a', 'Le ali si aprono e la luce del Cuore si spegne: la Falena del primo buio'),
    ('tessitore', 5, 'Il Tessitore delle radici', 'tessiradice', False, 'spora', 'brace',
     ['cammina', 'tessitore', 'spara'], ['rimodella', 'carica'],
     {'web_every': 5.0, 'rate': 2.4, 'shot_speed': 220.0, 'shot_grav': 200.0, 'shot_damage': 22,
      'pillar_every': 6.5, 'pillars': 3, 'charge': 290.0, 'charge_range': 20, 'charge_time': 1.0, 'charge_cool': 4.0},
     '#b88af0', 'Le radici del Cuore si muovono da sole: il Tessitore delle radici'),
    ('marea', 6, 'La Marea muta', 'polpo_stagno', True, 'linfa', 'gelo',
     ['vola', 'marea', 'spara'], ['correnti', 'evoca'],
     {'tide_every': 7.0, 'tide_cells': 12, 'rate': 2.2, 'shot_speed': 230.0, 'shot_grav': 80.0, 'shot_damage': 22,
      'gust_every': 7.0, 'summon_every': 9.0, 'summon_max': 3, 'summon': 'anguilla_brace'},
     '#5cf0d8', 'Il Cuore si allaga senza un rumore: la Marea muta'),
    ('mietistelle', 7, 'Il Mietitore di stelle', 'mangiastelle', False, 'luce', 'vuoto',
     ['cammina', 'salta_verso', 'spara'], ['teletrasporto', 'carica'],
     {'jump': 320.0, 'rate': 2.0, 'shot_speed': 240.0, 'shot_grav': 300.0, 'shot_damage': 24, 'blink_every': 4.5,
      'charge': 300.0, 'charge_range': 20, 'charge_time': 1.0, 'charge_cool': 4.0},
     '#ffe0a0', 'Qualcosa raccoglie le stelle cadute nel Cuore: il Mietitore di stelle'),
    ('ospite', 8, 'L\'Ospite del Vuoto', 'vagavuoto', True, 'vuoto', 'luce',
     ['vola', 'scatto', 'ventaglio'], ['evoca', 'correnti', 'teletrasporto'],
     {'dash_every': 5.0, 'dash_speed': 330.0, 'dash_time': 0.5, 'fan_rate': 2.6, 'fan_n': 8, 'fan_spread': 1.3,
      'shot_speed': 180.0, 'shot_grav': 40.0, 'shot_damage': 22, 'summon_every': 8.5, 'summon_max': 3,
      'summon': 'bolla_vuoto', 'gust_every': 7.5, 'blink_every': 5.5},
     '#c08aff', 'Il Cuore ha un ospite che non è stato invitato: l\'Ospite del Vuoto'),
    ('salamandra', 9, 'La Madre di brace', 'salamandra_brace', False, 'brace', 'gelo',
     ['cammina', 'carica', 'spara'], ['rimodella', 'salta_verso'],
     {'charge': 310.0, 'charge_range': 22, 'charge_time': 1.0, 'charge_cool': 3.8, 'rate': 1.9, 'shot_speed': 230.0,
      'shot_grav': 250.0, 'shot_damage': 25, 'pillar_every': 6.0, 'pillars': 3, 'jump': 330.0},
     '#ff8a4a', 'Il pavimento del Cuore si scalda: la Madre di brace'),
    ('bufera', 10, 'La Voce della bufera', 'spirito_bufera', True, 'gelo', 'luce',
     ['vola', 'folgore', 'ventaglio'], ['correnti', 'scatto'],
     {'bolt_every': 5.0, 'bolts': 2, 'bolt_delay': 0.9, 'bolt_damage': 30, 'fan_rate': 2.5, 'fan_n': 7,
      'fan_spread': 1.0, 'shot_speed': 200.0, 'shot_grav': 40.0, 'shot_damage': 22, 'gust_every': 6.5,
      'dash_every': 5.0, 'dash_speed': 320.0, 'dash_time': 0.5},
     '#8ad8ff', 'Nel Cuore comincia a nevicare e a tuonare: la Voce della bufera'),
    ('giardiniere', 11, 'Il Giardiniere spento', 'golem_muschio', False, 'spora', 'linfa',
     ['cammina', 'guaritore', 'evoca', 'carica', 'spara'], ['rimodella', 'marea'],
     {'rate': 2.4, 'shot_speed': 220.0, 'shot_grav': 260.0, 'shot_damage': 24, 'heal_every': 6.0, 'heal': 0.04, 'heal_r': 12, 'summon_every': 8.0, 'summon_max': 4, 'summon': 'grumo_spore',
      'charge': 300.0, 'charge_range': 20, 'charge_time': 1.0, 'charge_cool': 4.0, 'pillar_every': 6.0, 'pillars': 3,
      'tide_every': 8.0, 'tide_cells': 10},
     '#9fe070', 'Le aiuole del Cuore sono morte da tanto: il Giardiniere spento si alza a curarle'),
    ('eco', 12, 'L\'Eco del Seminatore', 'ombra_seminatore', True, 'vuoto', 'luce',
     ['vola', 'teletrasporto', 'ventaglio'], ['evoca', 'folgore'],
     {'blink_every': 4.5, 'fan_rate': 3.2, 'fan_n': 6, 'fan_spread': 1.2, 'shot_speed': 190.0, 'shot_grav': 40.0,
      'shot_damage': 22, 'rate': 2.6, 'summon_every': 9.0, 'summon_max': 3, 'summon': 'ombra_parola',
      'gust_every': 7.0, 'bolt_every': 6.0, 'bolts': 2, 'bolt_delay': 1.0, 'bolt_damage': 32},
     '#ffd88a', 'Nel Cuore qualcuno ti somiglia: l\'Eco del Seminatore'),
]
# voce 373, tarato con `tools/boss.gd` (Vite perse dal giocatore attento: da ~2,5 al vigore 4 a ~4 al 12): il danno
# di ogni Guardiano (al contatto, dei colpi, dei fulmini) per questo fattore
DMG_K = {'falena': 0.5, 'tessitore': 1.4, 'marea': 1.0, 'mietistelle': 0.9, 'ospite': 0.38, 'salamandra': 0.55,
         'bufera': 0.42, 'giardiniere': 0.6, 'eco': 0.4}
OPPOSITE = {'brace': 'gelo', 'gelo': 'brace', 'spora': 'linfa', 'linfa': 'spora', 'vuoto': 'luce', 'luce': 'vuoto'}

# i dodici Guardiani della spina con il loro sacchetto: id del Guardiano, nome breve, vigore, tavolozza
SPINE = [('nodo', 'il Nodo', 1, 'nodo'), ('regina', 'la Regina', 2, 'nottilite'), ('colosso', 'il Colosso', 3, 'ardesia')] + \
    [(g[0], g[2][0].lower() + g[2][1:], g[1], {'luce': 'brillaluce', 'spora': 'fungo', 'linfa': 'lagunite', 'vuoto': 'vuotite',
                                               'brace': 'tizzonite', 'gelo': 'brina'}[g[5]]) for g in GUARDIANS]
# l'accessorio di ogni Guardiano: [nome, effetti di GearEffects (acc), descrizione]
ACCESSORIES = {
    'nodo': ['Nodo che guarda', {'regen': 1.2, 'defense': 2}, 'la Vita ricresce il 20% più in fretta, +2 Scorza'],
    'regina': ['Corona di spore', {'magic': 1.1, 'linfa_regen': 1.2}, 'incantesimi +10%, la Linfa ricresce più in fretta'],
    'colosso': ['Cuore di pietra', {'defense': 6, 'regen': 1.1}, "+6 Scorza, la Vita ricresce un po' più in fretta"],
    'falena': ['Ali del primo buio', {'stealth': 0.75, 'jump': 1.08}, 'le creature ti vedono più tardi, salto più alto'],
    'tessitore': ['Fuso delle radici', {'thorns': 10, 'defense': 4}, 'chi ti tocca si ferisce (10), +4 Scorza'],
    'marea': ['Conchiglia muta', {'respiro': 2.0, 'acqua': 0.5, 'regen': 1.15}, "respiro doppio sott'acqua, protegge dalla sete, la Vita ricresce di più"],
    'mietistelle': ['Falce delle stelle', {'damage': 1.08, 'luck': 0.06}, 'danno +8%, fortuna'],
    'ospite': ['Invito del Vuoto', {'atk_speed': 1.1, 'stealth': 0.85}, 'colpi +10% più rapidi, ti vedono più tardi'],
    'salamandra': ['Squama della Madre', {'caldo': 1.0, 'damage': 1.06, 'thorns': 8}, 'protegge dal caldo, danno +6%, spine'],
    'bufera': ['Voce del tuono', {'fresco': 1.0, 'run': 1.1, 'magic': 1.08}, 'protegge dal freddo, corsa +10%, incantesimi +8%'],
    'giardiniere': ['Guanto del Giardiniere', {'grow': 1.25, 'regen': 1.25, 'defense': 6}, 'le colture crescono più in fretta, Vita che ricresce, +6 Scorza'],
    'eco': ['Eco del nome', {'damage': 1.1, 'atk_speed': 1.06, 'luck': 0.08}, 'danno +10%, colpi più rapidi, fortuna'],
}
BARS = {1: 'legnoferro', 2: 'ambra', 3: 'linfa', 4: 'vuoto', 5: 'stellare', 6: 'corallite', 7: 'sanguinite',
        8: 'cuorelegno', 9: 'eterite', 10: 'astrite', 11: 'primambra', 12: 'primambra'}


def firma_phase(v):
    """La fase delle armi firma del sacchetto di un Guardiano di vigore v (`FirmaDrops.guardian_phase`)."""
    return min(2 * v + 1, 23)


def build():
    creatures, items, loot, calls, guardians = {}, {}, {}, {}, []
    for (gid, v, name, body, fly, elem, elem2, bh, fury, p, color, wake) in GUARDIANS:
        cid = 'guardiano_' + gid
        pp = {'sight': 70, 'leash': 26, 'wobble': 30.0, 'phase2': 0.5}
        pp.update(p)
        k = DMG_K.get(gid, 1.0)
        for key in ('shot_damage', 'bolt_damage'):
            if key in pp:
                pp[key] = max(int(round(pp[key] * k)), 4)
        creatures[cid] = {'name': name, 'hp': 1500 + 60 * (v - 4), 'damage': max(int(round((26 + v) * k)), 8), 'defense': 12 + v, 'knock': 1.0,
                          'body': body, 'speed_k': 1.1, 'fly': fly, 'behaviors': bh, 'fury': fury, 'p': pp, 'loot': 'guardiano_spina',
                          'strata': [], 'weight': 0, 'glow': True, 'boss': True, 'elem': elem, 'weak': [OPPOSITE[elem]],
                          'resist': [elem], 'phase_elem': elem2, 'base': body,
                          'affinity': {'weak': [OPPOSITE[elem]], 'resist': [elem]},
                          'art_mods': {'elem': elem, 'scale': 3.0, 'temper': 'feroce', 'glow_body': True}}
        guardians.append({'id': gid, 'creature': cid, 'vigor': v, 'cure': {'linfa_gg': 14}, 'defeat': {'nucleo_' + elem: 14},
                          'pages': {'sconfitto': 'g_%s_sconfitto' % gid, 'curato': 'g_%s_curato' % gid},
                          'color': color, 'wake': wake, 'sower': 'senza_nome'})
        rid = 'richiamo_' + gid
        items[rid] = {'name': 'Richiamo: %s' % name[0].lower() + name[1:], 'kind': 'richiamo', 'icon': ['seme', 'iride'],
                      'stack': 10, 'fase': firma_phase(v) - 1,
                      'desc': 'Al Cerchio dei Seminatori risveglia %s, se l\'hai già affrontato. Lo trovi nel suo Sacchetto.' % (name[0].lower() + name[1:])}
        calls[rid] = {'creature': cid, 'loot': {'nucleo_' + elem: [5, 8], 'linfa_gg': [4, 6], 'lumino': [120 + 20 * v, 180 + 30 * v]}}
    for (gid, short, v, pal) in SPINE:
        ph = firma_phase(v)
        bag = 'sacchetto_' + gid
        acc = 'gioiello_' + gid
        tro = 'trofeo_' + gid
        an, ab, ad = ACCESSORIES[gid]
        items[bag] = {'name': 'Sacchetto del Guardiano (%s)' % short, 'kind': 'sacchetto', 'icon': ['sacca', pal], 'stack': 20,
                      'fase': ph - 1, 'table': bag, 'source': '%s, ogni volta che lo risolvi o lo rievochi al Cerchio' % short,
                      'desc': 'Lo lascia %s quando lo risolvi o lo rievochi. Aprilo con il clic: una o due armi firma della sua fase, '
                              'il suo Richiamo, lingotti e, a volte, il suo gioiello e il suo trofeo.' % short}
        items[acc] = {'name': an, 'kind': 'accessorio', 'icon': ['amuleto', pal], 'fase': ph - 1, 'acc': ab,
                      'source': 'il Sacchetto di %s (sempre la prima volta, poi a volte)' % short,
                      'desc': 'Il gioiello di %s: %s.' % (short, ad)}
        items[tro] = {'name': 'Trofeo: %s' % short, 'kind': 'trofeo', 'icon': ['corona', pal], 'fase': ph - 1, 'value': 200 * v,
                      'source': 'il Sacchetto di %s (raro)' % short,
                      'desc': 'Una piccola immagine di %s, per la sala dei trofei o il Museo.' % short}
        t = [{'item': 'firma_f%d_%d' % (ph, k), 'min': 1, 'max': 1, 'chance': 1.0, 'group': 'arma'} for k in range(10)]
        t += [{'item': 'firma_f%d_%d' % (ph, k), 'min': 1, 'max': 1, 'chance': 0.3, 'group': 'arma2'} for k in range(10)]
        t += [{'item': acc, 'min': 1, 'max': 1, 'chance': 1.0, 'first': True},
              {'item': acc, 'min': 1, 'max': 1, 'chance': 0.2},
              {'item': tro, 'min': 1, 'max': 1, 'chance': 0.1},
              {'item': 'lingotto_' + BARS[v], 'min': 4 + v, 'max': 8 + v, 'chance': 1.0},
              {'item': 'lumino', 'min': 60 + 30 * v, 'max': 100 + 50 * v, 'chance': 1.0}]
        if gid not in ('nodo', 'regina', 'colosso'):
            t.append({'item': 'richiamo_' + gid, 'min': 1, 'max': 1, 'chance': 1.0})
        else:
            t.append({'item': 'richiamo_' + gid, 'min': 1, 'max': 1, 'chance': 1.0})
        loot[bag] = t
    # il sacchetto dei Guardiani generati (il dopo): armi firma della fase 23, Nuclei, primambra
    items['sacchetto_generato'] = {'name': 'Sacchetto del Guardiano senza nome', 'kind': 'sacchetto', 'icon': ['sacca', 'sem'],
                                   'stack': 20, 'fase': 22, 'table': 'sacchetto_generato', 'source': 'i Guardiani dei mondi oltre il dodicesimo',
                                   'desc': 'Lo lascia un Guardiano dei mondi oltre il dodicesimo. Aprilo con il clic: armi firma dell\'ultima fase e primambra.'}
    t = [{'item': 'firma_f23_%d' % k, 'min': 1, 'max': 1, 'chance': 1.0, 'group': 'arma'} for k in range(10)]
    t += [{'item': 'firma_f23_%d' % k, 'min': 1, 'max': 1, 'chance': 0.35, 'group': 'arma2'} for k in range(10)]
    t += [{'item': 'lingotto_primambra', 'min': 12, 'max': 20, 'chance': 1.0}, {'item': 'lumino', 'min': 600, 'max': 900, 'chance': 1.0}]
    loot['sacchetto_generato'] = t
    # abbattuto, il corpo lascia poco: il tesoro è nel Sacchetto che lascia il Cuore
    loot['guardiano_spina'] = [{'item': 'lumino', 'min': 30, 'max': 60, 'chance': 1.0}]
    header = ('I Guardiani della spina (voci 373-374): nove Guardiani scritti a mano per i vigori 4-12 e i Sacchetti ' +
              'di tutti i dodici, con accessori, trofei, Richiami e le tabelle del bottino.')
    return [('guardiani.gd', header, {'creatures': creatures, 'items': items, 'loot': loot, 'calls': calls,
                                      'guardians': guardians})]
