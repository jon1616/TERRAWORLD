class_name HerdData
extends RefCounted
## L'addomesticamento (voce 59, Roadmap 7): quali famiglie si addomesticano, cosa mangiano, cosa producono nei recinti,
## come aiutano chi seguono, quali si cavalcano; gli oggetti (Vasetto, Laccio, Recinto, Incubatrice…) e le regole in
## numeri. Solo dati; le regole vive stanno in `Herd`, `Taming` e `Pens`.
##
## TAME: famiglia →
##   diet        cibi che la calmano e che mangia nel recinto (il primo è il preferito)
##   diff        1-5: quanto è difficile (meno affetto per pasto, laccio meno sicuro)
##   produce     [oggetto, secondi, min, max] nel recinto, se non ha fame (più in fretta se è felice)
##   aid         doni a chi segue, come gli accessori di `GearEffects` (più "light": fa luce), con `aid_text`
##   mount       si cavalca (tasto R): effetti di chi sta in sella, con `mount_text`
## Le famiglie che non ci sono non si lasciano addomesticare (Avvizziti, creature del Vuoto, mimi…).

const _TAME := {
	"grumi": {"diet": ["gelatina", "fungo_luminoso"], "diff": 1, "produce": ["gelatina", 150, 1, 2]},
	"pecore": {"diet": ["seme_lanterna", "tubero_linfa"], "diff": 1, "produce": ["lana_muschio", 180, 1, 2],
		"aid": {"defense": 1}, "aid_text": "+1 Scorza (la lana tiene caldo)"},
	"cornoradici": {"diet": ["tubero_linfa", "foglia_rugiada"], "diff": 3, "produce": ["corno_radice", 600, 1, 1],
		"mount": {"run": 1.5, "jump": 1.1}, "mount_text": "corsa +50%, salto +10%"},
	"lepri": {"diet": ["tubero_linfa", "foglia_rugiada"], "diff": 2, "produce": ["pelo_lepre", 200, 1, 2],
		"aid": {"run": 1.08}, "aid_text": "corri l'8% più in fretta"},
	"bruchi": {"diet": ["foglia_rugiada", "seme_lanterna"], "diff": 1, "produce": ["seta_bruco", 200, 1, 2]},
	"api": {"diet": ["petali_lume", "foglia_rugiada"], "diff": 2, "produce": ["miele_lume", 240, 1, 1],
		"aid": {"regen": 1.1}, "aid_text": "la Vita ricresce il 10% più in fretta"},
	"formiche": {"diet": ["resina_dolce", "gelatina"], "diff": 2, "produce": ["resina_dolce", 240, 1, 2]},
	"volpi": {"diet": ["boccone"], "diff": 3, "produce": ["pelliccia_volpe", 600, 1, 1],
		"aid": {"damage": 1.05}, "aid_text": "colpi più forti del 5%"},
	"linci": {"diet": ["boccone"], "diff": 4, "produce": ["zanna_lince", 900, 1, 1],
		"mount": {"run": 1.55, "jump": 1.25}, "mount_text": "corsa +55%, salto +25%"},
	"cervi": {"diet": ["tubero_linfa", "foglia_rugiada"], "diff": 3, "produce": ["vello_brina", 360, 1, 2],
		"mount": {"run": 1.65, "jump": 1.3}, "mount_text": "corsa +65%, salto +30%"},
	"salamandre": {"diet": ["boccone", "fungo_brace"], "diff": 3, "produce": ["squama_brace", 360, 1, 2],
		"mount": {"run": 1.4, "fall_safe": true}, "mount_text": "corsa +40%, niente ferite da caduta"},
	"tessiradici": {"diet": ["boccone", "polvere_lucciola"], "diff": 3, "produce": ["seta_radice", 240, 1, 3],
		"aid": {"atk_speed": 1.05}, "aid_text": "colpi più rapidi del 5%"},
	"talponi": {"diet": ["fungo_brace", "tubero_linfa"], "diff": 2, "produce": ["humus", 120, 3, 6],
		"aid": {"dig": 1.15}, "aid_text": "scavi il 15% più in fretta",
		"mount": {"run": 1.25, "dig": 2.0}, "mount_text": "scavo doppio, corsa +25%"},
	"saltafunghi": {"diet": ["fungo_luminoso"], "diff": 1, "produce": ["lamella_fungo", 240, 1, 1],
		"aid": {"jump": 1.1}, "aid_text": "salti più in alto"},
	"chiocciole": {"diet": ["cristallo_linfa", "foglia_rugiada"], "diff": 3, "produce": ["guscio_cristallo", 600, 1, 1],
		"aid": {"defense": 2}, "aid_text": "+2 Scorza"},
	"corvi": {"diet": ["seme_lanterna", "boccone"], "diff": 2, "produce": ["penna_corteccia", 200, 1, 2],
		"aid": {"luck": 0.05}, "aid_text": "un po' di fortuna nel bottino"},
	"lucciole": {"diet": ["petali_lume"], "diff": 1, "produce": ["polvere_lucciola", 180, 1, 2],
		"aid": {"light": Color(1.2, 1.1, 0.5)}, "aid_text": "fa luce attorno a sé"},
	"falene": {"diet": ["polvere_brace", "petali_lume"], "diff": 2, "produce": ["polvere_brace", 200, 1, 2],
		"aid": {"light": Color(1.3, 0.7, 0.3)}, "aid_text": "fa una luce di brace"},
	"gufi": {"diet": ["boccone"], "diff": 3, "produce": ["piuma_gelo", 360, 1, 2],
		"aid": {"stealth": 0.85}, "aid_text": "le creature ti notano più tardi"},
	"libellule": {"diet": ["petali_lume"], "diff": 2, "produce": ["ala_libellula", 300, 1, 1],
		"aid": {"run": 1.05}, "aid_text": "corri il 5% più in fretta"},
	"pipistrelli": {"diet": ["boccone", "fungo_luminoso"], "diff": 2, "produce": ["ala_pipistrello", 300, 1, 1],
		"aid": {"stealth": 0.9}, "aid_text": "le creature ti notano un po' più tardi"},
	"spinoricci": {"diet": ["boccone", "tubero_linfa"], "diff": 2, "produce": ["aculeo", 240, 2, 4],
		"aid": {"thorns": 3}, "aid_text": "chi ti ferisce si punge (3)"},
	"serpi": {"diet": ["boccone", "cristallo_linfa"], "diff": 4, "produce": ["scaglia_linfa", 400, 1, 2],
		"aid": {"magic": 1.08}, "aid_text": "incantesimi più forti dell'8%"},
	"guizzalinfe": {"diet": ["cristallo_linfa"], "diff": 3, "produce": ["latte_linfa", 300, 1, 1],
		"aid": {"linfa_regen": 1.25}, "aid_text": "la Linfa torna il 25% più in fretta"},
	"campanule": {"diet": ["petali_lume"], "diff": 2, "produce": ["petali_lume", 200, 1, 3],
		"aid": {"regen": 1.2}, "aid_text": "la Vita ricresce il 20% più in fretta"},
}

## Roadmap 16: più quelle dei pacchetti (campo "tame", come qui).
static var TAME: Dictionary = _TAME.merged(BiomesData.pack("tame"))

## Le regole in numeri.
const FOLLOW_MAX := 5                  # Roadmap 32: la Sacca dei legami (una sola in campo, `BondBag`)
const PEN_CAP := 4                     # creature per recinto
const PEN_LEFT := 4                    # il recinto va da `PEN_LEFT` tessere a sinistra della stazione…
const PEN_RIGHT := 7                   # …a `PEN_RIGHT` a destra
const HATCH := 150.0                   # secondi di cova nell'Incubatrice
const LVL_MAX := 20
const LVL_DAMAGE := 0.12               # danno in più per livello
const HUNGER_RATE := 1.0 / 600.0       # fame al secondo (0 sazia, 1 affamata): dieci minuti
const CAPTURE_HP := 0.4                # il Laccio prende solo chi ha meno di questa frazione di Vita
const OFFLINE_CAP := 7200.0            # secondi di recinto che passano mentre sei altrove (al più due ore)
const REST_HEAL := 120.0               # secondi per guarire del tutto riposando (nel Giardino o nel recinto)
const STUDY := 3                       # dopo quante sconfitte di una specie se ne conosce la dieta

## I nomi che il Germogliato dà alle creature (due pezzi a caso; si cambiano nel pannello).
const NAME_A := ["Bri", "Mu", "Ta", "Lo", "Fe", "Ri", "Zu", "Pi", "No", "Ca", "Ve", "Sa", "Gi", "Ru", "Ne", "Ombre", "Sci"]
const NAME_B := ["na", "schio", "llo", "ra", "mo", "tta", "lù", "bo", "sco", "rì", "nda", "ffo", "ccia", "po", "vo"]

## Gli oggetti.
const ITEMS := {
	"vasetto": {"name": "Vasetto di radice", "kind": "vasetto", "icon": ["vasetto", "legno"], "stack": 10,
		"desc": "Clic su una creatura della tua mandria: entra nel vasetto e la porti dove vuoi (anche in un altro mondo). Il vasetto pieno, usato, la fa uscire."},
	"creatura": {"name": "Creatura nel vasetto", "kind": "creatura", "icon": ["vasetto", "muschio"], "stack": 1,
		"source": "mettendo nel vasetto una creatura della mandria, o dall'Incubatrice",
		"desc": "Una creatura della tua mandria, al sicuro in un vasetto. Usala (clic) per farla uscire: ti seguirà."},
	"laccio": {"name": "Laccio di seta", "kind": "laccio", "icon": ["frusta", "seta"], "stack": 20,
		"desc": "Clic su una creatura stremata (meno del 40% della Vita): forse la prendi. Più è debole, più è facile; le feroci si liberano più spesso."},
	"recinto": {"name": "Recinto di radici", "kind": "stazione", "place": "recinto", "icon": ["parete", "radice"], "stack": 9,
		"desc": "Quattro creature della mandria ci vivono (G: «Al recinto»). È anche la mangiatoia: clic destro per metterci il loro cibo e prendere ciò che producono."},
	"incubatrice": {"name": "Incubatrice di muschio", "kind": "stazione", "place": "incubatrice", "icon": ["gemma", "muschio"], "stack": 9,
		"desc": "Clic destro: ci posi le uova. In due minuti e mezzo (anche se sei lontano) si schiudono in vasetti con la creatura già tua."},
	"latte_linfa": {"name": "Latte di Linfa", "kind": "consumabile", "icon": ["pozione", "cristallo"], "linfa": 12, "stack": 30,
		"source": "dai guizzalinfa del recinto",
		"desc": "Lo danno i guizzalinfa del recinto: ridà 12 di Linfa."},
}

const RECIPES := [
	{"out": "vasetto", "qty": 2, "in": {"vetro_resina": 1, "legno": 2}, "station": "ceppo"},
	{"out": "laccio", "qty": 3, "in": {"seta_radice": 4, "legno": 1}, "station": "telaio"},
	{"out": "laccio", "qty": 3, "in": {"seta_bruco": 3, "legno": 1}, "station": "telaio"},
	{"out": "recinto", "qty": 1, "in": {"legno": 30, "humus": 10}, "station": "ceppo"},
	{"out": "incubatrice", "qty": 1, "in": {"legno": 10, "fungo_luminoso": 4, "humus": 10}, "station": "ceppo"},
]

static var _food := {}


## Roadmap 32: ogni famiglia si lega; quelle senza una riga qui prendono cibo, dono e prodotto dal loro ruolo
## (`BondsData.default_tame`).
static func tame_of(fam: String) -> Dictionary:
	if TAME.has(fam):
		return TAME[fam]
	return BondsData.default_tame(fam)


## È il cibo di qualche famiglia?
static func is_food(id: String) -> bool:
	if _food.is_empty():
		for f in TAME:
			for d in TAME[f]["diet"]:
				_food[d] = true
	return _food.has(id)


## Quanto affetto dà un pasto (100 = addomesticata): meno per le difficili, il doppio per le docili, meno per le feroci.
static func feed_gain(fam: String, temper: String) -> float:
	var t := tame_of(fam)
	if t.is_empty():
		return 0.0
	var g := 100.0 / (float(t["diff"]) * 1.5 + 1.0)
	match temper:
		"docile":
			g *= 2.0
		"feroce":
			g *= 0.5
	return g


## Probabilità che il Laccio prenda una creatura (secondo quanta Vita le resta e quanto è difficile).
static func capture_chance(fam: String, hp_ratio: float) -> float:
	var t := tame_of(fam)
	if t.is_empty() or hp_ratio > CAPTURE_HP:
		return 0.0
	return clampf((1.0 - hp_ratio) * 1.1 / (0.6 + float(t["diff"]) * 0.25), 0.05, 0.95)


## I punti per salire dal livello `lvl` al successivo.
static func xp_for(lvl: int) -> int:
	return 40 * lvl
