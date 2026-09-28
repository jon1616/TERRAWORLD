class_name ProjectsData
extends RefCounted
## I progetti dei Seminatori (voce 145, Roadmap 15): strutture scritte a mano come i luoghi della voce 70, che si
## trovano nelle rovine (gli scrigni: `LootData`, tabelle «rovina_N») e che, portati i materiali, nascono in un colpo
## (`BuilderTools.build_blueprint`: il progetto in mano, clic dove va l'angolo in alto a sinistra). Esplorare dà
## architettura.
## Legenda (una riga di caratteri per fila di tessere; lo spazio lascia la cella com'è):
##   #  mattoni dei Seminatori     =  lastre d'ardesia       o  levigato d'ambra      |  colonna dei Seminatori
##   ^  tegole di lanterna         v  vetrata di vetro       t  travi di lanterna     p  piastrelle di Linfa
##   .  aria con la parete dei Seminatori dietro            _  passerella            *  torcia
##   D  porta aperta (l'angolo in alto: la cella sotto è «.»)       F  fonte d'acqua (1×2)    A  armadio d'ardesia (2×2)
##   S  scaffale di Seminatori (2×2)   L  lanterna appesa d'ambra   V  vaso fiorito di lanterna
##   c  cristallo celeste levigato      k  vetrata di cristallo celeste (Roadmap 16: l'osservatorio)
## I materiali che servono li conta `needs`.

const BLOCK := {"#": ["mattoni", "seminatori"], "=": ["lastre", "ardesia"], "o": ["levigato", "ambra"],
	"|": ["colonna", "seminatori"], "^": ["tegole", "lanterna"], "v": ["vetrata", "vetro"], "t": ["travi", "lanterna"],
	"p": ["piastrelle", "linfa"], "c": ["levigato", "celeste"], "k": ["vetrata", "celeste"]}
const WALL_MAT := "seminatori"
const STATION := {"D": "porta_aperta", "F": "fonte_acqua", "A": "arredo_armadio_ardesia", "S": "arredo_scaffale_seminatori",
	"L": "arredo_lanterna_ambra", "V": "arredo_vaso_lanterna"}

const PROJECTS := {
	"ponte": {"name": "Il ponte dei Seminatori", "desc": "Un ponte di lastre su colonne, con due torce: per passare le voragini.",
		"grid": [
			"*                  *",
			"====================",
			" |       ||       | ",
			" |       ||       | ",
			" |       ||       | ",
		]},
	"torre": {"name": "La torre di vedetta", "desc": "Una torre stretta con i piani di passerelle e una lanterna in cima.",
		"grid": [
			" ^^^^^ ",
			"^^.L.^^",
			"#.....#",
			"v.....v",
			"#_____#",
			"#.....#",
			"v.....v",
			"#_____#",
			"#.....#",
			"#.....D",
			"#......",
			"=======",
		]},
	"serra": {"name": "La serra a cupola", "desc": "Una cupola di vetrate: dentro, con tre vasi o tre colture, è una serra.",
		"grid": [
			"   vvvvvv   ",
			"  vv....vv  ",
			" vv......vv ",
			"vv........vv",
			"#..V.V.V...D",
			"#...........",
			"============",
		]},
	"faro": {"name": "Il faro", "desc": "Una torre alta di pietra levigata con il fuoco in cima: si vede da lontano.",
		"grid": [
			" ooooo ",
			" o*.*o ",
			" o...o ",
			"ooo_ooo",
			" #...# ",
			" #...# ",
			" #___# ",
			" #...# ",
			" #...# ",
			" #___# ",
			" #...# ",
			" #...D ",
			" #.... ",
			"=======",
		]},
	"pozzo": {"name": "Il pozzo delle fonti", "desc": "Una vasca di piastrelle di Linfa con una fonte che la riempie: uno stagno per pescare.",
		"grid": [
			"|          |",
			"|    F     |",
			"|    .     |",
			"p          p",
			"p          p",
			"pppppppppppp",
		]},
	# Roadmap 16, voce 163: l'osservatorio del cielo (il generatore lo costruisce sulle isole alte, `PassOsservatori`)
	"osservatorio": {"name": "L'osservatorio delle stelle", "desc": "Una cupola di cristallo celeste su due colonne, aperta ai lati: da qui i Seminatori guardavano il cielo.",
		"grid": [
			"   kkkkk   ",
			"  kk.L.kk  ",
			" |.......| ",
			" |.......| ",
			"  .......  ",
			"  .......  ",
			"ccccccccccc",
		]},
	"sala_trofei": {"name": "La sala dei trofei", "desc": "Una sala di mattoni con gli scaffali e un armadio: mettici tre trofei.",
		"grid": [
			"^^^^^^^^^^^^^^",
			"#.L........L.#",
			"#............#",
			"#.S..S....A..D",
			"#.............",
			"==============",
		]},
}


static func item_of(id: String) -> String:
	return "progetto_" + id


static func items() -> Dictionary:
	var out := {}
	for id in PROJECTS:
		out[item_of(id)] = {"name": "Progetto: %s" % PROJECTS[id]["name"], "kind": "progetto_sem", "icon": ["mappa", "sem"],
			"stack": 1, "project": id, "source": "negli scrigni delle rovine dei Seminatori",
			"desc": "%s In mano: clic dove va l'angolo in alto a sinistra, se nella Bisaccia hai i materiali (la scheda li elenca)." % PROJECTS[id]["desc"]}
	return out


## Il costrutto di un carattere (0 = nessuno).
static func kind_of(ch: String) -> int:
	if not BLOCK.has(ch):
		return 0
	var fi := -1
	for i in BuildData.FORMS.size():
		if String(BuildData.FORMS[i]["id"]) == String(BLOCK[ch][0]):
			fi = i
	var mi := -1
	for i in BuildData.MATERIALS.size():
		if String(BuildData.MATERIALS[i]["id"]) == String(BLOCK[ch][1]):
			mi = i
	return mi * BuildData.FORMS.size() + fi + 1 if fi >= 0 and mi >= 0 else 0


static func wall_id() -> int:
	for i in BuildData.MATERIALS.size():
		if String(BuildData.MATERIALS[i]["id"]) == WALL_MAT:
			return BuildData.WALL_BASE + i
	return 0


## Che cosa serve: {oggetto: quanti}.
static func needs(id: String) -> Dictionary:
	var out := {}
	var grid: Array = PROJECTS[id]["grid"]
	for row in grid:
		for ch in String(row):
			var item := ""
			if BLOCK.has(ch):
				item = BuildData.item_of(kind_of(ch))
			elif ch == ".":
				item = "parete_" + WALL_MAT
			elif ch == "_":
				item = "passerella"
			elif ch == "*":
				item = "torcia"
			elif STATION.has(ch):
				item = String(StationsData.STATIONS[STATION[ch]]["item"])
			if item != "":
				out[item] = int(out.get(item, 0)) + 1
	return out


static func size_of(id: String) -> Vector2i:
	var grid: Array = PROJECTS[id]["grid"]
	var wmax := 0
	for row in grid:
		wmax = maxi(wmax, String(row).length())
	return Vector2i(wmax, grid.size())
