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
##          specchio (riporta al punto di partenza) · trofeo (lo lasciano solo le creature rare, `TrophyItemsData`)
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
## Le famiglie di metallo sono generate da `METALS` × `GEAR` in `all()`: un metallo nuovo = una riga in `METALS`.

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
	# consumabili
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
	"seme_mondo": {"name": "Seme di mondo", "kind": "seme_mondo", "icon": ["seme", "cristallo"], "stack": 9, "desc": "Il Cuore del mondo ti ha donato un seme. Piantalo sul terreno: crescerà un portale verso un mondo nuovo."},
}

## Metalli: grado, forza di piccone e ascia, danno della spada, difesa dell'armatura (elmo, corazza, gambali).
const METALS := {
	"radicite": {"label": "di radicite", "tier": 1, "power": 35, "damage": 9, "speed": 2.2, "defense": [1, 2, 1]},
	"legnoferro": {"label": "di legnoferro", "tier": 2, "power": 45, "damage": 12, "speed": 2.3, "defense": [2, 3, 2]},
	"ambra": {"label": "d'ambra", "tier": 3, "power": 55, "damage": 16, "speed": 2.4, "defense": [3, 4, 3]},
	"linfa": {"label": "di Linfa", "tier": 4, "power": 65, "damage": 21, "speed": 2.6, "defense": [4, 6, 4], "icon": "cristallo"},
	"vuoto": {"label": "di vuotite forgiata", "tier": 5, "power": 75, "damage": 27, "speed": 2.7, "defense": [5, 8, 5], "icon": "vuotite"},
	# voce 24: metalli laterali, per chi vuole una strada diversa (più veloce, o più forte prima della Linfa)
	"pallidite": {"label": "di pallidite", "tier": 2, "power": 42, "damage": 11, "speed": 2.7, "defense": [2, 2, 2]},
	"tizzonite": {"label": "di tizzonite", "tier": 3, "power": 60, "damage": 18, "speed": 2.4, "defense": [3, 5, 3]},
	"stellare": {"label": "stellare", "label_pl": "stellari", "tier": 6, "power": 85, "damage": 34, "speed": 2.8, "defense": [6, 10, 6], "icon": "ambra"},
}

## Modelli delle famiglie di metallo: tipo, costo in lingotti (+ legno).
const GEAR := {
	"piccone": {"name": "Piccone", "bars": 12, "wood": 4},
	"ascia": {"name": "Ascia", "bars": 9, "wood": 3},
	"spada": {"name": "Spada", "bars": 8, "wood": 0},
	"elmo": {"name": "Elmo", "bars": 15, "wood": 0},
	"corazza": {"name": "Corazza", "bars": 25, "wood": 0},
	"gambali": {"name": "Gambali", "bars": 20, "wood": 0, "plural": true},
	"arco": {"name": "Arco", "bars": 10, "wood": 3},
}

## Oggetti che nascono da qualcosa che non è una tabella (es. alberi abbattuti, voce 4).
const OTHER_SOURCES := {"legno": "alberi", "seme_lanterna": "alberi", "frammento_nodo": "Guardiano sconfitto",
	"linfa_guardiano": "Guardiano curato", "seme_mondo": "Cuore del mondo", "velo_spora": "Regina sconfitta",
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
	for m in METALS:
		var md: Dictionary = METALS[m]
		for g in GEAR:
			var gd: Dictionary = GEAR[g]
			var it := {"name": "%s %s" % [gd["name"], md.get("label_pl", md["label"]) if gd.get("plural", false) else md["label"]], "kind": g, "icon": [g, md.get("icon", m)], "tier": md["tier"]}
			match g:
				"piccone", "ascia":
					it["power"] = md["power"]
					it["damage"] = int(md["damage"] * 0.6)
					it["speed"] = 2.6
				"spada":
					it["damage"] = md["damage"]
					it["speed"] = md["speed"]
					it["knockback"] = 4.0
				"elmo":
					it["defense"] = md["defense"][0]
				"corazza":
					it["defense"] = md["defense"][1]
				"gambali":
					it["defense"] = md["defense"][2]
				"arco":
					it["damage"] = int(md["damage"] * 0.55)
					it["speed"] = 1.6 + 0.15 * float(md["tier"])
					it["knockback"] = 1.2
			out["%s_%s" % [g, m]] = it
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
	return ""
