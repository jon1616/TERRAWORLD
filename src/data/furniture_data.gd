class_name FurnitureData
extends RefCounted
## Mobili e arredi in serie (voce 141, Roadmap 15): **forme × materiali** come le armi e i costrutti. Ogni combinazione
## è una stazione («arredo_<forma>_<materiale>», campo `arredo` = la forma) con il suo oggetto e la sua ricetta; il
## disegno lo fa `FurnitureSeriesArt` dalla tavolozza del materiale (`BuildData`). I letti della serie sono letti veri
## (rinascita, abitanti), gli armadi tengono gli oggetti, le lampade e i camini fanno luce. Una **serie completa** nella
## stessa stanza dà più comfort (voce 142, `serie`); la bellezza di un arredo = quella del materiale più la forma.
## Questo file legge solo costanti di `BuildData` (nessun giro di dipendenze).

## Le forme: nome («%s» = il materiale), misura, quanto materiale grezzo, l'ingrediente in più, luce, contenitore.
const FORMS := [
	{"id": "tavolo", "name": "Tavolo di %s", "size": [3, 1], "n": 4, "bello": 1},
	{"id": "sedia", "name": "Sedia di %s", "size": [1, 1], "n": 2, "bello": 0},
	{"id": "letto", "name": "Letto di %s", "size": [3, 1], "n": 4, "extra": ["seta_radice", 3], "bello": 1},
	{"id": "armadio", "name": "Armadio di %s", "size": [2, 2], "n": 6, "slots": 24, "bello": 1},
	{"id": "scaffale", "name": "Scaffale di %s", "size": [2, 2], "n": 4, "bello": 1},
	{"id": "lampada", "name": "Lampada di %s", "size": [1, 2], "n": 2, "extra": ["torcia", 2], "light": true, "bello": 1},
	{"id": "lanterna", "name": "Lanterna appesa di %s", "size": [1, 1], "n": 2, "extra": ["torcia", 1], "light": true, "bello": 1},
	{"id": "finestra", "name": "Finestra di %s", "size": [2, 2], "n": 2, "extra": ["vetro_resina", 2], "bello": 2},
	{"id": "tappeto", "name": "Tappeto orlato di %s", "size": [3, 1], "n": 1, "extra": ["seta_radice", 4], "bello": 2},
	{"id": "quadro", "name": "Quadro in cornice di %s", "size": [2, 2], "n": 2, "extra": ["seta_radice", 2], "bello": 3},
	{"id": "vaso", "name": "Vaso fiorito di %s", "size": [1, 1], "n": 2, "extra": ["humus", 3], "bello": 2},
	{"id": "camino", "name": "Camino di %s", "size": [2, 2], "n": 8, "extra": ["pietra_brace", 2], "light": true, "bello": 2},
]

## I materiali degli arredi (id di `BuildData.MATERIALS`), con il banco dove si fanno: i legni al Ceppo, il resto
## allo scalpellino.
const MATS := [["lanterna", "ceppo"], ["radice", "ceppo"], ["ardesia", "scalpellino"], ["ambra", "scalpellino"],
	["legnoferro", "scalpellino"], ["seminatori", "scalpellino"], ["linfa", "scalpellino"], ["stellare", "scalpellino"],
	["osso", "scalpellino"], ["chitina", "scalpellino"],               # voce 147: i materiali delle creature
	["celeste", "scalpellino"]]                                        # Roadmap 16: il cristallo celeste


static var _stations := {}


static func _mat(mid: String) -> Dictionary:
	for md in BuildData.MATERIALS:
		if String(md["id"]) == mid:
			return md
	return {}


static func id_of(form: String, mat: String) -> String:
	return "arredo_%s_%s" % [form, mat]


## Le stazioni degli arredi (le unisce `StationsData.STATIONS`).
static func stations() -> Dictionary:
	if _stations.is_empty():
		for mm in MATS:
			var md := _mat(String(mm[0]))
			var pal: Array = md["pal"]
			for f in FORMS:
				var e := {"name": String(f["name"]) % String(md["label"]), "size": f["size"], "item": id_of(String(f["id"]), String(md["id"])),
					"arredo": String(f["id"]), "mat": String(md["id"]), "bello": int(f["bello"]) + int(md.get("bello", 1))}
				if f.has("slots"):
					e["slots"] = int(f["slots"])
				if f.get("light", false):
					e["light"] = true
					e["light_color"] = Color(1.4, 1.0, 0.6) if String(f["id"]) != "camino" else Color(1.7, 0.8, 0.35)
					if md.get("glow", false):
						e["light_color"] = Color(String(pal[4])) * 1.5
				_stations[id_of(String(f["id"]), String(md["id"]))] = e
	return _stations


static func items() -> Dictionary:
	var out := {}
	for sid in stations():
		var st: Dictionary = _stations[sid]
		var md := _mat(String(st["mat"]))
		out[sid] = {"name": st["name"], "kind": "stazione", "icon": [_icon(String(st["arredo"])), String(md["icon"])], "place": sid,
			"stack": 99, "gen": true, "desc": "%s. Bellezza %d: nelle stanze dà comfort; la serie completa di un materiale nella stessa stanza ne dà di più." % [
				_use(String(st["arredo"])), int(st["bello"])]}
	return out


static func recipes() -> Array:
	var out := []
	for mm in MATS:
		var md := _mat(String(mm[0]))
		var metal := int(md.get("n", 2)) == 1
		for f in FORMS:
			var n := int(f["n"])
			if metal:
				n = maxi(1, n / 2)
			var ins := {String(md["raw"]): n}
			if f.has("extra"):
				ins[String(f["extra"][0])] = int(f["extra"][1])
			out.append({"out": id_of(String(f["id"]), String(md["id"])), "qty": 1, "in": ins, "station": String(mm[1])})
	return out


## Una serie completa di un materiale: tutte le forme (vedi `Rooms`).
static func series_of(station_ids: Array) -> Array:
	var forms_by_mat := {}
	for sid in station_ids:
		var st: Dictionary = stations().get(String(sid), {})
		if st.is_empty():
			continue
		if not forms_by_mat.has(st["mat"]):
			forms_by_mat[st["mat"]] = {}
		forms_by_mat[st["mat"]][st["arredo"]] = true
	var out := []
	for mat in forms_by_mat:
		if (forms_by_mat[mat] as Dictionary).size() >= SERIES_MIN:
			out.append(mat)
	return out


## Quante forme diverse dello stesso materiale fanno una serie (non servono tutte e dodici: basta una stanza vera).
const SERIES_MIN := 5


static func _icon(form: String) -> String:
	return {"tavolo": "tavolo", "sedia": "sedia", "letto": "letto", "armadio": "cassa", "scaffale": "cassa", "lampada": "lanterna",
		"lanterna": "lanterna", "finestra": "gemma", "tappeto": "seta", "quadro": "tavoletta", "vaso": "seme", "camino": "bomba"}.get(form, "cassa")


static func _use(form: String) -> String:
	return {"tavolo": "Un tavolo", "sedia": "Una sedia", "letto": "Un letto: clic destro, e rinasci qui; un abitante ci può dormire",
		"armadio": "Un armadio: tiene 24 oggetti", "scaffale": "Uno scaffale per esporre i trofei", "lampada": "Una lampada: fa luce",
		"lanterna": "Una lanterna da appendere: fa luce", "finestra": "Una finestra", "tappeto": "Un tappeto",
		"quadro": "Un quadro", "vaso": "Un vaso con una pianta", "camino": "Un camino: scalda e fa luce"}.get(form, "Un arredo")
