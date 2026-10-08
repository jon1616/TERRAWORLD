"""Genera i Signori dei luoghi (voce 135, Roadmap 15) in src/data/bestiary/signori.gd.

Un Signore per ogni bioma di superficie, per ogni bioma del sottosuolo e per ogni strato: un mini-boss nato da una
**ricetta** (corpo di `BodyArt` ingrandito, comportamenti delle voci 127-131, una fase di furia con altri comportamenti)
che si chiama con la sua **esca rituale** nel suo luogo. Lascia un materiale che c'è solo lì e il suo trofeo; con
entrambi si fa il suo oggetto. Per cambiarne uno si cambia la riga e si rilancia:
    python tools/gen_signori.py
"""
import os
from gen_bestiario import gd

ROOT = os.path.join(os.path.dirname(__file__), '..', 'src', 'data', 'bestiary')
TIER = {2: (520, 20, 4), 3: (820, 26, 7), 4: (1200, 32, 10)}

# key, dove (biome/under/stratum), grado, nome, piano, w, h, tavolozza, occhio, extra corpo, comportamenti, furia,
# parametri, chi chiama nella furia, elemento debole/forte, materiale (id, nome, icona), trofeo (id, nome, icona),
# oggetto (id, nome, tipo, icona, campi), ingredienti dell'esca (oltre all'ambra)
L = [
    ('foresta', {'biomes': ['foresta']}, 2, 'Cervo-lanterna antico', 'quadrupede', 40, 34, ['#1e2a1e', '#2e4a2a', '#4a7040', '#7aa860', '#d0f0a0'], '#ffd24a',
     {'horns': 2, 'marks': 'macchie', 'mark': '#ffd24a', 'glow': True}, ['cammina', 'carica'], ['richiamo', 'scatto'],
     {'sight': 26, 'charge': 260.0, 'charge_range': 10, 'charge_time': 0.8, 'charge_cool': 3.0, 'call_time': 1.4, 'call_n': 2, 'calls': 3, 'dash_every': 2.6, 'dash_speed': 300.0, 'dash_time': 0.35},
     'orso_corteccia', ('brace', 'spora'), ('palco_lanterna', 'Palco-lanterna', ['artiglio', 'lucciola']), ('corona_lanterna', 'Corona del Cervo-lanterna', ['amuleto', 'lucciola']),
     ('lanterna_signore', 'Lanterna del Signore del bosco', 'accessorio', ['lanterna', 'lucciola'], {'acc': {'halo': 1.8, 'regen': 1.1}, 'desc': 'Alone +80%; la Vita ricresce +10%.'}), {'legno': 20, 'seme_lanterna': 3}),
    ('palude', {'biomes': ['palude']}, 2, 'Madre delle spore', 'lumaca', 40, 32, ['#20182a', '#3a2a46', '#5a4468', '#8a6a98', '#d0b0e0'], '#a0ff60',
     {'marks': 'macchie', 'mark': '#a0ff60', 'glow': True}, ['cammina', 'spara'], ['ventaglio', 'evoca'],
     {'sight': 24, 'rate': 2.0, 'shot_speed': 180.0, 'fan_n': 5, 'fan_rate': 3.0, 'summon_every': 7.0, 'summon_max': 3},
     'grumo_muschio', ('brace', 'spora'), ('cuore_spore', 'Cuore di spore', ['essenza', 'fungo']), ('velo_madre', 'Velo della Madre', ['velo', 'fungo']),
     ('mantello_spore_madre', 'Mantello della Madre delle spore', 'accessorio', ['velo', 'fungo'], {'acc': {'filtro': 0.6, 'thorns': 8}, 'desc': 'Polvere: protegge al 60%; chi ti tocca si ferisce (8).'}), {'fungo_luminoso': 4, 'gelatina': 3}),
    ('ambra', {'biomes': ['ambra']}, 3, 'Scarabeo regale d\'ambra', 'insetto', 44, 30, ['#3a2208', '#6a3e10', '#a0621a', '#d8962a', '#fff0a8'], '#ff6030',
     {'marks': 'punte', 'mark': '#fff0a8', 'glow': True}, ['cammina', 'carica', 'guscio'], ['scatto', 'richiamo'],
     {'sight': 22, 'charge': 240.0, 'charge_range': 9, 'charge_time': 0.9, 'charge_cool': 3.5, 'shell_time': 2.0, 'dash_every': 3.0, 'dash_speed': 280.0, 'dash_time': 0.4, 'call_time': 1.4, 'call_n': 2, 'calls': 3},
     'formica_ladra', ('gelo', 'spora'), ('elitra_regale', 'Elitra regale', ['scaglia', 'ambra']), ('corno_regale', 'Corno regale d\'ambra', ['artiglio', 'ambra']),
     ('scudo_regale', 'Scudo dell\'elitra regale', 'accessorio', ['scudo', 'ambra'], {'acc': {'defense': 6, 'thorns': 6}, 'desc': '+6 Scorza; chi ti tocca si punge (6).'}), {'resina_ladra': 4, 'lingotto_ambra': 2}),
    ('brina', {'biomes': ['brina']}, 3, 'Alce della brina', 'quadrupede', 42, 36, ['#6a7a88', '#9ab0c0', '#c8dce8', '#eef8ff', '#ffffff'], '#40c0ff',
     {'horns': 2, 'marks': 'strisce', 'mark': '#40c0ff', 'glow': True}, ['cammina', 'carica'], ['ventaglio', 'richiamo'],
     {'sight': 26, 'charge': 250.0, 'charge_range': 10, 'charge_time': 0.8, 'charge_cool': 3.0, 'fan_n': 5, 'fan_rate': 2.8, 'call_time': 1.4, 'call_n': 2, 'calls': 3},
     'ermellino', ('brace', 'gelo'), ('palco_alce', 'Palco della brina', ['artiglio', 'brina']), ('respiro_alce', 'Respiro gelato', ['essenza', 'brina']),
     ('mantello_alce', 'Mantello dell\'Alce della brina', 'accessorio', ['velo', 'brina'], {'acc': {'caldo': 1.0, 'run': 1.05}, 'desc': 'Il freddo non ti tocca; corsa +5%.'}), {'pelo_ermellino': 4, 'linfa_gelata': 2}),
    ('cenere', {'biomes': ['cenere']}, 3, 'Salamandra madre', 'serpe', 48, 22, ['#3a1008', '#6a1c0c', '#a83414', '#e06a24', '#ffd070'], '#fff0a0',
     {'marks': 'punte', 'mark': '#ffd070', 'glow': True, 'tail': True}, ['salta_verso', 'sbuca'], ['spara', 'evoca'],
     {'jump': 260.0, 'sight': 24, 'windup': 1.0, 'out_time': 5.0, 'rate': 1.8, 'shot_speed': 200.0, 'summon_every': 7.0, 'summon_max': 3},
     'salamandra_brace', ('gelo', 'brace'), ('lingua_brace', 'Lingua di brace', ['essenza', 'brace']), ('cresta_madre', 'Cresta della Salamandra madre', ['penna', 'brace']),
     ('guanti_madre', 'Guanti della Salamandra madre', 'accessorio', ['guanto', 'brace'], {'acc': {'fresco': 0.8, 'damage': 1.08}, 'desc': 'Calore: protegge all\'80%; danno +8%.'}), {'squama_brace': 4, 'cenere_viva': 3}),
    ('prati', {'biomes': ['prati']}, 2, 'Aquila del vento', 'uccello', 44, 30, ['#1e2a2a', '#344848', '#56706c', '#8aa89e', '#e0f0e0'], '#ffd040',
     {'wings': '#344848', 'marks': 'strisce', 'mark': '#e0f0e0'}, ['vola', 'bombarda'], ['scatto', 'richiamo'],
     {'sight': 30, 'hover': 90.0, 'wobble': 20.0, 'rate': 2.4, 'dash_every': 2.6, 'dash_speed': 320.0, 'dash_time': 0.4, 'call_time': 1.4, 'call_n': 2, 'calls': 3},
     'pavoncella', ('vuoto', 'spora'), ('penna_aquila', 'Penna dell\'Aquila', ['penna', 'seta']), ('artiglio_aquila', 'Artiglio del vento', ['artiglio', 'seta']),
     ('ali_aquila', 'Ali dell\'Aquila del vento', 'accessorio', ['penna', 'seta'], {'acc': {'glide': True, 'air_jumps': 1, 'jump': 1.05}, 'desc': 'Un salto in aria in più; si plana; salto +5%.'}), {'piuma_pavoncella': 5, 'seta_radice': 3}),
    ('rossa', {'biomes': ['rossa']}, 3, 'Orso rosso antico', 'quadrupede', 46, 36, ['#2a1010', '#4a1c18', '#702a22', '#a04030', '#e08060'], '#ffd040',
     {'marks': 'strisce', 'mark': '#e08060', 'tail': False}, ['cammina', 'carica'], ['scatto', 'evoca'],
     {'sight': 22, 'charge': 230.0, 'charge_range': 9, 'charge_time': 1.0, 'charge_cool': 3.5, 'dash_every': 2.8, 'dash_speed': 280.0, 'dash_time': 0.4, 'summon_every': 7.0, 'summon_max': 2},
     'orso_corteccia', ('spora', 'gelo'), ('pelliccia_rossa_antica', 'Pelliccia rossa antica', ['seta', 'sanguinella']), ('zanna_orso_rosso', 'Zanna dell\'Orso rosso', ['artiglio', 'sanguinella']),
     ('guanti_orso', 'Zampe dell\'Orso rosso', 'accessorio', ['guanto', 'sanguinella'], {'acc': {'damage': 1.12, 'defense': 2}, 'desc': 'Danno +12%; +2 Scorza.'}), {'pelliccia_rossa': 4, 'legno': 10}),
    ('funghi', {'biomes': ['funghi']}, 2, 'Re dei cappelli', 'lumaca', 40, 36, ['#3a1a1a', '#6a2a24', '#9a4034', '#d07060', '#f0c0a0'], '#fff0a0',
     {'marks': 'macchie', 'mark': '#f0f0e0'}, ['salta_verso', 'spara'], ['divide', 'evoca'],
     {'jump': 220.0, 'sight': 22, 'rate': 2.2, 'shot_speed': 180.0, 'big_hit': 0.2, 'split_hp': 0.2, 'summon_every': 7.0, 'summon_max': 3},
     'cappelletto', ('brace', 'spora'), ('cappello_re', 'Cappello del Re', ['seme', 'fungo']), ('scettro_re', 'Scettro di lamella', ['bastone', 'fungo']),
     ('corona_cappelli', 'Corona dei cappelli', 'accessorio', ['amuleto', 'fungo'], {'acc': {'luck': 0.12, 'regen': 1.08}, 'desc': 'Fortuna +12%; la Vita ricresce +8%.'}), {'lamella_ladra': 4, 'fungo_luminoso': 3}),
    ('torba', {'biomes': ['torba']}, 2, 'Rospo re della torbiera', 'anfibio', 42, 32, ['#1a2418', '#2e3e26', '#48603a', '#7a9a58', '#c0e090'], '#f0a030',
     {'marks': 'macchie', 'mark': '#a0e060', 'glow': True}, ['salta_verso', 'spara'], ['evoca', 'scatto'],
     {'jump': 260.0, 'sight': 24, 'rate': 2.2, 'shot_speed': 190.0, 'summon_every': 6.0, 'summon_max': 3, 'dash_every': 3.0, 'dash_speed': 260.0, 'dash_time': 0.35},
     'rospo_torba', ('gelo', 'spora'), ('gozzo_re', 'Gozzo del re', ['gel', 'muschio']), ('corona_torba', 'Corona di torba', ['amuleto', 'muschio']),
     ('sacca_re', 'Sacca del re dei rospi', 'accessorio', ['sacca', 'muschio'], {'acc': {'respiro': 2.0, 'jump': 1.08}, 'desc': 'Respiro raddoppiato; salto +8%.'}), {'sacca_torba': 4, 'gelatina': 3}),
    ('vetro', {'biomes': ['vetro']}, 3, 'Verme di vetro', 'serpe', 56, 24, ['#3a5a60', '#5a8088', '#80a8ae', '#b0d8dc', '#f0ffff'], '#ff5050',
     {'marks': 'strisce', 'mark': '#f0ffff', 'glow': True}, ['cammina', 'sbuca'], ['ventaglio', 'scatto'],
     {'sight': 22, 'windup': 0.9, 'out_time': 4.0, 'fan_n': 5, 'fan_rate': 2.8, 'dash_every': 2.6, 'dash_speed': 300.0, 'dash_time': 0.4},
     'lucertola_vetro', ('vuoto', 'luce'), ('anello_vetro_vivo', 'Anello di vetro vivo', ['anello', 'cristallo']), ('dente_verme', 'Dente del Verme di vetro', ['artiglio', 'cristallo']),
     ('lama_verme', 'Lama del Verme di vetro', 'spada', ['lama', 'cristallo'], {'tier': 5, 'damage': 34, 'speed': 2.6, 'knockback': 2.0, 'desc': 'Tagliente come il vetro fuso.'}), {'scaglia_vetro': 4, 'sabbia_fusa': 3}),
    ('ghiacciaio', {'biomes': ['ghiacciaio']}, 3, 'Orca dei ghiacci', 'serpe', 54, 26, ['#2a4a5a', '#406878', '#5e8e9e', '#90c0cc', '#e0f8ff'], '#101820',
     {'marks': 'macchie', 'mark': '#e0f8ff', 'glow': True}, ['cammina', 'carica'], ['ventaglio', 'richiamo'],
     {'sight': 24, 'charge': 260.0, 'charge_range': 10, 'charge_time': 0.8, 'charge_cool': 3.0, 'fan_n': 5, 'fan_rate': 2.8, 'call_time': 1.4, 'call_n': 2, 'calls': 3},
     'lupo_ghiaccio', ('brace', 'gelo'), ('pinna_orca', 'Pinna dell\'Orca', ['membrana', 'brina']), ('dente_orca', 'Dente dell\'Orca', ['artiglio', 'brina']),
     ('corazza_orca', 'Pelle dell\'Orca dei ghiacci', 'accessorio', ['scudo', 'brina'], {'acc': {'caldo': 0.8, 'defense': 4}, 'desc': 'Freddo: protegge all\'80%; +4 Scorza.'}), {'zanna_ghiaccio': 4, 'grasso_foca': 3}),
    ('pietra', {'biomes': ['pietra']}, 3, 'Golem antico di pietra', 'quadrupede', 48, 40, ['#2a2a26', '#46463e', '#6a6a5e', '#9a9a88', '#d0d0b8'], '#8ef0d8',
     {'marks': 'macchie', 'mark': '#3aa08a', 'glow': True, 'horns': 1}, ['cammina', 'carica', 'scudo'], ['bombarda', 'richiamo'],
     {'sight': 20, 'charge': 210.0, 'charge_range': 8, 'charge_time': 1.0, 'charge_cool': 4.0, 'turn': 1.2, 'rate': 2.6, 'call_time': 1.4, 'call_n': 2, 'calls': 3},
     'scudato_pietra', ('linfa', 'brace'), ('cuore_pietra_antico', 'Cuore di pietra antico', ['essenza', 'ardesia']), ('masso_rune', 'Masso con le rune', ['gemma', 'ardesia']),
     ('amuleto_golem', 'Amuleto del Golem antico', 'accessorio', ['amuleto', 'ardesia'], {'acc': {'defense': 8, 'run': 0.95}, 'desc': '+8 Scorza, ma si corre un poco più piano.'}), {'placca_pietra': 4, 'muschio_antico': 3}),
    ('brace', {'biomes': ['brace']}, 3, 'Drago di brace', 'uccello', 50, 34, ['#2a1010', '#501c14', '#84301c', '#c05a28', '#ffb060'], '#ffff80',
     {'wings': '#84301c', 'marks': 'punte', 'mark': '#ffb060', 'glow': True}, ['vola', 'spara'], ['ventaglio', 'bombarda'],
     {'sight': 30, 'hover': 80.0, 'wobble': 20.0, 'rate': 1.8, 'shot_speed': 220.0, 'fan_n': 6, 'fan_rate': 2.6, 'rate': 2.4},
     'falco_brace', ('gelo', 'brace'), ('scaglia_drago', 'Scaglia di drago', ['scaglia', 'tizzonite']), ('cuore_drago', 'Cuore del drago', ['essenza', 'tizzonite']),
     ('mantello_drago', 'Mantello di scaglie di drago', 'accessorio', ['velo', 'tizzonite'], {'acc': {'fresco': 1.0, 'damage': 1.1}, 'desc': 'Il calore non ti tocca; danno +10%.'}), {'penna_brace': 4, 'nocciolo_brace': 3}),
    ('iridato', {'biomes': ['iridato']}, 3, 'Cervo del prisma', 'quadrupede', 44, 38, ['#3a2a4a', '#5a4470', '#8468a0', '#d0b8f0', '#ffffff'], '#ffe070',
     {'horns': 2, 'marks': 'macchie', 'mark': '#ffb0f0', 'glow': True}, ['cammina', 'scatto'], ['ventaglio', 'teletrasporto'],
     {'sight': 24, 'dash_every': 2.4, 'dash_speed': 320.0, 'dash_time': 0.4, 'fan_n': 6, 'fan_rate': 2.6, 'blink_every': 4.0, 'tp_range': 8},
     'cervo_iride', ('vuoto', 'luce'), ('prisma_vivo', 'Prisma vivo', ['gemma', 'iride']), ('palco_prisma', 'Palco del prisma', ['artiglio', 'iride']),
     ('anello_prisma', 'Anello del prisma', 'accessorio', ['anello', 'iride'], {'acc': {'magic': 1.15, 'luck': 0.08}, 'desc': 'Incantesimi +15%; fortuna +8%.'}), {'palco_iride': 3, 'polvere_ali': 4}),
    ('stellare', {'biomes': ['stellare']}, 3, 'Gufo della notte senza fine', 'uccello', 44, 36, ['#1a1a2a', '#2e2e48', '#4c4c70', '#8080a8', '#e0e0f0'], '#ffd040',
     {'wings': '#2e2e48', 'marks': 'macchie', 'mark': '#ffffc0', 'glow': True}, ['vola', 'spara'], ['teletrasporto', 'evoca'],
     {'sight': 30, 'hover': 70.0, 'wobble': 20.0, 'rate': 1.8, 'shot_speed': 220.0, 'blink_every': 4.0, 'tp_range': 8, 'summon_every': 7.0, 'summon_max': 3},
     'gufo_stellare', ('luce', 'vuoto'), ('piuma_notte', 'Piuma della notte', ['penna', 'nottilite']), ('occhio_notte', 'Occhio della notte', ['gemma', 'nottilite']),
     ('mantello_notte', 'Mantello della notte senza fine', 'accessorio', ['velo', 'nottilite'], {'acc': {'stealth': 0.7, 'magic': 1.08}, 'desc': 'Le creature ti vedono molto più tardi (−30%); incantesimi +8%.'}), {'piuma_gufo': 4, 'gelatina_stelle': 3}),
    ('sussurri', {'biomes': ['sussurri']}, 3, 'Voce del bosco', 'fluttuante', 38, 44, ['#0e0e16', '#1c1c2a', '#2e2e44', '#50506e', '#9a9ac0'], '#e0e0ff',
     {'marks': 'strisce', 'mark': '#9a9ac0', 'glow': True}, ['vola', 'fotofobo', 'spara'], ['teletrasporto', 'evoca'],
     {'sight': 26, 'hover': 30.0, 'wobble': 40.0, 'dark_mult': 1.5, 'rate': 2.0, 'shot_speed': 200.0, 'blink_every': 3.5, 'tp_range': 8, 'summon_every': 7.0, 'summon_max': 3},
     'sussurratore', ('luce', 'vuoto'), ('eco_bosco', 'Eco del bosco', ['essenza', 'nottilite']), ('voce_bosco', 'Voce del bosco chiusa', ['gemma', 'nottilite']),
     ('velo_voce', 'Velo della Voce del bosco', 'accessorio', ['velo', 'nottilite'], {'acc': {'stealth': 0.75, 'linfa_regen': 1.2}, 'desc': 'Le creature ti vedono più tardi; la Linfa ricresce +20%.'}), {'velo_sussurro': 4, 'pelle_ombra': 3}),
    # i biomi del sottosuolo
    ('canto', {'under': 'canto'}, 3, 'Coro di cristallo', 'fluttuante', 40, 40, ['#1a2440', '#2c3e66', '#4a64a0', '#80a8e0', '#e0f0ff'], '#fff0a0',
     {'marks': 'punte', 'mark': '#e0f0ff', 'glow': True}, ['vola', 'ventaglio'], ['richiamo', 'teletrasporto'],
     {'sight': 26, 'hover': 30.0, 'wobble': 30.0, 'fan_n': 6, 'fan_rate': 2.4, 'call_time': 1.4, 'call_n': 2, 'calls': 3, 'blink_every': 4.0, 'tp_range': 8},
     'corista_cristallo', ('vuoto', 'luce'), ('nota_cristallo', 'Nota di cristallo', ['gemma', 'cristallo']), ('diapason', 'Diapason del Coro', ['artiglio', 'cristallo']),
     ('bastone_coro', 'Bastone del Coro', 'accessorio', ['amuleto', 'cristallo'], {'acc': {'magic': 1.18}, 'desc': 'Incantesimi +18%.'}), {'corda_cristallo': 4, 'sabbia_cantante': 3}),
    ('giungla', {'under': 'giungla'}, 2, 'Madre della giungla', 'insetto', 46, 32, ['#1a1a0e', '#2e2e18', '#4a4a26', '#78783e', '#c0c070'], '#ff4040',
     {'marks': 'strisce', 'mark': '#c0c070'}, ['cammina', 'tessitore'], ['evoca', 'scatto'],
     {'sight': 22, 'web_every': 3.5, 'summon_every': 6.0, 'summon_max': 3, 'dash_every': 3.0, 'dash_speed': 280.0, 'dash_time': 0.35},
     'ragno_giungla', ('brace', 'spora'), ('seta_madre', 'Seta della Madre', ['seta', 'radice']), ('filiera_madre', 'Filiera della Madre', ['essenza', 'radice']),
     ('rampino_seta', 'Guanti di seta della Madre', 'accessorio', ['guanto', 'radice'], {'acc': {'wall': True, 'atk_speed': 1.08}, 'desc': 'Ci si aggrappa alle pareti; colpi +8%.'}), {'seta_giungla': 4, 'pelo_liana': 3}),
    ('lago', {'under': 'lago'}, 3, 'Granchio re del lago', 'insetto', 48, 30, ['#1a2a30', '#2e4650', '#4a6a78', '#7aa0b0', '#c0e0e8'], '#ffd24a',
     {'marks': 'punte', 'mark': '#c0e0e8'}, ['cammina', 'carica', 'scudo'], ['richiamo', 'bombarda'],
     {'sight': 20, 'charge': 230.0, 'charge_range': 8, 'charge_time': 0.8, 'charge_cool': 3.0, 'turn': 1.0, 'call_time': 1.4, 'call_n': 2, 'calls': 3, 'rate': 2.6},
     'granchio_lago', ('brace', 'gelo'), ('chela_re', 'Chela del re', ['artiglio', 'lagunite']), ('corona_lago', 'Corona del lago', ['amuleto', 'lagunite']),
     ('scudo_chela', 'Scudo della chela del re', 'accessorio', ['scudo', 'lagunite'], {'acc': {'defense': 6, 'respiro': 1.5}, 'desc': '+6 Scorza; respiro +50%.'}), {'carapace_lago': 4, 'guscio_tartaruga': 2}),
    ('catacombe', {'under': 'catacombe'}, 3, 'Custode delle ossa', 'anfibio', 40, 44, ['#2a2822', '#46423a', '#6a6458', '#9a9282', '#e0d8c4'], '#6ff0d8',
     {'marks': 'strisce', 'mark': '#e0d8c4', 'glow': True}, ['cammina', 'carica', 'scudo'], ['evoca', 'teletrasporto'],
     {'sight': 22, 'charge': 220.0, 'charge_range': 8, 'charge_time': 0.8, 'charge_cool': 3.5, 'turn': 1.0, 'summon_every': 6.0, 'summon_max': 3, 'blink_every': 4.0, 'tp_range': 8},
     'ossuto_scudato', ('luce', 'vuoto'), ('osso_rune', 'Osso con le rune', ['artiglio', 'sem']), ('teschio_custode', 'Teschio del Custode', ['essenza', 'sem']),
     ('amuleto_ossa_rune', 'Amuleto delle ossa con le rune', 'accessorio', ['amuleto', 'sem'], {'acc': {'defense': 4, 'magic': 1.1}, 'desc': '+4 Scorza; incantesimi +10%.'}), {'osso_seminatore': 4, 'ectoplasma': 3}),
    # gli strati
    ('sottobosco', {'stratum': 1}, 2, 'Talpone delle radici', 'quadrupede', 44, 32, ['#2a1c16', '#443024', '#664834', '#8e6a4c', '#c8a078'], '#90ff70',
     {'marks': 'punte', 'mark': '#c8a078'}, ['cammina', 'sbuca'], ['carica', 'evoca'],
     {'sight': 20, 'windup': 1.0, 'out_time': 5.0, 'charge': 230.0, 'charge_range': 8, 'charge_time': 0.8, 'charge_cool': 3.0, 'summon_every': 6.0, 'summon_max': 3},
     'lombrico_radice', ('gelo', 'spora'), ('artiglio_talpone_radici', 'Artiglio del Talpone', ['artiglio', 'radice']), ('muso_talpone_radici', 'Muso del Talpone', ['essenza', 'radice']),
     ('trivella_talpone', 'Guanti del Talpone', 'accessorio', ['guanto', 'radice'], {'acc': {'dig': 1.3}, 'desc': 'Scavo +30%.'}), {'radichetta': 4, 'muco_lombrico': 3}),
    ('caverne', {'stratum': 2}, 3, 'Pipistrello re dell\'eco', 'uccello', 46, 30, ['#141420', '#262638', '#3e3e58', '#62628a', '#a0a0c8'], '#ff5050',
     {'wings': '#262638'}, ['vola', 'fotofobo', 'scatto'], ['richiamo', 'bombarda'],
     {'sight': 28, 'hover': 40.0, 'wobble': 40.0, 'dark_mult': 1.4, 'dash_every': 2.4, 'dash_speed': 300.0, 'dash_time': 0.4, 'call_time': 1.2, 'call_n': 3, 'calls': 3, 'rate': 2.6},
     'pipistrello_eco', ('luce', 'vuoto'), ('ala_eco_re', 'Ala del re dell\'eco', ['membrana', 'ardesia']), ('orecchio_re', 'Orecchio del re', ['essenza', 'ardesia']),
     ('cuffie_re', 'Cuffie del re dell\'eco', 'accessorio', ['membrana', 'ardesia'], {'acc': {'halo': 1.4, 'stealth': 0.85}, 'desc': 'Alone +40%; le creature ti notano più tardi.'}), {'membrana_eco': 4, 'lastra_carapace': 3}),
    ('profondita', {'stratum': 3}, 4, 'Anguilla madre della Linfa', 'serpe', 58, 26, ['#0a2a2a', '#10504e', '#1a8480', '#40c0b4', '#b0fff0'], '#ffffff',
     {'marks': 'macchie', 'mark': '#ffffff', 'glow': True, 'tail': True}, ['vola', 'scatto', 'spara'], ['divide', 'evoca'],
     {'sight': 28, 'hover': 20.0, 'wobble': 30.0, 'dash_every': 2.4, 'dash_speed': 320.0, 'dash_time': 0.4, 'rate': 1.8, 'shot_speed': 220.0, 'big_hit': 0.2, 'split_hp': 0.15, 'summon_every': 6.0, 'summon_max': 3},
     'goccia_divisa', ('brace', 'linfa'), ('cuore_linfa_madre', 'Cuore di Linfa madre', ['essenza', 'linfa']), ('cresta_madre_linfa', 'Cresta della madre', ['penna', 'linfa']),
     ('anello_madre_linfa', 'Anello della Linfa madre', 'accessorio', ['anello', 'linfa'], {'acc': {'linfa_regen': 1.4, 'magic': 1.1}, 'desc': 'La Linfa ricresce +40%; incantesimi +10%.'}), {'nucleo_goccia': 4, 'luce_guaritrice': 3}),
    ('fondo', {'stratum': 4}, 4, 'Ombra del Fondo', 'fluttuante', 44, 46, ['#0a0614', '#1a1030', '#2e1e54', '#5a40a0', '#c0a0ff'], '#ff80ff',
     {'marks': 'punte', 'mark': '#c0a0ff', 'glow': True}, ['vola', 'teletrasporto', 'ventaglio'], ['evoca', 'scatto'],
     {'sight': 30, 'hover': 30.0, 'wobble': 30.0, 'blink_every': 3.5, 'tp_range': 9, 'fan_n': 7, 'fan_rate': 2.4, 'summon_every': 6.0, 'summon_max': 3, 'dash_every': 2.4, 'dash_speed': 320.0, 'dash_time': 0.4},
     'bolla_vuoto', ('luce', 'vuoto'), ('frammento_fondo', 'Frammento del Fondo', ['gemma', 'vuotite']), ('occhio_fondo', 'Occhio del Fondo', ['essenza', 'vuotite']),
     ('mantello_fondo', 'Mantello dell\'Ombra del Fondo', 'accessorio', ['velo', 'vuotite'], {'acc': {'damage': 1.15, 'stealth': 0.8}, 'desc': 'Danno +15%; le creature ti vedono più tardi.'}), {'artiglio_vuoto': 4, 'vello_vuoto': 3}),
    # Roadmap 16, voce 161: i Signori del cielo (uno per bioma del cielo, tutti volanti: sulle isole non si cade)
    ('radici_sospese', {'sky': 'radici_sospese'}, 3, 'Regina turchese', 'insetto', 40, 32, ['#0f2a30', '#1f5c58', '#3aa08a', '#8ef0d8', '#fff0a0'], '#101010',
     {'wings': '#d8fff4', 'marks': 'strisce', 'mark': '#fff0a0', 'glow': True}, ['vola', 'richiamo'], ['ventaglio', 'evoca'],
     {'sight': 28, 'hover': 50.0, 'wobble': 40.0, 'call_time': 1.2, 'call_n': 3, 'calls': 3, 'fan_n': 6, 'fan_rate': 2.6, 'summon_every': 6.0, 'summon_max': 4},
     'ape_turchese', ('brace', 'spora'), ('pappa_reale_cielo', 'Pappa reale di cielo', ['goccia', 'cielo']), ('corona_turchese', 'Corona turchese', ['corona', 'cielo']),
     ('mantello_regina', 'Mantello della Regina turchese', 'accessorio', ['mantello', 'cielo'], {'acc': {'glide': True, 'regen': 1.15}, 'desc': 'Si plana tenendo il salto; la Vita ricresce +15%.'}), {'miele_cielo': 4, 'seta_cielo': 3}),
    ('mare_nubi', {'sky': 'mare_nubi'}, 3, 'Grande Nuvolo', 'fluttuante', 48, 36, ['#4a5470', '#7a88a8', '#aebcd8', '#d8e2f4', '#ffffff'], '#303040',
     {'marks': 'macchie', 'mark': '#ffffff'}, ['vola', 'divide'], ['bombarda', 'evoca'],
     {'sight': 26, 'hover': 40.0, 'wobble': 30.0, 'rate': 2.4, 'summon_every': 6.0, 'summon_max': 4},
     'nuvolo_vivo', ('brace', 'gelo'), ('cuore_nembo', 'Cuore del nembo', ['cuore', 'nuvola']), ('occhio_nuvolo', 'Occhio del Grande Nuvolo', ['occhio', 'nuvola']),
     ('cuscino_nuvola', 'Cuscino di nuvola', 'accessorio', ['sacca', 'nuvola'], {'acc': {'fall_safe': True, 'defense': 4, 'regen': 1.1}, 'desc': 'Le cadute non fanno male; +4 Scorza; la Vita ricresce +10%.'}), {'vapore_vivo': 4, 'velo_nuvola': 3}),
    ('giardini_vento', {'sky': 'giardini_vento'}, 3, 'Falco re dei venti', 'uccello', 46, 30, ['#2a1a0a', '#5a3a14', '#8a6020', '#c09040', '#f0e0b0'], '#ffd24a',
     {'wings': '#5a3a14', 'marks': 'strisce', 'mark': '#f0e0b0'}, ['vola', 'picchiata'], ['scatto', 'richiamo'],
     {'sight': 32, 'hover': 90.0, 'wobble': 20.0, 'rise': 8, 'dive_speed': 380.0, 'dive_every': 3.5, 'dash_every': 2.6, 'dash_speed': 330.0, 'dash_time': 0.4, 'call_time': 1.2, 'call_n': 2, 'calls': 3},
     'falco_vento', ('gelo', 'luce'), ('piuma_re_venti', 'Piuma del re dei venti', ['penna', 'vento']), ('artiglio_re_venti', 'Artiglio del re dei venti', ['artiglio', 'vento']),
     ('ali_re_venti', 'Ali del re dei venti', 'accessorio', ['ali', 'vento'], {'acc': {'glide': True, 'air_jumps': 1, 'run': 1.08}, 'desc': 'Un salto in aria in più; si plana; corsa +8%.'}), {'penna_falco_vento': 4, 'pelo_vento': 3}),
    ('scogliere_cristallo', {'sky': 'scogliere_cristallo'}, 4, 'Drago di cristallo', 'serpe', 56, 26, ['#14304a', '#1f5078', '#3a80b0', '#8ac8f0', '#e0f6ff'], '#ffd24a',
     {'wings': '#8ac8f0', 'marks': 'punte', 'mark': '#e0f6ff', 'glow': True}, ['vola', 'ventaglio'], ['teletrasporto', 'evoca'],
     {'sight': 30, 'hover': 60.0, 'wobble': 30.0, 'fan_n': 5, 'fan_rate': 2.4, 'fan_spread': 0.7, 'shot_speed': 200.0, 'blink_every': 3.5, 'summon_every': 6.0, 'summon_max': 3},
     'draghetto_eco', ('brace', 'gelo'), ('scaglia_drago_cristallo', 'Scaglia del drago di cristallo', ['scaglia', 'celeste']), ('corno_cristallo', 'Corno di cristallo', ['artiglio', 'celeste']),
     ('corona_cristallo', 'Corona di cristallo', 'accessorio', ['corona', 'celeste'], {'acc': {'quota': 0.6, 'defense': 4}, 'desc': 'Aria sottile: protegge al 60%; +4 Scorza.'}), {'squama_eco': 4, 'cristallo_celeste': 4}),
    ('nidi_tempesta', {'sky': 'nidi_tempesta'}, 4, 'Signore del tuono', 'fluttuante', 46, 42, ['#14182a', '#2a3048', '#4a5478', '#8a98c8', '#fffac0'], '#fffac0',
     {'marks': 'punte', 'mark': '#fffac0', 'glow': True}, ['vola', 'folgore'], ['scatto', 'evoca'],
     {'sight': 30, 'hover': 80.0, 'wobble': 20.0, 'bolt_every': 3.5, 'bolt_delay': 1.0, 'bolts': 3, 'dash_every': 2.8, 'dash_speed': 320.0, 'dash_time': 0.4, 'summon_every': 6.0, 'summon_max': 4},
     'scintilla_viva', ('spora', 'luce'), ('nucleo_tuono', 'Nucleo del tuono', ['stella', 'folgorite']), ('corona_tuono', 'Corona del tuono', ['corona', 'folgorite']),
     ('corno_tuono', 'Corno del tuono', 'accessorio', ['artiglio', 'folgorite'], {'acc': {'damage': 1.12, 'atk_speed': 1.05}, 'desc': 'Danno +12%; colpi +5% più rapidi.'}), {'scintilla_tuono': 4, 'folgorite': 3}),
    ('firmamento', {'sky': 'firmamento'}, 4, 'Balena madre delle stelle', 'fluttuante', 60, 30, ['#101430', '#1c2450', '#2e3a78', '#6a78c0', '#f0f0ff'], '#fff0a0',
     {'marks': 'macchie', 'mark': '#fffbe0', 'glow': True}, ['vola', 'bombarda'], ['teletrasporto', 'ventaglio'],
     {'sight': 30, 'hover': 100.0, 'wobble': 15.0, 'rate': 2.2, 'shot_look': 'stella', 'blink_every': 4.0, 'fan_n': 7, 'fan_rate': 2.4, 'shot_speed': 190.0},
     'stella_errante', ('vuoto', 'luce'), ('lacrima_stelle', 'Lacrima di stelle', ['goccia', 'stelle']), ('canto_madre', 'Canto della balena madre', ['essenza', 'stelle']),
     ('mantello_firmamento', 'Mantello del Firmamento', 'accessorio', ['mantello', 'stelle'], {'acc': {'quota': 1.0, 'magic': 1.1}, 'desc': "L'aria sottile non ti tocca; incantesimi +10%."}), {'ambra_stelle': 4, 'polvere_stelle': 10}),
    # voce 445: i Signori dei due biomi del cielo di mezzo
    ('selve_pensili', {'sky': 'selve_pensili'}, 4, 'Serpente delle mille liane', 'serpe', 58, 24, ['#0e2a1a', '#1a4a2c', '#2a7a44', '#5ab070', '#c8f0a0'], '#ffd060',
     {'marks': 'strisce', 'mark': '#ffd060'}, ['vola', 'scatto'], ['richiamo', 'evoca'],
     {'sight': 30, 'hover': 50.0, 'wobble': 35.0, 'dash_every': 2.4, 'dash_speed': 330.0, 'dash_time': 0.45, 'call_time': 1.2, 'call_n': 3, 'calls': 3, 'summon_every': 6.0, 'summon_max': 4},
     'serpe_liane', ('gelo', 'linfa'), ('linfa_liane', 'Linfa delle mille liane', ['goccia', 'muschio']), ('corona_liane', 'Corona di liane', ['corona', 'muschio']),
     ('fascia_re_liane', 'Fascia del re delle liane', 'accessorio', ['benda', 'muschio'], {'acc': {'jump': 1.12, 'regen': 1.12}, 'desc': 'Salto +12%; la Vita ricresce +12%.'}), {'muta_serpe_liane': 4, 'pelo_saltaliane': 3}),
    ('fonti_sospese', {'sky': 'fonti_sospese'}, 4, 'Airone madre delle fonti', 'uccello', 50, 40, ['#2a3a48', '#4a6478', '#7a9ab0', '#c0dcec', '#ffffff'], '#ffd060',
     {'wings': '#7a9ab0', 'marks': 'macchie', 'mark': '#ffffff'}, ['vola', 'picchiata'], ['bombarda', 'richiamo'],
     {'sight': 32, 'hover': 90.0, 'wobble': 20.0, 'rise': 8, 'dive_speed': 360.0, 'dive_every': 3.6, 'rate': 2.4, 'call_time': 1.2, 'call_n': 2, 'calls': 3},
     'airone_fonti', ('brace', 'gelo'), ('perla_fonti', 'Perla delle fonti', ['gemma', 'lagunite']), ('piuma_madre_fonti', 'Piuma della madre delle fonti', ['penna', 'lagunite']),
     ('mantello_fonti', 'Mantello delle fonti', 'accessorio', ['mantello', 'lagunite'], {'acc': {'respiro': 2.0, 'glide': True, 'linfa_regen': 1.15}, 'desc': "Respiro sott'acqua doppio; si plana; Linfa +15%."}), {'piuma_airone_fonti': 4, 'pelle_salamandra': 3}),
]


def main():
    creatures, loot, items, recipes = {}, {}, {}, []
    lords = {}
    for (key, where, tier, name, plan, w, h, pal, eye, extra, beh, fury, p, summon, aff, mat, trophy, uni, bait) in L:
        hp, dmg, de = TIER[tier]
        cid = 'signore_' + key
        pp = dict(p)
        pp['phase2'] = 0.5
        pp['summon'] = summon
        body = {'plan': plan, 'w': w, 'h': h, 'pal': pal, 'eye': eye}
        body.update(extra)
        c = {'name': name, 'hp': hp, 'damage': dmg, 'defense': de, 'knock': 0.9, 'half': [max(8, w // 2 - 6), max(8, h // 2 - 4)],
             'speed': 85, 'behaviors': beh, 'fury': fury, 'p': pp, 'loot': cid, 'art': [cid, 0], 'strata': [], 'weight': 0,
             'boss': True, 'lord': key, 'no_trophy': True, 'glow': bool(extra.get('glow', False)), 'body': body,
             'affinity': {'weak': [aff[0]], 'resist': [aff[1]]}}
        if beh[0] == 'vola':
            c['fly'] = True
        creatures[cid] = c
        loot[cid] = [{'item': mat[0], 'min': 3, 'max': 5, 'chance': 1.0}, {'item': trophy[0], 'min': 1, 'max': 1, 'chance': 1.0}]
        items[mat[0]] = {'name': mat[1], 'kind': 'materiale', 'icon': mat[2], 'desc': 'Lo lascia solo il %s: non c\'è altro posto dove trovarlo.' % name}
        items[trophy[0]] = {'name': trophy[1], 'kind': 'trofeo', 'icon': trophy[2], 'desc': 'Il trofeo del %s: esposto in una sala dei trofei, rende più forti contro la sua famiglia.' % name}
        u = {'name': uni[1], 'kind': uni[2], 'icon': uni[3], 'stack': 1}
        u.update(uni[4])
        items[uni[0]] = u
        recipes.append({'out': uni[0], 'qty': 1, 'in': {mat[0]: 6, trophy[0]: 1, 'lingotto_ambra': 3}, 'station': 'maglio'})
        bait_id = 'esca_' + cid
        items[bait_id] = {'name': 'Esca rituale del %s' % name, 'kind': 'esca_signore', 'icon': ['seme', mat[2][1]], 'stack': 5,
                          'lord': cid, 'desc': 'Usala nel suo luogo e il %s viene a cercarti.' % name}
        ins = dict(bait)
        ins['lingotto_ambra'] = 2
        recipes.append({'out': bait_id, 'qty': 1, 'in': ins, 'station': 'altare'})
        lords[key] = {'creature': cid, 'where': where, 'bait': bait_id}
    out = ['extends RefCounted',
           '## I Signori dei luoghi (voce 135, Roadmap 15): un mini-boss per ogni bioma di superficie, del sottosuolo e per',
           '## ogni strato e per ogni bioma del cielo (Roadmap 16), nato da una ricetta (corpo, comportamenti, furia a metà Vita). Si chiamano con la loro esca rituale',
           '## nel loro luogo (`Lords`). Fatto da `tools/gen_signori.py` (non a mano). Non nomina altre classi.', '',
           'const DATA := {']
    for k, v in (('creatures', creatures), ('loot', loot), ('items', items)):
        out.append('\t%s: {' % gd(k))
        for a, b in v.items():
            out.append('\t\t%s: %s,' % (gd(a), gd(b)))
        out.append('\t},')
    out.append('\t"recipes": [')
    for r in recipes:
        out.append('\t\t%s,' % gd(r))
    out.append('\t],')
    out.append('\t"lords": {')
    for a, b in lords.items():
        out.append('\t\t%s: %s,' % (gd(a), gd(b)))
    out.append('\t},')
    out.append('}')
    with open(os.path.join(ROOT, 'signori.gd'), 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(out) + '\n')
    print('signori.gd', len(creatures), 'Signori')


if __name__ == '__main__':
    main()
