import os
os.chdir(r'C:\Users\Principale\Desktop\CLAUDE\TERRAWORLD')

# (id, nome, tipo, [forma, materiale], statistiche, effetti, storia)
S = {}   # serie -> dict

def sw(dmg, spd, kb):
    return {"damage": dmg, "speed": spd, "knockback": kb, "tier": 4}

def bow(dmg, spd, ms=1):
    d = {"damage": dmg, "speed": spd, "knockback": 1.0, "tier": 4}
    if ms > 1:
        d["multishot"] = ms
    return d

def acc(**k):
    return {"acc": k}

def arm(defense, **k):
    d = {"defense": defense, "tier": 4}
    if k:
        d["acc"] = k
    return d

S["lame_perdute"] = {"name": "Lame perdute", "pool": "profondo", "bonus": {"damage": 1.08},
    "desc": "+8% danno per sempre", "hint": "negli scrigni antichi e nelle arche delle rovine profonde",
    "items": [
    ("lama_salice", "Lama di salice", "spada", ["lama", "legno"], sw(18, 2.8, 1.5), ["gelo_colpo"], "Piegata dal vento per cento anni prima di diventare una spada."),
    ("dente_colosso", "Dente del Colosso", "spada", ["martello", "ardesia"], sw(30, 1.4, 5.0), ["stordisce_colpo", "ottavo_rintocco"], "Il Colosso d'Ardesia ne aveva due. Ora ne ha uno."),
    ("ago_ambra", "Ago d'ambra", "spada", ["pugnale", "ambra"], sw(12, 3.6, 0.8), ["linfa_colpo"], "Dentro l'ambra c'è ancora la goccia che l'ha forgiato."),
    ("falce_radici", "Falce delle radici", "spada", ["falce", "radice"], sw(20, 2.2, 2.0), ["catena_colpo"], "Taglia una cosa sola, ma le sue radici arrivano più lontano."),
    ("lancia_stellata", "Lancia stellata", "spada", ["lancia", "brillaluce"], sw(22, 2.4, 2.5), ["sole_spalle"], "Cadde dal cielo già a forma di lancia."),
    ("spina_nera", "Spina nera", "spada", ["pugnale", "vuotite"], sw(15, 3.2, 1.0), ["notturno", "passo_nebbia"], "Nessuno l'ha mai vista di giorno."),
    ("tizzone_quieto", "Tizzone quieto", "spada", ["spada", "tizzonite"], sw(21, 2.5, 2.0), ["brace_colpo", "braciere_addosso"], "Brucia piano, senza fretta: tanto prima o poi prende."),
    ("remo_lago", "Remo del lago", "spada", ["martello", "lagunite"], sw(19, 2.0, 4.0), ["anfibio", "stordisce_colpo"], "Il barcaiolo dei laghi sotterranei non l'ha mai rivoluto indietro."),
    ("lama_mille_foglie", "Lama delle mille foglie", "spada", ["lama", "muschio"], sw(16, 3.0, 1.2), ["pioggia_schegge"], "Ogni colpo lascia cadere foglie affilate."),
    ("ascia_guardiana", "Ascia della guardiana", "spada", ["martello", "radicite"], sw(26, 1.7, 3.5), ["spine_vive"], "La guardiana delle Aiuole la teneva sempre accanto al letto."),
    ("sciabola_brina", "Sciabola di brina", "spada", ["lama", "brina"], sw(18, 2.7, 1.6), ["gelo_colpo", "aura_gelo"], "Fredda anche nel pugno di chi la stringe."),
    ("zanna_prima", "Zanna prima", "spada", ["pugnale", "sanguinella"], sw(14, 3.4, 1.0), ["furia_bassa", "linfa_colpo"], "La prima arma che un Germogliato abbia mai impugnato. O così dicono."),
    ]}
S["archi_antichi"] = {"name": "Archi antichi", "pool": "profondo", "bonus": {"damage": 1.05, "atk_speed": 1.05},
    "desc": "+5% danno e colpi più rapidi per sempre", "hint": "negli scrigni antichi e nelle arche delle rovine profonde",
    "items": [
    ("arco_salice", "Arco di salice piangente", "arco", ["arco", "legno"], bow(15, 2.8), ["gelo_colpo"], "Canta una nota bassa a ogni freccia."),
    ("arco_tempesta", "Arco della tempesta", "arco", ["arco", "brillaluce"], bow(18, 2.6, 2), ["catena_colpo"], "Tirato durante un temporale, non sbaglia mai."),
    ("arco_osso", "Arco d'osso antico", "arco", ["arco", "sem"], bow(20, 2.2), ["stordisce_colpo"], "Nessuno sa di quale creatura fosse l'osso."),
    ("arco_rovo", "Arco di rovo", "arco", ["arco", "radice"], bow(14, 3.0), ["pioggia_schegge"], "Le frecce si aprono in spine quando colpiscono."),
    ("arco_notte", "Arco della notte", "arco", ["arco", "nottilite"], bow(17, 2.7), ["notturno"], "Di giorno sembra un ramo qualunque."),
    ("arco_brace", "Arco di brace", "arco", ["arco", "tizzonite"], bow(16, 2.8), ["brace_colpo"], "La corda è un filo di fuoco che non si spezza."),
    ("arco_vento", "Arco del vento", "arco", ["arco", "seta"], bow(13, 3.4, 2), ["cielo_aperto"], "Più il vento soffia, più lontano arriva."),
    ("arco_cacciatore", "Arco del cacciatore di lumi", "arco", ["arco", "ambra"], bow(15, 2.9), ["lumini_colpo"], "Ogni freccia torna con un po' di luce."),
    ("arco_linfa_viva", "Arco di Linfa viva", "arco", ["arco", "linfa"], bow(14, 3.0), ["linfa_colpo"], "Cresce di un anello ogni primavera."),
    ("arco_eco", "Arco dell'eco", "arco", ["arco", "iride"], bow(12, 3.2, 3), ["ottavo_rintocco"], "Tre frecce per un solo tiro: la seconda e la terza sono l'eco della prima."),
    ]}
S["gioielli_seminatori"] = {"name": "Gioielli dei Seminatori", "pool": "segreti", "bonus": {"luck": 0.2, "magic": 1.1},
    "desc": "più fortuna e incantesimi +10% per sempre", "hint": "nei segreti profondi e leggendari dei mondi",
    "items": [
    ("anello_primo_seme", "Anello del primo Seme", "anello", ["anello", "sem"], acc(luck=0.15, regen=1.1), ["seconda_vita"], "Lo portava chi piantò il primo Seme, e non l'ha mai tolto."),
    ("amuleto_radice_madre", "Amuleto della radice madre", "amuleto", ["amuleto", "radice"], acc(regen=1.25), ["rigenera_fermo"], "Quando stai fermo, senti la terra che ti tiene."),
    ("anello_nove_mondi", "Anello dei nove mondi", "anello", ["anello", "iride"], acc(run=1.08, jump=1.08, luck=0.08), [], "Nove pietre minuscole, una per ogni mondo visitato dal suo padrone."),
    ("amuleto_stella_nera", "Amuleto della stella nera", "amuleto", ["amuleto", "nottilite"], acc(damage=1.1), ["notturno", "luna_amica"], "Fatto con un frammento del cielo che si spense."),
    ("anello_fonte", "Anello della fonte", "anello", ["anello", "lagunite"], acc(linfa_regen=1.4), ["respiro_lungo"], "Una goccia della prima fonte, chiusa in un cerchio d'argento."),
    ("amuleto_lingua", "Amuleto della lingua", "amuleto", ["amuleto", "sem"], acc(magic=1.15), ["ottavo_rintocco"], "Inciso con l'unica parola dei Seminatori che nessuno ha mai tradotto."),
    ("anello_brace_eterna", "Anello di brace eterna", "anello", ["anello", "tizzonite"], acc(damage=1.06), ["brace_colpo"], "Scalda il dito anche nel gelo."),
    ("amuleto_viandante", "Amuleto del viandante", "amuleto", ["amuleto", "legno"], acc(run=1.12), ["fuga", "cielo_aperto"], "Chi lo porta non si perde mai. Si allontana soltanto."),
    ("anello_silenzio", "Anello del silenzio", "anello", ["anello", "vuotite"], acc(stealth=0.75), ["passo_nebbia"], "Dove passa, anche le foglie tacciono."),
    ("amuleto_giardino", "Amuleto del Giardino", "amuleto", ["amuleto", "muschio"], acc(regen=1.15, halo=1.2), ["linfa_raccolta"], "Profuma dell'Albero-Madre."),
    ("anello_eco_lontana", "Anello dell'eco lontana", "anello", ["anello", "brillaluce"], acc(magic=1.1, halo=1.2), ["catena_colpo"], "Se lo avvicini all'orecchio, senti un mondo che non esiste più."),
    ("amuleto_quattro_venti", "Amuleto dei quattro venti", "amuleto", ["amuleto", "seta"], acc(jump=1.12, glide=True), [], "Quattro piume legate insieme: ognuna viene da un vento diverso."),
    ]}
S["vesti_viandante"] = {"name": "Vesti del viandante", "pool": "segreti", "bonus": {"defense": 4, "run": 1.06},
    "desc": "+4 Scorza e corsa +6% per sempre", "hint": "nei segreti profondi e leggendari dei mondi",
    "items": [
    ("cappuccio_viandante", "Cappuccio del viandante", "elmo", ["elmo", "seta"], arm(5, halo=1.15), ["passo_nebbia"], "Ha visto più mondi di quanti ne ricordi."),
    ("manto_viandante", "Manto del viandante", "corazza", ["corazza", "seta"], arm(8, regen=1.1), ["fuga"], "Rattoppato con la stoffa di dieci mondi diversi."),
    ("brache_viandante", "Brache del viandante", "gambali", ["gambali", "seta"], arm(5, run=1.06), [], "Non si sono mai strappate, e ne hanno avuto l'occasione."),
    ("guanti_viandante", "Guanti del viandante", "guanti", ["guanti", "seta"], arm(3, dig=1.2), [], "Hanno scavato in ogni terra del Giardino."),
    ("stivali_viandante", "Stivali del viandante", "stivali", ["stivali", "seta"], arm(3, run=1.1, fall_safe=True), [], "Consumati sotto, nuovi sopra: non si sa come."),
    ("mantello_viandante", "Mantello del viandante", "mantello", ["mantello", "seta"], arm(3, glide=True), ["cielo_aperto"], "Sotto il vento si apre come una foglia."),
    ("elmo_sentinella", "Elmo della sentinella", "elmo", ["elmo", "sem"], arm(7), ["spine_vive"], "L'ultima sentinella delle catacombe lo lasciò sul leggio."),
    ("corazza_sentinella", "Corazza della sentinella", "corazza", ["corazza", "sem"], arm(11), ["ombra_ferito"], "Mattoni dei Seminatori cuciti su cuoio."),
    ("gambali_sentinella", "Gambali della sentinella", "gambali", ["gambali", "sem"], arm(7, jump=1.05), [], "Pesanti, ma non fanno rumore."),
    ("guanti_brace", "Guanti del fabbro di brace", "guanti", ["guanti", "tizzonite"], arm(3, damage=1.06), ["brace_colpo"], "Tenevano il ferro rovente senza accorgersene."),
    ("stivali_nube", "Stivali di nube", "stivali", ["stivali", "iride"], arm(2, jump=1.15), ["fuga"], "Toccano terra solo quando vogliono."),
    ("mantello_foglie_morte", "Mantello di foglie morte", "mantello", ["mantello", "legno"], arm(4, stealth=0.85), ["passo_nebbia"], "Fruscia come un bosco d'autunno."),
    ]}
S["reliquie_bestie"] = {"name": "Reliquie delle bestie", "pool": "ancestrali", "bonus": {"damage": 1.05, "luck": 0.15},
    "desc": "+5% danno e più fortuna per sempre", "hint": "dalle creature ancestrali e iridate",
    "items": [
    ("zanna_capobranco", "Zanna del capobranco", "accessorio", ["artiglio", "ardesia"], acc(damage=1.08), ["slancio"], "Il branco la seguiva, ora segue te."),
    ("piuma_iridata", "Piuma iridata", "accessorio", ["penna", "iride"], acc(luck=0.2, jump=1.08), [], "Cambia colore a ogni passo."),
    ("occhio_ancestrale", "Occhio ancestrale", "accessorio", ["occhio", "ambra"], acc(halo=1.4), ["notturno"], "Ti guarda anche quando lo tieni in tasca."),
    ("scaglia_antica", "Scaglia antica", "accessorio", ["scaglia", "ardesia"], acc(regen=1.15), ["spine_vive"], "Dura come la prima pietra del mondo."),
    ("cuore_bestia", "Cuore della bestia", "accessorio", ["essenza", "sanguinella"], acc(damage=1.1), ["furia_bassa"], "Batte ancora, piano, quando hai paura."),
    ("corno_ancestrale", "Corno ancestrale", "accessorio", ["artiglio", "sem"], acc(run=1.08), ["stordisce_colpo"], "Suonato, fa tremare le grotte."),
    ("pelliccia_sogno", "Pelliccia del sogno", "accessorio", ["seta", "nottilite"], acc(stealth=0.8, regen=1.1), [], "Chi ci dorme sopra sogna di correre nei boschi."),
    ("artiglio_ombra", "Artiglio d'ombra", "accessorio", ["artiglio", "vuotite"], acc(damage=1.06), ["passo_nebbia", "slancio"], "Lascia graffi che non si vedono."),
    ("ala_tramonto", "Ala del tramonto", "accessorio", ["penna", "brace"], acc(glide=True, run=1.05), ["cielo_aperto"], "Presa a una creatura iridata un attimo prima che svanisse."),
    ("guscio_eterno", "Guscio eterno", "accessorio", ["scaglia", "lagunite"], acc(regen=1.2), ["rigenera_fermo"], "Chi ci si nasconde dentro non invecchia."),
    ("lingua_serpe", "Lingua della serpe madre", "accessorio", ["artiglio", "linfa"], acc(magic=1.12), ["linfa_colpo"], "Sa di Linfa e di bugie."),
    ("coda_iridata", "Coda iridata", "accessorio", ["penna", "brillaluce"], acc(luck=0.25), ["caccia_lumini"], "Lascia una scia di luce che non si spegne."),
    ]}
S["doni_custodi"] = {"name": "Doni dei Custodi", "pool": "custodi", "bonus": {"defense": 3, "regen": 1.1},
    "desc": "+3 Scorza e la Vita ricresce +10% per sempre", "hint": "dai Custodi degli strati sconfitti",
    "items": [
    ("seta_tessitrice", "Seta della Tessitrice", "accessorio", ["seta", "seta"], acc(stealth=0.8), ["gelo_ferita_nulla"], "Un filo che non si spezza, neanche tirato da un mondo intero."),
    ("uovo_madre_grumi", "Uovo della Madre dei grumi", "accessorio", ["essenza", "muschio"], acc(regen=1.2), ["linfa_raccolta"], "Non si schiude, ma è caldo."),
    ("anello_serpe_madre", "Anello della Serpe madre", "anello", ["anello", "linfa"], acc(magic=1.1, linfa_regen=1.2), [], "Si stringe da solo attorno al dito."),
    ("falce_del_mietitore", "Falce del Mietitore", "spada", ["falce", "vuotite"], sw(24, 2.0, 2.5), ["catena_colpo", "passo_nebbia"], "Mieteva ombre, prima di te."),
    ("palco_grande_cervo", "Palco del Grande cervo", "accessorio", ["artiglio", "brina"], acc(run=1.1, jump=1.1), ["aura_gelo"], "Ci sono ancora dei germogli di brina sui rami."),
    ("cuore_madre_salamandre", "Cuore della Madre delle salamandre", "accessorio", ["essenza", "tizzonite"], acc(damage=1.08), ["braciere_addosso"], "Scotta, ma non brucia chi lo porta."),
    ("bozzolo_intatto", "Bozzolo intatto", "accessorio", ["essenza", "legno"], acc(regen=1.15, defense_dummy=0), ["seconda_vita"], "Un bozzolo che non si è mai aperto. Dentro, qualcuno aspetta."),
    ("sigillo_custodi", "Sigillo dei Custodi", "amuleto", ["amuleto", "sem"], acc(luck=0.15, halo=1.2), ["ottavo_rintocco"], "Tutti i Custodi lo riconoscono. Alcuni si inchinano."),
    ("occhio_tessitrice", "Occhio della Tessitrice", "accessorio", ["occhio", "seta"], acc(halo=1.3, stealth=0.9), [], "Vede i fili che tengono insieme le grotte."),
    ("zoccolo_colosso", "Zoccolo del Colosso", "stivali", ["stivali", "ardesia"], arm(5, fall_safe=True), ["stordisce_colpo"], "Ogni passo è una piccola frana."),
    ]}
S["strumenti_giardiniere"] = {"name": "Strumenti del Giardiniere", "pool": "segreti", "bonus": {"dig": 1.2, "luck": 0.1},
    "desc": "scavo più rapido e più fortuna per sempre", "hint": "nei segreti dei mondi",
    "items": [
    ("guanti_giardiniere_primo", "Guanti del primo Giardiniere", "guanti", ["guanti", "legno"], arm(2, dig=1.35), [], "Hanno piantato più alberi di quanti ce ne siano."),
    ("cintura_semi", "Cintura dei semi", "accessorio", ["seta", "legno"], acc(luck=0.15), ["lumini_colpo"], "Ogni tasca ha un seme diverso. Nessuna è mai vuota."),
    ("lanterna_giardiniere", "Lanterna del Giardiniere", "accessorio", ["lanterna", "ambra"], acc(halo=1.5), [], "Illumina solo le cose che crescono."),
    ("annaffiatoio_vecchio", "Annaffiatoio vecchio", "accessorio", ["essenza", "lagunite"], acc(regen=1.15), ["rigenera_fermo"], "L'acqua che versa non finisce mai."),
    ("cappello_paglia", "Cappello di paglia di radice", "elmo", ["elmo", "legno"], arm(3, halo=1.2), ["sole_spalle"], "Ripara dal sole di tutti i mondi."),
    ("stivali_fango", "Stivali di fango", "stivali", ["stivali", "humus"], arm(3, run=1.05), ["radici_fonde"], "Pesanti, ma non scivolano mai."),
    ("forbici_seminatori", "Forbici dei Seminatori", "spada", ["pugnale", "legnoferro"], sw(13, 3.4, 0.8), ["linfa_raccolta"], "Potano i rami e le creature con la stessa cura."),
    ("zappa_luna", "Zappa della luna", "spada", ["falce", "brillaluce"], sw(17, 2.5, 2.0), ["luna_amica"], "Si lavora meglio la terra di notte, diceva chi la usava."),
    ("borsa_senza_fondo", "Borsa senza fondo", "accessorio", ["seta", "vuotite"], acc(luck=0.2), ["caccia_lumini"], "Ci mettevano dentro i mondi prima di piantarli."),
    ("sementa_eterna", "Sementa eterna", "accessorio", ["seme", "iride"], acc(regen=1.1, linfa_regen=1.2), [], "Un pugno di semi che germogliano solo nel Giardino."),
    ]}
S["ricordi_mondi"] = {"name": "Ricordi dei mondi", "pool": "profondo", "bonus": {"halo": 1.2, "magic": 1.08},
    "desc": "alone più ampio e incantesimi +8% per sempre", "hint": "negli scrigni antichi e nelle arche delle rovine profonde",
    "items": [
    ("conchiglia_mare_secco", "Conchiglia del mare secco", "accessorio", ["scaglia", "lagunite"], acc(respiro=1.5), ["anfibio"], "Se l'avvicini all'orecchio, senti un mare che non c'è più."),
    ("sasso_prima_frana", "Sasso della prima frana", "accessorio", ["zolla", "ardesia"], acc(damage=1.05), ["profondo"], "Il primo sasso che cadde, quando la terra imparò a muoversi."),
    ("foglia_prima_stagione", "Foglia della prima stagione", "accessorio", ["foglia", "muschio"], acc(regen=1.15), ["luna_amica"], "Verde da prima che esistesse l'autunno."),
    ("goccia_prima_pioggia", "Goccia della prima pioggia", "accessorio", ["essenza", "linfa"], acc(linfa_regen=1.3), [], "Non evapora e non cade."),
    ("scintilla_primo_fuoco", "Scintilla del primo fuoco", "accessorio", ["essenza", "brace"], acc(damage=1.06), ["braciere_addosso"], "Accese la prima brace del Giardino."),
    ("fiocco_prima_neve", "Fiocco della prima neve", "accessorio", ["gemma", "brina"], acc(stealth=0.9), ["aura_gelo"], "Non si scioglie in mano: è lui che scioglie te."),
    ("piuma_primo_volo", "Piuma del primo volo", "accessorio", ["penna", "seta"], acc(jump=1.1, glide=True), [], "La prima creatura che volò la lasciò cadere per sbaglio."),
    ("radice_prima_notte", "Radice della prima notte", "accessorio", ["radice", "nottilite"], acc(stealth=0.85), ["notturno"], "Cresce solo al buio, e al buio ti nasconde."),
    ("vetro_primo_sole", "Vetro del primo sole", "accessorio", ["gemma", "ambra"], acc(halo=1.4), ["sole_spalle"], "Ha visto sorgere il primo sole e ne ha tenuto un po'."),
    ("ombra_primo_eclissi", "Ombra della prima eclissi", "accessorio", ["essenza", "vuotite"], acc(magic=1.12), ["passo_nebbia"], "Un pezzo di buio staccato dal cielo."),
    ("seme_primo_albero", "Seme del primo albero", "accessorio", ["seme", "legno"], acc(regen=1.2), ["rigenera_fermo", "radici_fonde"], "Lo stesso seme da cui nacque l'Albero-Madre. Forse."),
    ("eco_primo_canto", "Eco del primo canto", "accessorio", ["gemma", "iride"], acc(magic=1.1, halo=1.2), ["ottavo_rintocco"], "La prima canzone del Giardino, rimasta intrappolata in un cristallo."),
    ]}
S["segni_notte"] = {"name": "Segni della notte", "pool": "ancestrali", "bonus": {"stealth": 0.85, "damage": 1.05},
    "desc": "le creature ti notano più tardi e +5% danno per sempre", "hint": "dalle creature ancestrali e iridate",
    "items": [
    ("mantello_mezzanotte", "Mantello di mezzanotte", "mantello", ["mantello", "nottilite"], arm(3, stealth=0.8), ["notturno"], "Di notte non si vede dove finisce."),
    ("anello_luna", "Anello della luna", "anello", ["anello", "brillaluce"], acc(regen=1.1), ["luna_amica"], "Cresce e cala con la luna del mondo in cui sei."),
    ("occhio_gufo_antico", "Occhio del gufo antico", "accessorio", ["occhio", "nottilite"], acc(halo=1.3), ["notturno"], "Vede al buio meglio di quanto tu veda di giorno."),
    ("lama_mezzanotte", "Lama di mezzanotte", "spada", ["lama", "nottilite"], sw(19, 2.6, 1.5), ["notturno", "passo_nebbia"], "Taglia soltanto dopo il tramonto. Prima, fa finta."),
    ("stivali_silenzio", "Stivali del silenzio", "stivali", ["stivali", "vuotite"], arm(2, stealth=0.8, run=1.05), [], "Anche la ghiaia smette di scricchiolare."),
    ("elmo_civetta", "Elmo della civetta", "elmo", ["elmo", "nottilite"], arm(5, halo=1.2), ["notturno"], "Due occhi grandi dipinti sopra: le creature ci cascano sempre."),
    ("guanti_ombra", "Guanti d'ombra", "guanti", ["guanti", "vuotite"], arm(2, damage=1.05), ["passo_nebbia"], "Le tue mani spariscono appena li infili."),
    ("stella_tasca", "Stella da tasca", "accessorio", ["gemma", "brillaluce"], acc(halo=1.5, luck=0.1), [], "Una stella piccola piccola, caduta in un Seme."),
    ("campana_notturna", "Campana notturna", "accessorio", ["essenza", "nottilite"], acc(magic=1.1), ["ottavo_rintocco"], "Suona da sola a mezzanotte."),
    ("velo_eclissi", "Velo dell'eclissi", "accessorio", ["velo", "vuotite"], acc(stealth=0.75), ["ombra_ferito"], "Durante un'eclissi è l'unica cosa che fa luce."),
    ]}
S["canti_vuoto"] = {"name": "Canti del Vuoto", "pool": "evocati", "bonus": {"magic": 1.12, "linfa_regen": 1.2},
    "desc": "incantesimi +12% e Linfa +20% per sempre", "hint": "dai Guardiani evocati al Cerchio dei Seminatori",
    "items": [
    ("corda_vuoto", "Corda del Vuoto", "accessorio", ["seta", "vuotite"], acc(jump=1.12), ["fuga"], "Legata al nulla, tiene lo stesso."),
    ("diadema_vuoto", "Diadema del Vuoto", "elmo", ["corona", "vuotite"], arm(4, magic=1.12), [], "Chi lo porta sente il silenzio tra i mondi."),
    ("lama_del_vuoto", "Lama del Vuoto", "spada", ["lama", "vuotite"], sw(23, 2.3, 2.0), ["catena_colpo"], "Non riflette niente, nemmeno la luce."),
    ("anello_nulla", "Anello del nulla", "anello", ["anello", "vuotite"], acc(stealth=0.8, magic=1.08), [], "Al posto della pietra, un buco."),
    ("occhio_vuoto_antico", "Occhio del Vuoto antico", "accessorio", ["occhio", "vuotite"], acc(halo=1.2, magic=1.1), ["notturno"], "Guardò il Seme Nero cadere, e non ha più chiuso la palpebra."),
    ("goccia_vuoto", "Goccia di Vuoto", "accessorio", ["essenza", "vuotite"], acc(linfa_regen=1.3), ["passo_nebbia"], "Pesa meno di niente."),
    ("mantello_del_vuoto", "Mantello del Vuoto", "mantello", ["mantello", "vuotite"], arm(3, glide=True, stealth=0.85), [], "Sotto, le stelle. Sopra, anche."),
    ("scheggia_primo_vuoto", "Scheggia del primo Vuoto", "accessorio", ["gemma", "vuotite"], acc(damage=1.08), ["pioggia_schegge"], "Un pezzo del nulla che c'era prima del Giardino."),
    ("ramo_del_vuoto", "Ramo del Vuoto", "spada", ["lancia", "vuotite"], sw(20, 2.4, 2.0), ["ottavo_rintocco", "catena_colpo"], "Un ramo cresciuto nel nulla, senza terra e senza luce."),
    ("cuore_vuoto", "Cuore del Vuoto", "accessorio", ["essenza", "iride"], acc(magic=1.15, regen=1.1), ["seconda_vita"], "Batte una volta ogni cento anni. L'ultima volta è stata ieri."),
    ]}
S["fiori_eterni"] = {"name": "Fiori eterni", "pool": "segreti", "bonus": {"regen": 1.15, "halo": 1.15},
    "desc": "la Vita ricresce +15% e alone più ampio per sempre", "hint": "nei segreti dei mondi",
    "items": [
    ("rosa_radice", "Rosa di radice", "accessorio", ["foglia", "sanguinella"], acc(regen=1.15), ["spine_vive"], "Ha le spine anche sui petali."),
    ("giglio_linfa", "Giglio di Linfa", "accessorio", ["foglia", "linfa"], acc(linfa_regen=1.3), ["linfa_raccolta"], "Beve la Linfa dall'aria."),
    ("campanula_eterna", "Campanula eterna", "accessorio", ["foglia", "cristallo"], acc(halo=1.3), [], "Illumina come una lanterna, ma non ha fiamma."),
    ("papavero_sonno", "Papavero del sonno", "accessorio", ["foglia", "brace"], acc(stealth=0.85), ["rigenera_fermo"], "Chi lo annusa si addormenta. Chi lo porta, no."),
    ("fiordaliso_vento", "Fiordaliso del vento", "accessorio", ["foglia", "seta"], acc(run=1.1), ["cielo_aperto"], "Non perde un petalo nemmeno nella bufera."),
    ("orchidea_grotta", "Orchidea di grotta", "accessorio", ["foglia", "nottilite"], acc(halo=1.2), ["radici_fonde"], "Fiorisce solo dove il sole non è mai arrivato."),
    ("girasole_stellato", "Girasole stellato", "accessorio", ["foglia", "ambra"], acc(luck=0.12), ["sole_spalle"], "Segue il sole anche sottoterra."),
    ("loto_torba", "Loto di torba", "accessorio", ["foglia", "lagunite"], acc(respiro=1.5), ["anfibio"], "Galleggia anche sull'aria."),
    ("margherita_prima", "Margherita del primo prato", "accessorio", ["foglia", "muschio"], acc(regen=1.1, luck=0.08), [], "M'ama, non m'ama: tutti i petali dicono sì."),
    ("fiore_gelo_perenne", "Fiore del gelo perenne", "accessorio", ["foglia", "brina"], acc(stealth=0.9), ["aura_gelo"], "Sboccia soltanto nella neve."),
    ]}
S["armi_guardiani_2"] = {"name": "Armi dei Guardiani", "pool": "evocati", "bonus": {"damage": 1.06, "defense": 2},
    "desc": "+6% danno e +2 Scorza per sempre", "hint": "dai Guardiani evocati al Cerchio dei Seminatori",
    "items": [
    ("mazza_nodo", "Mazza del Nodo", "spada", ["martello", "radice"], sw(27, 1.6, 4.5), ["stordisce_colpo"], "Fatta con un pezzo del Nodo Avvizzito, guarito."),
    ("pungiglione_regina", "Pungiglione della Regina", "spada", ["pugnale", "fungo"], sw(15, 3.3, 1.0), ["linfa_colpo", "pioggia_schegge"], "La Regina delle Spore lo perse combattendo, e non lo rivolle."),
    ("scudo_colosso", "Scudo del Colosso", "corazza", ["corazza", "ardesia"], arm(12), ["spine_vive"], "Una scaglia del Colosso d'Ardesia, grande come una porta."),
    ]}
# le serie degli unici che ci sono già (dalle voci 85, 92-97): solo il raggruppamento e il premio
OLD = {
    "ornamenti_evocati": {"name": "Ornamenti evocati", "pool": "evocati", "bonus": {"luck": 0.1, "regen": 1.1},
        "desc": "più fortuna e la Vita ricresce +10% per sempre", "hint": "dai Guardiani evocati al Cerchio dei Seminatori",
        "items": ["lingua_tizzone", "spina_inverno", "campana_rovo", "ramo_temporale", "falce_sete", "occhio_gufo", "pinna_lago",
                  "muschio_ombra", "seme_secondo", "corno_cacciatore", "cuore_inverno", "rovo_vivo"]},
    "doni_biomi": {"name": "Doni dei biomi", "pool": "", "bonus": {"run": 1.05, "jump": 1.05, "halo": 1.1},
        "desc": "corsa e salto +5%, alone più ampio per sempre", "hint": "si fabbricano con i trofei delle creature rare di ogni bioma",
        "items": ["aquilone_vento", "cuore_sequoia", "cappello_vecchio", "ninfea_perenne", "clessidra_dune", "corno_branco",
                  "seme_pietrificato", "fiamma_rinata"]},
    "doni_profondo": {"name": "Doni del profondo e dei rari", "pool": "", "bonus": {"magic": 1.08, "luck": 0.1},
        "desc": "incantesimi +8% e più fortuna per sempre", "hint": "dal sottosuolo, dai biomi rari e dalle creature nascoste",
        "items": ["diapason_cristallo", "liana_viva", "guscio_abisso", "sigillo_custode", "corona_iride", "cuore_stellare_vivo",
                  "voce_seminatore", "lanterna_quattro"]},
}

KIND_OK = {"spada", "arco", "accessorio", "amuleto", "anello", "elmo", "corazza", "gambali", "guanti", "stivali", "mantello"}


def gd(v):
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return repr(v)
    if isinstance(v, str):
        return '"%s"' % v.replace('"', '\\"')
    if isinstance(v, list):
        return "[" + ", ".join(gd(x) for x in v) + "]"
    if isinstance(v, dict):
        return "{" + ", ".join('"%s": %s' % (k, gd(x)) for k, x in v.items()) + "}"
    raise TypeError(v)


lines = []
series = []
total = 0
for sid, sd in S.items():
    ids = []
    for (iid, name, kind, icon, stats, effects, story) in sd["items"]:
        assert kind in KIND_OK, kind
        st = dict(stats)
        if "acc" in st:
            st["acc"] = {k: v for k, v in st["acc"].items() if k != "defense_dummy"}
        effects = [e for e in effects if e != "gelo_ferita_nulla"]
        it = {"name": name, "kind": kind, "icon": icon, "unique": True, "stack": 1}
        it.update(st)
        if effects:
            it["effects"] = effects
        it["story"] = story
        it["source"] = sd["hint"]
        it["serie"] = sid
        lines.append('\t"%s": %s,' % (iid, gd(it)))
        ids.append(iid)
        total += 1
    series.append((sid, sd, ids))
for sid, sd in OLD.items():
    series.append((sid, sd, sd["items"]))

out = []
out.append('class_name UniqueSeriesData')
out.append('## Gli oggetti unici della voce 98 (Roadmap 12) e le **serie** di tutti gli unici. Solo dati: ogni unico ha nome,')
out.append('## storia, effetti speciali (`EffectsData`) e un posto dove si trova (`source`); i `POOLS` dicono chi li lascia a caso')
out.append('## (`UniquesData.roll`): segreti profondi e leggendari, creature ancestrali e iridate, scrigni antichi delle rovine,')
out.append('## Custodi, Guardiani evocati. Una **serie** completa (tutti i suoi unici ricordati dall\'Erbario) dà il suo bonus per')
out.append('## sempre (`GearEffects`, come le collezioni di reliquie). Generato da `gen_uniques.py` nello scratchpad della voce 98:')
out.append('## si può ritoccare a mano.')
out.append('')
out.append('const ITEMS := {')
out.extend(lines)
out.append('}')
out.append('')
out.append('const SERIES := {')
for sid, sd, ids in series:
    out.append('\t"%s": {"name": %s, "pool": %s, "bonus": %s, "desc": %s, "hint": %s,\n\t\t"items": %s},' % (
        sid, gd(sd["name"]), gd(sd["pool"]), gd(sd["bonus"]), gd(sd["desc"]), gd(sd["hint"]), gd(ids)))
out.append('}')
out.append('')
out.append('''## I pool: da chi escono a caso gli unici (le serie con quel pool), e con che probabilità.
const POOL_CHANCE := {"profondo": 0.3, "segreti": 1.0, "ancestrali": 0.25, "custodi": 0.6, "evocati": 0.3}


## La serie di un unico ("" se nessuna).
static func series_of(id: String) -> String:
	for s in SERIES:
		if id in SERIES[s]["items"]:
			return s
	return ""


## Le serie complete, secondo gli oggetti che l'Erbario ricorda.
static func complete(found: Dictionary) -> Array:
	var out := []
	for s in SERIES:
		var ok := true
		for id in SERIES[s]["items"]:
			if not found.has(id):
				ok = false
				break
		if ok:
			out.append(s)
	return out


## Gli unici di un pool.
static func pool_items(pool: String) -> Array:
	var out := []
	for s in SERIES:
		if String(SERIES[s]["pool"]) == pool:
			out.append_array(SERIES[s]["items"])
	return out
''')
open('src/data/unique_series_data.gd', 'w', encoding='utf-8').write('\n'.join(out))
print('nuovi unici', total)
