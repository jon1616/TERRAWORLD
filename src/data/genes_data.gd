class_name GenesData
extends RefCounted
## I geni dei Semi di mondo (voce 42, piano «Il Giardiniere dei mondi»). Solo dati; le regole (genoma a caso,
## effetti sommati, innesto) stanno in `Genome`.
##
## Un Seme porta un **genoma**: un gene di superficie (sempre) e alcuni geni di altre categorie, al più uno per
## categoria, più il vigore. Ogni categoria corrisponde a una parte del generatore o del mondo mentre si gioca.
##
## Campi di un gene:
##   cat     categoria (`CATEGORIES`)          name, desc   nome dell'universo e cosa fa, in breve
##   rar     rarità 0-3 (`RARITY`)             dom          dominanza 1-5: negli innesti vince più spesso
##   good    true = un dono, false = una prova (colore della scritta)
##   gen     effetti sul generatore            run          effetti mentre si gioca (chiavi in `DEFAULTS`)
##   item    (solo superficie) l'oggetto Seme che porta questo gene
##   vmin    vigore minimo perché compaia in un Seme trovato (i geni rari solo nei mondi più profondi)
##   only    come si ottiene se non a caso: "mutazione" (solo innestando), "firma" (solo dalla firma di un mondo)
##   combo   [a, b]: nasce per mutazione con probabilità alta quando i genitori portano a e b (voce 48)

const CATEGORIES := ["superficie", "forma", "grotte", "sottosuolo", "minerali", "gemme", "rovine", "fauna", "stirpi",
	"flora", "cielo", "tempo", "ombra"]

## Nome della categoria, colore, e dove la Provetta di Linfa trova i suoi geni (voce 46: `Sampling`).
const CAT_INFO := {
	"superficie": {"name": "Superficie", "color": "#8ef0d8", "where": "l'erba della superficie"},
	"forma": {"name": "Forma", "color": "#c8b890", "where": "la terra della superficie"},
	"grotte": {"name": "Grotte", "color": "#8aa8d8", "where": "l'aria delle grotte"},
	"sottosuolo": {"name": "Sottosuolo", "color": "#b89ae8", "where": "le rocce profonde"},
	"minerali": {"name": "Minerali", "color": "#e89a6a", "where": "le vene di minerale"},
	"gemme": {"name": "Gemme", "color": "#f07ab0", "where": "gemme e cristalli"},
	"rovine": {"name": "Rovine", "color": "#e8d27a", "where": "la pietra dei Seminatori"},
	"fauna": {"name": "Fauna", "color": "#d88a6a", "where": "le creature sconfitte"},
	"stirpi": {"name": "Stirpi", "color": "#ffd24a", "where": "le creature rare sconfitte"},
	"flora": {"name": "Flora", "color": "#7ad87a", "where": "alberi e piante"},
	"cielo": {"name": "Cielo", "color": "#9ad8ff", "where": "il cielo aperto"},
	"tempo": {"name": "Tempo", "color": "#a8a8e8", "where": "il cielo aperto"},
	"ombra": {"name": "Ombra", "color": "#a86a8a", "where": "la terra avvizzita"},
}

const RARITY := [
	{"name": "comune", "color": "#b8c8b0", "weight": 100},
	{"name": "robusto", "color": "#8ef0d8", "weight": 40},
	{"name": "antico", "color": "#f0c060", "weight": 12},
	{"name": "stellare", "color": "#d890ff", "weight": 3},
]

## Valori neutri degli effetti. Le chiavi in `MUL` si moltiplicano tra geni, le altre numeriche si sommano; gli array
## si uniscono, i dizionari si fondono, i vero/falso valgono se almeno un gene li accende.
## gen: ore (soglia delle vene più bassa), ruins, gems, surface (altezza della superficie, in frazione del mondo),
##      hills (colline), rough (rupi), worm (larghezza delle gallerie), room (soglia delle caverne: meno = più),
##      big (soglia delle grandi caverne), comb (grotte ad alveare), shafts (voragini), under (biomi del sottosuolo,
##      `PassSottosuolo`), roots (radici giganti), shallow (profondità minima delle vene), ore_boost (tessera → soglia
##      più bassa per quel minerale), geodes, crystal (soglia dei cristalli più bassa), rich (tiri di bottino in più
##      negli scrigni delle rovine), trees, blight_zones (macchie di Avvizzimento in più o in meno)
const DEFAULTS := {
	"gen": {"ore": 0.0, "ruins": 1.0, "gems": 1.0, "surface": 0.0, "hills": 1.0, "rough": 0.0, "worm": 1.0, "room": 0.0,
		"big": 0.0, "comb": false, "shafts": 0.0, "under": [], "roots": 1.0, "shallow": 1.0, "ore_boost": {},
		"geodes": 1.0, "crystal": 0.0, "rich": 0.0, "trees": 1.0, "blight_zones": 0.0, "mosaic": false, "islands": 0.0,
		"city": false, "sea": false, "pools": 1.0},
	"run": {"danger": 0.0, "lumini": 1.0, "rare": 1.0, "grow": 1.0, "night": 0.0, "events": 1.0, "blight": 1.0, "season": 0.0,
		"aurora": 0.0, "roles": {}, "rain": 1.0, "wind": 1.0, "fog": 1.0},
}
const MUL := ["ruins", "gems", "lumini", "rare", "grow", "events", "blight", "hills", "worm", "roots", "shallow", "geodes",
	"trees", "pools", "rain", "wind", "fog"]

const GENES := {
	# --- superficie: i biomi (erano le specie della voce 39) -------------------------------------------------------
	"lanterna": {"cat": "superficie", "name": "Salice-lanterna", "rar": 0, "dom": 3, "good": true,
		"desc": "foreste di alberi-lanterna a perdita d'occhio", "item": "seme_mondo_lanterna",
		"gen": {"biomes": {"foresta": 6, "palude": 2, "ambra": 2}}},
	"sporangio": {"cat": "superficie", "name": "Sporangio", "rar": 0, "dom": 3, "good": true,
		"desc": "paludi di spore quasi ovunque", "item": "seme_mondo_sporangio",
		"gen": {"biomes": {"palude": 6, "foresta": 2, "ambra": 1}}},
	"resina": {"cat": "superficie", "name": "Resina", "rar": 0, "dom": 3, "good": true,
		"desc": "distese d'ambra, calde e aperte", "item": "seme_mondo_resina",
		"gen": {"biomes": {"ambra": 6, "foresta": 2, "palude": 1}}},
	"brina": {"cat": "superficie", "name": "Brina", "rar": 1, "dom": 2, "good": true,
		"desc": "boschi gelati e cieli chiari", "item": "seme_mondo_brina",
		"gen": {"biomes": {"brina": 6, "foresta": 2, "ambra": 1}}},
	"cenere": {"cat": "superficie", "name": "Cenere", "rar": 1, "dom": 2, "good": true,
		"desc": "pianure di cenere e braci", "item": "seme_mondo_cenere",
		"gen": {"biomes": {"cenere": 6, "ambra": 2, "palude": 1}}},
	# voce 66: i geni delle stagioni (si prendono solo con la Provetta, nell'aria della superficie, nella loro stagione)
	"germoglio_eterno": {"cat": "tempo", "name": "Germoglio eterno", "rar": 2, "dom": 2, "good": true, "only": "stagione",
		"desc": "il mondo resta per sempre nella stagione del Germoglio", "run": {"season": 1}},
	"rigoglio_lungo": {"cat": "tempo", "name": "Rigoglio lungo", "rar": 2, "dom": 2, "good": true, "only": "stagione",
		"desc": "il mondo resta per sempre nel Rigoglio", "run": {"season": 2}},
	"raccolto_doro": {"cat": "tempo", "name": "Raccolto d'oro", "rar": 2, "dom": 2, "good": true, "only": "stagione",
		"desc": "il mondo resta per sempre nel Raccolto", "run": {"season": 3}},
	"gelo_perenne": {"cat": "tempo", "name": "Gelo perenne", "rar": 2, "dom": 2, "good": true, "only": "stagione",
		"desc": "il mondo resta per sempre nel Gelo", "run": {"season": 4}},
	# --- i tratti della voce 39, ora geni della loro categoria ----------------------------------------------------
	"vene_ricche": {"cat": "minerali", "name": "Vene ricche", "rar": 0, "dom": 3, "good": true,
		"desc": "minerali più abbondanti", "gen": {"ore": 0.035}},
	"rovine_fitte": {"cat": "rovine", "name": "Rovine fitte", "rar": 0, "dom": 3, "good": true,
		"desc": "molte più stanze dei Seminatori", "gen": {"ruins": 1.6}},
	"gemme_ricche": {"cat": "gemme", "name": "Gemme ricche", "rar": 0, "dom": 3, "good": true,
		"desc": "il doppio dei grappoli di gemme", "gen": {"gems": 2.0}},
	"iridescente": {"cat": "stirpi", "name": "Iridescente", "rar": 1, "dom": 2, "good": true,
		"desc": "creature rare molto più frequenti", "run": {"rare": 2.0}},
	"fertile": {"cat": "flora", "name": "Fertile", "rar": 0, "dom": 3, "good": true,
		"desc": "le colture crescono il 60% più in fretta", "run": {"grow": 1.6}},
	"stellato": {"cat": "cielo", "name": "Stellato", "rar": 1, "dom": 2, "good": true,
		"desc": "eventi del cielo molto più frequenti", "run": {"events": 2.2}},
	"brulicante": {"cat": "fauna", "name": "Brulicante", "rar": 0, "dom": 3, "good": false,
		"desc": "più creature e più forti, ma il doppio dei Lumini", "run": {"danger": 1.0, "lumini": 2.0}},
	# voce 56: geni che cambiano quali famiglie vivono nel mondo (`FamiliesData` role)
	"pascoli": {"cat": "fauna", "name": "Pascoli", "rar": 0, "dom": 3, "good": true,
		"desc": "mandrie di erbivori ovunque", "run": {"roles": {"erbivoro": 3.0}}},
	"cacciatori": {"cat": "fauna", "name": "Cacciatori", "rar": 1, "dom": 2, "good": false,
		"desc": "predatori affamati, molti di più", "run": {"roles": {"predatore": 2.5}, "danger": 0.2}},
	"alveari": {"cat": "fauna", "name": "Alveari", "rar": 1, "dom": 2, "good": true,
		"desc": "colonie di api e formiche", "run": {"roles": {"colonia": 3.0}}},
	"quieto": {"cat": "fauna", "name": "Quieto", "rar": 0, "dom": 2, "good": true,
		"desc": "meno creature, e meno Lumini", "run": {"danger": -0.6, "lumini": 0.7}},
	"notti_lunghe": {"cat": "tempo", "name": "Notti lunghe", "rar": 0, "dom": 3, "good": false,
		"desc": "la notte dura molto di più", "run": {"night": 0.08}},
	"avvizzito": {"cat": "ombra", "name": "Avvizzito", "rar": 0, "dom": 4, "good": false,
		"desc": "l'Avvizzimento si allarga il doppio più in fretta, da più macchie", "gen": {"blight_zones": 2.0},
		"run": {"blight": 2.0, "danger": 0.3}},
	# --- voce 43: i geni del generatore -----------------------------------------------------------------------------
	# forma
	"pianure": {"cat": "forma", "name": "Pianure", "rar": 0, "dom": 2, "good": true,
		"desc": "colline basse e orizzonti lunghi", "gen": {"hills": 0.35}},
	"montagne": {"cat": "forma", "name": "Montagne", "rar": 1, "dom": 3, "good": true,
		"desc": "montagne alte e valli profonde", "gen": {"hills": 2.2}},
	"altopiano": {"cat": "forma", "name": "Altopiano", "rar": 0, "dom": 2, "good": true,
		"desc": "la terra più alta: cielo basso e sottosuolo profondissimo", "gen": {"surface": -0.05}},
	"conca": {"cat": "forma", "name": "Conca", "rar": 0, "dom": 2, "good": true,
		"desc": "la terra più bassa: un cielo immenso", "gen": {"surface": 0.035}},
	"frastagliato": {"cat": "forma", "name": "Frastagliato", "rar": 2, "dom": 1, "good": true, "vmin": 3,
		"desc": "rupi, picchi e salti di roccia", "gen": {"rough": 6.0, "hills": 1.3}},
	# grotte
	"cavo": {"cat": "grotte", "name": "Cavo", "rar": 0, "dom": 3, "good": true,
		"desc": "grotte ovunque, grandi e piccole", "gen": {"room": -0.07, "worm": 1.3}},
	"compatto": {"cat": "grotte", "name": "Compatto", "rar": 0, "dom": 2, "good": false,
		"desc": "roccia piena: poche grotte, tutto da scavare", "gen": {"room": 0.1, "worm": 0.55}},
	"gallerie": {"cat": "grotte", "name": "Gallerie", "rar": 1, "dom": 2, "good": true,
		"desc": "gallerie larghe che corrono per tutto il mondo", "gen": {"worm": 2.1, "room": 0.06}},
	"alveare": {"cat": "grotte", "name": "Alveare", "rar": 1, "dom": 1, "good": true,
		"desc": "grotte a celle, una accanto all'altra come in un alveare", "gen": {"comb": true, "room": 0.05}},
	"voragini": {"cat": "grotte", "name": "Voragini", "rar": 1, "dom": 2, "good": true,
		"desc": "pozzi che scendono dalla superficie fino al profondo", "gen": {"shafts": 9.0}},
	"abissale": {"cat": "grotte", "name": "Abissale", "rar": 2, "dom": 1, "good": true, "vmin": 3,
		"desc": "caverne immense sotto le Caverne d'ardesia", "gen": {"big": -0.28}},
	# sottosuolo
	"fungaie": {"cat": "sottosuolo", "name": "Fungaie", "rar": 1, "dom": 2, "good": true,
		"desc": "sale di funghi giganti nel Sottobosco di radici", "gen": {"under": ["fungaie"]}},
	"geodi_brina": {"cat": "sottosuolo", "name": "Geodi di brina", "rar": 1, "dom": 2, "good": true,
		"desc": "grotte tonde di cristallo e ghiaccio nelle Caverne d'ardesia", "gen": {"under": ["geodi_brina"]}},
	"fiumi_brace": {"cat": "sottosuolo", "name": "Fiumi di brace", "rar": 1, "dom": 2, "good": true, "vmin": 2,
		"desc": "lunghe gallerie di cenere viva e tizzonite nel profondo", "gen": {"under": ["fiumi_brace"]}},
	"radici_giganti": {"cat": "sottosuolo", "name": "Radici giganti", "rar": 0, "dom": 3, "good": true,
		"desc": "il Sottobosco attraversato da radici enormi", "gen": {"roots": 2.5}},
	"laghi_linfa": {"cat": "sottosuolo", "name": "Laghi di Linfa", "rar": 2, "dom": 1, "good": true, "vmin": 3,
		"desc": "caverne con laghi di Linfa rappresa in cristallo", "gen": {"under": ["laghi_linfa"]}},
	# minerali
	"vene_affioranti": {"cat": "minerali", "name": "Vene affioranti", "rar": 1, "dom": 2, "good": true,
		"desc": "i minerali affiorano più vicini alla superficie", "gen": {"shallow": 0.45}},
	"radicite_diffusa": {"cat": "minerali", "name": "Radicite diffusa", "rar": 0, "dom": 2, "good": true,
		"desc": "radicite e pallidite ovunque", "gen": {"ore_boost": {TileDefs.RADICITE: 0.07, TileDefs.PALLIDITE: 0.05}}},
	"metalli_nobili": {"cat": "minerali", "name": "Metalli nobili", "rar": 2, "dom": 1, "good": true, "vmin": 3,
		"desc": "legnoferro, ambra e tizzonite in abbondanza",
		"gen": {"ore_boost": {TileDefs.LEGNOFERRO: 0.04, TileDefs.AMBRA: 0.06, TileDefs.TIZZONITE: 0.06}}},
	# gemme
	"geodi_fitti": {"cat": "gemme", "name": "Geodi fitti", "rar": 1, "dom": 2, "good": true,
		"desc": "il triplo dei geodi nascosti nella roccia", "gen": {"geodes": 3.0}},
	"cristalli_giganti": {"cat": "gemme", "name": "Cristalli giganti", "rar": 2, "dom": 1, "good": true, "vmin": 3,
		"desc": "banchi di cristallo di Linfa nel profondo", "gen": {"crystal": 0.14}},
	# rovine
	"rovine_sepolte": {"cat": "rovine", "name": "Rovine sepolte", "rar": 2, "dom": 1, "good": true, "vmin": 3,
		"desc": "più rovine, con scrigni molto più ricchi", "gen": {"ruins": 1.25, "rich": 2.0}},
	# stirpi
	"ancestrale": {"cat": "stirpi", "name": "Ancestrale", "rar": 2, "dom": 1, "good": true, "vmin": 3,
		"desc": "creature rare più frequenti e più forti, con più Lumini", "run": {"rare": 1.5, "danger": 0.4, "lumini": 1.4}},
	# flora
	"rigoglioso": {"cat": "flora", "name": "Rigoglioso", "rar": 0, "dom": 3, "good": true,
		"desc": "boschi fitti, il doppio degli alberi", "gen": {"trees": 1.9}},
	"spoglio": {"cat": "flora", "name": "Spoglio", "rar": 0, "dom": 2, "good": false,
		"desc": "pochi alberi: il legno è prezioso", "gen": {"trees": 0.25}},
	# tempo
	"giorni_lunghi": {"cat": "tempo", "name": "Giorni lunghi", "rar": 0, "dom": 2, "good": true,
		"desc": "il giorno dura di più, la notte è breve", "run": {"night": -0.05}},
	# ombra
	"sano": {"cat": "ombra", "name": "Sano", "rar": 1, "dom": 2, "good": true,
		"desc": "nessuna macchia di Avvizzimento", "gen": {"blight_zones": -9.0}, "run": {"blight": 0.0}},
	# --- voce 48: i geni rari. Solo per mutazione (innestando, o nei Semi selvatici) ------------------------------
	"mosaico": {"cat": "superficie", "name": "Mosaico", "rar": 2, "dom": 1, "good": true, "only": "mutazione",
		"desc": "tutti i biomi, a tratti brevi uno accanto all'altro", "item": "seme_mondo_mosaico",
		"gen": {"biomes": {"foresta": 1, "palude": 1, "ambra": 1, "brina": 1, "cenere": 1}, "mosaic": true}},
	"isole_sospese": {"cat": "forma", "name": "Isole sospese", "rar": 3, "dom": 1, "good": true, "only": "mutazione",
		"desc": "isole di terra e alberi che galleggiano nel cielo, alcune con uno scrigno", "gen": {"islands": 9.0}},
	"cuore_cavo": {"cat": "sottosuolo", "name": "Cuore cavo", "rar": 3, "dom": 1, "good": true, "only": "mutazione",
		"desc": "una caverna immensa nel Fondo, con il pavimento di cristallo", "gen": {"under": ["cuore_cavo"]}},
	"citta_sepolta": {"cat": "rovine", "name": "Città sepolta", "rar": 3, "dom": 1, "good": true, "only": "mutazione",
		"desc": "una città dei Seminatori: molte stanze collegate, ognuna con il suo scrigno", "gen": {"city": true}},
	"aurora": {"cat": "tempo", "name": "Aurora", "rar": 3, "dom": 1, "good": true, "only": "mutazione",
		"desc": "le notti sono chiare: la luce non scende mai del tutto", "run": {"aurora": 0.35}},
	"cuore_nero": {"cat": "ombra", "name": "Cuore nero", "rar": 2, "dom": 4, "good": false, "only": "mutazione",
		"combo": ["avvizzito", "notti_lunghe"],       # voce 69: la via del Seme Nero lo insegna
		"desc": "l'Avvizzimento ovunque e creature rare e feroci, con molti Lumini", "gen": {"blight_zones": 5.0},
		"run": {"blight": 2.5, "danger": 0.8, "rare": 2.0, "lumini": 1.5}},
	# voce 75: il tempo atmosferico
	"piovoso": {"cat": "cielo", "name": "Piovoso", "rar": 0, "dom": 2, "good": true,
		"desc": "piove spesso: pozze, orti rigogliosi e temporali", "run": {"rain": 3.0}},
	"ventoso": {"cat": "cielo", "name": "Ventoso", "rar": 1, "dom": 2, "good": true,
		"desc": "vento forte: si plana lontano, e i dardi volano storti", "run": {"wind": 1.8}},
	"nebbioso": {"cat": "tempo", "name": "Nebbioso", "rar": 0, "dom": 2, "good": true,
		"desc": "nebbie frequenti: si vede poco, e le creature vedono meno", "run": {"fog": 3.0}},
	# voce 73: l'acqua
	"sommerso": {"cat": "forma", "name": "Sommerso", "rar": 2, "dom": 2, "good": true, "vmin": 2,
		"desc": "un mare copre quasi tutto il mondo: isole, conche allagate, creature d'acqua", "gen": {"sea": true}},
	"sorgenti": {"cat": "grotte", "name": "Sorgenti", "rar": 0, "dom": 2, "good": true,
		"desc": "tante conche d'acqua nelle grotte", "gen": {"pools": 3.0}},
	# combinazioni segrete: nascono per mutazione, molto più spesso se i genitori portano i due geni indicati
	"vene_stellari": {"cat": "minerali", "name": "Vene stellari", "rar": 3, "dom": 1, "good": true, "combo": ["vene_ricche", "stellato"],
		"only": "mutazione", "desc": "vene ricchissime e stelle che cadono spesso", "gen": {"ore": 0.05}, "run": {"events": 1.8}},
	"fioritura_eterna": {"cat": "flora", "name": "Fioritura eterna", "rar": 2, "dom": 2, "good": true, "combo": ["fertile", "rigoglioso"],
		"only": "mutazione", "desc": "colture tre volte più svelte e boschi fitti", "gen": {"trees": 1.5}, "run": {"grow": 3.0}},
	# un gene raro ma che si trova, nei mondi profondi
	"eclissi": {"cat": "cielo", "name": "Eclissi", "rar": 2, "dom": 2, "good": false, "vmin": 4,
		"desc": "notti lunghe, eventi e creature rare più frequenti", "run": {"night": 0.12, "events": 1.5, "rare": 1.5}},
	# solo dalla firma di certi mondi (la Provetta vicino alla firma)
	"eco_seminatori": {"cat": "rovine", "name": "Eco dei Seminatori", "rar": 3, "dom": 2, "good": true, "only": "firma",
		"desc": "rovine ovunque, con gli scrigni più ricchi", "gen": {"ruins": 1.8, "rich": 3.0}},
	"cuore_stellare": {"cat": "cielo", "name": "Cuore stellare", "rar": 3, "dom": 2, "good": true, "only": "firma",
		"desc": "il cielo è sempre in festa: eventi continui e creature rare", "run": {"events": 3.0, "rare": 1.3}},
	"radice_madre": {"cat": "sottosuolo", "name": "Radice madre", "rar": 3, "dom": 2, "good": true, "only": "firma",
		"desc": "fungaie e laghi di Linfa insieme, e radici enormi", "gen": {"under": ["fungaie", "laghi_linfa"], "roots": 3.0}},
}

## Voce 46: le Fiale, una per gene (oggetti generati da `items()`, uniti in `ItemsData.all()`), con il colore della
## categoria nell'icona; e la Provetta di Linfa che le riempie (`Sampling`).
const VIAL_MAT := {"superficie": "muschio", "forma": "humus", "grotte": "ardesia", "sottosuolo": "fungo",
	"minerali": "radicite", "gemme": "brillaluce", "rovine": "sem", "fauna": "brace", "stirpi": "iride", "flora": "linfa",
	"cielo": "lagunite", "tempo": "nottilite", "ombra": "nodo"}
const VIAL_PREFIX := "fiala_"
static var _items := {}


static func vial_of(g: String) -> String:
	return VIAL_PREFIX + g


## Il gene di una Fiala ("" se l'oggetto non è una Fiala).
static func gene_of_vial(id: String) -> String:
	if not id.begins_with(VIAL_PREFIX):
		return ""
	var g := id.trim_prefix(VIAL_PREFIX)
	return g if GENES.has(g) else ""


static func items() -> Dictionary:
	if not _items.is_empty():
		return _items
	_items["provetta"] = {"name": "Provetta di Linfa", "kind": "provetta", "icon": ["pozione", "cristallo"], "stack": 30,
		"desc": "Una provetta di vetro con una goccia di Linfa sul fondo. Con il clic su ciò che porta un gene del mondo (l'erba, l'aria delle grotte, una vena, la pietra dei Seminatori, un albero, il cielo…) si riempie: diventa la Fiala di quel gene, e il gene lo impari."}
	for g in GENES:
		var d: Dictionary = GENES[g]
		_items[vial_of(g)] = {"name": "Fiala di %s" % String(d["name"]).to_lower() if d["cat"] != "superficie" else "Fiala di %s" % d["name"],
			"kind": "fiala", "icon": ["pozione", VIAL_MAT[d["cat"]]], "stack": 20, "value": 30 + 40 * int(d["rar"]),
			"source": "con la Provetta di Linfa in un mondo che ha questo gene, dalle piante-seme, dalle creature e negli scrigni",
			"desc": "Il gene «%s» (%s, %s): %s. Averla fa imparare il gene; all'innesto dei Semi fissa questo gene nel Seme figlio." % [
				d["name"], String(CAT_INFO[d["cat"]]["name"]).to_lower(), RARITY[int(d["rar"])]["name"], d["desc"]]}
	return _items


## Quanti geni oltre la superficie ha un Seme trovato: uno, più uno ogni due punti di vigore, fino a `MAX_EXTRA`.
const MAX_EXTRA := 4


static func info(g: String) -> Dictionary:
	return GENES.get(g, {})


static func cat_of(g: String) -> String:
	return String(GENES.get(g, {}).get("cat", ""))


## I geni di una categoria.
static func of_cat(cat: String) -> Array:
	var out := []
	for g in GENES:
		if GENES[g]["cat"] == cat:
			out.append(g)
	return out


## Il gene di superficie portato da un oggetto Seme ("" se è un Seme generico).
static func of_item(item_id: String) -> String:
	for g in GENES:
		if String(GENES[g].get("item", "")) == item_id:
			return g
	return ""


## Il nome colorato di un gene, con il colore della rarità (o della prova, se non è un dono).
static func tag(g: String) -> String:
	var d := info(g)
	if d.is_empty():
		return "?"
	var col := String(RARITY[int(d["rar"])]["color"]) if d.get("good", true) else "#ff9a7a"
	return "[color=%s]%s[/color]" % [col, d["name"]]
