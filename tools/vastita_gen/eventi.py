"""Gli eventi della Roadmap 42 (voce 382; piano in VASTITA.md).

Otto eventi nuovi, ognuno con le sue creature (la «pool»: nascono più spesso mentre dura), un obiettivo (quante
sconfiggerne), un **capo dell'evento** che arriva quando l'obiettivo è raggiunto, e un bottino suo (la tabella
«evento_<id>»: un'arma, un gioiello, un materiale, e il segnale per richiamare l'evento). Alcuni vengono solo dopo il
Risveglio del Cuore («awake») o dai mondi di un certo vigore («vmin»); tutti si possono chiamare con il loro segnale.
"""

# id: (nome, scritta, quando, probabilità, colore, pericolo, pool, obiettivo, capo [nome, corpo, volo, elemento],
#      vigore minimo, dopo il Risveglio, forma dell'arma, tavolozza)
EVENTS = [
    ('assalto_rovi', "L'assalto dei rovi", 'I rovi si muovono e i loro guardiani con loro: difendi il Giardino fino all\'alba',
     'notte', 0.07, '#9ac860', 1.0, ['cinghiale_rovo', 'cervo_rovo', 'liana_predatrice'], 30,
     ['La Madre dei rovi', 'cervo_rovo', False, 'spora'], 1, False, 'falcelunga', 'muschio'),
    ('notte_falene', 'La notte delle falene', 'Mille ali attorno alle luci: le falene cercano chi le ha svegliate',
     'notte', 0.07, '#ffd08a', 1.2, ['falena_brace', 'falena_vampira', 'falena_firmamento'], 35,
     ['La Falena regina', 'falena_firmamento', True, 'luce'], 2, False, 'flauto', 'brillaluce'),
    ('migrazione', 'La migrazione dei cervi', 'I cervi bianchi attraversano il mondo: seguili, ma qualcuno li guida',
     'giorno', 0.06, '#e8f8ff', 0.6, ['cervo_gelo_bianco', 'cervo_iride', 'cerva_guida'], 20,
     ['Il Cervo che guida', 'cervo_iridato', False, 'gelo'], 2, False, 'lancia', 'brina'),
    ('stelle_vive', 'La pioggia di stelle viva', 'Le stelle cadono e alcune si alzano in piedi',
     'notte', 0.06, '#fff2a8', 1.5, ['stella_errante', 'stellino', 'brillo_stellare'], 35,
     ['La Stella che cammina', 'stellamimo', False, 'luce'], 3, False, 'sfera', 'stelle'),
    ('sciame_metallo', 'Lo sciame di metallo', 'Ragni d\'ingranaggio escono dalle Centrali morte: qualcuno li comanda',
     'giorno', 0.05, '#c0c8d0', 1.6, ['ragno_ingranaggio', 'sentinella_sem', 'sentinella_radice'], 35,
     ['Il Ragno maestro', 'ragno_ingranaggio', False, 'luce'], 4, False, 'dischi', 'ardesia'),
    ('marea_nera', 'La marea di Linfa nera', 'La Linfa sale scura dalle profondità: ciò che vive dentro sale con lei',
     'giorno', 0.06, '#5a3a8a', 2.0, ['goccia_divisa', 'guizzalinfa', 'serpe_linfa'], 40,
     ['La Goccia nera', 'goccia_divisa', False, 'vuoto'], 5, True, 'virgulto', 'nottilite'),
    ('caduti', "L'invasione dei Seminatori caduti", 'Ombre con la forma dei Seminatori camminano sui loro mondi',
     'notte', 0.06, '#c090ff', 2.2, ['ombra_seminatore', 'ombra_parola', 'spirito_catacomba'], 40,
     ["L'Ombra che ricorda", 'ombra_seminatore', True, 'vuoto'], 6, True, 'tomo', 'sem'),
    ('eclissi_vuoto', "L'eclissi del Vuoto", 'Il Vuoto copre il sole: le sue creature non hanno più paura della luce',
     'giorno', 0.05, '#7a38c0', 2.5, ['vagavuoto', 'bolla_vuoto', 'talpa_vuoto', 'mietivuoto'], 45,
     ['La Bocca del Vuoto', 'vagavuoto', True, 'vuoto'], 7, True, 'semetorre', 'vuotite'),
]
OPP = {'brace': 'gelo', 'gelo': 'brace', 'spora': 'linfa', 'linfa': 'spora', 'vuoto': 'luce', 'luce': 'vuoto'}
FORM_KIND = {'falcelunga': 'spada', 'flauto': 'strumento', 'lancia': 'spada', 'sfera': 'bastone', 'dischi': 'lancio',
             'virgulto': 'ramo', 'tomo': 'bastone', 'semetorre': 'semeguerra'}
FX = [{'when': 'colpo', 'chance': 0.35, 'do': 'avvelena', 't': 5.0, 'desc': 'spesso avvelena'},
      {'when': 'ogni', 'n': 4, 'do': 'pioggia', 'shards': 4, 'dmg': 0.5, 'desc': 'ogni quarto colpo piovono stelle'},
      {'when': 'colpo', 'chance': 0.3, 'do': 'gela', 't': 3.0, 'desc': 'spesso gela'},
      {'when': 'ogni', 'n': 5, 'do': 'scoppio', 'r': 3, 'dmg': 0.7, 'desc': 'ogni quinto colpo scoppia attorno'},
      {'when': 'ogni', 'n': 5, 'do': 'catena', 'targets': 3, 'dmg': 0.6, 'r': 7, 'desc': 'ogni quinto colpo un fulmine salta su tre creature'},
      {'when': 'colpo', 'chance': 1.0, 'do': 'cura', 'frac': 0.06, 'desc': 'ogni colpo rende Vita'},
      {'when': 'colpo', 'chance': 0.35, 'do': 'vulnera', 't': 3.0, 'desc': 'spesso rende vulnerabile'},
      {'when': 'colpo', 'cond': 'notte', 'chance': 0.5, 'do': 'brucia', 't': 4.0, 'desc': 'di notte un colpo su due incendia'}]
ACC = [{'run': 1.1, 'jump': 1.06}, {'magic': 1.12, 'linfa_regen': 1.2}, {'regen': 1.2, 'defense': 4},
       {'luck': 0.08, 'halo': 1.15}, {'atk_speed': 1.08, 'damage': 1.05}, {'regen': 1.25, 'linfa_regen': 1.15},
       {'damage': 1.1, 'stealth': 0.85}, {'defense': 8, 'thorns': 8}]
ACC_W = {'run': 'corsa', 'jump': 'salto', 'magic': 'incantesimi', 'linfa_regen': 'la Linfa ricresce', 'regen': 'la Vita ricresce',
         'defense': 'Scorza', 'luck': 'fortuna', 'halo': 'alone', 'atk_speed': 'colpi più rapidi', 'damage': 'danno',
         'stealth': 'ti vedono più tardi', 'thorns': 'spine'}
ADD = ('defense', 'luck', 'thorns')


def words(acc):
    out = []
    for k, v in acc.items():
        if k in ADD:
            out.append('+%s %s' % (('%g' % v).replace('.', ','), ACC_W[k]))
        elif k == 'stealth':
            out.append(ACC_W[k])
        else:
            out.append('%s +%d%%' % (ACC_W[k], round((v - 1.0) * 100)))
    return ', '.join(out)


def build():
    creatures, items, loot, effects, events, recipes = {}, {}, {}, {}, {}, []
    for i, (eid, name, desc, when, ch, color, danger, pool, goal, boss, vmin, awake, form, pal) in enumerate(EVENTS):
        bname, body, fly, elem = boss
        cid = 'evento_' + eid
        p = {'sight': 40, 'leash': 30, 'phase2': 0.5, 'fan_rate': 2.6, 'fan_n': 6, 'fan_spread': 1.0, 'shot_speed': 190.0,
             'shot_grav': 80.0, 'shot_damage': 16, 'dash_every': 5.5, 'dash_speed': 290.0, 'dash_time': 0.5, 'rate': 2.4,
             'charge': 270.0, 'charge_range': 18, 'charge_time': 0.9, 'charge_cool': 4.0, 'rain_every': 6.0, 'rain_n': 5,
             'ring_every': 4.5, 'ring_n': 8, 'wave_every': 5.0, 'wave_n': 3, 'summon_every': 8.0, 'summon_max': 3,
             'summon': pool[0], 'blink_every': 5.0}
        beh = ['vola', 'ventaglio', 'pioggia'] if fly else ['cammina', 'carica', 'onda']
        fury = ['evoca', 'scatto'] if fly else ['evoca', 'spine']
        creatures[cid] = {'name': bname, 'hp': 900 + 120 * vmin, 'damage': 22 + 2 * vmin, 'defense': 8 + vmin, 'knock': 0.5,
                          'body': body, 'speed_k': 1.15, 'fly': fly, 'behaviors': beh, 'fury': fury, 'p': p,
                          'loot': 'evento_' + eid, 'strata': [], 'weight': 0, 'glow': True, 'boss': True, 'elem': elem,
                          'weak': [OPP[elem]], 'resist': [elem], 'base': body, 'affinity': {'weak': [OPP[elem]], 'resist': [elem]},
                          'art_mods': {'elem': elem, 'scale': 2.6, 'temper': 'feroce', 'glow_body': True}}
        ph = min(2 * vmin + 2, 23)
        short = bname[0].lower() + bname[1:]
        wid = 'arma_evento_' + eid
        fx = dict(FX[i % len(FX)])
        fdesc = fx.pop('desc')
        fx['name'] = name
        fx['desc'] = fdesc
        effects[wid + '_e0'] = fx
        items[wid] = {'name': '%s %s' % ({'falcelunga': 'Falce', 'flauto': 'Flauto', 'lancia': 'Lancia', 'sfera': 'Sfera',
                                          'dischi': 'Dischi', 'virgulto': 'Virgulto', 'tomo': 'Tomo', 'semetorre': 'Seme'}[form],
                                         {'assalto_rovi': 'dei rovi', 'notte_falene': 'delle falene', 'migrazione': 'della migrazione',
                                          'stelle_vive': 'delle stelle vive', 'sciame_metallo': 'dello sciame',
                                          'marea_nera': 'della marea nera', 'caduti': 'dei caduti',
                                          'eclissi_vuoto': "dell'eclissi"}[eid]),
                      'kind': FORM_KIND[form], 'form': form, 'fase': ph, 'firma': True, 'elem': elem,
                      'icon': [form if form != 'semetorre' else 'semetorre', pal], 'effects': [wid + '_e0'],
                      'plural': form == 'dischi',
                      'source': '%s, il capo dell\'evento «%s»' % (short, name),
                      'desc': "L'arma dell'evento «%s»: %s. Si trova, non si fabbrica." % (name, fdesc)}
        gid = 'gioiello_evento_' + eid
        acc = ACC[i % len(ACC)]
        items[gid] = {'name': 'Ricordo: %s' % name[0].lower() + name[1:], 'kind': 'amuleto', 'icon': ['amuleto', pal],
                      'fase': ph, 'acc': acc, 'source': '%s, il capo dell\'evento' % short,
                      'desc': 'Un ricordo dell\'evento «%s»: %s.' % (name, words(acc))}
        sid = 'segnale_' + eid
        items[sid] = {'name': 'Segnale: %s' % name[0].lower() + name[1:], 'kind': 'segnale', 'icon': ['seme', pal],
                      'stack': 10, 'event': eid, 'fase': ph,
                      'source': '%s, il capo dell\'evento (a volte), o al Cerchio' % short,
                      'desc': 'Usalo (clic) per chiamare l\'evento «%s», di giorno o di notte.' % name}
        loot['evento_' + eid] = [{'item': wid, 'min': 1, 'max': 1, 'chance': 1.0, 'first': True},
                                 {'item': wid, 'min': 1, 'max': 1, 'chance': 0.25},
                                 {'item': gid, 'min': 1, 'max': 1, 'chance': 0.5},
                                 {'item': sid, 'min': 1, 'max': 1, 'chance': 0.4},
                                 {'item': 'linfa_antica', 'min': 1, 'max': 2, 'chance': 0.5},
                                 {'item': 'lumino', 'min': 80 + 40 * vmin, 'max': 140 + 60 * vmin, 'chance': 1.0}]
        recipes.append({'out': sid, 'qty': 1, 'in': {'lumino': 150 + 50 * vmin, 'cristallo_linfa': 3}, 'station': 'arena'})
        ev = {'name': name, 'desc': desc, 'when': when, 'chance': ch, 'color': color, 'danger': danger, 'pool': pool,
              'goal': goal, 'reward': 'evento_' + eid, 'rolls': 0, 'boss': cid, 'vmin': vmin}
        if awake:
            ev['awake'] = True
        events[eid] = ev
    header = 'Gli eventi della Roadmap 42 (voce 382): otto eventi con creature, capo e bottino loro.'
    return [('eventi.gd', header, {'creatures': creatures, 'items': items, 'loot': loot, 'effects': effects, 'events': events,
                                    'recipes': recipes})]
