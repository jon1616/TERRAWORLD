class_name FishData
extends RefCounted
## I pesci (voce 120, Roadmap 14 «Le acque vive»). Solo dati e le regole per sceglierli: quali pesci vivono in uno
## specchio (`pool`) e quale abbocca (`roll`). I pesci di superficie di ogni bioma stanno nel suo file (campo «fish» del
## pacchetto, vedi `BiomesData`): un bioma nuovo porta i suoi pesci. Qui quelli di tutti i mondi: sotto terra per strato,
## nella Linfa, nella brace, nel mare del gene Sommerso, e i leggendari.
##
## Campi di un pesce (tutti facoltativi tranne name, rar, size, color):
##   name, desc      nome e descrizione (anche per l'oggetto «pesce» che nasce da lui, con lo stesso id)
##   liq             il liquido: 0 acqua (se manca), 1 Linfa, 2 brace (`LiquidsData`)
##   strata          gli strati in cui vive (`StrataData`; se manca: solo la superficie)
##   biomes          i biomi di superficie (id di `BiomesData`) — vale solo in superficie
##   depth           la profondità minima dello specchio (righe di liquido)
##   big             il volume minimo dello specchio (celle piene): i pesci dei laghi grandi e del mare
##   time            "notte" o "giorno"
##   season          le stagioni (id di `SeasonsData`)
##   weather         i tempi (id di `WeatherData`)
##   gene            un gene che il mondo deve avere
##   rar             comune, non_comune, raro, leggendario (`RARITY`)
##   size            [min, max] in centimetri (la taglia si tira tra i due; i record stanno nell'Erbario)
##   color           il materiale che colora l'icona (`ItemIcons.MATERIALS`)

const RARITY := {
	"comune": {"name": "comune", "w": 100.0, "color": "#cfe8e2", "value": 4},
	"non_comune": {"name": "non comune", "w": 35.0, "color": "#8ef0a8", "value": 12},
	"raro": {"name": "raro", "w": 9.0, "color": "#8ec8ff", "value": 40},
	"leggendario": {"name": "leggendario", "w": 1.2, "color": "#ffd08a", "value": 200},
}
## Quanto conta la fortuna (canna, esca, accessori: voce 121-122) per ogni rarità: peso × (1 + fortuna × questo).
const LUCK_BOOST := {"comune": 0.0, "non_comune": 0.6, "raro": 1.5, "leggendario": 3.0}

const FISH := {
	# ---- superficie, in ogni bioma con l'acqua
	"pesce_avannotto": {"name": "Avannotto di muschio", "rar": "comune", "size": [4, 9], "color": "muschio",
		"desc": "Piccolo e verde come il muschio da cui sembra nato. Abbocca a tutto."},
	"pesce_carpa_lanterna": {"name": "Carpa-lanterna", "rar": "comune", "size": [20, 45], "color": "ambra",
		"desc": "Dorata e lenta, si ferma sotto gli alberi-lanterna a guardare i baccelli."},
	"pesce_lasca": {"name": "Lasca di radice", "rar": "non_comune", "size": [15, 30], "color": "legno", "depth": 3,
		"desc": "Il dorso ha i segni delle radici tra cui si nasconde."},
	"pesce_persico_lume": {"name": "Persico di lume", "rar": "raro", "size": [18, 35], "color": "lucciola", "time": "notte",
		"desc": "Di notte le sue pinne si accendono come lucciole."},
	# ---- Sottobosco di radici
	"pesce_radicola": {"name": "Radicola", "rar": "comune", "size": [10, 25], "color": "radice", "strata": [1],
		"desc": "Sottile come una radice bianca: vive nelle pozze tra le radici giganti."},
	"pesce_ghiozzo_humus": {"name": "Ghiozzo d'humus", "rar": "comune", "size": [6, 14], "color": "humus", "strata": [1],
		"desc": "Sta sul fondo, immobile, finché non gli passa davanti qualcosa da mangiare."},
	"pesce_luccio_radice": {"name": "Luccio di radice", "rar": "raro", "size": [40, 90], "color": "legno", "strata": [1],
		"depth": 3, "desc": "Il predatore delle acque sotterranee: denti come spine di rovo."},
	# ---- Caverne d'ardesia
	"pesce_cieco": {"name": "Pesce cieco d'ardesia", "rar": "comune", "size": [8, 20], "color": "ardesia", "strata": [2],
		"desc": "Non ha occhi: trova il cibo sentendo la pietra vibrare."},
	"pesce_gambero_scaglia": {"name": "Gambero di scaglia", "rar": "comune", "size": [5, 12], "color": "scisto", "strata": [2, 3],
		"desc": "Il guscio è fatto di scaglie d'ardesia: croccante, se si cuoce."},
	"pesce_anguilla_ardesia": {"name": "Anguilla d'ardesia", "rar": "non_comune", "size": [30, 70], "color": "ardesia",
		"strata": [2], "depth": 3, "desc": "Si infila nelle crepe della roccia sommersa."},
	"pesce_lanterna_grotte": {"name": "Pesce-lanterna delle grotte", "rar": "raro", "size": [12, 25], "color": "lucciola",
		"strata": [2, 3], "desc": "Porta davanti alla bocca una piccola luce per attirare le prede."},
	# ---- Profondità della Linfa (acqua)
	"pesce_cristallo": {"name": "Pesce di cristallo", "rar": "comune", "size": [10, 22], "color": "cristallo", "strata": [3],
		"desc": "Trasparente: si vede il cuore che batte, color Linfa."},
	"pesce_medusa_pallida": {"name": "Medusa pallida", "rar": "non_comune", "size": [15, 40], "color": "pallidite",
		"strata": [3], "desc": "Più che nuotare, galleggia. Non punge, ma è fredda."},
	"pesce_storione": {"name": "Storione delle profondità", "rar": "raro", "size": [60, 150], "color": "scisto", "strata": [3],
		"depth": 5, "desc": "Antico e corazzato: c'era prima delle grotte, dicono."},
	# ---- il Fondo (acqua)
	"pesce_vuoto": {"name": "Pesce del Vuoto", "rar": "raro", "size": [20, 45], "color": "vuotite", "strata": [4],
		"desc": "Nero come il Vuoto; se lo guardi a lungo sembra un buco nell'acqua."},
	# ---- Linfa
	"pesce_guizzo_linfa": {"name": "Guizzo di Linfa", "rar": "comune", "size": [6, 14], "color": "linfa", "liq": 1,
		"strata": [0, 1, 2, 3, 4], "desc": "Veloce e luminoso: la Linfa lo rende sempre sveglio."},
	"pesce_ondina": {"name": "Ondina di Linfa", "rar": "comune", "size": [10, 20], "color": "linfa", "liq": 1,
		"strata": [0, 1, 2, 3, 4], "desc": "Nuota a onde lente, e dove passa la Linfa brilla di più."},
	"pesce_nastro_linfa": {"name": "Nastro di Linfa", "rar": "non_comune", "size": [40, 90], "color": "linfa", "liq": 1,
		"strata": [3, 4], "desc": "Lungo e piatto come un nastro di seta."},
	"pesce_serpe_linfa": {"name": "Serpe di Linfa", "rar": "non_comune", "size": [30, 60], "color": "lagunite", "liq": 1,
		"strata": [3, 4], "depth": 3, "desc": "Parente delle anguille di Linfa, ma non morde."},
	"pesce_cuore_linfa": {"name": "Cuore di Linfa", "rar": "raro", "size": [15, 30], "color": "cristallo", "liq": 1,
		"strata": [3, 4], "desc": "Rotondo e pulsante: dentro ha una goccia di Linfa antica."},
	"pesce_linfa_antica": {"name": "Pesce della Linfa antica", "rar": "leggendario", "size": [80, 160], "color": "linfa",
		"liq": 1, "strata": [3, 4], "depth": 4, "desc": "Si dice che abbia bevuto la prima Linfa dell'Albero-Madre."},
	# ---- brace
	"pesce_tizzoncino": {"name": "Tizzoncino", "rar": "comune", "size": [6, 12], "color": "brace", "liq": 2,
		"strata": [0, 1, 2, 3, 4], "desc": "Una brace con la coda: scotta anche dopo pescato."},
	"pesce_scoria": {"name": "Pesce di scoria", "rar": "comune", "size": [10, 25], "color": "tizzonite", "liq": 2,
		"strata": [0, 1, 2, 3, 4], "desc": "Coperto di scorie nere: dentro è rovente."},
	"pesce_salamandrino": {"name": "Salamandrino di brace", "rar": "non_comune", "size": [15, 30], "color": "brace", "liq": 2,
		"strata": [3, 4], "desc": "Ha quattro zampette: nuota nella brace come nell'acqua."},
	"pesce_carpa_fuoco": {"name": "Carpa di fuoco", "rar": "raro", "size": [30, 60], "color": "brace", "liq": 2,
		"strata": [4], "depth": 3, "desc": "Le squame sono fiamme ferme."},
	"pesce_occhio_magma": {"name": "Occhio di magma", "rar": "raro", "size": [20, 40], "color": "tizzonite", "liq": 2,
		"strata": [4], "time": "notte", "desc": "Un solo occhio enorme, che non si chiude mai."},
	"pesce_cuore_fondo": {"name": "Cuore del Fondo", "rar": "leggendario", "size": [90, 200], "color": "brace", "liq": 2,
		"strata": [4], "depth": 4, "desc": "Il calore del Fondo nasce da lui, raccontano i Seminatori."},
	# ---- il mare del gene Sommerso
	"pesce_sgombro": {"name": "Sgombro dei mari sommersi", "rar": "comune", "size": [20, 40], "color": "lagunite", "big": 400.0,
		"gene": "sommerso", "desc": "A branchi di mille, sotto la superficie del mare."},
	"pesce_razza": {"name": "Razza velata", "rar": "non_comune", "size": [60, 140], "color": "seta", "big": 400.0,
		"gene": "sommerso", "depth": 5, "desc": "Scivola sul fondo come un velo steso."},
	"pesce_spada_onda": {"name": "Spada d'onda", "rar": "raro", "size": [100, 200], "color": "cristallo", "big": 400.0,
		"gene": "sommerso", "depth": 6, "desc": "Taglia le onde col suo naso d'argento."},
	"pesce_custode_maree": {"name": "Custode delle maree", "rar": "leggendario", "size": [300, 600], "color": "lagunite",
		"big": 400.0, "gene": "sommerso", "depth": 8, "desc": "Quando si gira, il mare sale."},
	# ---- leggendari di tutti i mondi
	"pesce_primo": {"name": "Il Primo Pesce", "rar": "leggendario", "size": [50, 90], "color": "iride", "weather": ["temporale"],
		"time": "notte", "desc": "Abbocca solo nelle notti di temporale. Nessuno sa da quale mondo venga."},
	"pesce_eclissi": {"name": "Pesce d'eclissi", "rar": "leggendario", "size": [30, 60], "color": "nottilite", "gene": "eclissi",
		"strata": [0, 1, 2, 3, 4], "desc": "Nei mondi delle eclissi: metà luce, metà ombra."},
}


static var _all := {}


## Tutti i pesci: questi e quelli dei biomi.
static func all() -> Dictionary:
	if _all.is_empty():
		_all = FISH.duplicate(true)
		_all.merge(BiomesData.pack("fish").duplicate(true))
	return _all


static func info(id: String) -> Dictionary:
	return all().get(id, {})


## Gli oggetti che nascono dai pesci (stesso id): uniti a `ItemsData.all()`.
static func items() -> Dictionary:
	var out := {}
	for id in all():
		var f: Dictionary = all()[id]
		out[id] = {"name": String(f["name"]), "kind": "pesce", "icon": ["pesce", String(f["color"])], "stack": 99,
			"rar": String(f["rar"]), "desc": String(f.get("desc", "")), "source": "si pesca: %s" % where(id)}
	return out


## Il pesce può vivere qui? ctx = {liq, stratum, biome (id), depth, volume, night, season (id), weather (id), genes}.
static func fits(f: Dictionary, ctx: Dictionary) -> bool:
	if int(f.get("liq", 0)) != int(ctx["liq"]):
		return false
	var st: Array = f.get("strata", [0])
	if not int(ctx["stratum"]) in st:
		return false
	if f.has("biomes") and int(ctx["stratum"]) == 0 and not String(ctx["biome"]) in (f["biomes"] as Array):
		return false
	if int(ctx["depth"]) < int(f.get("depth", 1)) or float(ctx["volume"]) < float(f.get("big", 0.0)):
		return false
	if f.has("time") and (String(f["time"]) == "notte") != bool(ctx["night"]):
		return false
	if f.has("season") and not String(ctx.get("season", "")) in (f["season"] as Array):
		return false
	if f.has("weather") and not String(ctx.get("weather", "")) in (f["weather"] as Array):
		return false
	if f.has("gene") and not String(f["gene"]) in (ctx.get("genes", []) as Array):
		return false
	return true


## I pesci di uno specchio, con il loro peso: [[id, peso], …]. `luck` (0 = niente) alza le rarità più alte.
static func pool(ctx: Dictionary, luck := 0.0) -> Array:
	var out := []
	for id in all():
		var f: Dictionary = all()[id]
		if fits(f, ctx):
			var r := String(f["rar"])
			out.append([id, float(RARITY[r]["w"]) * (1.0 + luck * float(LUCK_BOOST[r]))])
	return out


## Quale pesce abbocca ("" se lo specchio non ne ha).
static func roll(ctx: Dictionary, rng: RandomNumberGenerator, luck := 0.0) -> String:
	var p := pool(ctx, luck)
	var tot := 0.0
	for e in p:
		tot += float(e[1])
	if tot <= 0.0:
		return ""
	var r := rng.randf() * tot
	for e in p:
		r -= float(e[1])
		if r <= 0.0:
			return String(e[0])
	return String(p[-1][0])


## La taglia di un pesce pescato (centimetri): più spesso vicino al mezzo, di rado un gigante.
static func roll_size(id: String, rng: RandomNumberGenerator, bonus := 0.0) -> int:
	var s: Array = info(id)["size"]
	var t := clampf((rng.randf() + rng.randf()) / 2.0 + bonus, 0.0, 1.0)
	return roundi(lerpf(float(s[0]), float(s[1]), t))


## Dove e quando vive, in parole (Erbario, schede).
static func where(id: String) -> String:
	var f := info(id)
	var parts := ["nella %s" % LiquidsData.TYPES[int(f.get("liq", 0))]["name"].to_lower() if int(f.get("liq", 0)) > 0 else "nell'acqua"]
	var st := []
	for k in f.get("strata", [0]):
		st.append(String(StrataData.STRATA[int(k)]["name"]))
	parts.append(", ".join(st))
	if f.has("biomes"):
		var bs := []
		for b in f["biomes"]:
			var bd := BiomesData.by_id(String(b))
			bs.append(String(bd.get("name", b)))
		parts.append(", ".join(bs))
	if f.has("depth"):
		parts.append("acque profonde almeno %d" % int(f["depth"]))
	if f.has("big"):
		parts.append("solo nei laghi grandi e nel mare")
	if f.has("time"):
		parts.append("di %s" % f["time"])
	if f.has("season"):
		parts.append("in %s" % ", ".join(f["season"]))
	if f.has("weather"):
		var ws := []
		for wk in f["weather"]:
			ws.append(String(WeatherData.STATES.get(wk, {}).get("name", wk)).to_lower())
		parts.append("con %s" % ", ".join(ws))
	if f.has("gene"):
		parts.append("nei mondi con il gene %s" % GenesData.info(String(f["gene"])).get("name", f["gene"]))
	return " · ".join(parts)
