class_name FishingData
extends RefCounted
## Gli attrezzi della pesca (voce 121, Roadmap 14 «Le acque vive»). Le canne di metallo nascono dalla forma «canna» di
## `FormsData` × i materiali (`MaterialsData`): qui c'è la prima, di legno, per cominciare senza metallo, e le regole
## che dal materiale fanno i valori della canna.
##
## Valori di una canna (oggetto di tipo «canna»):
##   fish        la fortuna di pesca: alza la probabilità dei pesci più rari (`FishData.LUCK_BOOST`)
##   fish_speed  quanto dura l'attesa prima che un pesce abbocchi (× l'attesa di base; più basso = più svelto)
##   fish_liq    i liquidi in cui pesca: 0 acqua, 1 Linfa, 2 brace (`LiquidsData`)

## Voce 122: le esche (tipo «esca», campo `bait`: luck = fortuna in più, wait = × l'attesa). A ogni pesce preso si
## consuma la migliore che si ha nella Bisaccia; senza esche si pesca lo stesso, solo più piano e con meno fortuna.
## Gli accessori della pesca (campo `acc`, sommati da `GearEffects`): fish_luck (+ fortuna), fish_wait (× attesa),
## fish_size (taglie più grandi), fish_double (probabilità di due pesci), fish_any (la lenza regge ogni liquido).
const ITEMS := {
	"esca_humus": {"name": "Pallottola d'humus", "kind": "esca", "icon": ["gel", "humus"], "stack": 99,
		"bait": {"luck": 0.1, "wait": 0.9}, "desc": "Terra impastata con la gelatina: i pesci la annusano da lontano."},
	"esca_petali": {"name": "Esca di petali di lume", "kind": "esca", "icon": ["gel", "lucciola"], "stack": 99,
		"bait": {"luck": 0.25, "wait": 0.85}, "desc": "Brilla appena sotto il pelo dell'acqua: di notte non le resiste nessuno."},
	"esca_squama": {"name": "Esca di squama", "kind": "esca", "icon": ["gel", "cristallo"], "stack": 99,
		"bait": {"luck": 0.45, "wait": 0.8}, "desc": "Squame di lume sminuzzate nella Linfa: attira i pesci più grossi."},
	"esca_iridata": {"name": "Esca iridata", "kind": "esca", "icon": ["gel", "iride"], "stack": 99,
		"bait": {"luck": 0.9, "wait": 0.75}, "desc": "Cambia colore nell'acqua: i pesci rari la seguono ovunque."},
	"galleggiante_lume": {"name": "Galleggiante di lume", "kind": "accessorio", "icon": ["goccia", "lucciola"], "stack": 1,
		"acc": {"fish_wait": 0.8}, "desc": "Un galleggiante che brilla: i pesci arrivano prima a guardarlo (attesa −20%)."},
	"amo_ambra": {"name": "Amo d'ambra", "kind": "accessorio", "icon": ["aculeo", "ambra"], "stack": 1,
		"acc": {"fish_luck": 0.3}, "desc": "Un amo d'ambra dorata: i pesci rari abboccano più volentieri (fortuna di pesca +30%)."},
	"sacca_pescatore": {"name": "Sacca del pescatore", "kind": "accessorio", "icon": ["membrana", "seta"], "stack": 1,
		"acc": {"fish_size": 0.15, "fish_double": 0.1}, "desc": "Una sacca di seta sempre umida: pesci più grandi, e a volte due in una volta."},
	# ---- voce 123: che cosa danno i pesci
	"filetto": {"name": "Filetto di pesce", "kind": "materiale", "icon": ["foglia", "sanguinella"], "stack": 99,
		"desc": "Pulito da un pesce d'acqua. Nel Paiolo e nel Baccello ardente diventa un piatto."},
	"filetto_linfa": {"name": "Filetto di Linfa", "kind": "materiale", "icon": ["foglia", "linfa"], "stack": 99,
		"desc": "Da un pesce della Linfa: brilla ancora un poco."},
	"filetto_brace": {"name": "Filetto di brace", "kind": "materiale", "icon": ["foglia", "brace"], "stack": 99,
		"desc": "Da un pesce della brace: si cuoce da solo, se lo lasci al sole."},
	"filetto_pregiato": {"name": "Filetto pregiato", "kind": "materiale", "icon": ["foglia", "ambra"], "stack": 99,
		"desc": "Da un pesce raro o leggendario: il piatto del pescatore lo vuole."},
	"perla_stagno": {"name": "Perla di stagno", "kind": "materiale", "icon": ["gemma", "seta"], "stack": 99,
		"source": "pescando: a volte è attaccata alla lenza, e nelle casse pescate",
		"desc": "Rara: a volte è attaccata alla lenza insieme al pesce. Il Pescatore la paga bene."},
	"pesce_arrosto": {"name": "Pesce arrosto", "kind": "consumabile", "icon": ["tubero", "sanguinella"], "heal": 30,
		"boon": ["sazio", 300.0], "stack": 30, "desc": "Cura 30 Vita, e sazio per cinque minuti."},
	"zuppa_pesce": {"name": "Zuppa di pesce", "kind": "consumabile", "icon": ["ciotola", "lagunite"], "heal": 20,
		"boon": ["sazio", 900.0], "stack": 30, "desc": "Cura 20 Vita, e sazio per un quarto d'ora."},
	"guazzetto_linfa": {"name": "Guazzetto di Linfa", "kind": "consumabile", "icon": ["ciotola", "linfa"], "linfa": 10,
		"boon": ["vista", 600.0], "stack": 30, "desc": "Rende 10 Linfa, e per dieci minuti vedi un poco anche dove la luce non arriva."},
	"spiedo_ardente": {"name": "Spiedo ardente", "kind": "consumabile", "icon": ["tubero", "brace"], "heal": 15,
		"boon": ["vigore", 300.0], "stack": 30, "desc": "Cura 15 Vita, e per cinque minuti colpisci il 20% più forte."},
	"piatto_pescatore": {"name": "Piatto del pescatore", "kind": "consumabile", "icon": ["ciotola", "ambra"], "heal": 40,
		"boon": ["fortuna", 600.0], "stack": 30, "desc": "Cura 40 Vita, e per dieci minuti la fortuna ti accompagna."},
	"collana_perle": {"name": "Collana di perle di stagno", "kind": "amuleto", "icon": ["amuleto", "seta"], "stack": 1,
		"acc": {"luck": 0.05, "fish_luck": 0.15}, "desc": "Bella e un poco fortunata, anche con la canna."},
	# le casse che a volte abboccano al posto di un pesce (si aprono con un clic)
	"cassetta_alga": {"name": "Cassetta d'alga", "kind": "cassetta", "icon": ["cesta", "muschio"], "stack": 30, "crate": [1, 2],
		"source": "pescando negli stagni e nelle acque poco profonde, al posto di un pesce", "desc": "Pescata negli stagni e nelle acque poco profonde. Clic per aprirla."},
	"forziere_sommerso": {"name": "Forziere sommerso", "kind": "cassetta", "icon": ["scrigno", "ardesia"], "stack": 30, "crate": [3, 3],
		"source": "pescando nelle acque delle grotte, al posto di un pesce", "desc": "Pescato nelle acque delle grotte. Clic per aprirlo."},
	"scrigno_fondo": {"name": "Scrigno del Fondo", "kind": "cassetta", "icon": ["scrigno", "vuotite"], "stack": 30, "crate": [4, 4],
		"source": "pescando nel Fondo, nella Linfa o nella brace, al posto di un pesce", "desc": "Pescato nel profondo, nella Linfa o nella brace. Clic per aprirlo."},
	# i sei unici della serie «Tesori delle acque» (`UniqueSeriesData`): solo dalle casse pescate
	"canna_primo_pescatore": {"name": "Canna del primo pescatore", "kind": "canna", "icon": ["canna", "iride"], "unique": true,
		"stack": 1, "tier": 5, "fish": 1.2, "fish_speed": 0.55, "fish_liq": [0, 1, 2],
		"story": "Il primo Giardiniere pescava per ascoltare i mondi, non per mangiare.", "source": "nelle casse pescate"},
	"amo_luna": {"name": "Amo di luna", "kind": "accessorio", "icon": ["aculeo", "nottilite"], "unique": true, "stack": 1,
		"acc": {"fish_luck": 0.5, "fish_wait": 0.9}, "story": "Si dice che abbia preso la luna, una notte, e l'abbia lasciata andare.",
		"source": "nelle casse pescate"},
	"arpione_maree": {"name": "Arpione delle maree", "kind": "spada", "icon": ["lancia", "lagunite"], "form": "lancia", "unique": true,
		"stack": 1, "damage": 22, "speed": 2.2, "knockback": 2.5, "tier": 4, "effects": ["anfibio", "respiro_lungo"],
		"story": "Ha ancora il sale di un mare che nessuno ricorda.", "source": "nelle casse pescate"},
	"anello_marea": {"name": "Anello della marea", "kind": "anello", "icon": ["anello", "lagunite"], "unique": true, "stack": 1,
		"acc": {"respiro": 2.0, "fish_wait": 0.85}, "story": "Si stringe quando l'acqua sale, si allarga quando scende.",
		"source": "nelle casse pescate"},
	"mantello_squame": {"name": "Mantello di squame", "kind": "mantello", "icon": ["mantello", "cristallo"], "unique": true, "stack": 1,
		"defense": 6, "acc": {"respiro": 1.5, "run": 1.05}, "story": "Mille squame di mille pesci, cucite da qualcuno con molta pazienza.",
		"source": "nelle casse pescate"},
	"amuleto_perla_nera": {"name": "Amuleto della perla nera", "kind": "amuleto", "icon": ["amuleto", "vuotite"], "unique": true,
		"stack": 1, "acc": {"fish_double": 0.15, "luck": 0.1}, "story": "Una perla del Fondo: nera, e calda come un cuore.",
		"source": "nelle casse pescate"},
	"canna_radice": {"name": "Canna di radice", "kind": "canna", "icon": ["canna", "legno"], "stack": 1, "tier": 0,
		"fish": 0.0, "fish_speed": 1.15, "fish_liq": [0],
		"desc": "Un ramo di radice flessibile e un filo di gelatina: pesca nell'acqua. Clic su uno specchio d'acqua: la lenza parte, e quando un pesce abbocca sale da solo."},
}

const RECIPES := [
	{"out": "canna_radice", "qty": 1, "in": {"legno": 10, "gelatina": 3}, "station": "ceppo"},
	{"out": "esca_humus", "qty": 5, "in": {"humus": 3, "gelatina": 1}, "station": ""},
	{"out": "esca_petali", "qty": 5, "in": {"petali_lume": 2, "gelatina": 1}, "station": ""},
	{"out": "esca_squama", "qty": 5, "in": {"squama_lume": 1, "gelatina": 2}, "station": "ceppo"},
	{"out": "esca_iridata", "qty": 5, "in": {"polvere_iridata": 1, "gelatina": 2}, "station": "maglio"},
	{"out": "galleggiante_lume", "qty": 1, "in": {"squama_lume": 4, "legno": 2}, "station": "telaio"},
	{"out": "amo_ambra", "qty": 1, "in": {"lingotto_ambra": 2, "squama_lume": 2}, "station": "maglio"},
	{"out": "sacca_pescatore", "qty": 1, "in": {"seta_radice": 6, "gelatina": 4}, "station": "telaio"},
	{"out": "pesce_arrosto", "qty": 1, "in": {"filetto": 2}, "station": "baccello_ardente"},
	{"out": "zuppa_pesce", "qty": 1, "in": {"filetto": 3, "tubero_linfa": 1}, "station": "paiolo"},
	{"out": "guazzetto_linfa", "qty": 1, "in": {"filetto_linfa": 2, "filetto": 1}, "station": "paiolo"},
	{"out": "spiedo_ardente", "qty": 1, "in": {"filetto_brace": 2}, "station": "baccello_ardente"},
	{"out": "piatto_pescatore", "qty": 1, "in": {"filetto_pregiato": 1, "filetto": 2, "petali_lume": 1}, "station": "paiolo"},
	{"out": "collana_perle", "qty": 1, "in": {"perla_stagno": 3, "seta_radice": 2}, "station": "telaio"},
]

## Voce 125: ogni specchio si stanca se ci si pesca tanto (la sua «fatica» sale di 1 a pesce e scende di 1 ogni
## `TIRE_RECOVER` secondi, anche mentre non si gioca) e l'attesa si allunga di `TIRE_WAIT` per punto, fino a `TIRE_MAX`
## punti: la pesca resta un'attività, non una fabbrica.
const TIRE_WAIT := 0.15
const TIRE_MAX := 16.0                     # voce 187: era 10 (la pesca rendeva 4-8 volte la caccia)
const TIRE_RECOVER := 180.0

## Voce 123: una cassa al posto del pesce (probabilità di base, più la fortuna × `CRATE_LUCK`), una perla in più.
const CRATE := 0.03
const CRATE_LUCK := 0.02
const PEARL := 0.03
const UNIQUE_IN_CRATE := {"cassetta_alga": 0.02, "forziere_sommerso": 0.05, "scrigno_fondo": 0.1}

## Voce 122: il tempo. L'attesa si accorcia con la pioggia, i temporali, la nebbia, di notte e all'alba e al tramonto.
const WEATHER_WAIT := {"pioggia": 0.8, "temporale": 0.7, "nebbia": 0.9, "bufera": 1.2}
const NIGHT_WAIT := 0.9
const TWILIGHT_WAIT := 0.75                # quando la luce del giorno sale o scende


## I valori della forma «canna» di un materiale (chiamato da `FormsData.stats`): la fortuna cresce con il grado e con la
## risonanza; l'attesa cala con il grado; la Linfa vuole un materiale di Linfa o di luce (o che la conduca molto), la
## brace un materiale di brace o di grado 5 e oltre.
static func rod_stats(md: Dictionary) -> Dictionary:
	var tier := int(md.get("tier", 1))
	var el := String(md.get("elemento", ""))
	var liq := [0]
	if el.contains("linfa") or el.contains("luce") or int(md.get("conduzione", 0)) >= 12:
		liq.append(1)
	if el.contains("brace") or tier >= 5:
		liq.append(2)
	return {"fish": snappedf(0.15 * tier + 0.1 * int(md.get("risonanza", 0)), 0.01),
		"fish_speed": snappedf(maxf(1.0 - 0.07 * tier, 0.5), 0.01), "fish_liq": liq}


## I liquidi di una canna, in parole: «acqua, Linfa».
static func liquids_text(liq: Array) -> String:
	var out := []
	for t in liq:
		out.append(String(LiquidsData.TYPES[int(t)]["name"]).to_lower())
	return ", ".join(out)


## Il tempo, in parole, quando aiuta (per l'avviso del lancio): «pioggia, alba».
static func weather_wait(weather: String, night: bool, twilight: bool) -> float:
	var k := float(WEATHER_WAIT.get(weather, 1.0))
	if twilight:
		k *= TWILIGHT_WAIT
	elif night:
		k *= NIGHT_WAIT
	return k


## La migliore esca di una Bisaccia (la più fortunata): l'indice della casella, o -1.
static func best_bait(b: Bisaccia) -> int:
	var best := -1
	var bl := -1.0
	for i in b.slots.size():
		var id := b.id_at(i)
		if id == "":
			continue
		var bt: Dictionary = ItemsData.get_item(id).get("bait", {})
		if not bt.is_empty() and float(bt["luck"]) > bl:
			bl = float(bt["luck"])
			best = i
	return best


## Voce 123: pulire un pesce dà i filetti del suo liquido (i rari e i leggendari quelli pregiati). Una ricetta per pesce,
## fatta a mano, generata dai dati: un pesce nuovo ha la sua da solo.
static func fillet_recipes() -> Array:
	var out := []
	var fish := FishData.all()
	for id in fish:
		var f: Dictionary = fish[id]
		var r := String(f["rar"])
		var what: String = ["filetto", "filetto_linfa", "filetto_brace"][int(f.get("liq", 0))]
		var n := 1 if r == "comune" else 2
		if r in ["raro", "leggendario"]:
			what = "filetto_pregiato"
			n = 1 if r == "raro" else 3
		out.append({"out": what, "qty": n, "in": {String(id): 1}, "station": ""})
	return out


## Roadmap 46, voce 400: le casse da pesca dei biomi e dei gradi del mondo (campo «crates» dei pacchetti) e i premi del
## Pescatore a collezione delle gare vinte (campo «angler»: [{n, item}]).
static var CRATES: Array = BiomesData.pack_list("crates")
static var ANGLER_PRIZES: Array = BiomesData.pack_list("angler")
const BIOME_CRATE := 0.5                  # una cassa che abbocca in superficie: quella del bioma, una volta su due
const VIGOR_CRATE := 0.35                 # nei mondi dal vigore 4: quella del grado del mondo


## La cassa più ricca che si può pescare: quella del bioma (in superficie) o del grado del mondo, se tocca.
static func special_crate(ctx: Dictionary, vigor: int, rng: RandomNumberGenerator) -> String:
	if int(ctx["liq"]) == 0 and int(ctx["stratum"]) == 0 and rng.randf() < BIOME_CRATE:
		for e in CRATES:
			if String(e.get("biome", "")) == String(ctx.get("biome", "")):
				return String(e["id"])
	var best := ""
	for e in CRATES:
		if e.has("vigor") and vigor >= int(e["vigor"]):
			best = String(e["id"])
	if best != "" and rng.randf() < VIGOR_CRATE:
		return best
	return ""


## La cassa che abbocca in uno specchio: dalla profondità (strato) e dal liquido.
static func crate_for(ctx: Dictionary) -> String:
	if int(ctx["liq"]) > 0 or int(ctx["stratum"]) >= 4:
		return "scrigno_fondo"
	return "forziere_sommerso" if int(ctx["stratum"]) >= 2 else "cassetta_alga"

