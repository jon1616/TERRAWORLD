class_name FamiliesData
extends RefCounted
## Le **famiglie** di creature (voce 55, Roadmap 7 «L'ecologia»). Solo dati e le regole che fanno una variante.
## Una famiglia raccoglie le specie di `CreaturesData` che si somigliano (i grumi di muschio, di resina e di spore sono
## una famiglia sola) e ognuna nasce in **varianti**: taglia × elemento × indole, con i colori, la misura e i segni
## che cambiano di conseguenza (`CreatureArt.modded`). L'id di una variante è «specie~taglia~elemento~indole»
## (le parti vuote sono quelle normali: `grumo_muschio~grande~gelo~`); `CreaturesData.get_data` la costruisce.
##
## Campi di una famiglia: name (il nome della famiglia, per l'Erbario), members (le specie), fem (nome femminile: per
## gli aggettivi), role (voce 56: erbivoro · predatore · colonia · volante · scavatore · neutro: i geni di fauna ne
## cambiano la frequenza), e dalle voci dopo: prey (57), nest (58), diet, tame, produce, mount (59).

const FAMILIES := {
	"grumi": {"name": "Grumi", "members": ["grumo_muschio", "grumo_resina", "grumo_spore"], "fem": false, "role": "neutro"},
	"falene": {"name": "Falene di brace", "members": ["falena_brace"], "fem": true, "role": "volante"},
	"strisciaradici": {"name": "Strisciaradici", "members": ["strisciaradice"], "fem": true, "role": "neutro"},
	"scarabei": {"name": "Scarabei d'ardesia", "members": ["scarabeo_ardesia"], "fem": false, "role": "neutro"},
	"sputaspore": {"name": "Sputaspore", "members": ["sputaspore"], "fem": false, "role": "neutro"},
	"avvizziti": {"name": "Avvizziti erranti", "members": ["avvizzito_errante"], "fem": false, "role": "neutro"},
	"vagavuoti": {"name": "Vagavuoti", "members": ["vagavuoto"], "fem": false, "role": "volante"},
	"corvi": {"name": "Corvi di corteccia", "members": ["corvo_corteccia"], "fem": false, "role": "volante"},
	"spinoricci": {"name": "Spinoricci", "members": ["spinoriccio"], "fem": false, "role": "neutro"},
	"lucciole": {"name": "Lucciole voraci", "members": ["lucciola_vorace"], "fem": true, "role": "volante"},
	"tessiradici": {"name": "Tessiradici", "members": ["tessiradice"], "fem": true, "role": "predatore"},
	"talponi": {"name": "Talponi di humus", "members": ["talpone"], "fem": false, "role": "scavatore"},
	"saltafunghi": {"name": "Saltafunghi", "members": ["saltafungo"], "fem": false, "role": "neutro"},
	"ali_ardesia": {"name": "Ali d'ardesia", "members": ["ala_ardesia"], "fem": true, "role": "volante"},
	"chiocciole": {"name": "Chiocciole di cristallo", "members": ["chiocciola_cristallo"], "fem": true, "role": "erbivoro"},
	"geomimi": {"name": "Geomimi", "members": ["geomimo"], "fem": false, "role": "neutro"},
	"serpi": {"name": "Serpi di Linfa", "members": ["serpe_linfa"], "fem": true, "role": "predatore"},
	"campanule": {"name": "Campanule erranti", "members": ["campanula_errante"], "fem": true, "role": "neutro"},
	"guizzalinfe": {"name": "Guizzalinfe", "members": ["guizzalinfa"], "fem": false, "role": "neutro"},
	"mietivuoti": {"name": "Mietivuoti", "members": ["mietivuoto"], "fem": false, "role": "predatore"},
	"tessivuoti": {"name": "Tessivuoti", "members": ["tessivuoto"], "fem": false, "role": "predatore"},
	"sciami": {"name": "Sciami di schegge", "members": ["sciame_schegge"], "fem": false, "role": "colonia"},
	"cervi": {"name": "Cervi di brina", "members": ["cervo_brina"], "fem": false, "role": "erbivoro"},
	"gufi": {"name": "Gufi del gelo", "members": ["gufo_gelo"], "fem": false, "role": "predatore"},
	"salamandre": {"name": "Salamandre di brace", "members": ["salamandra_brace"], "fem": true, "role": "predatore"},
	"fatui": {"name": "Fatui di cenere", "members": ["fatuo_cenere"], "fem": false, "role": "neutro"},
	# voce 56: le famiglie nuove
	"pecore": {"name": "Pecore di muschio", "members": ["pecora_muschio"], "fem": true, "role": "erbivoro"},
	"cornoradici": {"name": "Cornoradici", "members": ["cornoradice"], "fem": false, "role": "erbivoro"},
	"lepri": {"name": "Lepri di Linfa", "members": ["lepre_linfa"], "fem": true, "role": "erbivoro"},
	"bruchi": {"name": "Bruchi di lanterna", "members": ["bruco_lanterna"], "fem": false, "role": "erbivoro"},
	"api": {"name": "Api di lume", "members": ["ape_lume"], "fem": true, "role": "colonia"},
	"formiche": {"name": "Formiche di resina", "members": ["formica_resina"], "fem": true, "role": "colonia"},
	"pipistrelli": {"name": "Pipistrelli di corteccia", "members": ["pipistrello_corteccia"], "fem": false, "role": "volante"},
	"libellule": {"name": "Libellule di brina", "members": ["libellula_brina"], "fem": true, "role": "volante"},
	"volpi": {"name": "Volpi d'ambra", "members": ["volpe_ambra"], "fem": true, "role": "predatore"},
	"linci": {"name": "Linci d'ardesia", "members": ["lince_ardesia"], "fem": true, "role": "predatore"},
}
const ROLES := ["erbivoro", "predatore", "colonia", "volante", "scavatore", "neutro"]

## Le taglie: Vita, danno, velocità e misura del disegno.
const SIZES := {
	"piccolo": {"hp": 0.7, "damage": 0.8, "speed": 1.1, "scale": 0.8, "adj": ["piccolo", "piccola"]},
	"grande": {"hp": 1.6, "damage": 1.3, "speed": 0.9, "scale": 1.25, "adj": ["grande", "grande"]},
}
## Gli elementi delle varianti: resistono al proprio, sono deboli a quello opposto (`OPPOSITE`); il disegno prende il
## colore dell'elemento.
const ELEM_ADJ := {"brace": ["ardente", "ardente"], "gelo": ["gelido", "gelida"], "spora": ["sporigeno", "sporigena"],
	"linfa": ["linfatico", "linfatica"], "vuoto": ["cavo", "cava"], "luce": ["lucente", "lucente"]}
const OPPOSITE := {"brace": "gelo", "gelo": "brace", "spora": "brace", "linfa": "vuoto", "vuoto": "luce", "luce": "vuoto"}
## Le indoli: docile (non attacca finché non la colpisci: la più facile da addomesticare, voce 59), feroce (più forte,
## più svelta, vede più lontano), timida (scappa e non attacca).
const TEMPERS := {
	"docile": {"damage": 0.8, "adj": ["docile", "docile"]},
	"feroce": {"damage": 1.35, "speed": 1.2, "sight": 1.5, "adj": ["feroce", "feroce"]},
	"timida": {"damage": 0.0, "adj": ["timido", "timida"]},
}

static var _family_of := {}


## La famiglia di una specie (o di una sua variante): "" se non ne ha (Guardiani e Custodi).
static func family_of(id: String) -> String:
	if _family_of.is_empty():
		for f in FAMILIES:
			for s in FAMILIES[f]["members"]:
				_family_of[s] = f
	return String(_family_of.get(CreaturesData.base_of(id), ""))


static func variant_id(base: String, size := "", elem := "", temper := "") -> String:
	if size == "" and elem == "" and temper == "":
		return base
	return "%s~%s~%s~%s" % [base, size, elem, temper]


## Le parti di una variante: [specie, taglia, elemento, indole].
static func parts(id: String) -> Array:
	var p := id.split("~")
	return [p[0], p[1] if p.size() > 1 else "", p[2] if p.size() > 2 else "", p[3] if p.size() > 3 else ""]


## Una variante a caso di una specie: taglia, elemento (più spesso quello del luogo, `bias`) e indole (più feroce dove
## è più pericoloso). Guardiani, Custodi e chi non ha famiglia restano come sono.
static func roll_variant(base: String, rng: RandomNumberGenerator, bias := "", danger := 1.0) -> String:
	if family_of(base) == "":
		return base
	var size := ""
	var r := rng.randf()
	if r < 0.15:
		size = "piccolo"
	elif r < 0.3 + 0.05 * maxf(danger - 1.0, 0.0):
		size = "grande"
	var elem := ""
	if rng.randf() < 0.2:
		var keys := ELEM_ADJ.keys()
		elem = bias if bias != "" and rng.randf() < 0.7 else String(keys[rng.randi_range(0, keys.size() - 1)])
	var temper := ""
	var still := float(CreaturesData.CREATURES[base].get("speed", 60)) <= 0.0   # chi sta fermo non può scappare
	r = rng.randf()
	if r < 0.14:
		temper = "docile"
	elif r < 0.24 + 0.03 * maxf(danger - 1.0, 0.0):
		temper = "feroce"
	elif r < 0.32 and not still:
		temper = "timida"
	return variant_id(base, size, elem, temper)


## I dati di una variante, costruiti da quelli della sua specie.
static func make(id: String) -> Dictionary:
	var pr := parts(id)
	var base: Dictionary = CreaturesData.CREATURES[pr[0]]
	var d: Dictionary = base.duplicate(true)
	var fem := bool(FAMILIES.get(family_of(pr[0]), {}).get("fem", false))
	var tags := []
	var mods := {}
	var sd: Dictionary = SIZES.get(pr[1], {})
	if not sd.is_empty():
		d["hp"] = maxi(roundi(float(d["hp"]) * float(sd["hp"])), 1)
		d["damage"] = roundi(float(d["damage"]) * float(sd["damage"]))
		d["speed"] = float(d.get("speed", 60)) * float(sd["speed"])
		d["half"] = [maxi(roundi(float(d["half"][0]) * float(sd["scale"])), 2), maxi(roundi(float(d["half"][1]) * float(sd["scale"])), 2)]
		mods["scale"] = float(sd["scale"])
		tags.append(sd["adj"][1 if fem else 0])
	if ELEM_ADJ.has(pr[2]):
		d["elem"] = pr[2]
		d["weak"] = [OPPOSITE[pr[2]]]
		d["resist"] = [pr[2]]
		mods["elem"] = pr[2]
		tags.append(ELEM_ADJ[pr[2]][1 if fem else 0])
		if pr[2] in ["luce", "linfa", "brace"]:
			d["glow"] = true
	var td: Dictionary = TEMPERS.get(pr[3], {})
	if not td.is_empty():
		d["damage"] = roundi(float(d["damage"]) * float(td.get("damage", 1.0)))
		d["speed"] = float(d.get("speed", 60)) * float(td.get("speed", 1.0))
		var p: Dictionary = d.get("p", {})
		if td.has("sight"):
			p["sight"] = float(p.get("sight", 20)) * float(td["sight"])
		d["p"] = p
		mods["temper"] = pr[3]
		tags.append(td["adj"][1 if fem else 0])
		if pr[3] != "docile":
			d.erase("docile")                  # una pecora feroce non è più docile
		match pr[3]:
			"docile":
				d["docile"] = true             # non attacca finché non la colpisci (`Creature.provoked`)
			"timida":
				d["behaviors"] = ["fugge"]
				d["p"]["flee"] = 12
	d["name"] = "%s (%s)" % [d["name"], ", ".join(tags)] if not tags.is_empty() else d["name"]
	d["base"] = pr[0]
	d["variant"] = pr
	d["art_mods"] = mods
	return d
