class_name ArmorData
extends RefCounted
## Le armature e i set (Roadmap 44, voci 389-391; piano in `VASTITA.md`). Solo dati: li leggono `FormsData` (gli elmi
## degli stili), `SetsData` (i set degli stili e le abilità dei set), `EffectsData` (le righe delle abilità),
## `TraitsData` (le essenze della forgia) e `GearEffects`.
##
## Voce 389: **un elmo per stile** in ogni materiale puro (come in Terraria la testa cambia con lo stile): meno Scorza
## dell'elmo comune, ma il danno del suo stile più alto. Con la corazza e i gambali dello stesso materiale fa un **set
## dello stile**: il bonus del suo stile cresce ancora e arriva un'abilità dello stile.
## Voce 390: ogni set ha un'**abilità** (una riga di `EFFECTS`, con i «quando» del motore delle abilità): il set
## d'ambra stordisce chi ti ferisce, quello di nimbite chiama un fulmine quando salti, quello del Vuoto ti fa ombra
## ogni tanto dopo i colpi. Le leghe portano le abilità dei due metalli.
## Voce 391: le **essenze della forgia** (`ESSENCES`): tratti nuovi da innestare al Maglio sui pezzi d'armatura (che ora
## ne portano anche di rari dalla nascita, `TRAITS` con peso).

## Gli elmi degli stili: forma → [stile, nome, plurale, materiale in più della ricetta, descrizione].
const HELMS := {
	"celata": ["mischia", "Celata", false, {}, "chiusa e pesante: per chi combatte da vicino"],
	"cappuccio_mira": ["distanza", "Cappuccio da tiro", false, {"seta_radice": 3}, "tiene la vista sul bersaglio: per chi tira"],
	"tiara": ["linfa", "Diadema", false, {"cristallo_linfa": 2}, "una corona sottile che porta la Linfa: per gli incantesimi"],
	"maschera": ["evocazione", "Maschera del branco", false, {"seta_radice": 2}, "il volto di una bestia: gli alleati la seguono"],
	"benda": ["lancio", "Benda del lanciatore", false, {"seta_radice": 4}, "lascia libero lo sguardo: per dischi e girandole"],
	"ghirlanda": ["canto", "Ghirlanda", false, {"seta_radice": 2}, "foglie di metallo che vibrano: per chi suona"],
	"velo": ["cura", "Velo di rugiada", false, {"gelatina": 2}, "trattiene la Rugiada: per chi cura"],
	"cappello_radice": ["radice", "Cappello di radice", false, {"humus": 4}, "fa germogliare i semi: per chi pianta"],
}
const HELM_DEF := 0.8              # la Scorza dell'elmo di stile = tenacia × questo (l'elmo comune: × 1)
const HELM_BONUS := 0.06           # il bonus del suo stile: 1 + questo + HELM_STEP × grado del materiale
const HELM_STEP := 0.01
const SET_BONUS := 0.08            # il set dello stile: altrettanto in più, e un'abilità (`STYLE_FX`)
const SET_STEP := 0.008


## Il bonus del suo stile di un elmo (o di un set) di un materiale di quel grado.
static func helm_bonus(tier: int) -> float:
	return snappedf(1.0 + HELM_BONUS + HELM_STEP * tier, 0.001)


static func set_bonus(tier: int) -> float:
	return snappedf(1.0 + SET_BONUS + SET_STEP * tier, 0.001)


## La forma dell'elmo di uno stile.
static func helm_of(style: String) -> String:
	for f in HELMS:
		if HELMS[f][0] == style:
			return String(f)
	return ""


## Voce 390: l'abilità di ogni set di metallo, di materiale dei geni e di metallo del Risveglio.
const SET_FX := {
	"radicite": ["set_radicite"], "legnoferro": ["set_legnoferro"], "pallidite": ["set_pallidite"], "ambra": ["set_ambra"],
	"tizzonite": ["set_tizzonite"], "linfa": ["set_linfa"], "vuoto": ["set_vuoto"], "nimbite": ["set_nimbite"],
	"stellare": ["set_stellare"],
	"ferro_brina": ["set_ferro_brina"], "ossidiana_brace": ["set_ossidiana_brace"], "micelio_duro": ["set_micelio_duro"],
	"linfite": ["set_linfite"], "radicite_pura": ["set_radicite_pura"], "ambra_dorata": ["set_ambra_dorata"],
	"ferro_stellato": ["set_ferro_stellato"], "vuoto_cavo": ["set_vuoto_cavo"], "sospesite": ["set_sospesite"],
	"nerume": ["set_nerume"], "chitina": ["set_chitina"], "osso_antico": ["set_osso_antico"],
	"corallite": ["set_corallite"], "sanguinite": ["set_sanguinite"], "cuorelegno": ["set_cuorelegno"],
	"eterite": ["set_eterite"], "astrite": ["set_astrite"], "primambra": ["set_primambra"],
	# Roadmap 51: i metalli del dopo (abilità già scritte, più forti dei loro gemelli)
	"aurorite": ["set_stellare", "set_corallite"], "sognite": ["set_linfa", "set_eterite"],
	"abissite": ["set_vuoto", "set_ossidiana_brace"], "memorite": ["set_micelio_duro", "set_astrite"],
	"crepuscolite": ["set_tizzonite", "set_cuorelegno"], "seminite": ["set_ferro_brina", "set_primambra"],
	# i set scritti a mano di prima
	"seta": ["set_seta"], "seta_vuoto": ["set_seta_vuoto"], "scaglie": ["set_scaglie"], "cielo": ["set_cielo"],
}
## L'abilità dei set degli stili.
const STYLE_FX := {
	"mischia": "stile_mischia", "distanza": "stile_distanza", "linfa": "stile_linfa", "evocazione": "stile_evocazione",
	"lancio": "stile_lancio", "canto": "stile_canto", "cura": "stile_cura", "radice": "stile_radice",
}

## Le righe delle abilità (come quelle di `EffectsData`; le unisce `EffectsData.info`).
const EFFECTS := {
	# i metalli
	"set_radicite": {"name": "Radici salde", "when": "atterraggio", "da": 4.0, "do": "scossa", "r": 3.0, "t": 1.0, "cool": 4.0,
		"desc": "atterrando da almeno 4 tessere scuoti il terreno: chi ti sta attorno resta stordito"},
	"set_legnoferro": {"name": "Corteccia che si chiude", "when": "ferita", "chance": 1.0, "do": "scudo", "n": 4, "t": 3.0, "cool": 8.0,
		"desc": "quando sei ferito la corteccia si chiude: +4 Scorza per 3 secondi"},
	"set_pallidite": {"name": "Scia di luna", "when": "scatto", "do": "scia", "t": 1.5, "dmg": 0.35, "cool": 1.0,
		"desc": "lo scatto lascia una scia fredda che ferisce chi tocchi"},
	"set_ambra": {"name": "Trappola d'ambra", "when": "ferita", "chance": 1.0, "do": "stordisce", "t": 1.4, "cool": 5.0,
		"desc": "chi ti ferisce resta intrappolato nell'ambra per un attimo"},
	"set_tizzonite": {"name": "Pelle di brace", "when": "ferita", "chance": 1.0, "do": "brucia", "t": 4.0, "cool": 2.0,
		"desc": "chi ti ferisce prende fuoco"},
	"set_linfa": {"name": "Linfa che ritorna", "when": "uccisione", "do": "linfa", "n": 3,
		"desc": "ogni creatura sconfitta ti rende 3 Linfa"},
	"set_vuoto": {"name": "Passo d'ombra", "when": "ogni", "n": 6, "do": "ombra", "mult": 0.4, "t": 2.5,
		"desc": "ogni sei colpi diventi ombra: per un attimo le creature quasi non ti vedono"},
	"set_nimbite": {"name": "Salto del nembo", "when": "salto", "do": "fulmine", "dmg": 0.8, "cool": 2.0,
		"desc": "saltando chiami un fulmine sulla creatura più vicina"},
	"set_stellare": {"name": "Stelle del Giardino", "when": "colpo", "chance": 0.15, "do": "pioggia", "shards": 3, "dmg": 0.35,
		"desc": "a volte tre stelle cadono sulla creatura colpita"},
	# i materiali dei geni
	"set_ferro_brina": {"name": "Morso di brina", "when": "colpo", "chance": 0.2, "do": "gela", "t": 2.0,
		"desc": "un colpo su cinque gela la creatura"},
	"set_ossidiana_brace": {"name": "Cuore che scoppia", "when": "ferita", "chance": 1.0, "do": "scoppio", "r": 3.0, "dmg": 1.2,
		"cool": 4.0, "desc": "quando sei ferito il cuore d'ossidiana scoppia attorno a chi ti ha colpito"},
	"set_micelio_duro": {"name": "Micelio che nutre", "when": "uccisione", "do": "cura", "frac": 0.0, "min": 6,
		"desc": "ogni creatura sconfitta ti cura un poco"},
	"set_linfite": {"name": "Vena aperta", "when": "ogni", "n": 5, "do": "linfa", "n_linfa": 2,
		"desc": "ogni cinque colpi ritrovi 2 Linfa"},
	"set_radicite_pura": {"name": "Mano del minatore", "when": "raccolta", "do": "magnete", "mult": 2.2, "t": 4.0, "cool": 6.0,
		"desc": "raccogliendo un oggetto attiri gli altri da lontano per qualche secondo"},
	"set_ambra_dorata": {"name": "Oro che cade", "when": "uccisione", "do": "lumini", "n": 2,
		"desc": "ogni creatura sconfitta lascia 2 Lumini in più"},
	"set_ferro_stellato": {"name": "Cielo che risponde", "when": "salto_aria", "do": "pioggia", "shards": 2, "dmg": 0.5, "cool": 2.0,
		"desc": "con il doppio salto due stelle cadono sulla creatura più vicina"},
	"set_vuoto_cavo": {"name": "Guscio che svanisce", "when": "scatto", "do": "ombra", "mult": 0.3, "t": 3.0, "cool": 4.0,
		"desc": "dopo lo scatto svanisci: le creature quasi non ti vedono per 3 secondi"},
	"set_sospesite": {"name": "Passo sospeso", "when": "salto", "do": "corsa", "mult": 1.25, "t": 1.5, "cool": 3.0,
		"desc": "saltando corri più in fretta per un attimo"},
	"set_nerume": {"name": "Ferita avvizzita", "when": "colpo", "chance": 0.15, "do": "sanguina", "dps": 0.2, "t": 4.0,
		"desc": "a volte il colpo apre una ferita che sanguina"},
	"set_chitina": {"name": "Guscio che respinge", "when": "ferita", "chance": 1.0, "do": "riflesso", "frac": 0.5,
		"desc": "metà della ferita torna a chi te l'ha fatta"},
	"set_osso_antico": {"name": "Furia antica", "when": "uccisione", "do": "slancio", "n": 2,
		"desc": "ogni creatura sconfitta ti dà 2 Slancio"},
	# i metalli del Risveglio
	"set_corallite": {"name": "Barriera che si alza", "when": "ferita", "chance": 1.0, "sotto": 0.5, "do": "scudo", "n": 10, "t": 4.0,
		"cool": 12.0, "desc": "sotto metà della Vita il corallo si alza: +10 Scorza per 4 secondi"},
	"set_sanguinite": {"name": "Sangue che chiama", "when": "colpo", "chance": 1.0, "do": "cura", "frac": 0.03,
		"desc": "ogni colpo ti cura del 3% del danno"},
	"set_cuorelegno": {"name": "Radici del Cuore", "when": "atterraggio", "da": 3.0, "do": "scossa", "r": 4.0, "t": 1.4, "cool": 3.0,
		"desc": "atterrando da almeno 3 tessere le radici scuotono tutto attorno"},
	"set_eterite": {"name": "Scia d'etere", "when": "salto_aria", "do": "scia", "t": 2.0, "dmg": 0.45, "cool": 1.5,
		"desc": "il doppio salto lascia una scia che ferisce chi tocchi"},
	"set_astrite": {"name": "Costellazione", "when": "ogni", "n": 5, "do": "catena", "targets": 3, "dmg": 0.6, "r": 7,
		"desc": "ogni cinque colpi la luce salta su altre tre creature"},
	"set_primambra": {"name": "Prima luce", "when": "ferita", "chance": 1.0, "do": "fulmine", "dmg": 1.0, "cool": 3.0,
		"desc": "chi ti ferisce è colpito da un fulmine di luce"},
	# i set scritti a mano
	"set_seta": {"name": "Filo di Linfa", "when": "ogni", "n": 8, "do": "linfa", "n_linfa": 3,
		"desc": "ogni otto colpi ritrovi 3 Linfa"},
	"set_seta_vuoto": {"name": "Trama d'ombra", "when": "ferita", "chance": 1.0, "do": "ombra", "mult": 0.4, "t": 2.0, "cool": 6.0,
		"desc": "quando sei ferito ti nascondi per 2 secondi"},
	"set_scaglie": {"name": "Carica dello scarabeo", "when": "scatto", "do": "scossa", "r": 2.5, "t": 0.8, "cool": 3.0,
		"desc": "lo scatto stordisce chi ti sta attorno"},
	"set_cielo": {"name": "Penne del vento", "when": "volo", "do": "magnete", "mult": 2.0, "t": 2.0,
		"desc": "volando attiri gli oggetti da lontano"},
	# gli stili
	"stile_mischia": {"name": "Furia del guerriero", "when": "ogni", "n": 4, "do": "slancio", "n_slancio": 1,
		"desc": "ogni quattro colpi uno Slancio in più"},
	"stile_distanza": {"name": "Tiro che trapassa", "when": "colpo", "chance": 0.25, "cond": "fermo", "do": "trapassa", "len": 4.0,
		"dmg": 0.5, "desc": "da fermo un tiro su quattro trapassa: ferisce anche chi sta dietro"},
	"stile_linfa": {"name": "Pozzo di Linfa", "when": "uccisione", "do": "linfa", "n": 4,
		"desc": "ogni creatura sconfitta ti rende 4 Linfa"},
	"stile_evocazione": {"name": "Voce del branco", "when": "ogni", "n": 8, "do": "catena", "targets": 3, "dmg": 0.5, "r": 6,
		"desc": "ogni otto colpi gli spiriti del branco saltano su tre creature vicine"},
	"stile_lancio": {"name": "Occhio pronto", "when": "salto", "do": "mira", "cool": 2.5,
		"desc": "saltando la Mira ferma è subito pronta"},
	"stile_canto": {"name": "Eco della canzone", "when": "ogni", "n": 5, "do": "ispira", "n_ispira": 2,
		"desc": "ogni cinque note 2 Ispirazione in più"},
	"stile_cura": {"name": "Rugiada che salva", "when": "ferita", "chance": 1.0, "sotto": 0.5, "do": "cura", "frac": 1.0, "cool": 10.0,
		"desc": "sotto metà della Vita la ferita si richiude subito (una volta ogni 10 secondi)"},
	"stile_radice": {"name": "Rovi che crescono", "when": "uccisione", "do": "scia", "t": 3.0, "dmg": 0.4,
		"desc": "ogni creatura sconfitta fa crescere rovi attorno a te per 3 secondi"},
}

## Voce 391: le essenze della forgia (tratti da innestare sui pezzi d'armatura). id del tratto → riga di `TraitsData`
## (con "item" = l'essenza da innestare, "src" = da dove viene).
const ESSENCES := {
	"cresta": {"pal": "sanguinite", "name": "Cresta", "desc": "+6% danno", "for": ["armatura"], "weight": 2, "essence": true, "damage": 1.06,
		"item": "essenza_cresta", "item_name": "Essenza di cresta"},
	"fuso": {"pal": "vento", "name": "Fuso", "desc": "+6% velocità del colpo", "for": ["armatura"], "weight": 2, "essence": true, "speed": 1.06,
		"item": "essenza_fuso", "item_name": "Essenza del fuso"},
	"eco_linfa": {"pal": "lagunite", "name": "Eco di Linfa", "desc": "incantesimi +8%", "for": ["armatura"], "weight": 2, "essence": true,
		"magic": 1.08, "item": "essenza_eco", "item_name": "Essenza d'eco"},
	"molla": {"pal": "nimbite", "name": "Molla", "desc": "+6% salto", "for": ["armatura"], "weight": 2, "essence": true, "jump": 1.06,
		"item": "essenza_molla", "item_name": "Essenza della molla"},
	"corteccia_viva": {"pal": "cuorelegno", "name": "Corteccia viva", "desc": "+4 Scorza", "for": ["armatura"], "weight": 1, "essence": true,
		"scorza": 4, "item": "essenza_corteccia", "item_name": "Essenza di corteccia"},
	"rugiada_lenta": {"pal": "brina", "name": "Rugiada lenta", "desc": "la Linfa torna il 25% più in fretta", "for": ["armatura"], "weight": 2,
		"essence": true, "linfa_regen": 1.25, "item": "essenza_rugiada", "item_name": "Essenza di rugiada"},
	"branco": {"pal": "pallidite", "name": "Branco", "desc": "gli alleati degli scettri +10%", "for": ["armatura"], "weight": 1, "essence": true,
		"st_evocazione": 1.1, "item": "essenza_branco", "item_name": "Essenza del branco"},
	"coro": {"pal": "brillaluce", "name": "Coro", "desc": "canto +10%", "for": ["armatura"], "weight": 1, "essence": true, "st_canto": 1.1,
		"item": "essenza_coro", "item_name": "Essenza del coro"},
}
## Le chiavi dei tratti dei pezzi indossati che `GearEffects` legge (oltre a corsa, alone, Vita, ombra, fortuna, spine).
const WORN_KEYS := {"damage": "damage", "speed": "atk_speed", "magic": "magic", "jump": "jump", "linfa_regen": "linfa_regen",
	"st_evocazione": "st_evocazione", "st_canto": "st_canto"}


## I tratti delle essenze, per `TraitsData.TRAITS`.
static func traits() -> Dictionary:
	var out := {}
	for t in ESSENCES:
		var d: Dictionary = (ESSENCES[t] as Dictionary).duplicate()
		d.erase("item")
		d.erase("item_name")
		d.erase("pal")
		out[t] = d
	return out


## Le essenze come oggetti (si innestano al Maglio come le altre: campo "graft").
static func items() -> Dictionary:
	var out := {}
	for t in ESSENCES:
		var e: Dictionary = ESSENCES[t]
		out[String(e["item"])] = {"name": e["item_name"], "kind": "essenza", "graft": t, "icon": ["essenza", String(e["pal"])],
			"stack": 99, "desc": "Un'essenza della forgia, dai capi erranti, dai Sacchetti dei Guardiani e dagli scrigni delle " +
			"rovine. Al Maglio dei Seminatori si innesta su un pezzo d'armatura: %s." % e["desc"]}
	return out


## La tabella del bottino delle essenze (una a scelta).
static func loot() -> Dictionary:
	var rows := []
	for t in ESSENCES:
		rows.append({"item": ESSENCES[t]["item"], "min": 1, "max": 1, "chance": 1.0, "group": "essenza",
			"w": int(ESSENCES[t]["weight"]) + 1})
	return {"essenze_forgia": rows}
