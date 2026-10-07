class_name BuildData
extends RefCounted
## I costrutti (voce 128, Roadmap 15 «Il mondo abitato»): i blocchi e le pareti da costruire, fatti come le armi, **forme
## × materiali**. Nel mondo un costrutto è una tessera sola (`TileDefs.COSTRUTTO`, o `COSTRUTTO_T` se lascia passare la
## luce) più un byte in `World.build` che dice quale: `kind = materiale × FORMS.size() + forma + 1` (0 = nessuno), così
## ci stanno 28 materiali. Le pareti costruite hanno i numeri da `WALL_BASE` in su (una per materiale). Il disegno è un
## atlante squadrato a parte (`BuildPainter`), una riga per costrutto: 200 blocchi non pesano sull'avvio come i
## 45 strati del terreno. Le proprietà dei materiali (voce 139) dicono quanto sono duri, quanto isolano, quanta luce
## lasciano passare e quanto sono belli (il comfort delle stanze, voce 142). Voce 139: 21 materiali (rocce degli
## strati, legno, metalli, cristalli, i materiali dei biomi); la voce 147 aggiunge quelli delle creature (al più 28:
## un costrutto sta in un byte).

## Le forme: nome, disegno (`BuildPainter`), quanti blocchi dà una ricetta, trasparente.
const FORMS := [
	{"id": "grezzo", "name": "Blocco grezzo di %s", "qty": 2},
	{"id": "mattoni", "name": "Mattoni di %s", "qty": 2},
	{"id": "lastre", "name": "Lastre di %s", "qty": 2},
	{"id": "levigato", "name": "%s levigato", "qty": 2, "cap": true},
	{"id": "colonna", "name": "Colonna di %s", "qty": 2},
	{"id": "travi", "name": "Travi di %s", "qty": 2},
	{"id": "tegole", "name": "Tegole di %s", "qty": 2},
	{"id": "piastrelle", "name": "Piastrelle di %s", "qty": 2},
	{"id": "vetrata", "name": "Vetrata di %s", "qty": 1, "clear": true},
]
## Le pareti costruite: `WALL_BASE + indice del materiale`.
const WALL_BASE := 64

## I materiali da costruzione. Proprietà (voce 139): hard (secondi di scavo col piccone di radicite), power (forza
## di piccone che serve e che le creature degli assedi devono superare), iso (isolamento, 0-3: i rigori della voce 93),
## luce (0 = la ferma, 1 = la lascia passare), bello (0-5: il comfort delle stanze), glow (fa luce), raw (l'ingrediente
## grezzo), n (quanti grezzi per ricetta), icon (la tavolozza di `ItemIcons`), pal (5 colori dal più scuro), label.
## Roadmap 47, voce 403: blast (le esplosioni non lo rompono, `Throwing.explode`), slow (le creature che ci camminano
## sopra vanno a questa velocità, `Creature`: le cere, le sete, l'argilla e il muschio sono appiccicosi).
const MATERIALS := [
	{"id": "ardesia", "label": "ardesia", "pal": ["#3a4866", "#4c5e80", "#62779c", "#7a90b4", "#9cb0d0"], "icon": "ardesia",
		"raw": "ardesia", "n": 2, "hard": 0.45, "power": 0, "iso": 1, "luce": 0, "bello": 1},
	{"id": "lanterna", "label": "legno di lanterna", "pal": ["#4a3040", "#6a4a58", "#8a6474", "#aa8290", "#d0a8b4"], "icon": "legno",
		"raw": "legno", "n": 2, "hard": 0.3, "power": 0, "iso": 2, "luce": 0, "bello": 1},
	{"id": "ambra", "label": "ambra", "pal": ["#6a3a10", "#a8641a", "#d8962a", "#eec04a", "#fff0a8"], "icon": "ambra",
		"raw": "lingotto_ambra", "n": 1, "hard": 0.7, "power": 45, "iso": 1, "luce": 1, "bello": 3, "glow": true},
	{"id": "radice", "label": "radice antica", "pal": ["#3a2a2a", "#553c38", "#70524a", "#8e6c5e", "#b08e7a"], "icon": "radice",
		"raw": "radice_antica", "n": 2, "hard": 0.55, "power": 0, "iso": 2, "luce": 0, "bello": 1},
	{"id": "scisto", "label": "scisto di Linfa", "pal": ["#1e3a40", "#2c5058", "#3e6a70", "#56888c", "#7cb0b0"], "icon": "scisto",
		"raw": "scisto", "n": 2, "hard": 0.5, "power": 0, "iso": 1, "luce": 0, "bello": 2},
	{"id": "vuotite", "label": "vuotite", "pal": ["#1a1428", "#2a2040", "#3c2e58", "#524078", "#7a64a8"], "icon": "vuotite",
		"raw": "vuotite", "n": 2, "hard": 0.8, "power": 45, "iso": 1, "luce": 0, "bello": 3, "blast": true},
	{"id": "brace", "label": "pietra di brace", "pal": ["#3a1a14", "#5a2618", "#823a1e", "#b05a28", "#e08a3a"], "icon": "brace",
		"raw": "pietra_brace", "n": 2, "hard": 0.6, "power": 35, "iso": 3, "luce": 0, "bello": 2, "glow": true},
	{"id": "seminatori", "label": "pietra dei Seminatori", "pal": ["#2c3a3a", "#40504e", "#586a66", "#768a84", "#a0b8ae"], "icon": "sem",
		"raw": "pietra_seminatori", "n": 2, "hard": 0.7, "power": 35, "iso": 1, "luce": 0, "bello": 4, "blast": true},
	{"id": "radicite", "label": "radicite", "pal": ["#4a2a1a", "#6e4028", "#965a38", "#bc7a4c", "#e0a070"], "icon": "radicite",
		"raw": "lingotto_radicite", "n": 1, "hard": 0.6, "power": 35, "iso": 0, "luce": 0, "bello": 2},
	{"id": "legnoferro", "label": "legnoferro", "pal": ["#303844", "#4a5666", "#6a7688", "#a2b0c2", "#dce6f2"], "icon": "legnoferro",
		"raw": "lingotto_legnoferro", "n": 1, "hard": 0.75, "power": 45, "iso": 0, "luce": 0, "bello": 2},
	{"id": "pallidite", "label": "pallidite", "pal": ["#4a4a5a", "#6c6c80", "#9090a8", "#b8b8cc", "#e4e4f0"], "icon": "pallidite",
		"raw": "lingotto_pallidite", "n": 1, "hard": 0.75, "power": 45, "iso": 1, "luce": 0, "bello": 3},
	{"id": "tizzonite", "label": "tizzonite", "pal": ["#3a1010", "#6a1c14", "#a0301c", "#d8582a", "#ffa050"], "icon": "tizzonite",
		"raw": "lingotto_tizzonite", "n": 1, "hard": 0.85, "power": 55, "iso": 1, "luce": 0, "bello": 3, "glow": true},
	{"id": "linfa", "label": "cristallo di Linfa", "pal": ["#0c3a3a", "#146060", "#1e8a88", "#3ab8b0", "#90f0e0"], "icon": "linfa",
		"raw": "cristallo_linfa", "n": 1, "hard": 0.8, "power": 55, "iso": 0, "luce": 1, "bello": 4, "glow": true},
	{"id": "stellare", "label": "metallo stellare", "pal": ["#1a1a3a", "#2e2e60", "#4a4a90", "#8080c8", "#e0e0ff"], "icon": "brillaluce",
		"raw": "lingotto_stellare", "n": 1, "hard": 0.9, "power": 55, "iso": 1, "luce": 0, "bello": 5, "glow": true, "blast": true},
	{"id": "vetro", "label": "vetro di sabbia", "pal": ["#5a7a80", "#7aa0a8", "#a0c8cc", "#c8e8ea", "#f0ffff"], "icon": "cristallo",
		"raw": "sabbia_fusa", "n": 1, "hard": 0.3, "power": 0, "iso": 0, "luce": 1, "bello": 3},
	{"id": "argilla", "label": "argilla del lago", "pal": ["#3e2c22", "#5a4030", "#765642", "#94705a", "#b89478"], "icon": "humus",
		"raw": "fango_lago", "n": 2, "hard": 0.35, "power": 0, "iso": 3, "luce": 0, "bello": 1, "slow": 0.5},
	{"id": "terra", "label": "terra battuta", "pal": ["#2e2226", "#44323a", "#5c4450", "#765a68", "#9a7a8a"], "icon": "humus",
		"raw": "humus", "n": 2, "hard": 0.3, "power": 0, "iso": 2, "luce": 0, "bello": 0},
	{"id": "catacomba", "label": "pietra di catacomba", "pal": ["#3a3630", "#54504a", "#706a62", "#8e887e", "#b4aea2"], "icon": "ardesia",
		"raw": "mattone_catacomba", "n": 1, "hard": 0.6, "power": 35, "iso": 1, "luce": 0, "bello": 3, "blast": true},
	{"id": "muschio", "label": "muschio antico", "pal": ["#12302a", "#1c4a3e", "#286656", "#3a8870", "#5cb094"], "icon": "muschio",
		"raw": "muschio_antico", "n": 1, "hard": 0.3, "power": 0, "iso": 2, "luce": 0, "bello": 3, "slow": 0.5},
	{"id": "ghiaccio", "label": "Linfa gelata", "pal": ["#3a6a80", "#5a8aa0", "#80b0c4", "#a8d4e4", "#e0f6ff"], "icon": "brina",
		"raw": "linfa_gelata", "n": 1, "hard": 0.35, "power": 0, "iso": 0, "luce": 1, "bello": 3},
	{"id": "cenere", "label": "cenere antica", "pal": ["#2a2a2c", "#3e3e42", "#56565a", "#727278", "#9a9aa0"], "icon": "cenere",
		"raw": "cenere_antica", "n": 2, "hard": 0.45, "power": 0, "iso": 2, "luce": 0, "bello": 1},
	# voce 147: i materiali delle creature
	{"id": "osso", "label": "osso levigato", "pal": ["#5a5448", "#8a8270", "#b8ae98", "#dcd4c0", "#f8f4e8"], "icon": "ardesia",
		"raw": "osso_antico_grezzo", "n": 1, "hard": 0.5, "power": 0, "iso": 1, "luce": 0, "bello": 3},
	{"id": "chitina", "label": "chitina", "pal": ["#1e2a1a", "#34462a", "#52683c", "#7a9254", "#b0c880"], "icon": "muschio",
		"raw": "chitina_grezza", "n": 1, "hard": 0.55, "power": 35, "iso": 1, "luce": 0, "bello": 2},
	{"id": "cera", "label": "cera di lume", "pal": ["#6a4a10", "#a0741a", "#d0a030", "#f0cc60", "#fff4b0"], "icon": "ambra",
		"raw": "miele_lume", "n": 1, "hard": 0.25, "power": 0, "iso": 2, "luce": 1, "bello": 3, "glow": true, "slow": 0.5},
	{"id": "seta", "label": "seta intrecciata", "pal": ["#6a6a60", "#9a9a8a", "#c8c8b8", "#e8e8dc", "#ffffff"], "icon": "seta",
		"raw": "seta_radice", "n": 2, "hard": 0.2, "power": 0, "iso": 3, "luce": 0, "bello": 2, "slow": 0.5},
	{"id": "squama", "label": "squame di salamandra", "pal": ["#3a1008", "#6a1c0c", "#a83414", "#e06a24", "#ffc070"], "icon": "brace",
		"raw": "squama_brace", "n": 1, "hard": 0.6, "power": 35, "iso": 3, "luce": 0, "bello": 3},
	{"id": "carapace", "label": "carapace di granchio", "pal": ["#1a2a30", "#2e4650", "#4a6a78", "#7aa0b0", "#c0e0e8"], "icon": "lagunite",
		"raw": "carapace_lago", "n": 1, "hard": 0.6, "power": 35, "iso": 1, "luce": 0, "bello": 2, "blast": true},
	# Roadmap 16, voce 159: il cielo (l'ultimo posto: 28 materiali × 9 forme stanno in un byte)
	{"id": "celeste", "label": "cristallo celeste", "pal": ["#1a3a5a", "#2a6090", "#4a90c8", "#8ac8f0", "#e0f6ff"], "icon": "celeste",
		"raw": "cristallo_celeste", "n": 1, "hard": 0.6, "power": 35, "iso": 0, "luce": 1, "bello": 5, "glow": true},
]


static var _kinds := []
static var _by_id := {}


## Tutti i costrutti: [{kind, form, mat, id, name, clear}] (l'indice + 1 è il numero salvato nel mondo).
static func kinds() -> Array:
	if _kinds.is_empty():
		for mi in MATERIALS.size():
			for fi in FORMS.size():
				var f: Dictionary = FORMS[fi]
				var md: Dictionary = MATERIALS[mi]
				var k := mi * FORMS.size() + fi + 1
				var nm := String(f["name"]) % String(md["label"])
				if f.get("cap", false):
					nm = nm.substr(0, 1).to_upper() + nm.substr(1)
				var e := {"kind": k, "form": String(f["id"]), "mat": String(md["id"]), "id": "costr_%s_%s" % [f["id"], md["id"]],
					"name": nm, "clear": f.get("clear", false) or int(md.get("luce", 0)) == 1}
				_kinds.append(e)
				_by_id[e["id"]] = e
	return _kinds


static func kind_info(k: int) -> Dictionary:
	var ks := kinds()
	return ks[k - 1] if k >= 1 and k <= ks.size() else {}


static func material_of(k: int) -> Dictionary:
	return MATERIALS[(k - 1) / FORMS.size()] if k >= 1 else {}


## La tessera che un costrutto mette nel mondo: opaca o trasparente.
static func tile_of(k: int) -> int:
	return TileDefs.COSTRUTTO_T if bool(kind_info(k).get("clear", false)) else TileDefs.COSTRUTTO


## Secondi di scavo, forza del piccone e l'oggetto che lascia.
static func hard(k: int) -> float:
	return float(material_of(k).get("hard", 0.4)) * (0.6 if String(kind_info(k).get("form", "")) == "vetrata" else 1.0)


static func power(k: int) -> int:
	return int(material_of(k).get("power", 0))


static func item_of(k: int) -> String:
	return String(kind_info(k).get("id", ""))


## Gli oggetti: un blocco per costrutto (tipo «blocco», campo `build`) e una parete per materiale (campo `wall`).
static func items() -> Dictionary:
	var out := {}
	for e in kinds():
		var md := material_of(int(e["kind"]))
		out[e["id"]] = {"name": String(e["name"]), "kind": "blocco", "build": int(e["kind"]), "place": tile_of(int(e["kind"])), "stack": 999,
			"icon": ["zolla" if e["form"] != "vetrata" else "gemma", String(md["icon"])], "gen": true,
			"desc": "Un blocco da costruzione: %s." % _props_text(md)}
	for mi in MATERIALS.size():
		var md: Dictionary = MATERIALS[mi]
		out["parete_%s" % md["id"]] = {"name": "Parete di %s" % md["label"], "kind": "parete", "wall": WALL_BASE + mi,
			"icon": ["parete", String(md["icon"])], "stack": 999, "gen": true,
			"desc": "Una parete di fondo di %s: chiude le stanze e ferma le creature che nascono al buio." % md["label"]}
	return out


## Le ricette: il blocco grezzo a mano, le altre forme al Banco dello scalpellino, dal materiale grezzo; le pareti
## dal blocco grezzo (a mano).
static func recipes() -> Array:
	var out := []
	for e in kinds():
		var md := material_of(int(e["kind"]))
		var f: Dictionary = FORMS[(int(e["kind"]) - 1) % FORMS.size()]
		var st := "" if String(f["id"]) == "grezzo" else STATION
		out.append({"out": String(e["id"]), "qty": int(f["qty"]), "in": {String(md["raw"]): int(md["n"])}, "station": st})
	for md in MATERIALS:
		out.append({"out": "parete_%s" % md["id"], "qty": 4, "in": {"costr_grezzo_%s" % md["id"]: 1}, "station": ""})
	return out


const STATION := "scalpellino"

## Il Banco dello scalpellino (voce 139): lavora ogni forma tranne il grezzo, che si fa a mano.
const STATION_ITEMS := {
	"scalpellino": {"name": "Banco dello scalpellino", "kind": "stazione", "icon": ["incudine", "ardesia"], "place": "scalpellino",
		"stack": 99, "desc": "Scalpelli, squadre e un piano di pietra: qui i materiali diventano mattoni, lastre, colonne, travi, tegole, piastrelle e vetrate."},
}
const STATION_RECIPES := [
	{"out": "scalpellino", "qty": 1, "in": {"legno": 12, "ardesia": 20, "lingotto_radicite": 2}, "station": "ceppo"},
]


static func _props_text(md: Dictionary) -> String:
	var t := []
	t.append("duro" if int(md.get("power", 0)) >= 40 else "resistente" if float(md.get("hard", 0.4)) >= 0.45 else "facile da lavorare")
	if int(md.get("iso", 0)) >= 2:
		t.append("isola dal freddo e dal caldo")
	if int(md.get("luce", 0)) == 1:
		t.append("lascia passare la luce")
	if md.get("glow", false):
		t.append("brilla appena")
	if int(md.get("bello", 0)) >= 3:
		t.append("bello da vedere")
	if md.get("blast", false):
		t.append("le esplosioni non lo rompono")
	if md.has("slow"):
		t.append("le creature ci camminano sopra lente")
	return ", ".join(t)


## Voce 403: le proprietà di un costrutto in una cella (k = il byte di `World.build`).
static func blast_proof(k: int) -> bool:
	return bool(material_of(k).get("blast", false))


static func slow_of(k: int) -> float:
	return float(material_of(k).get("slow", 1.0))

