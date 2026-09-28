class_name IncisionsData
extends RefCounted
## Le incisioni (Roadmap 17, voce 175): al Maglio una parola **certa** della lingua dei Seminatori si incide su
## un'arma, un attrezzo, un'armatura o un accessorio. È un tratto in più (`TraitsData.TRAITS`, id «incisione_<parola>»)
## che **non prende un posto d'innesto**: una sola per oggetto (nei "dati" della casella, "incisione"; `Gear.traits` la
## conta, `Gear.free_slots` no). Più forti quelle delle lingue alte. Solo dati; la lavorazione è in `CraftWork`, le
## regole in `Crafting.engrave`. Non nomina altre classi (le tabelle dei tratti le leggono mentre si preparano).
## [parola, per chi, effetti (chiavi dei tratti), testo, costo]

const LIST := [
	# la lingua comune
	["brace", ["arma"], {"damage": 1.08}, "+8% danno", {"polvere_brace": 3}],
	["gelo", ["arma", "attrezzo"], {"speed": 1.06}, "+6% velocità del colpo", {"polvere_brace": 3}],
	["molto", ["arma"], {"knock": 1.3}, "+30% spinta", {"polvere_brace": 3}],
	["apre", ["attrezzo"], {"dig": 1.15}, "+15% scavo e taglio", {"polvere_brace": 3}],
	["radice", ["armatura"], {"scorza": 1}, "+1 Scorza", {"polvere_brace": 3}],
	["pietra", ["armatura", "accessorio"], {"scorza": 2}, "+2 Scorza", {"polvere_brace": 4}],
	["luce", ["armatura", "accessorio"], {"halo": 1.25}, "+25% alone", {"polvere_brace": 3}],
	["buio", ["armatura", "accessorio"], {"stealth": 0.85}, "le creature ti notano più tardi", {"polvere_brace": 4}],
	["cura", ["armatura", "accessorio"], {"regen": 1.15}, "la Vita ricresce il 15% più in fretta", {"polvere_brace": 4}],
	["stella", ["armatura", "accessorio"], {"luck": 0.5}, "un po' di fortuna nel bottino", {"polvere_brace": 4}],
	# la lingua antica
	["fuoco", ["arma"], {"damage": 1.14}, "+14% danno", {"polvere_brace": 5, "lingotto_nimbite": 1}],
	["fulmine", ["arma", "attrezzo"], {"speed": 1.12}, "+12% velocità del colpo", {"polvere_brace": 5, "lingotto_nimbite": 1}],
	["tuono", ["arma"], {"burst": 0.3}, "le creature abbattute scoppiano un poco", {"polvere_brace": 5, "lingotto_nimbite": 1}],
	["cristallo", ["armatura", "accessorio"], {"scorza": 3}, "+3 Scorza", {"polvere_brace": 5, "lingotto_nimbite": 1}],
	["vento", ["armatura", "accessorio"], {"run": 1.06}, "+6% corsa", {"polvere_brace": 5, "lingotto_nimbite": 1}],
	["protegge", ["armatura"], {"thorns": 6}, "chi ti tocca si ferisce (6)", {"polvere_brace": 5, "lingotto_nimbite": 1}],
	# la lingua del Seme Nero
	["divora", ["arma"], {"damage": 1.22}, "+22% danno", {"linfa_antica": 1}],
	["fame", ["arma"], {"poison": 1.0}, "i colpi avvelenano", {"linfa_antica": 1}],
	["ombra", ["armatura", "accessorio"], {"stealth": 0.7}, "le creature ti notano molto più tardi", {"linfa_antica": 1}],
	["rinascita", ["armatura", "accessorio"], {"regen": 1.35}, "la Vita ricresce il 35% più in fretta", {"linfa_antica": 1}],
]


static func trait_id(word: String) -> String:
	return "incisione_" + word


## L'incisione di una parola ({} se la parola non si incide).
static func of_word(word: String) -> Dictionary:
	for e in LIST:
		if String(e[0]) == word:
			return {"word": word, "for": e[1], "effects": e[2], "desc": e[3], "cost": e[4], "trait": trait_id(word)}
	return {}


## I tratti delle incisioni, per `TraitsData.TRAITS` (il nome lo completa `TraitsData`: «Incisione: ‹parola›»).
static func traits() -> Dictionary:
	var out := {}
	for e in LIST:
		var t := {"name": "Incisione «%s»" % String(e[0]), "desc": String(e[3]), "for": e[1], "weight": 0, "rune": true,
			"word": String(e[0])}
		t.merge(e[2])
		out[trait_id(String(e[0]))] = t
	return out
