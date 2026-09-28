"""Genera i pacchetti del nuovo bestiario (Roadmap 15, voci 132-134) in src/data/bestiary/.

Ogni specie è una riga qui sotto: il file .gd che ne esce è solo dati (come i file dei biomi) e lo unisce
`BiomesData.PACK_FILES`. Per cambiare una creatura si cambia la riga e si rilancia:
    python tools/gen_bestiario.py
"""
import os

ROOT = os.path.join(os.path.dirname(__file__), '..', 'src', 'data', 'bestiary')

# Le forze secondo il grado del bioma (1 facile … 4 difficile): vita, danno, difesa.
TIER = {1: (26, 8, 0), 2: (40, 11, 2), 3: (58, 14, 4), 4: (80, 18, 6)}


def gd(v, ind=0):
    """Un valore Python scritto come GDScript."""
    if isinstance(v, bool):
        return 'true' if v else 'false'
    if isinstance(v, (int, float)):
        return repr(v)
    if isinstance(v, str):
        if v.startswith('Color('):
            return v
        return '"%s"' % v.replace('"', '\\"')
    if isinstance(v, list):
        return '[' + ', '.join(gd(x) for x in v) + ']'
    if isinstance(v, dict):
        return '{' + ', '.join('%s: %s' % (gd(k), gd(x)) for k, x in v.items()) + '}'
    raise TypeError(v)


def creature(s):
    """Una specie dalla sua riga: i campi mancanti vengono dal grado."""
    hp, dmg, de = TIER[s['tier']]
    c = {
        'name': s['name'],
        'hp': int(hp * s.get('hp', 1.0)),
        'damage': 0 if s.get('docile_zero') else int(dmg * s.get('dmg', 1.0)),
        'defense': de + s.get('def', 0),
        'knock': s.get('knock', 0.2),
        'half': s['half'],
        'speed': s.get('speed', 70),
    }
    if s.get('fly'):
        c['fly'] = True
    c['behaviors'] = s['beh']
    c['p'] = s.get('p', {})
    for k in ('group', 'night', 'docile', 'glow'):
        if k in s:
            c[k] = s[k]
    c['loot'] = s['id']
    c['art'] = [s['id'], 0]
    c['strata'] = s.get('strata', [0])
    c['weight'] = s.get('weight', 5)
    if 'biomes' in s:
        c['biomes'] = s['biomes']
    c['body'] = s['body']
    c['affinity'] = s['aff']
    c['trophy'] = s['trophy'][0]
    for k in ('under', 'uw', 'water', 'liquid'):
        if k in s:
            c[k] = s[k]
    for k in ('season', 'weather', 'eclipse'):
        if k in s:
            c[k] = s[k]
    return c


def write(fname, header, species, extra_items=None, extra_recipes=None):
    creatures, families, loot, items, recipes = {}, {}, {}, {}, []
    for s in species:
        creatures[s['id']] = creature(s)
        fam = s['fam']
        f = {'name': fam[1], 'members': [s['id']], 'fem': fam[2], 'role': fam[3]}
        if len(fam) > 4:
            f.update(fam[4])
        if fam[0] in families:
            families[fam[0]]['members'].append(s['id'])
        else:
            families[fam[0]] = f
        mat = s['mat']
        loot[s['id']] = [{'item': mat[0], 'min': 1, 'max': mat[4] if len(mat) > 4 else 2, 'chance': 1.0}] + s.get('loot', [])
        items[mat[0]] = {'name': mat[1], 'kind': 'materiale', 'icon': mat[2], 'desc': mat[3]}
        tr = s['trophy']
        items[tr[0]] = {'name': tr[1], 'kind': 'trofeo', 'icon': tr[2], 'desc': 'Lo lasciano solo le creature rare di questa specie.'}
    items.update(extra_items or {})
    recipes += extra_recipes or []
    data = {'creatures': creatures, 'families': families, 'loot': loot, 'items': items, 'recipes': recipes}
    out = ['extends RefCounted', '## ' + header.replace('\n', '\n## '),
           '## Fatto da `tools/gen_bestiario.py` (non a mano): si cambia la riga là e si rilancia. Non nomina altre classi.',
           '', 'const DATA := {']
    for key in ('creatures', 'families', 'loot', 'items', 'recipes'):
        v = data[key]
        if isinstance(v, dict):
            out.append('\t%s: {' % gd(key))
            for k, x in v.items():
                out.append('\t\t%s: %s,' % (gd(k), gd(x)))
            out.append('\t},')
        else:
            out.append('\t%s: [' % gd(key))
            for x in v:
                out.append('\t\t%s,' % gd(x))
            out.append('\t],')
    out.append('}')
    os.makedirs(ROOT, exist_ok=True)
    with open(os.path.join(ROOT, fname), 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(out) + '\n')
    print(fname, len(creatures), 'specie')


def P(*cols):
    return list(cols)


# ------------------------------------------------------------------------------------------------ voce 132: la superficie
SURFACE = [
    # Colline dei cappelli
    dict(id='tessispore', name='Tessispore', tier=2, half=[7, 5], speed=60, beh=['cammina', 'tessitore'], biomes=['funghi'],
         p={'sight': 18, 'web_every': 6.0},
         body={'plan': 'insetto', 'w': 18, 'h': 12, 'pal': P('#2a1a24', '#4a2e3e', '#6e4a5c', '#a07a86', '#e0c0c4'), 'eye': '#f0e060', 'marks': 'macchie', 'mark': '#f0e0d0'},
         aff={'weak': ['brace'], 'resist': ['spora']}, fam=('tessispore', 'Tessispore', False, 'predatore', {'prey': ['bruchi']}),
         mat=('filo_spore', 'Filo di spore', ['seta', 'fungo'], 'Il filo di un Tessispore: appiccica ancora.'),
         trophy=('ghiandola_tessispore', 'Ghiandola del tessitore', ['essenza', 'fungo'])),
    dict(id='cappelletto', name='Cappelletto ladro', tier=2, half=[6, 6], speed=85, beh=['cammina', 'ladro'], biomes=['funghi'],
         p={'sight': 20, 'steal': 4}, knock=0.1, hp=0.7, dmg=0.5,
         body={'plan': 'lumaca', 'w': 16, 'h': 14, 'pal': P('#3a1a1a', '#6a2a24', '#9a4034', '#d07060', '#f0c0a0'), 'eye': '#fff0a0', 'marks': 'macchie', 'mark': '#f0f0e0'},
         aff={'weak': ['brace'], 'resist': ['spora']}, fam=('cappelletti', 'Cappelletti', False, 'neutro'),
         mat=('lamella_ladra', 'Lamella del cappelletto', ['polvere', 'fungo'], 'Sotto il cappello teneva ciò che rubava.'),
         trophy=('cappello_rubato', 'Cappello rubato', ['seme', 'fungo'])),
    # Torbiere di Linfa
    dict(id='rospo_torba', name='Rospo gonfio di torba', tier=2, half=[8, 6], speed=55, beh=['salta_verso', 'scoppia'], biomes=['torba'],
         p={'jump': 200.0, 'sight': 16, 'fuse': 1.0, 'fuse_r': 2.2, 'blast_r': 2.2},
         body={'plan': 'anfibio', 'w': 20, 'h': 14, 'pal': P('#1a2418', '#2e3e26', '#48603a', '#7a9a58', '#c0e090'), 'eye': '#f0a030', 'marks': 'macchie', 'mark': '#a0e060', 'glow': True},
         aff={'weak': ['gelo'], 'resist': ['spora']}, fam=('rospi_torba', 'Rospi di torba', False, 'neutro'),
         mat=('sacca_torba', 'Sacca di torba', ['gel', 'muschio'], 'La sacca che si gonfia: dentro c\'è gas di palude.'),
         trophy=('gozzo_rospo', 'Gozzo del rospo', ['essenza', 'muschio'])),
    # Prati di vento
    dict(id='pavoncella', name='Pavoncella del vento', tier=1, half=[7, 5], speed=95, fly=True, beh=['vola', 'richiamo'], biomes=['prati'],
         p={'sight': 22, 'hover': 50.0, 'wobble': 30.0, 'call_time': 1.8, 'call_n': 2, 'calls': 1},
         body={'plan': 'uccello', 'w': 18, 'h': 14, 'pal': P('#1e2a2a', '#344848', '#56706c', '#8aa89e', '#e0f0e0'), 'eye': '#101010', 'wings': '#344848', 'marks': 'strisce', 'mark': '#e0f0e0'},
         aff={'weak': ['vuoto'], 'resist': ['spora']}, fam=('pavoncelle', 'Pavoncelle', True, 'volante'),
         mat=('piuma_pavoncella', 'Piuma di pavoncella', ['penna', 'seta'], 'Leggera: ricorda ancora il vento.'),
         trophy=('ciuffo_pavoncella', 'Ciuffo della pavoncella', ['penna', 'brillaluce'])),
    # Boschi di brina
    dict(id='ermellino', name='Ermellino di brina', tier=2, half=[7, 4], speed=105, beh=['cammina', 'ladro'], biomes=['brina'],
         p={'sight': 22, 'steal': 5}, hp=0.8, dmg=0.6,
         body={'plan': 'quadrupede', 'w': 20, 'h': 12, 'pal': P('#6a7a88', '#9ab0c0', '#c8dce8', '#eef8ff', '#ffffff'), 'eye': '#101820', 'tail': True},
         aff={'weak': ['brace'], 'resist': ['gelo']}, fam=('ermellini', 'Ermellini', False, 'neutro'),
         mat=('pelo_ermellino', 'Pelo d\'ermellino', ['seta', 'brina'], 'Bianco come la brina, caldo come una tana.'),
         trophy=('coda_ermellino', 'Coda d\'ermellino', ['penna', 'brina'])),
    # Cenerarie
    dict(id='talpa_cenere', name='Talpa di cenere', tier=3, half=[8, 6], speed=70, beh=['cammina', 'sbuca'], biomes=['cenere'],
         p={'sight': 16, 'windup': 1.0, 'out_time': 5.0},
         body={'plan': 'quadrupede', 'w': 20, 'h': 14, 'pal': P('#2a1e1e', '#44302c', '#664640', '#8e6458', '#d09a80'), 'eye': '#ff7a30', 'marks': 'punte', 'mark': '#ff9a50', 'glow': True},
         aff={'weak': ['gelo'], 'resist': ['brace']}, fam=('talpe_cenere', 'Talpe di cenere', True, 'scavatore'),
         mat=('artiglio_cenere', 'Artiglio di talpa', ['artiglio', 'cenere'], 'Scava la cenere viva senza bruciarsi.'),
         trophy=('muso_talpa', 'Muso di talpa', ['essenza', 'cenere'])),
    dict(id='scarabeo_cenere', name='Scarabeo delle ceneri', tier=3, half=[7, 5], speed=45, beh=['cammina', 'guscio'], biomes=['cenere'],
         p={'sight': 12, 'shell_time': 2.5}, docile=True, dmg=0.6, hp=1.1, **{'def': 3},
         body={'plan': 'insetto', 'w': 18, 'h': 12, 'pal': P('#1a1414', '#302424', '#4c3a36', '#78605a', '#b8a09a'), 'eye': '#ffb050', 'marks': 'strisce', 'mark': '#ff8030', 'glow': True},
         aff={'weak': ['linfa'], 'resist': ['brace']}, fam=('scarabei_cenere', 'Scarabei delle ceneri', False, 'erbivoro', {'nest': {'type': 'tana', 'n': 5}}),
         mat=('elitra_cenere', 'Elitra di cenere', ['scaglia', 'cenere'], 'Un guscio che non brucia.'),
         trophy=('corno_scarabeo', 'Corno di scarabeo', ['artiglio', 'brace'])),
    # Deserti di vetro
    dict(id='lucertola_vetro', name='Lucertola di vetro', tier=3, half=[9, 4], speed=100, beh=['cammina', 'mimetico', 'scatto'], biomes=['vetro'],
         p={'sight': 22, 'look': 'vetro_resina', 'wake': 3.0, 'dash_every': 2.8, 'dash_speed': 260.0, 'dash_time': 0.35},
         body={'plan': 'serpe', 'w': 22, 'h': 10, 'pal': P('#3a5a60', '#5a8088', '#80a8ae', '#b0d8dc', '#f0ffff'), 'eye': '#ff5050', 'tail': True},
         aff={'weak': ['vuoto'], 'resist': ['luce']}, fam=('lucertole_vetro', 'Lucertole di vetro', True, 'predatore', {'prey': ['scarabei_sabbia']}),
         mat=('scaglia_vetro', 'Scaglia di vetro', ['scaglia', 'cristallo'], 'Trasparente: si vede la luce attraverso.'),
         trophy=('occhio_vetro', 'Occhio di vetro', ['gemma', 'cristallo'])),
    dict(id='scarabeo_sabbia', name='Scarabeo della sabbia fusa', tier=3, half=[7, 5], speed=50, beh=['cammina', 'fugge'], biomes=['vetro'],
         p={'sight': 14, 'flee': 10}, docile=True, dmg=0.5,
         body={'plan': 'insetto', 'w': 16, 'h': 12, 'pal': P('#4a3a1a', '#7a6030', '#a8884a', '#d8b870', '#fff0b0'), 'eye': '#303030', 'marks': 'macchie', 'mark': '#fff0b0'},
         aff={'weak': ['gelo'], 'resist': ['brace']}, fam=('scarabei_sabbia', 'Scarabei della sabbia', False, 'erbivoro', {'nest': {'type': 'tana', 'n': 5}}),
         mat=('perla_sabbia', 'Perla di sabbia', ['gemma', 'ambra'], 'La sabbia che rotola diventa vetro, e il vetro perla.'),
         trophy=('palla_sabbia', 'Palla di sabbia fusa', ['gemma', 'ambra'])),
    # Ghiacciai di Linfa
    dict(id='foca_linfa', name='Foca di Linfa gelata', tier=3, half=[11, 6], speed=40, beh=['cammina', 'fugge'], biomes=['ghiacciaio'],
         p={'sight': 12, 'flee': 12}, docile=True, hp=1.4, dmg=0.6,
         body={'plan': 'lumaca', 'w': 26, 'h': 14, 'pal': P('#2a4a5a', '#406878', '#5e8e9e', '#90c0cc', '#e0f8ff'), 'eye': '#101820', 'marks': 'macchie', 'mark': '#90f0e0', 'glow': True},
         aff={'weak': ['brace'], 'resist': ['gelo']}, fam=('foche', 'Foche di Linfa', True, 'erbivoro', {'nest': {'type': 'erba', 'n': 4}}),
         mat=('grasso_foca', 'Grasso di foca', ['gel', 'brina'], 'Tiene caldo più di qualunque pelliccia.'),
         trophy=('baffo_foca', 'Baffo di foca', ['penna', 'linfa'])),
    dict(id='lupo_ghiaccio', name='Lupo del ghiacciaio', tier=3, half=[10, 7], speed=110, beh=['cammina', 'carica'], biomes=['ghiacciaio'],
         p={'sight': 24, 'charge': 240.0, 'charge_range': 8, 'charge_time': 0.6, 'charge_cool': 3.5}, group=[2, 3],
         body={'plan': 'quadrupede', 'w': 24, 'h': 18, 'pal': P('#3a4a5a', '#5a7084', '#8098ac', '#b0c8d8', '#f0faff'), 'eye': '#50f0ff', 'tail': True, 'glow': True},
         aff={'weak': ['brace'], 'resist': ['gelo']}, fam=('lupi_ghiaccio', 'Lupi del ghiacciaio', False, 'predatore', {'prey': ['foche']}),
         mat=('zanna_ghiaccio', 'Zanna di ghiaccio', ['artiglio', 'brina'], 'Non si scioglie nemmeno in mano.'),
         trophy=('pelliccia_capobranco', 'Pelliccia del capobranco', ['seta', 'brina'])),
    # Foreste pietrificate
    dict(id='muschiolo', name='Muschiolo guaritore', tier=3, half=[7, 6], speed=35, beh=['cammina', 'guaritore'], biomes=['pietra'],
         p={'sight': 14, 'heal_every': 5.0, 'heal': 0.25, 'heal_r': 8}, hp=0.8, dmg=0.5,
         body={'plan': 'lumaca', 'w': 18, 'h': 14, 'pal': P('#1a2e26', '#2a4a3c', '#3e6a56', '#5c9478', '#a0d8b0'), 'eye': '#f0f060', 'marks': 'macchie', 'mark': '#80ffb0', 'glow': True},
         aff={'weak': ['brace'], 'resist': ['vuoto']}, fam=('muschioli', 'Muschioli', False, 'neutro'),
         mat=('muschio_guaritore', 'Muschio che cura', ['seta', 'muschio'], 'Messo su una ferita, la chiude.'),
         trophy=('cuore_muschiolo', 'Cuore di muschiolo', ['essenza', 'muschio'])),
    dict(id='scudato_pietra', name='Scudato di pietra', tier=3, half=[9, 8], speed=45, beh=['cammina', 'carica', 'scudo'], biomes=['pietra'],
         p={'sight': 18, 'charge': 200.0, 'charge_range': 6, 'charge_time': 0.7, 'charge_cool': 4.0, 'turn': 0.9}, hp=1.3, **{'def': 2},
         body={'plan': 'quadrupede', 'w': 22, 'h': 18, 'pal': P('#2a2a28', '#44443e', '#66665c', '#94948a', '#d0d0c4'), 'eye': '#ff8a3a', 'marks': 'punte', 'mark': '#94948a', 'horns': 1},
         aff={'weak': ['linfa'], 'resist': ['brace', 'gelo']}, fam=('scudati', 'Scudati di pietra', False, 'predatore', {'prey': ['muschioli']}),
         mat=('placca_pietra', 'Placca di pietra', ['scaglia', 'ardesia'], 'Lo scudo di uno Scudato: pesa come un sasso.'),
         trophy=('scudo_scudato', 'Scudo intero', ['scaglia', 'ardesia'])),
    # Lande di brace viva
    dict(id='grumo_diviso', name='Grumo di brace che si divide', tier=3, half=[8, 7], speed=60, beh=['salta_verso', 'divide'], biomes=['brace'],
         p={'jump': 220.0, 'sight': 18, 'big_hit': 0.5, 'split_hp': 0.45}, glow=True,
         body={'plan': 'fluttuante', 'w': 18, 'h': 16, 'pal': P('#3a1008', '#6a1c0c', '#a83414', '#e06a24', '#ffc070'), 'eye': '#fff0a0', 'marks': 'punte', 'mark': '#ffd080', 'glow': True},
         aff={'weak': ['gelo'], 'resist': ['brace']}, fam=('grumi_divisi', 'Grumi di brace', False, 'neutro'),
         mat=('nocciolo_brace', 'Nocciolo di brace', ['gemma', 'brace'], 'Il cuore di un grumo: pulsa ancora.'),
         trophy=('seme_grumo', 'Seme di grumo', ['seme', 'brace'])),
    dict(id='falco_brace', name='Falco di brace', tier=3, half=[8, 6], speed=120, fly=True, beh=['vola', 'bombarda'], biomes=['brace'],
         p={'sight': 28, 'hover': 90.0, 'wobble': 20.0, 'drop_every': 3.0}, glow=True,
         body={'plan': 'uccello', 'w': 22, 'h': 16, 'pal': P('#2a1010', '#501c14', '#84301c', '#c05a28', '#ffb060'), 'eye': '#ffff80', 'wings': '#84301c', 'marks': 'strisce', 'mark': '#ffb060', 'glow': True},
         aff={'weak': ['gelo'], 'resist': ['brace']}, fam=('falchi_brace', 'Falchi di brace', False, 'predatore', {'prey': ['grumi_divisi']}),
         mat=('penna_brace', 'Penna di brace', ['penna', 'brace'], 'Scotta, ma non brucia chi la sa tenere.'),
         trophy=('artiglio_falco', 'Artiglio del falco', ['artiglio', 'tizzonite'])),
    # Prati iridati
    dict(id='cervo_iride', name='Cervo iridato', tier=3, half=[11, 9], speed=120, beh=['cammina', 'fugge'], biomes=['iridato'],
         p={'sight': 18, 'flee': 16}, docile=True, hp=1.2, dmg=0.6, group=[2, 4],
         body={'plan': 'quadrupede', 'w': 26, 'h': 22, 'pal': P('#3a2a4a', '#5a4470', '#8468a0', '#b89ad0', '#f0e0ff'), 'eye': '#50ffd0', 'horns': 2, 'marks': 'macchie', 'mark': '#ffb0f0', 'glow': True},
         aff={'weak': ['vuoto'], 'resist': ['luce']}, fam=('cervi_iride', 'Cervi iridati', False, 'erbivoro', {'nest': {'type': 'erba', 'n': 5}}),
         mat=('palco_iride', 'Palco di cervo iridato', ['artiglio', 'iride'], 'Cambia colore quando lo giri.'),
         trophy=('corona_cervo', 'Corona di palchi', ['artiglio', 'iride'])),
    dict(id='cerva_guida', name='Cerva guida iridata', tier=3, half=[11, 10], speed=110, beh=['cammina', 'fugge', 'pastore'], biomes=['iridato'],
         p={'sight': 20, 'flee': 16, 'herd_r': 14}, docile=True, hp=1.6, dmg=0.7, weight=2,
         body={'plan': 'quadrupede', 'w': 28, 'h': 24, 'pal': P('#3a2a4a', '#5a4470', '#8468a0', '#d0b8f0', '#ffffff'), 'eye': '#ffe070', 'marks': 'strisce', 'mark': '#ffffff', 'glow': True},
         aff={'weak': ['vuoto'], 'resist': ['luce']}, fam=('cervi_iride', 'Cervi iridati', False, 'erbivoro'),
         mat=('pelo_guida', 'Pelo della guida', ['seta', 'iride'], 'Chi lo porta sa dove andare.'),
         trophy=('stella_guida', 'Stella della guida', ['essenza', 'iride'])),
    dict(id='farfalla_iride', name='Farfalla iridata', tier=3, half=[6, 5], speed=80, fly=True, beh=['vola', 'fugge'], biomes=['iridato'],
         p={'sight': 16, 'hover': 30.0, 'wobble': 50.0, 'flee': 10}, docile=True, dmg=0.3, hp=0.5, group=[3, 5],
         body={'plan': 'insetto', 'w': 16, 'h': 14, 'pal': P('#2a1a3a', '#4a2e6a', '#7a4ca0', '#c080e0', '#fff0ff'), 'eye': '#ffffff', 'wings': '#c080e0', 'marks': 'macchie', 'mark': '#80ffe0', 'glow': True},
         aff={'weak': ['brace'], 'resist': ['luce']}, fam=('farfalle_iride', 'Farfalle iridate', True, 'volante'),
         mat=('polvere_ali', 'Polvere d\'ali iridata', ['polvere', 'iride'], 'Resta sulle dita per giorni, e brilla.'),
         trophy=('ala_iride', 'Ala iridata intera', ['membrana', 'iride'])),
    # Radure stellari
    dict(id='brillo_stellare', name='Brillo stellare', tier=3, half=[6, 5], speed=60, beh=['salta_verso', 'fugge'], biomes=['stellare'],
         p={'jump': 240.0, 'sight': 14, 'flee': 12}, docile=True, dmg=0.4, hp=0.7, glow=True, night=True,
         body={'plan': 'anfibio', 'w': 16, 'h': 12, 'pal': P('#101a3a', '#1e2e60', '#34509a', '#70a0e0', '#e0f0ff'), 'eye': '#fff0a0', 'marks': 'macchie', 'mark': '#fff0a0', 'glow': True},
         aff={'weak': ['vuoto'], 'resist': ['luce']}, fam=('brilli', 'Brilli stellari', False, 'erbivoro'),
         mat=('gelatina_stelle', 'Gelatina di stelle', ['gel', 'brillaluce'], 'Trema e brilla come il cielo di notte.'),
         trophy=('perla_brillo', 'Perla del brillo', ['gemma', 'brillaluce'])),
    dict(id='stellamimo', name='Stellamimo', tier=3, half=[7, 6], speed=90, beh=['salta_verso', 'mimetico'], biomes=['stellare'],
         p={'jump': 260.0, 'sight': 20, 'look': 'frammento_stella', 'wake': 3.0}, hp=1.1, dmg=1.2,
         body={'plan': 'fluttuante', 'w': 16, 'h': 16, 'pal': P('#1a1a3a', '#2e2e60', '#4a4a90', '#a0a0e0', '#ffffc0'), 'eye': '#ff5070', 'marks': 'punte', 'mark': '#ffffc0', 'glow': True},
         aff={'weak': ['spora'], 'resist': ['luce']}, fam=('stellamimi', 'Stellamimi', False, 'predatore', {'prey': ['brilli']}),
         mat=('cuore_stellamimo', 'Cuore di stellamimo', ['essenza', 'brillaluce'], 'Sembrava un frammento di stella. Quasi.'),
         trophy=('maschera_stella', 'Maschera di stella', ['gemma', 'brillaluce'])),
    dict(id='gufo_stellare', name='Gufo delle radure', tier=3, half=[7, 8], speed=90, fly=True, beh=['vola', 'spara'], biomes=['stellare'],
         p={'sight': 26, 'hover': 70.0, 'wobble': 20.0, 'shot_every': 2.6, 'shot_speed': 200.0, 'shot_look': 'spora'}, night=True, glow=True,
         body={'plan': 'uccello', 'w': 20, 'h': 18, 'pal': P('#1a1a2a', '#2e2e48', '#4c4c70', '#8080a8', '#e0e0f0'), 'eye': '#ffd040', 'wings': '#2e2e48', 'marks': 'macchie', 'mark': '#ffffc0', 'glow': True},
         aff={'weak': ['luce'], 'resist': ['vuoto']}, fam=('gufi_stellari', 'Gufi delle radure', False, 'predatore', {'prey': ['brilli']}),
         mat=('piuma_gufo', 'Piuma di gufo', ['penna', 'nottilite'], 'Non fa rumore nemmeno cadendo.'),
         trophy=('occhio_gufo_radure', 'Occhio del gufo delle radure', ['gemma', 'nottilite'])),
    # Boschi dei sussurri
    dict(id='sussurratore', name='Sussurratore', tier=3, half=[7, 9], speed=85, fly=True, beh=['vola', 'fotofobo'], biomes=['sussurri'],
         p={'sight': 22, 'hover': 30.0, 'wobble': 40.0, 'dark_mult': 1.6}, night=True, hp=1.1,
         body={'plan': 'fluttuante', 'w': 16, 'h': 20, 'pal': P('#0e0e16', '#1c1c2a', '#2e2e44', '#50506e', '#9a9ac0'), 'eye': '#e0e0ff', 'marks': 'strisce', 'mark': '#9a9ac0', 'glow': True},
         aff={'weak': ['luce'], 'resist': ['vuoto']}, fam=('sussurratori', 'Sussurratori', False, 'predatore', {'prey': ['cerbiatti_ombra']}),
         mat=('velo_sussurro', 'Velo di sussurro', ['velo', 'nottilite'], 'Messo sull\'orecchio, si sente ciò che il bosco dice.'),
         trophy=('voce_sussurro', 'Voce chiusa', ['essenza', 'nottilite'])),
    dict(id='zecca_sussurri', name='Zecca dei sussurri', tier=3, half=[5, 4], speed=70, beh=['salta_verso', 'parassita'], biomes=['sussurri'],
         p={'jump': 250.0, 'sight': 16, 'drain': 2, 'hold': 7.0}, hp=0.6, dmg=0.7, group=[1, 2],
         body={'plan': 'insetto', 'w': 14, 'h': 10, 'pal': P('#1a0e14', '#301a24', '#4e2c3a', '#7a4a5c', '#c08aa0'), 'eye': '#ff3050', 'marks': 'punte', 'mark': '#ff6080'},
         aff={'weak': ['brace'], 'resist': ['linfa']}, fam=('zecche', 'Zecche dei sussurri', True, 'predatore', {'prey': ['cerbiatti_ombra']}),
         mat=('rostro_zecca', 'Rostro di zecca', ['artiglio', 'sanguinella'], 'Beveva Linfa: ne è rimasta una goccia.'),
         trophy=('ventre_zecca', 'Ventre pieno di Linfa', ['gel', 'linfa'])),
    dict(id='cerbiatto_ombra', name='Cerbiatto d\'ombra', tier=3, half=[9, 8], speed=115, beh=['cammina', 'fugge'], biomes=['sussurri'],
         p={'sight': 18, 'flee': 14}, docile=True, hp=1.0, dmg=0.5,
         body={'plan': 'quadrupede', 'w': 22, 'h': 20, 'pal': P('#141420', '#24243a', '#3a3a58', '#5e5e86', '#a8a8d0'), 'eye': '#a0f0ff', 'marks': 'macchie', 'mark': '#a0f0ff', 'glow': True},
         aff={'weak': ['luce'], 'resist': ['vuoto']}, fam=('cerbiatti_ombra', 'Cerbiatti d\'ombra', False, 'erbivoro', {'nest': {'type': 'erba', 'n': 4}}),
         mat=('pelle_ombra', 'Pelle d\'ombra', ['seta', 'nottilite'], 'Al buio non si vede, neppure chi la indossa.'),
         trophy=('zoccolo_ombra', 'Zoccolo d\'ombra', ['artiglio', 'nottilite'])),
    # Distese d'ambra
    dict(id='formica_ladra', name='Formica ladra d\'ambra', tier=2, half=[6, 4], speed=80, beh=['cammina', 'ladro'], biomes=['ambra'],
         p={'sight': 18, 'steal': 3}, hp=0.6, dmg=0.6, group=[2, 3],
         body={'plan': 'insetto', 'w': 16, 'h': 10, 'pal': P('#3a2208', '#6a3e10', '#a0621a', '#d8962a', '#fff0a8'), 'eye': '#101010', 'marks': 'strisce', 'mark': '#fff0a8'},
         aff={'weak': ['gelo'], 'resist': ['spora']}, fam=('formiche_ladre', 'Formiche ladre', True, 'colonia', {'nest': {'type': 'formicaio', 'n': 5}}),
         mat=('resina_ladra', 'Resina rubata', ['goccia', 'ambra'], 'Chissà a chi l\'aveva presa.'),
         trophy=('regina_ladra', 'Sigillo della regina ladra', ['amuleto', 'ambra'])),
]

# Gli oggetti che ne nascono: per ogni bioma uno che usa i materiali, e uno che usa i trofei (i trofei servono a qualcosa).
SURFACE_ITEMS = {
    'mantello_spore': {'name': 'Mantello di filo di spore', 'kind': 'accessorio', 'icon': ['velo', 'fungo'], 'acc': {'stealth': 0.85, 'run': 1.04},
                       'desc': 'Le creature ti notano più tardi (−15% della loro vista); corsa +4%.'},
    'borsa_cappelletto': {'name': 'Borsa del cappelletto', 'kind': 'accessorio', 'icon': ['sacca', 'fungo'], 'acc': {'luck': 0.08},
                          'desc': 'Fortuna +8%: ciò che i ladri nascondono, ora lo trovi tu.'},
    'bomba_torba': {'name': 'Sacca esplosiva di torba', 'kind': 'esplosivo', 'icon': ['bomba', 'muschio'], 'stack': 30,
                    'blast': {'radius': 2.5, 'power': 35, 'damage': 40, 'fuse': 1.5}, 'desc': 'Si lancia: scoppia dopo un attimo, rompe la roccia tenera.'},
    'richiamo_pavoncella': {'name': 'Fischietto di pavoncella', 'kind': 'accessorio', 'icon': ['penna', 'seta'], 'acc': {'jump': 1.06, 'glide': True},
                            'desc': 'Salto +6%; tenendo il salto si plana.'},
    'guanti_ermellino': {'name': 'Manicotto d\'ermellino', 'kind': 'accessorio', 'icon': ['guanto', 'brina'], 'acc': {'caldo': 0.5, 'dig': 1.06},
                         'desc': 'Freddo: protegge a metà; scavo +6%.'},
    'artigli_talpa': {'name': 'Artigli da talpa', 'kind': 'accessorio', 'icon': ['artiglio', 'cenere'], 'acc': {'dig': 1.15},
                      'desc': 'Scavo +15%: la cenere e la terra cedono prima.'},
    'scudo_elitra': {'name': 'Scudo d\'elitra', 'kind': 'accessorio', 'icon': ['scudo', 'cenere'], 'acc': {'defense': 3, 'fresco': 0.3},
                     'desc': '+3 Scorza; calore: protegge un poco.'},
    'lente_vetro': {'name': 'Lente di scaglia', 'kind': 'accessorio', 'icon': ['anello', 'cristallo'], 'acc': {'halo': 1.3, 'magic': 1.05},
                    'desc': 'Alone +30%, incantesimi +5%.'},
    'collana_perle': {'name': 'Collana di perle di sabbia', 'kind': 'accessorio', 'icon': ['amuleto', 'ambra'], 'acc': {'luck': 0.06, 'regen': 1.08},
                      'desc': 'Fortuna +6%; la Vita ricresce +8%.'},
    'unguento_foca': {'name': 'Unguento di grasso di foca', 'kind': 'consumabile', 'icon': ['pozione', 'brina'], 'boon': ['riparo_freddo', 300.0], 'stack': 20,
                      'desc': 'Per 5 minuti il freddo non ti tocca.'},
    'collare_zanne': {'name': 'Collare di zanne', 'kind': 'accessorio', 'icon': ['amuleto', 'brina'], 'acc': {'damage': 1.07, 'caldo': 0.25},
                      'desc': 'Danno +7%; freddo: protegge un poco.'},
    'impiastro_muschio': {'name': 'Impiastro di muschio', 'kind': 'consumabile', 'icon': ['pozione', 'muschio'], 'heal': 60, 'stack': 20,
                          'desc': 'Cura 60 Vita.'},
    'scudo_placche': {'name': 'Scudo di placche', 'kind': 'accessorio', 'icon': ['scudo', 'ardesia'], 'acc': {'defense': 5, 'run': 0.96},
                      'desc': '+5 Scorza, ma si corre un poco più piano.'},
    'anello_noccioli': {'name': 'Anello di noccioli di brace', 'kind': 'accessorio', 'icon': ['anello', 'brace'], 'acc': {'thorns': 8, 'fresco': 0.3},
                        'desc': 'Chi ti tocca si scotta (8); calore: protegge un poco.'},
    'ali_brace': {'name': 'Penne di falco', 'kind': 'accessorio', 'icon': ['penna', 'brace'], 'acc': {'glide': True, 'jump': 1.05, 'run': 1.03},
                  'desc': 'Si plana; salto +5%, corsa +3%.'},
    'corona_palchi': {'name': 'Diadema di palco', 'kind': 'accessorio', 'icon': ['amuleto', 'iride'], 'acc': {'regen': 1.12, 'luck': 0.05},
                      'desc': 'La Vita ricresce +12%; fortuna +5%.'},
    'bussola_guida': {'name': 'Bussola del pelo di guida', 'kind': 'accessorio', 'icon': ['amuleto', 'iride'], 'acc': {'run': 1.08},
                      'desc': 'Corsa +8%: chi la porta sa dove andare.'},
    'polvere_iride_boccetta': {'name': 'Boccetta di polvere d\'ali', 'kind': 'consumabile', 'icon': ['pozione', 'iride'], 'boon': ['bagliore', 240.0], 'stack': 20,
                               'desc': 'Per 4 minuti fai più luce attorno a te.'},
    'lanterna_brillo': {'name': 'Lanterna di gelatina stellare', 'kind': 'accessorio', 'icon': ['lanterna', 'brillaluce'], 'acc': {'halo': 1.5},
                        'desc': 'Alone +50%: una piccola notte stellata in tasca.'},
    'mantello_gufo': {'name': 'Mantello di piume di gufo', 'kind': 'accessorio', 'icon': ['velo', 'nottilite'], 'acc': {'stealth': 0.8, 'fall_safe': True},
                      'desc': 'Le creature ti vedono più tardi (−20%); le cadute non fanno male.'},
    'velo_ascolto': {'name': 'Velo dell\'ascolto', 'kind': 'accessorio', 'icon': ['velo', 'nottilite'], 'acc': {'stealth': 0.85, 'magic': 1.06},
                     'desc': 'Le creature ti notano più tardi (−15%); incantesimi +6%.'},
    'fiala_zecca': {'name': 'Fiala di Linfa rubata', 'kind': 'consumabile', 'icon': ['pozione', 'linfa'], 'linfa': 10, 'stack': 20,
                    'desc': 'Restituisce 10 Linfa.'},
    'mantello_ombra': {'name': 'Mantello d\'ombra', 'kind': 'accessorio', 'icon': ['velo', 'nottilite'], 'acc': {'stealth': 0.75},
                       'desc': 'Le creature ti vedono molto più tardi (−25%).'},
    'sacca_ladra': {'name': 'Sacca della formica ladra', 'kind': 'accessorio', 'icon': ['sacca', 'ambra'], 'acc': {'luck': 0.05, 'run': 1.03},
                    'desc': 'Fortuna +5%; corsa +3%: prendi e scappa.'},
    # i trofei: un talismano per bioma, fatto con i trofei delle specie nuove di quel bioma
    'talismano_cappelli': {'name': 'Talismano delle Colline', 'kind': 'accessorio', 'icon': ['amuleto', 'fungo'], 'acc': {'luck': 0.1, 'stealth': 0.9}, 'desc': 'Fortuna +10%; le creature ti notano più tardi.'},
    'talismano_torba': {'name': 'Talismano della torbiera', 'kind': 'accessorio', 'icon': ['amuleto', 'muschio'], 'acc': {'regen': 1.15, 'respiro': 1.3}, 'desc': 'La Vita ricresce +15%; sott\'acqua il respiro dura +30%.'},
    'talismano_vento': {'name': 'Talismano del vento', 'kind': 'accessorio', 'icon': ['amuleto', 'seta'], 'acc': {'jump': 1.1, 'glide': True}, 'desc': 'Salto +10%; si plana.'},
    'talismano_brina': {'name': 'Talismano della brina', 'kind': 'accessorio', 'icon': ['amuleto', 'brina'], 'acc': {'caldo': 0.7, 'luck': 0.05}, 'desc': 'Freddo: protegge al 70%; fortuna +5%.'},
    'talismano_ceneri': {'name': 'Talismano delle ceneri', 'kind': 'accessorio', 'icon': ['amuleto', 'cenere'], 'acc': {'fresco': 0.6, 'dig': 1.1}, 'desc': 'Calore: protegge al 60%; scavo +10%.'},
    'talismano_vetro': {'name': 'Talismano del vetro', 'kind': 'accessorio', 'icon': ['amuleto', 'cristallo'], 'acc': {'acqua': 0.6, 'halo': 1.3}, 'desc': 'Sete: protegge al 60%; alone +30%.'},
    'talismano_ghiaccio': {'name': 'Talismano del ghiacciaio', 'kind': 'accessorio', 'icon': ['amuleto', 'linfa'], 'acc': {'caldo': 0.7, 'damage': 1.06}, 'desc': 'Freddo: protegge al 70%; danno +6%.'},
    'talismano_pietra': {'name': 'Talismano della pietra', 'kind': 'accessorio', 'icon': ['amuleto', 'ardesia'], 'acc': {'filtro': 0.6, 'defense': 3}, 'desc': 'Polvere: protegge al 60%; +3 Scorza.'},
    'talismano_brace': {'name': 'Talismano della brace viva', 'kind': 'accessorio', 'icon': ['amuleto', 'tizzonite'], 'acc': {'fresco': 0.7, 'thorns': 10}, 'desc': 'Calore: protegge al 70%; chi ti tocca si brucia (10).'},
    'talismano_iride': {'name': 'Talismano iridato', 'kind': 'accessorio', 'icon': ['amuleto', 'iride'], 'acc': {'luck': 0.12, 'regen': 1.1}, 'desc': 'Fortuna +12%; la Vita ricresce +10%.'},
    'talismano_stelle': {'name': 'Talismano delle stelle', 'kind': 'accessorio', 'icon': ['amuleto', 'brillaluce'], 'acc': {'magic': 1.12, 'halo': 1.3}, 'desc': 'Incantesimi +12%; alone +30%.'},
    'talismano_sussurri': {'name': 'Talismano dei sussurri', 'kind': 'accessorio', 'icon': ['amuleto', 'nottilite'], 'acc': {'stealth': 0.75, 'damage': 1.05}, 'desc': 'Le creature ti vedono molto più tardi; danno +5%.'},
    'talismano_ambra': {'name': 'Talismano della regina ladra', 'kind': 'accessorio', 'icon': ['amuleto', 'ambra'], 'acc': {'luck': 0.1, 'dig': 1.05}, 'desc': 'Fortuna +10%; scavo +5%.'},
}
R = lambda out, ins, st, q=1: {'out': out, 'qty': q, 'in': ins, 'station': st}
SURFACE_RECIPES = [
    R('mantello_spore', {'filo_spore': 10, 'seta_radice': 4}, 'telaio'),
    R('borsa_cappelletto', {'lamella_ladra': 8, 'seta_radice': 3}, 'telaio'),
    R('bomba_torba', {'sacca_torba': 2, 'polvere_brace': 1}, 'alambicco', 3),
    R('richiamo_pavoncella', {'piuma_pavoncella': 10, 'lingotto_radicite': 2}, 'telaio'),
    R('guanti_ermellino', {'pelo_ermellino': 10, 'seta_radice': 4}, 'telaio'),
    R('artigli_talpa', {'artiglio_cenere': 8, 'lingotto_legnoferro': 3}, 'maglio'),
    R('scudo_elitra', {'elitra_cenere': 10, 'lingotto_legnoferro': 4}, 'maglio'),
    R('lente_vetro', {'scaglia_vetro': 8, 'lingotto_ambra': 2}, 'maglio'),
    R('collana_perle', {'perla_sabbia': 8, 'seta_radice': 2}, 'telaio'),
    R('unguento_foca', {'grasso_foca': 2, 'gelatina': 1}, 'alambicco', 2),
    R('collare_zanne', {'zanna_ghiaccio': 8, 'seta_radice': 3}, 'telaio'),
    R('impiastro_muschio', {'muschio_guaritore': 2}, 'alambicco', 2),
    R('scudo_placche', {'placca_pietra': 10, 'lingotto_legnoferro': 4}, 'maglio'),
    R('anello_noccioli', {'nocciolo_brace': 8, 'lingotto_ambra': 2}, 'maglio'),
    R('ali_brace', {'penna_brace': 12, 'seta_radice': 4}, 'telaio'),
    R('corona_palchi', {'palco_iride': 6, 'lingotto_ambra': 2}, 'maglio'),
    R('bussola_guida', {'pelo_guida': 6, 'palco_iride': 2}, 'telaio'),
    R('polvere_iride_boccetta', {'polvere_ali': 3, 'gelatina': 1}, 'alambicco', 2),
    R('lanterna_brillo', {'gelatina_stelle': 8, 'cuore_stellamimo': 1, 'lingotto_radicite': 3}, 'maglio'),
    R('mantello_gufo', {'piuma_gufo': 12, 'seta_radice': 4}, 'telaio'),
    R('velo_ascolto', {'velo_sussurro': 8, 'seta_radice': 2}, 'telaio'),
    R('fiala_zecca', {'rostro_zecca': 2, 'gelatina': 1}, 'alambicco', 2),
    R('mantello_ombra', {'pelle_ombra': 10, 'seta_radice': 4}, 'telaio'),
    R('sacca_ladra', {'resina_ladra': 8, 'seta_radice': 3}, 'telaio'),
    R('talismano_cappelli', {'ghiandola_tessispore': 1, 'cappello_rubato': 1, 'lingotto_ambra': 2}, 'maglio'),
    R('talismano_torba', {'gozzo_rospo': 2, 'lingotto_ambra': 2}, 'maglio'),
    R('talismano_vento', {'ciuffo_pavoncella': 2, 'lingotto_ambra': 2}, 'maglio'),
    R('talismano_brina', {'coda_ermellino': 2, 'lingotto_ambra': 2}, 'maglio'),
    R('talismano_ceneri', {'muso_talpa': 1, 'corno_scarabeo': 1, 'lingotto_ambra': 2}, 'maglio'),
    R('talismano_vetro', {'occhio_vetro': 1, 'palla_sabbia': 1, 'lingotto_ambra': 2}, 'maglio'),
    R('talismano_ghiaccio', {'baffo_foca': 1, 'pelliccia_capobranco': 1, 'lingotto_ambra': 2}, 'maglio'),
    R('talismano_pietra', {'cuore_muschiolo': 1, 'scudo_scudato': 1, 'lingotto_ambra': 2}, 'maglio'),
    R('talismano_brace', {'seme_grumo': 1, 'artiglio_falco': 1, 'lingotto_ambra': 2}, 'maglio'),
    R('talismano_iride', {'corona_cervo': 1, 'stella_guida': 1, 'ala_iride': 1, 'lingotto_ambra': 2}, 'maglio'),
    R('talismano_stelle', {'perla_brillo': 1, 'maschera_stella': 1, 'occhio_gufo_radure': 1, 'lingotto_ambra': 2}, 'maglio'),
    R('talismano_sussurri', {'voce_sussurro': 1, 'ventre_zecca': 1, 'zoccolo_ombra': 1, 'lingotto_ambra': 2}, 'maglio'),
    R('talismano_ambra', {'regina_ladra': 2, 'lingotto_ambra': 2}, 'maglio'),
]

if __name__ == '__main__':
    write('superficie.gd', 'Il nuovo bestiario, primo ciclo: la superficie (voce 132, Roadmap 15). 24 specie per i biomi di superficie\nche ne avevano poche (misurati da `tools/ecosistemi.gd`), con le astuzie della voce 130.',
          SURFACE, SURFACE_ITEMS, SURFACE_RECIPES)
    import bestiario_sottosuolo as sot
    write('sottosuolo.gd', 'Il nuovo bestiario, secondo ciclo: il sottosuolo e i liquidi (voce 133, Roadmap 15). 24 specie per gli\nstrati, i biomi del sottosuolo (`under`) e i liquidi (`water` con `liquid`); la lontra e il luccio rubano il\npesce alla lenza (`steal_fish`).',
          sot.UNDER, sot.UNDER_ITEMS, sot.UNDER_RECIPES)
