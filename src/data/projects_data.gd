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
##   Roadmap 19, le macchine (l'angolo in alto a sinistra): Y Foglia-lanterna (2×2)  M Mulino di semi (2×3)
##   O Otre di Linfa  P Lampada a baccello  Q Leva di radice
## Roadmap 19: due griglie in più, facoltative, della stessa misura: "vene" (r radice, l legnoferro, a ambra, c cristallo)
## e "fili" (t turchese, y ambra, k corallo, v viola); lo spazio non posa niente.
## Roadmap 22, voce 233, le **grandi opere** del Giardino: `opera` (l'id dell'opera: costruita, dona per sempre ciò che
## dice `WORKS`, solo nel Giardino) ed `extra` (materiali in più, da tutti i pilastri, oltre ai blocchi della griglia).
## I materiali che servono li conta `needs`.

const BLOCK := {"#": ["mattoni", "seminatori"], "=": ["lastre", "ardesia"], "o": ["levigato", "ambra"],
	"|": ["colonna", "seminatori"], "^": ["tegole", "lanterna"], "v": ["vetrata", "vetro"], "t": ["travi", "lanterna"],
	"p": ["piastrelle", "linfa"], "c": ["levigato", "celeste"], "k": ["vetrata", "celeste"]}
const WALL_MAT := "seminatori"
const STATION := {"D": "porta_aperta", "F": "fonte_acqua", "A": "arredo_armadio_ardesia", "S": "arredo_scaffale_seminatori",
	"L": "arredo_lanterna_ambra", "V": "arredo_vaso_lanterna",
	"Y": "foglia_lanterna", "M": "mulino_semi", "O": "otre_linfa", "P": "lampada_baccello", "Q": "leva_radice"}
const VEIN := {"r": 1, "l": 2, "a": 3, "c": 4}
const WIRE := {"t": 0, "y": 1, "k": 2, "v": 3}

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
	# Roadmap 19, voce 210: i progetti della rete (le Centrali, la Tessitrice di vene)
	"centralina": {"name": "La centralina del Giardiniere", "desc": "Una casetta con due Foglie-lanterna sul tetto, un Otre, due Lampade e la Leva che le accende: una rete già posata.",
		"grid": [
			"Y     Y     ",
			"            ",
			"^^^^^^^^^^^^",
			"#..........#",
			"#..........D",
			"#.P..O.QP...",
			"============",
		],
		"vene": [
			"            ",
			"lllllll     ",
			"      l     ",
			"      l     ",
			"      l     ",
			"  lllllll   ",
		],
		"fili": [
			"            ",
			"            ",
			"            ",
			"            ",
			"            ",
			"  ttttttt   ",
		]},
	"torre_mulino": {"name": "La torre del mulino", "desc": "Un Mulino di semi in cima a una colonna, dove il vento è più forte, con la vena che scende a un Otre.",
		"grid": [
			"M   ",
			"    ",
			"    ",
			"====",
			" |  ",
			" |  ",
			" |O.",
			"====",
		],
		"vene": [
			"    ",
			"    ",
			"l   ",
			"l   ",
			"l   ",
			"l   ",
			"lll ",
		]},
	# Roadmap 22, voce 233: le grandi opere del Giardino
	"torre_albero": {"name": "La Torre dell'Albero", "opera": "torre", "desc": "Una torre di pietra dei Seminatori con le radici dell'Albero-Madre che la salgono: il Giardino può ospitare due Aiuole in più.",
		"extra": {"linfa_antica": 6, "frammento_albero": 2, "lingotto_ambra": 20, "perla_maree": 1},
		"grid": [
			"   ^^^^^   ",
			"  ^^.L.^^  ",
			"  |.....|  ",
			"  v.....v  ",
			"  |_____|  ",
			"  |.....|  ",
			"  v.....v  ",
			"  |_____|  ",
			"  |.....|  ",
			"  |.....D  ",
			"  |......  ",
			"ooooooooooo",
		]},
	"serra_grande": {"name": "La Serra grande", "opera": "serra", "desc": "Una cupola enorme di vetrate: tutte le colture del Giardino crescono il 25% più in fretta.",
		"extra": {"bacca_rovo": 20, "seme_campanula": 20, "lana_muschio": 20, "cuore_rovo": 1},
		"grid": [
			"     vvvvvvvv     ",
			"   vvv......vvv   ",
			"  vv..........vv  ",
			" vv............vv ",
			"vv..V..V..V..V..vv",
			"#................D",
			"#.................",
			"pppppppppppppppppp",
		]},
	"fontana_mondi": {"name": "La Fontana dei mondi", "opera": "fontana", "desc": "Una vasca di Linfa con l'acqua di ogni mondo: la Vita ricresce il 10% più in fretta, per sempre.",
		"extra": {"goccia_acqua_viva": 20, "cristallo_linfa": 15, "pesce_carpa_radice": 3, "spola_viva": 1},
		"grid": [
			"|.....F......|",
			"|............|",
			"pp....F.....pp",
			"pp..........pp",
			"pppppppppppppp",
		]},
	"arco_aiuole": {"name": "L'Arco delle Aiuole", "opera": "arco", "desc": "Un arco di radici e ambra sopra le Aiuole: ogni giorno arriva un visitatore, e un'Aiuola in più.",
		"extra": {"polvere_iridata": 6, "parola_prima": 1, "eco_parola": 12, "tavoletta_seminatori": 6},
		"grid": [
			"  ooooooooooo  ",
			" oo.........oo ",
			"oo...........oo",
			"|.............|",
			"|.............|",
			"|.............|",
			"|.............|",
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
	for it in PROJECTS[id].get("extra", {}):                 # voce 233: i materiali delle grandi opere
		out[String(it)] = int(out.get(String(it), 0)) + int(PROJECTS[id]["extra"][it])
	for row in PROJECTS[id].get("vene", []):
		for ch in String(row):
			if VEIN.has(ch):
				var it := String(VeinsData.TIERS[int(VEIN[ch])]["item"])
				out[it] = int(out.get(it, 0)) + 1
	for row in PROJECTS[id].get("fili", []):
		for ch in String(row):
			if WIRE.has(ch):
				var it2 := String(VeinsData.WIRES[int(WIRE[ch])]["item"])
				out[it2] = int(out.get(it2, 0)) + 1
	return out


static func size_of(id: String) -> Vector2i:
	var grid: Array = PROJECTS[id]["grid"]
	var wmax := 0
	for row in grid:
		wmax = maxi(wmax, String(row).length())
	return Vector2i(wmax, grid.size())


## Voce 233: che cosa dona per sempre ogni grande opera (la legge chi serve: `Aiuole`, `Garden`, `GearEffects`, `Visitors`).
const WORKS := {
	"torre": {"aiuole": 2},
	"serra": {"grow": 1.25},
	"fontana": {"regen": 1.1},
	"arco": {"aiuole": 1, "visitors": true},
}


## Le grandi opere costruite dal personaggio (id dell'opera → dati di `WORKS`).
static func works_built(stats: Dictionary) -> Array:
	var out := []
	for k in WORKS:
		if int(stats.get("opera_" + k, 0)) == 1:
			out.append(WORKS[k])
	return out
