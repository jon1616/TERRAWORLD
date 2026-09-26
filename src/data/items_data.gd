class_name ItemsData
extends RefCounted
## Tutti gli oggetti del gioco. Solo dati: nessuna logica di gioco qui.
## Nomi dell'universo del Giardino dei Semi (regola dell'utente, 24 set 2026: le funzioni possono somigliare a quelle di
## Terraria, i nomi no). Metalli: radicite (grado 1), legnoferro (2), ambra fossile (3); poi i cristalli di Linfa.
##
## Campi di un oggetto:
##   name   nome visibile
##   kind   materiale · blocco · piccone · ascia · spada · arco · munizione · torcia · stazione · piattaforma ·
##          elmo · corazza · gambali · accessorio · essenza · consumabile · seme · lanterna · cura · seme_mondo ·
##          bastone (tira incantesimi con la Linfa) · dono (si assorbe: Vita o Linfa massima per sempre) ·
##          specchio (riporta al punto di partenza) · richiamo (risveglia un Custode all'Altare) · reliquia (da
##          collezionare, `RelicsData`) · mappa (indica il reliquiario più vicino) · trofeo ·
##          rampino (`hook`: {range in tessere, speed}; si aggancia alla roccia e tira il Germogliato) ·
##          esplosivo (`blast`: {radius, power, damage, fuse}) · ricurvo (`throw`: {range, speed}; torna in mano) ·
##          giavellotto (si lancia e si consuma; `pierce`). Li lancia `Throwing`.
##          coltura (seme da giardino, `CropsData`) · annaffiatoio (dimezza il tempo di crescita di una coltura) ·
##          parete (`wall`: la parete di fondo che piazza) · martello (toglie le pareti, tenendo premuto) ·
##          moneta (i Lumini, vedi `ValueData`)
##   value  valore in Lumini, se non va bene quello calcolato da `ValueData` (lo lasciano solo le creature rare, `TrophyItemsData`)
## Oggetti del bestiario della voce 22 in `BeastItemsData` (uniti qui in `all()`).
##   acc    effetti di un accessorio (vedi `GearEffects`): run (corsa ×), jump (salto ×), glide (planare tenendo
##          Spazio), fall_safe (niente ferite da caduta), halo (alone ×), regen (ricrescita della Vita ×),
##          thorns (danno a chi tocca), dig (scavo e taglio ×), luck (fortuna nel bottino), stealth (visto più tardi ×)
##   cure   per le bende: tolgono il veleno
##   icon   [forma, materiale] per `ItemIcons.make`
##   stack  quanti per casella (predefinito: 999 per materiali e blocchi, 1 per attrezzi e armature)
##   tier   grado: 0 radice/pietra, 1 radicite, 2 legnoferro, 3 ambra
##   power  forza del piccone o dell'ascia (vedi `TileDefs.POWER`)
##   damage, speed (colpi al secondo), knockback, defense, heal
##   boon   effetto a tempo di una pozione (vedi `Boons`): [nome, secondi]
##   spell  per i bastoni: l'incantesimo (di `SpellsData`); linfa = quanta Linfa costa un colpo
##   gift   per i doni: [che cosa, quanto] ("vita" o "linfa"); gift_max = quanti se ne possono assorbire in tutto
##   linfa  per le pozioni: Linfa che ridanno
##   graft  per le essenze: il tratto (di `TraitsData`) che danno innestate al Maglio
##   place  tessera (id di `TileDefs`) o stazione (id di `StationsData`) che l'oggetto piazza
##   desc   descrizione breve
##
## Le famiglie di equipaggiamento sono generate da forma × materiale in `all()` (voce 49: `FormsData`,
## `MaterialsData`): un materiale nuovo = una riga in `MaterialsData`, una forma nuova = una riga in `FormsData`.

const ITEMS := {
	# materiali grezzi
	"legno": {"name": "Legno di lanterna", "kind": "materiale", "icon": ["tronco", "legno"], "desc": "Dagli alberi-lanterna. Leggero, fibroso, utile a tutto."},
	"humus": {"name": "Humus", "kind": "blocco", "icon": ["zolla", "humus"], "place": TileDefs.DIRT, "desc": "Terra scura intrecciata di radici."},
	"ardesia": {"name": "Ardesia", "kind": "blocco", "icon": ["zolla", "ardesia"], "place": TileDefs.STONE, "desc": "Roccia blu a strati."},
	"radice_antica": {"name": "Radice antica", "kind": "blocco", "icon": ["zolla", "radice"], "place": TileDefs.RADICE, "desc": "Un pezzo delle radici enormi del Sottobosco. Legno duro, venato di Linfa."},
	"scisto": {"name": "Scisto di Linfa", "kind": "blocco", "icon": ["zolla", "scisto"], "place": TileDefs.SCISTO, "desc": "La roccia delle Profondità della Linfa, attraversata da vene che brillano."},
	"pietra_seminatori": {"name": "Pietra dei Seminatori", "kind": "blocco", "icon": ["zolla", "sem"], "place": TileDefs.PIETRA_SEM, "desc": "Mattoni lavorati dai Seminatori, con le rune ancora accese."},
	"vuotite": {"name": "Vuotite", "kind": "blocco", "icon": ["zolla", "vuotite"], "place": TileDefs.VUOTITE, "desc": "Roccia del Fondo, scura come il Vuoto e punteggiata di scintille. Serve un piccone di legnoferro."},
	"minerale_radicite": {"name": "Radicite grezza", "kind": "materiale", "icon": ["minerale", "radicite"], "desc": "Il metallo che le radici succhiano dalla roccia vicino alla superficie."},
	"minerale_legnoferro": {"name": "Legnoferro grezzo", "kind": "materiale", "icon": ["minerale", "legnoferro"], "desc": "Radici antiche diventate metallo. Serve un piccone di radicite."},
	"minerale_ambra": {"name": "Ambra fossile", "kind": "materiale", "icon": ["minerale", "ambra"], "desc": "Linfa di ere lontane, dura come metallo. Serve un piccone di legnoferro."},
	"cristallo_linfa": {"name": "Cristallo di Linfa", "kind": "materiale", "icon": ["cristallo", "cristallo"], "desc": "Linfa dell'Albero-Madre, indurita nel profondo."},
	"gelatina": {"name": "Gelatina di muschio", "kind": "materiale", "icon": ["gel", "muschio"], "desc": "Appiccicosa, brucia bene."},
	"fungo_brace": {"name": "Fungo di brace", "kind": "materiale", "icon": ["fungo", "brace"], "desc": "Cresce nelle grotte vicine alla superficie."},
	"fungo_luminoso": {"name": "Fungo luminoso", "kind": "materiale", "icon": ["fungo", "cristallo"], "desc": "Brilla nel profondo."},
	"polvere_brace": {"name": "Polvere di brace", "kind": "materiale", "icon": ["polvere", "brace"], "desc": "Scintille cadute dalle ali delle falene: non si spengono mai del tutto."},
	"scaglia_ardesia": {"name": "Scaglia d'ardesia", "kind": "materiale", "icon": ["scaglia", "ardesia"], "desc": "Un pezzo del guscio di uno scarabeo: dura come la roccia."},
	"scheggia_vuoto": {"name": "Scheggia del Vuoto", "kind": "materiale", "icon": ["cristallo", "vuotite"], "desc": "Spunta dai pavimenti del Fondo. Fredda al tatto, brilla di viola."},
	"cenere_avvizzita": {"name": "Cenere avvizzita", "kind": "materiale", "icon": ["polvere", "nodo"], "desc": "Ciò che resta della terra malata. Brucia di una forza cattiva."},
	"seme_muschio": {"name": "Seme di muschio", "kind": "purifica", "icon": ["seme", "muschio"], "stack": 99, "desc": "Gettato su una zona avvizzita, la fa rifiorire (un cerchio di qualche tessera)."},
	"sacca_spore": {"name": "Sacca di spore", "kind": "materiale", "icon": ["sacca", "muschio"], "desc": "Una sacca che pulsa di luce viola."},
	"seme_lanterna": {"name": "Seme d'albero-lanterna", "kind": "seme", "icon": ["seme", "brace"], "stack": 99, "desc": "Piantalo sul muschio: in pochi minuti diventa un albero."},
	# lingotti (il baccello ardente fonde i minerali)
	"lingotto_radicite": {"name": "Lingotto di radicite", "kind": "materiale", "icon": ["lingotto", "radicite"], "tier": 1},
	"lingotto_legnoferro": {"name": "Lingotto di legnoferro", "kind": "materiale", "icon": ["lingotto", "legnoferro"], "tier": 2},
	"lingotto_ambra": {"name": "Lingotto d'ambra", "kind": "materiale", "icon": ["lingotto", "ambra"], "tier": 3},
	"minerale_pallidite": {"name": "Pallidite grezza", "kind": "materiale", "icon": ["minerale", "pallidite"], "desc": "Un metallo pallido come la luna, nelle radici del Sottobosco e nelle Caverne. Leggero: le armi di pallidite colpiscono in fretta."},
	"lingotto_pallidite": {"name": "Lingotto di pallidite", "kind": "materiale", "icon": ["lingotto", "pallidite"], "tier": 2},
	"minerale_tizzonite": {"name": "Tizzonite grezza", "kind": "materiale", "icon": ["minerale", "tizzonite"], "desc": "Brace diventata pietra nelle Profondità: ancora calda. Serve un piccone d'ambra."},
	"lingotto_tizzonite": {"name": "Lingotto di tizzonite", "kind": "materiale", "icon": ["lingotto", "tizzonite"], "tier": 3},
	# gemme a grappolo nelle grotte (voce 24)
	"brillaluce": {"name": "Brillaluce", "kind": "materiale", "icon": ["gemma", "brillaluce"], "desc": "Gemma verde-oro delle Caverne d'ardesia: tiene la luce che la tocca."},
	"sanguinella": {"name": "Sanguinella", "kind": "materiale", "icon": ["gemma", "sanguinella"], "desc": "Gemma rossa del Sottobosco, calda come un cuore che batte."},
	"lagunite": {"name": "Lagunite", "kind": "materiale", "icon": ["gemma", "lagunite"], "desc": "Gemma azzurra delle Profondità della Linfa: fredda, e raffredda."},
	"nottilite": {"name": "Nottilite", "kind": "materiale", "icon": ["gemma", "nottilite"], "desc": "Gemma viola del Fondo: dentro ha il buio del Vuoto."},
	"anello_brillaluce": {"name": "Anello di brillaluce", "kind": "accessorio", "icon": ["anello", "brillaluce"], "acc": {"halo": 1.4, "linfa_regen": 1.2}, "desc": "Alone più ampio, Linfa un poco più svelta."},
	"anello_sanguinella": {"name": "Anello di sanguinella", "kind": "accessorio", "icon": ["anello", "sanguinella"], "acc": {"damage": 1.08}, "desc": "+8% danno."},
	"anello_lagunite": {"name": "Anello di lagunite", "kind": "accessorio", "icon": ["anello", "lagunite"], "acc": {"linfa_regen": 1.7}, "desc": "La Linfa ricresce il 70% più in fretta."},
	"anello_nottilite": {"name": "Anello di nottilite", "kind": "accessorio", "icon": ["anello", "nottilite"], "acc": {"stealth": 0.75, "luck": 0.15}, "desc": "Visto più tardi, un po' più fortunato."},
	"bastone_sanguinella": {"name": "Bastone di sanguinella", "kind": "bastone", "icon": ["bastone", "sanguinella"], "tier": 2, "damage": 17, "speed": 3.0, "knockback": 1.0, "spell": "brace", "linfa": 3, "desc": "Faville di brace, più forti e più svelte."},
	"bastone_lagunite": {"name": "Bastone di lagunite", "kind": "bastone", "icon": ["bastone", "lagunite"], "tier": 3, "damage": 20, "speed": 2.4, "knockback": 0.8, "spell": "gelo", "linfa": 5, "desc": "Un'onda fredda che attraversa due creature e le rallenta per qualche secondo."},
	"lanterna_brillaluce": {"name": "Lanterna di brillaluce", "kind": "lanterna", "icon": ["lanterna", "brillaluce"], "light": Color(1.9, 2.1, 0.8), "desc": "Tenuta in mano, fa una luce verde-oro più ampia di quella di Linfa."},
	"lama_nottilite": {"name": "Lama di nottilite", "kind": "spada", "icon": ["lama", "nottilite"], "tier": 4, "damage": 25, "speed": 3.2, "knockback": 2.0, "desc": "Leggera come il buio: colpisce in fretta."},
	"lingotto_linfa": {"name": "Lingotto di Linfa", "kind": "materiale", "icon": ["lingotto", "cristallo"], "tier": 4, "desc": "Cristallo di Linfa legato con ciò che resta del Guardiano: il metallo più vivo del mondo."},
	# oggetti da piazzare
	"torcia": {"name": "Torcia di resina", "kind": "torcia", "icon": ["torcia", "legno"], "stack": 999, "desc": "Luce calda per le grotte."},
	"passerella": {"name": "Passerella di radice", "kind": "piattaforma", "icon": ["piattaforma", "legno"], "desc": "Ci si sale saltando da sotto."},
	"ceppo": {"name": "Ceppo del Giardiniere", "kind": "stazione", "icon": ["banco", "legno"], "place": "ceppo", "stack": 99, "desc": "Un ceppo intagliato: qui si lavora il legno."},
	"baccello_ardente": {"name": "Baccello ardente", "kind": "stazione", "icon": ["fornace", "ardesia"], "place": "baccello_ardente", "stack": 99, "desc": "Un baccello di pietra che cova la brace: fonde i minerali."},
	"cesta": {"name": "Cesta di radici", "kind": "stazione", "icon": ["cesta", "legno"], "place": "cesta", "stack": 99, "desc": "Una cesta intrecciata con il coperchio: tiene 20 pile di oggetti."},
	"scrigno": {"name": "Scrigno dei Seminatori", "kind": "stazione", "icon": ["scrigno", "sem"], "place": "scrigno", "stack": 99, "desc": "Si trova nelle rovine. Vuoto, si può portare via e usare come cesta."},
	"alambicco": {"name": "Alambicco di Linfa", "kind": "stazione", "icon": ["alambicco", "cristallo"], "place": "alambicco", "stack": 99, "desc": "Qui la Linfa bolle con le erbe: si fanno le pozioni."},
	"telaio": {"name": "Telaio di foglie", "kind": "stazione", "icon": ["telaio", "seta"], "place": "telaio", "stack": 99, "desc": "Si tesse la seta: vesti, mantelli, bende."},
	"mola": {"name": "Mola del gemmaio", "kind": "stazione", "icon": ["mola", "ardesia"], "place": "mola", "stack": 99, "desc": "Una ruota d'ardesia che taglia e lucida le gemme."},
	"maglio": {"name": "Maglio dei Seminatori", "kind": "stazione", "icon": ["incudine", "legnoferro"], "place": "maglio", "stack": 99, "desc": "Un attrezzo dei Seminatori ritrovato: forgia attrezzi e armature."},
	# radice: il primo equipaggiamento
	"arco_radice": {"name": "Arco di radice", "kind": "arco", "icon": ["arco", "legno"], "tier": 0, "damage": 5, "speed": 1.6, "knockback": 1.0},
	"dardo": {"name": "Dardo di spina", "kind": "munizione", "icon": ["freccia", "ardesia"], "damage": 4, "stack": 999},
	"dardo_vuoto": {"name": "Dardo di vuotite", "kind": "munizione", "icon": ["freccia", "vuotite"], "damage": 9, "stack": 999, "desc": "Punta di scheggia del Vuoto. L'arco lo preferisce ai dardi di spina."},
	"spada_radice": {"name": "Spada di radice", "kind": "spada", "icon": ["spada", "legno"], "tier": 0, "damage": 6, "speed": 2.4, "knockback": 3.0},
	"corazza_scaglie": {"name": "Corazza di scaglie", "kind": "corazza", "icon": ["corazza", "ardesia"], "tier": 1, "defense": 3, "desc": "Scaglie di scarabeo legate con radici."},
	# accessori: si trovano solo negli scrigni delle rovine (voce 10)
	"stivali_radice": {"name": "Stivali di radice svelta", "kind": "accessorio", "icon": ["stivali", "legno"], "acc": {"run": 1.25}, "desc": "Si corre un quarto più veloci."},
	"foglia_planante": {"name": "Foglia planante", "kind": "accessorio", "icon": ["foglia", "muschio"], "acc": {"glide": true, "fall_safe": true}, "desc": "Tenendo Spazio in caduta si plana; nessuna ferita da caduta."},
	"amuleto_corteccia": {"name": "Amuleto di corteccia", "kind": "accessorio", "icon": ["amuleto", "ambra"], "defense": 4, "desc": "+4 Scorza."},
	"anello_lucciola": {"name": "Anello di lucciola", "kind": "accessorio", "icon": ["anello", "cristallo"], "acc": {"halo": 1.6}, "desc": "L'alone del Germogliato si allarga."},
	"cuore_muschio": {"name": "Cuore di muschio", "kind": "accessorio", "icon": ["cuore", "muschio"], "acc": {"regen": 2.0}, "desc": "La Vita ricresce due volte più in fretta."},
	"pappo_seme": {"name": "Pappo di seme", "kind": "accessorio", "icon": ["pappo", "muschio"], "acc": {"jump": 1.18}, "desc": "Leggero come un seme nel vento: salto più alto."},
	# consumabili (le pozioni nuove della voce 25 si fanno all'Alambicco di Linfa)
	"pozione_passo": {"name": "Pozione del passo lungo", "kind": "consumabile", "icon": ["pozione", "fungo"], "boon": ["passo", 180.0], "stack": 30, "desc": "Si corre il 30% più veloci per tre minuti."},
	"pozione_minatore": {"name": "Pozione del minatore", "kind": "consumabile", "icon": ["pozione", "brillaluce"], "boon": ["scavo", 240.0], "stack": 30, "desc": "Si scava e si abbatte il 50% più in fretta per quattro minuti."},
	"pozione_spine": {"name": "Pozione di spine", "kind": "consumabile", "icon": ["pozione", "radicite"], "boon": ["spine", 180.0], "stack": 30, "desc": "Chi ti tocca si punge (15 danni) per tre minuti."},
	"pozione_esca": {"name": "Pozione dell'esca", "kind": "consumabile", "icon": ["pozione", "sanguinella"], "boon": ["esca", 300.0], "stack": 30, "desc": "Per cinque minuti le creature rare nascono due volte più spesso attorno a te."},
	"pozione_fortuna": {"name": "Pozione di fortuna", "kind": "consumabile", "icon": ["pozione", "nottilite"], "boon": ["fortuna", 300.0], "stack": 30, "desc": "Per cinque minuti le creature lasciano più spesso un giro di bottino in più."},
	# vesti di seta al Telaio (voce 25): poca Scorza, ma incantesimi più forti e Linfa più svelta
	"cappuccio_seta": {"name": "Cappuccio di seta", "kind": "elmo", "icon": ["elmo", "seta"], "tier": 2, "defense": 1, "acc": {"linfa_regen": 1.25}, "desc": "La Linfa ricresce più in fretta."},
	"veste_seta": {"name": "Veste di seta", "kind": "corazza", "icon": ["corazza", "seta"], "tier": 2, "defense": 2, "acc": {"magic": 1.12}, "desc": "Incantesimi dei bastoni +12%."},
	"calzari_seta": {"name": "Calzari di seta", "kind": "gambali", "icon": ["gambali", "seta"], "tier": 2, "defense": 1, "acc": {"run": 1.06, "magic": 1.05}, "desc": "Passo leggero, incantesimi +5%."},
	"cappuccio_vuoto": {"name": "Cappuccio del Vuoto", "kind": "elmo", "icon": ["elmo", "vuotite"], "tier": 5, "defense": 3, "acc": {"linfa_regen": 1.4, "magic": 1.08}, "desc": "Linfa molto più svelta, incantesimi +8%."},
	"veste_vuoto": {"name": "Veste del Vuoto", "kind": "corazza", "icon": ["corazza", "vuotite"], "tier": 5, "defense": 5, "acc": {"magic": 1.18}, "desc": "Incantesimi dei bastoni +18%."},
	"calzari_vuoto": {"name": "Calzari del Vuoto", "kind": "gambali", "icon": ["gambali", "vuotite"], "tier": 5, "defense": 3, "acc": {"run": 1.08, "magic": 1.07}, "desc": "Passo leggero, incantesimi +7%."},
	"pozione_rugiada": {"name": "Pozione di rugiada", "kind": "consumabile", "icon": ["pozione", "linfa"], "heal": 50, "stack": 30, "desc": "Rugiada raccolta all'alba: fa ricrescere 5 foglie di Vita."},
	"pozione_bagliore": {"name": "Pozione di bagliore", "kind": "consumabile", "icon": ["pozione", "cristallo"], "boon": ["bagliore", 180.0], "stack": 30, "desc": "Il Germogliato brilla come un fungo del profondo per tre minuti."},
	"pozione_vigore": {"name": "Pozione di vigore", "kind": "consumabile", "icon": ["pozione", "brace"], "boon": ["vigore", 180.0], "stack": 30, "desc": "Cenere e brace: +20% danno per tre minuti."},
	"pozione_scorza": {"name": "Pozione di scorza", "kind": "consumabile", "icon": ["pozione", "ambra"], "boon": ["scorza", 180.0], "stack": 30, "desc": "La pelle si fa corteccia: +8 Scorza per tre minuti."},
	# il primo anello (voce 8)
	"lanterna_linfa": {"name": "Lanterna di Linfa", "kind": "lanterna", "icon": ["lanterna", "cristallo"], "desc": "Tenuta in mano, illumina attorno di luce turchese."},
	"rugiada_linfa": {"name": "Rugiada di Linfa", "kind": "cura", "icon": ["goccia", "muschio"], "stack": 20, "desc": "Linfa pura raccolta in una goccia. Versata su un nodo avvizzito, lo guarisce."},
	"frammento_nodo": {"name": "Frammento del Nodo", "kind": "materiale", "icon": ["scaglia", "nodo"], "desc": "Un pezzo del Guardiano sconfitto: legno duro come pietra, ancora caldo."},
	"linfa_guardiano": {"name": "Linfa del Guardiano", "kind": "materiale", "icon": ["goccia", "cristallo"], "desc": "Il Guardiano guarito l'ha lasciata cadere per te: Linfa antica, luminosa."},
	# i materiali dei Guardiani dei mondi oltre i portali (voce 19): sconfitti o curati, aprono lo stesso grado
	"velo_spora": {"name": "Velo di spora", "kind": "materiale", "icon": ["foglia", "sem"], "desc": "Un lembo della Regina delle Spore sconfitta: leggero, e non si strappa."},
	"polline_regina": {"name": "Polline della Regina", "kind": "materiale", "icon": ["polvere", "cristallo"], "desc": "La Regina guarita l'ha scosso per te: spore buone, che fanno crescere."},
	"nucleo_colosso": {"name": "Nucleo del Colosso", "kind": "materiale", "icon": ["cristallo", "ardesia"], "desc": "Il cuore di pietra del Colosso sconfitto: pesa come una montagna."},
	"pietra_battente": {"name": "Pietra che batte", "kind": "materiale", "icon": ["cuore", "ardesia"], "desc": "Il Colosso guarito ha lasciato una pietra che pulsa piano, come un cuore."},
	"lingotto_vuoto": {"name": "Lingotto di vuotite forgiata", "kind": "materiale", "icon": ["lingotto", "vuotite"], "tier": 5, "desc": "Vuotite legata dal velo o dal polline della Regina."},
	"lingotto_stellare": {"name": "Lingotto stellare", "kind": "materiale", "icon": ["lingotto", "ambra"], "tier": 6, "desc": "Schegge del Vuoto fuse con il cuore del Colosso: brilla come le stelle del Giardino."},
	# essenze delle creature antiche (voce 20b): si innestano al Maglio e danno un tratto speciale all'equipaggiamento
	"essenza_furia": {"name": "Essenza di furia", "kind": "essenza", "icon": ["essenza", "brace"], "stack": 99, "graft": "furia", "desc": "Lasciata da una creatura antica. Al Maglio dei Seminatori si innesta su un'arma o un'armatura."},
	"essenza_guscio": {"name": "Essenza di guscio", "kind": "essenza", "icon": ["essenza", "ardesia"], "stack": 99, "graft": "guscio", "desc": "Lasciata da una creatura antica. Al Maglio dei Seminatori si innesta su un'arma o un'armatura."},
	"essenza_fulmine": {"name": "Essenza di fulmine", "kind": "essenza", "icon": ["essenza", "cristallo"], "stack": 99, "graft": "fulmine", "desc": "Lasciata da una creatura antica. Al Maglio dei Seminatori si innesta su un'arma o un'armatura."},
	"essenza_vastita": {"name": "Essenza di vastità", "kind": "essenza", "icon": ["essenza", "radice"], "stack": 99, "graft": "vastita", "desc": "Lasciata da una creatura antica. Al Maglio dei Seminatori si innesta su un'arma o un'armatura."},
	"essenza_veleno": {"name": "Essenza di veleno", "kind": "essenza", "icon": ["essenza", "muschio"], "stack": 99, "graft": "veleno", "desc": "Lasciata da una creatura antica. Al Maglio dei Seminatori si innesta su un'arma o un'armatura."},
	"essenza_spine": {"name": "Essenza di spine", "kind": "essenza", "icon": ["essenza", "nodo"], "stack": 99, "graft": "spine", "desc": "Lasciata da una creatura antica. Al Maglio dei Seminatori si innesta su un'arma o un'armatura."},
	"essenza_linfa": {"name": "Essenza di linfa lenta", "kind": "essenza", "icon": ["essenza", "cristallo"], "stack": 99, "graft": "linfa_lenta", "desc": "Lasciata da una creatura antica. Al Maglio dei Seminatori si innesta su un'arma o un'armatura."},
	"essenza_richiamo": {"name": "Essenza di richiamo", "kind": "essenza", "icon": ["essenza", "sem"], "stack": 99, "graft": "fortuna", "desc": "Lasciata da una creatura antica. Al Maglio dei Seminatori si innesta su un'arma o un'armatura."},
	"essenza_luce": {"name": "Essenza di luce", "kind": "essenza", "icon": ["essenza", "ambra"], "stack": 99, "graft": "lucciola_viva", "desc": "Lasciata da una creatura antica. Al Maglio dei Seminatori si innesta su un'arma o un'armatura."},
	"essenza_scoppio": {"name": "Essenza di scoppio", "kind": "essenza", "icon": ["essenza", "brace"], "stack": 99, "graft": "scoppio", "desc": "Lasciata da una creatura antica. Al Maglio dei Seminatori si innesta su un'arma o un'armatura."},
	"essenza_ombra": {"name": "Essenza d'ombra", "kind": "essenza", "icon": ["essenza", "vuotite"], "stack": 99, "graft": "ombra", "desc": "Lasciata da una creatura antica. Al Maglio dei Seminatori si innesta su un'arma o un'armatura."},
	# doni da trovare (voce 21): si assorbono con il clic, per sempre
	"cuore_bocciolo": {"name": "Cuore di bocciolo", "kind": "dono", "icon": ["cuore", "linfa"], "stack": 20,
		"gift": ["vita", 10], "gift_max": 15, "desc": "Il cuore di un bocciolo delle grotte, che batte ancora. Assorbilo: una foglia di Vita in più, per sempre (fino a 15)."},
	"stilla_perenne": {"name": "Stilla perenne", "kind": "dono", "icon": ["goccia", "cristallo"], "stack": 20,
		"gift": ["linfa", 4], "gift_max": 10, "desc": "Una goccia che pendeva dai soffitti profondi senza mai cadere. Assorbila: +4 Linfa massima, per sempre (fino a 10)."},
	"pozione_linfa": {"name": "Pozione di Linfa", "kind": "consumabile", "icon": ["pozione", "cristallo"], "linfa": 30, "stack": 30, "desc": "Ridà 30 Linfa, subito."},
	# bastoni di Linfa (voce 21): tenendo premuto tirano incantesimi verso il mouse, consumando Linfa
	"bastone_brace": {"name": "Bastone di brace", "kind": "bastone", "icon": ["bastone", "brace"], "tier": 1, "damage": 11, "speed": 2.6, "knockback": 1.0,
		"spell": "brace", "linfa": 3, "desc": "Tira faville di brace che fanno luce mentre volano."},
	"bastone_spore": {"name": "Bastone di spore", "kind": "bastone", "icon": ["bastone", "muschio"], "tier": 2, "damage": 10, "speed": 2.0, "knockback": 1.5,
		"spell": "spore", "linfa": 5, "desc": "Un ventaglio di tre spore buone che ricadono ad arco."},
	"bastone_cristallo": {"name": "Bastone di cristallo", "kind": "bastone", "icon": ["bastone", "cristallo"], "tier": 3, "damage": 24, "speed": 2.2, "knockback": 1.2,
		"spell": "cristallo", "linfa": 6, "desc": "Una scheggia di cristallo che attraversa fino a quattro creature."},
	"bastone_vuoto": {"name": "Bastone del Vuoto", "kind": "bastone", "icon": ["bastone", "vuotite"], "tier": 4, "damage": 34, "speed": 1.8, "knockback": 2.0,
		"spell": "vuoto", "linfa": 8, "desc": "Una sfera di Vuoto che attraversa la roccia e insegue la creatura più vicina."},
	# voce 31: muoversi meglio
	"radice_uncino": {"name": "Radice uncino", "kind": "rampino", "icon": ["uncino", "legno"], "hook": {"range": 11, "speed": 330.0}, "desc": "Clic: la radice vola verso il mouse, si aggancia alla roccia e ti tira su. Salto per sganciarti."},
	"uncino_cristallo": {"name": "Uncino di cristallo", "kind": "rampino", "icon": ["uncino", "cristallo"], "hook": {"range": 18, "speed": 480.0}, "desc": "Un rampino più lungo e più svelto, con la punta di cristallo."},
	"baccello_vento": {"name": "Baccello di vento", "kind": "accessorio", "icon": ["sacca", "cristallo"], "acc": {"air_jumps": 1}, "desc": "Un secondo salto in aria: il baccello sbuffa un colpo di vento sotto i piedi."},
	"seme_tempesta": {"name": "Seme di tempesta", "kind": "accessorio", "icon": ["seme", "lagunite"], "acc": {"air_jumps": 2, "jump": 1.05}, "desc": "Due salti in aria e un salto un po' più alto."},
	"artigli_corteccia": {"name": "Artigli di corteccia", "kind": "accessorio", "icon": ["artiglio", "radice"], "acc": {"wall": true}, "desc": "Spingendo contro una parete in aria si scivola piano; con il salto ci si stacca verso l'alto."},
	# voce 32: esplosivi e armi da lancio
	"baccello_esplosivo": {"name": "Baccello esplosivo", "kind": "esplosivo", "icon": ["bomba", "brace"], "stack": 99, "blast": {"radius": 2.6, "power": 40, "damage": 45, "fuse": 1.4}, "desc": "Lancialo: rimbalza e dopo un attimo scoppia. Rompe terra e roccia attorno (non l'ambra né i cristalli). Stai lontano!"},
	"baccello_tonante": {"name": "Baccello tonante", "kind": "esplosivo", "icon": ["bomba", "tizzonite"], "stack": 99, "blast": {"radius": 4.0, "power": 55, "damage": 90, "fuse": 1.6}, "desc": "Uno scoppio molto più grande, che rompe anche l'ambra fossile."},
	"seme_ricurvo": {"name": "Seme ricurvo", "kind": "ricurvo", "icon": ["ricurvo", "legno"], "tier": 0, "damage": 9, "knockback": 1.5, "throw": {"range": 9, "speed": 300.0}, "desc": "Lancialo: vola avanti, ferisce ciò che attraversa e torna in mano."},
	"seme_ricurvo_ambra": {"name": "Seme ricurvo d'ambra", "kind": "ricurvo", "icon": ["ricurvo", "ambra"], "tier": 3, "damage": 20, "knockback": 1.8, "throw": {"range": 12, "speed": 360.0}, "desc": "Più lontano e più forte."},
	"seme_ricurvo_vuoto": {"name": "Seme ricurvo del Vuoto", "kind": "ricurvo", "icon": ["ricurvo", "vuotite"], "tier": 5, "damage": 32, "knockback": 2.0, "throw": {"range": 15, "speed": 420.0}, "desc": "Tagliente come le schegge del Fondo."},
	"giavellotto_aculeo": {"name": "Giavellotto d'aculeo", "kind": "giavellotto", "icon": ["giavellotto", "ambra"], "stack": 999, "damage": 14, "pierce": 1, "desc": "Si lancia con il clic e attraversa due creature. Si consuma."},
	"giavellotto_cristallo": {"name": "Giavellotto di cristallo", "kind": "giavellotto", "icon": ["giavellotto", "cristallo"], "stack": 999, "damage": 26, "pierce": 2, "desc": "Attraversa tre creature."},
	# voce 33: il giardino
	"seme_rugiada": {"name": "Semi d'erba di rugiada", "kind": "coltura", "icon": ["seme", "muschio"], "stack": 99, "desc": "Piantali sul muschio o sull'erba: in tre minuti un ciuffo di foglie di rugiada."},
	"spore_brace": {"name": "Spore di brace", "kind": "coltura", "icon": ["polvere", "brace"], "stack": 99, "desc": "Piantale sulla terra o sulla roccia: crescono funghi di brace."},
	"spore_luminose": {"name": "Spore luminose", "kind": "coltura", "icon": ["polvere", "cristallo"], "stack": 99, "desc": "Crescono solo sotto terra, al buio: funghi luminosi."},
	"seme_campanula": {"name": "Seme di campanula lume", "kind": "coltura", "icon": ["seme", "fungo"], "stack": 99, "desc": "Sul muschio o sull'erba nasce una campanula che fa luce."},
	"occhio_tubero": {"name": "Occhio di tubero", "kind": "coltura", "icon": ["seme", "cristallo"], "stack": 99, "desc": "Un pezzo di tubero di Linfa con il suo occhio: piantalo sul muschio."},
	"foglia_rugiada": {"name": "Foglia di rugiada", "kind": "materiale", "icon": ["foglia", "muschio"], "desc": "Coperta di gocce che non asciugano mai."},
	"petali_lume": {"name": "Petali di lume", "kind": "materiale", "icon": ["foglia", "fungo"], "desc": "Rosa, tiepidi, fanno una luce debole anche staccati."},
	"tubero_linfa": {"name": "Tubero di Linfa", "kind": "materiale", "icon": ["tubero", "cristallo"], "desc": "Una radice gonfia di Linfa: nutriente."},
	"annaffiatoio": {"name": "Annaffiatoio di zucca", "kind": "annaffiatoio", "icon": ["annaffiatoio", "legno"], "desc": "Clic su una coltura che cresce: da lì in poi cresce il doppio più in fretta (una volta per pianta)."},
	"paiolo": {"name": "Paiolo di radice", "kind": "stazione", "icon": ["paiolo", "ardesia"], "place": "paiolo", "stack": 99, "desc": "Un paiolo d'ardesia sulla brace: si cucina."},
	"zuppa_funghi": {"name": "Zuppa di funghi", "kind": "consumabile", "icon": ["ciotola", "brace"], "boon": ["sazio", 600.0], "stack": 30, "desc": "Sazio per dieci minuti: la Vita ricresce un po' più in fretta, colpi e corsa un po' più forti."},
	"pane_tubero": {"name": "Pane di tubero", "kind": "consumabile", "icon": ["ciotola", "ambra"], "boon": ["sazio", 900.0], "stack": 30, "desc": "Sazio per quindici minuti."},
	"insalata_lume": {"name": "Insalata di lume", "kind": "consumabile", "icon": ["ciotola", "muschio"], "boon": ["sazio", 900.0], "stack": 30, "desc": "Sazio per quindici minuti."},
	"stufato_regale": {"name": "Stufato regale", "kind": "consumabile", "icon": ["ciotola", "linfa"], "boon": ["sazio", 1800.0], "stack": 30, "desc": "Sazio per mezz'ora."},
	"pozione_notte": {"name": "Pozione di notte", "kind": "consumabile", "icon": ["pozione", "fungo"], "boon": ["vista", 300.0], "stack": 30, "desc": "Per cinque minuti gli occhi vedono qualcosa anche dove non arriva la luce."},
	"pozione_radice": {"name": "Pozione di radice", "kind": "consumabile", "icon": ["pozione", "radice"], "heal": 90, "stack": 30, "desc": "Fa ricrescere 9 foglie di Vita."},
	# voce 34: eventi del mondo
	"stellina": {"name": "Stellina caduta", "kind": "materiale", "icon": ["stella", "ambra"], "desc": "Cade nelle notti della Pioggia di stelle. Tiepida, e brilla ancora."},
	"pendente_stelle": {"name": "Pendente di stelle", "kind": "accessorio", "icon": ["amuleto", "ambra"], "acc": {"linfa_regen": 1.5, "halo": 1.2, "magic": 1.05}, "desc": "Linfa +50%, alone più ampio, incantesimi +5%."},
	"bastone_stellare_caduto": {"name": "Bastone delle stelle cadute", "kind": "bastone", "icon": ["bastone", "ambra"], "tier": 4, "damage": 28, "speed": 2.2, "knockback": 1.2, "spell": "stelle", "linfa": 6, "desc": "Tre piccole stelle che cercano le creature."},
	# voce 35: costruire
	"assi_lanterna": {"name": "Assi di lanterna", "kind": "blocco", "icon": ["mattoni", "legno"], "place": TileDefs.ASSI, "desc": "Legno piallato: un blocco dai bordi dritti, per costruire."},
	"mattoni_ardesia": {"name": "Mattoni d'ardesia", "kind": "blocco", "icon": ["mattoni", "ardesia"], "place": TileDefs.MATTONI, "desc": "Ardesia squadrata e cotta nel Baccello."},
	"vetro_resina": {"name": "Vetro di resina", "kind": "blocco", "icon": ["vetro", "cristallo"], "place": TileDefs.VETRO, "desc": "Solido come un blocco, ma la luce ci passa attraverso."},
	"parete_assi": {"name": "Parete di assi", "kind": "parete", "icon": ["parete", "legno"], "wall": TileDefs.WALL_ASSI, "desc": "Clic: una parete di fondo di assi. Il Martello la toglie."},
	"parete_mattoni": {"name": "Parete di mattoni", "kind": "parete", "icon": ["parete", "ardesia"], "wall": TileDefs.WALL_MATTONI, "desc": "Clic: una parete di fondo di mattoni. Il Martello la toglie."},
	"parete_sem": {"name": "Parete dei Seminatori", "kind": "parete", "icon": ["parete", "sem"], "wall": TileDefs.WALL_SEM, "desc": "Clic: una parete di pietra lavorata, come quelle delle rovine."},
	"martello_radice": {"name": "Martello di radice", "kind": "martello", "icon": ["martello", "legno"], "desc": "Tenendo premuto su una parete di fondo la si stacca (le pareti costruite tornano nella Bisaccia)."},
	"porta_lanterna": {"name": "Porta di lanterna", "kind": "stazione", "icon": ["porta", "legno"], "place": "porta", "stack": 99, "desc": "Si piazza in un vano alto 3 tessere. Clic destro: si apre e si chiude. Chiusa ferma anche le creature."},
	"lampada_lanterna": {"name": "Lampada di lanterna", "kind": "stazione", "icon": ["lampada", "brace"], "place": "lampada", "stack": 99, "desc": "Una luce calda da tenere in casa."},
	"tavolo_radice": {"name": "Tavolo di radice", "kind": "stazione", "icon": ["tavolo", "legno"], "place": "tavolo", "stack": 99, "desc": "Un tavolo, per una casa vera."},
	"sedia_radice": {"name": "Sedia di radice", "kind": "stazione", "icon": ["sedia", "legno"], "place": "sedia", "stack": 99, "desc": "Una sedia accanto al tavolo."},
	"letto_foglie": {"name": "Letto di foglie", "kind": "stazione", "icon": ["letto", "muschio"], "place": "letto", "stack": 99, "desc": "Clic destro: da ora rinasci qui invece che alla partenza del mondo."},
	# voce 36: abitanti e commercio
	# voce 37: i compagni (`pet` = id di `CompanionsData.PETS`) e i bastoni evocatori (`ally` = id di `ALLIES`)
	"vasetto_lucciolina": {"name": "Vasetto della Lucciolina", "kind": "compagno", "icon": ["vasetto", "lucciola"], "pet": "lucciolina", "desc": "Clic: la Lucciolina esce e ti segue, facendo luce attorno a te. Clic di nuovo: torna nel vasetto."},
	"gelatina_viva": {"name": "Gelatina viva", "kind": "compagno", "icon": ["vasetto", "muschio"], "pet": "grumetto", "desc": "Clic: il Grumetto ti segue saltellando; gli oggetti a terra vengono attirati da più del doppio della distanza."},
	"goccia_spiritello": {"name": "Goccia dello Spiritello", "kind": "compagno", "icon": ["vasetto", "cristallo"], "pet": "spiritello", "desc": "Clic: lo Spiritello di Linfa ti segue; la tua Linfa ricresce il 30% più in fretta."},
	"bastone_grumi_amici": {"name": "Bastone dei grumi amici", "kind": "evocatore", "icon": ["evocatore", "muschio"], "ally": "grumo_amico", "desc": "Clic (10 Linfa): richiama un Grumo amico che salta addosso alle creature vicine. Due alla volta."},
	"bastone_falena_amica": {"name": "Bastone della falena amica", "kind": "evocatore", "icon": ["evocatore", "brace"], "ally": "falena_amica", "desc": "Clic (10 Linfa): richiama una Falena amica, svelta, che vola contro le creature vicine."},
	"bastone_vagavuoto": {"name": "Bastone del Vagavuoto domato", "kind": "evocatore", "icon": ["evocatore", "vuotite"], "ally": "vagavuoto_amico", "desc": "Clic (10 Linfa): un Vagavuoto domato ti segue in volo e tira sfere di Vuoto alle creature."},
	"fischietto_branco": {"name": "Fischietto del branco", "kind": "accessorio", "icon": ["amuleto", "seta"], "acc": {"allies": 1, "magic": 1.05}, "desc": "Un alleato in più insieme; incantesimi e alleati +5%."},
	# voce 39: Semi di mondo con la specie scelta (`species` = gene di superficie di `GenesData`; voce 42: ogni Seme
	# ha il suo genoma nei dati della casella, e non si impila)
	"seme_mondo_lanterna": {"name": "Seme di salice-lanterna", "kind": "seme_mondo", "icon": ["seme", "linfa"], "species": "lanterna", "stack": 1, "desc": "Un Seme di mondo nutrito di semi-lanterna: dietro il suo portale, foreste di alberi-lanterna a perdita d'occhio."},
	"seme_mondo_sporangio": {"name": "Seme di sporangio", "kind": "seme_mondo", "icon": ["seme", "fungo"], "species": "sporangio", "stack": 1, "desc": "Un Seme di mondo nutrito di spore: dietro il suo portale, paludi di spore quasi ovunque."},
	"seme_mondo_resina": {"name": "Seme di resina", "kind": "seme_mondo", "icon": ["seme", "ambra"], "species": "resina", "stack": 1, "desc": "Un Seme di mondo nutrito d'ambra: dietro il suo portale, distese d'ambra calde e aperte."},
	# voce 38: viaggio rapido
	"radice_viandante": {"name": "Radice viandante", "kind": "stazione", "icon": ["radice_viaggio", "linfa"], "place": "radice_viandante", "stack": 99, "desc": "Piantala dove vuoi tornare. Clic destro su una radice: la mappa mostra tutte le altre radici del mondo, un clic e ci arrivi."},
	"lumino": {"name": "Lumino", "kind": "moneta", "icon": ["lumino", "ambra"], "stack": 9999, "desc": "Una goccia di luce solida: la moneta degli abitanti. La lasciano le creature sconfitte e gli scrigni."},
	"focolare": {"name": "Focolare del Giardino", "kind": "stazione", "icon": ["focolare", "brace"], "place": "focolare", "stack": 99, "desc": "Un fuoco acceso che si vede da lontano. Con un Letto di foglie libero lì vicino, un viandante si ferma ad abitare (uno per letto)."},
	"banco_innesti": {"name": "Banco dell'Innestatrice", "kind": "stazione", "place": "banco_innesti", "icon": ["banco", "linfa"], "stack": 9,
		"desc": "Un banco di legnoferro con il coltello da innesto e una campana di vetro piena di Linfa. Clic destro: si uniscono due Semi di mondo in un Seme nuovo, con le Fiale per fissare i geni che vuoi."},
	"aiuola": {"name": "Aiuola del Giardino", "kind": "stazione", "place": "aiuola", "icon": ["vasetto", "humus"], "stack": 9,
		"desc": "Un letto di terra buona cerchiato di radici. Si mette solo nel Giardino, il tuo mondo di partenza (tre Aiuole al massimo): con un Seme di mondo in mano, clic sull'Aiuola e cresce un portale."},
	"seme_mondo_mosaico": {"name": "Seme a mosaico", "kind": "seme_mondo", "icon": ["seme", "iride"], "species": "mosaico", "stack": 1,
		"desc": "Un Seme nato da una mutazione, screziato di tutti i colori: dietro il suo portale, tutti i biomi a tratti brevi."},
	"seme_mondo": {"name": "Seme di mondo", "kind": "seme_mondo", "icon": ["seme", "cristallo"], "stack": 1, "desc": "Il Cuore del mondo ti ha donato un seme. Piantalo in un'Aiuola del Giardino: crescerà un portale verso un mondo nuovo. Ogni Seme porta i suoi geni: posalo in Esamina per leggerli."},
}

## Metalli: grado, forza di piccone e ascia, danno della spada, difesa dell'armatura (elmo, corazza, gambali).
## Oggetti che nascono da qualcosa che non è una tabella (es. alberi abbattuti, voce 4).
const OTHER_SOURCES := {"legno": "alberi", "seme_lanterna": "alberi", "frammento_nodo": "Guardiano sconfitto",
	"linfa_guardiano": "Guardiano curato", "seme_mondo": "Cuore del mondo", "seme_mondo_mosaico": "innesti (per mutazione)", "linfa_antica": "scrigni delle firme dei mondi e Cuori dei mondi",
	"ricordo_albero": "la firma di un mondo", "ricordo_cratere": "la firma di un mondo", "ricordo_foresta": "la firma di un mondo",
	"ricordo_pozzo": "la firma di un mondo", "ricordo_arco": "la firma di un mondo", "ricordo_isola": "la firma di un mondo",
	"ricordo_lucciole": "la firma di un mondo", "ricordo_nodo": "la firma di un mondo", "ricordo_serra": "la firma di un mondo",
	"ricordo_colonne": "la firma di un mondo", "ricordo_alveare": "la firma di un mondo", "ricordo_bolla": "la firma di un mondo", "velo_spora": "Regina sconfitta",
	"polline_regina": "Regina curata", "nucleo_colosso": "Colosso sconfitto", "pietra_battente": "Colosso curato", "scrigno": "rovine",
	"stivali_radice": "scrigni", "foglia_planante": "scrigni", "amuleto_corteccia": "scrigni", "anello_lucciola": "scrigni",
	"cuore_muschio": "scrigni", "pappo_seme": "scrigni",
	"essenza_furia": "creature antiche", "essenza_guscio": "creature antiche", "essenza_fulmine": "creature antiche", "essenza_vastita": "creature antiche", "essenza_veleno": "creature antiche", "essenza_spine": "creature antiche", "essenza_linfa": "creature antiche", "essenza_richiamo": "creature antiche", "essenza_luce": "creature antiche", "essenza_scoppio": "creature antiche", "essenza_ombra": "creature antiche"}

static var _all := {}


## Tutti gli oggetti, famiglie di metallo comprese (calcolati una volta).
static func all() -> Dictionary:
	if not _all.is_empty():
		return _all
	var out := ITEMS.duplicate(true)
	out.merge(BeastItemsData.ITEMS.duplicate(true))
	out.merge(TrophyItemsData.ITEMS.duplicate(true))
	out.merge(KeeperItemsData.ITEMS.duplicate(true))
	out.merge(RelicsData.ITEMS.duplicate(true))
	out.merge(BiomeItemsData.ITEMS.duplicate(true))
	out.merge(SignaturesData.ITEMS.duplicate(true))
	out.merge(GenesData.items().duplicate(true))
	out.merge(MaterialsData.items().duplicate(true))
	# le famiglie di equipaggiamento: forma × materiale (voce 49, `FormsData` e `MaterialsData`)
	for m in MaterialsData.all():
		for f in FormsData.FORMS:
			out[FormsData.item_id(f, m)] = FormsData.item(f, m)
	_all = out
	return _all


static func get_item(id: String) -> Dictionary:
	return all().get(id, {})


static func has(id: String) -> bool:
	return all().has(id)


static func stack_of(id: String) -> int:
	var it := get_item(id)
	if it.has("stack"):
		return int(it["stack"])
	return 999 if String(it.get("kind", "")) in ["materiale", "blocco", "munizione", "piattaforma"] else 1


## Che cosa fa il clic con l'oggetto in mano (per ora: scava, colpisci, piazza una torcia).
static func use_of(id: String) -> String:
	match String(get_item(id).get("kind", "")):
		"piccone":
			return "scava"
		"ascia":
			return "abbatti"
		"spada":
			return "colpo"
		"arco":
			return "tira"
		"seme":
			return "semina"
		"consumabile":
			return "bevi"
		"torcia":
			return "torcia"
		"cura":
			return "cura"
		"seme_mondo":
			return "portale"
		"purifica":
			return "purifica"
		"bastone":
			return "incanta"
		"dono":
			return "dono"
		"specchio":
			return "ritorna"
		"richiamo":
			return "richiama"
		"mappa":
			return "mappa"
		"rampino":
			return "aggancia"
		"esplosivo", "ricurvo", "giavellotto":
			return "lancia"
		"coltura":
			return "coltiva"
		"parete":
			return "mura"
		"martello":
			return "smura"
		"annaffiatoio":
			return "annaffia"
		"compagno":
			return "chiama"
		"evocatore":
			return "evoca"
	return ""
