class_name BuildData
extends RefCounted
## I costrutti (voce 128, Roadmap 15 «Il mondo abitato»): i blocchi e le pareti da costruire, fatti come le armi, **forme
## × materiali**. Nel mondo un costrutto è una tessera sola (`TileDefs.COSTRUTTO`, o `COSTRUTTO_T` se lascia passare la
## luce) più un byte in `World.build` che dice quale: `kind = materiale × FORMS.size() + forma + 1` (0 = nessuno), così
## ci stanno 28 materiali. Le pareti costruite hanno i numeri da `WALL_BASE` in su (una per materiale). Il disegno è un
## atlante squadrato a parte (`BuildPainter`), una riga per costrutto: 200 blocchi non pesano sull'avvio come i
## 45 strati del terreno. Le proprietà dei materiali (voce 139) dicono quanto sono duri, quanto isolano, quanta luce
## lasciano passare e quanto sono belli (il comfort delle stanze, voce 142).

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
const MATERIALS := [
	{"id": "ardesia", "label": "ardesia", "pal": ["#3a4866", "#4c5e80", "#62779c", "#7a90b4", "#9cb0d0"], "icon": "ardesia",
		"raw": "ardesia", "n": 2, "hard": 0.45, "power": 0, "iso": 1, "luce": 0, "bello": 1},
	{"id": "lanterna", "label": "legno di lanterna", "pal": ["#4a3040", "#6a4a58", "#8a6474", "#aa8290", "#d0a8b4"], "icon": "legno",
		"raw": "legno", "n": 2, "hard": 0.3, "power": 0, "iso": 2, "luce": 0, "bello": 1},
	{"id": "ambra", "label": "ambra", "pal": ["#6a3a10", "#a8641a", "#d8962a", "#eec04a", "#fff0a8"], "icon": "ambra",
		"raw": "lingotto_ambra", "n": 1, "hard": 0.7, "power": 45, "iso": 1, "luce": 1, "bello": 3, "glow": true},
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


## Le ricette: ogni forma dal materiale grezzo (al Ceppo: la voce 139 le porta al Banco dello scalpellino), le pareti
## dal blocco grezzo.
static func recipes() -> Array:
	var out := []
	for e in kinds():
		var md := material_of(int(e["kind"]))
		var f: Dictionary = FORMS[(int(e["kind"]) - 1) % FORMS.size()]
		out.append({"out": String(e["id"]), "qty": int(f["qty"]), "in": {String(md["raw"]): int(md["n"])}, "station": STATION})
	for md in MATERIALS:
		out.append({"out": "parete_%s" % md["id"], "qty": 4, "in": {"costr_grezzo_%s" % md["id"]: 1}, "station": ""})
	return out


const STATION := "ceppo"


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
	return ", ".join(t)
