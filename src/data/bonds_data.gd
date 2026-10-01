class_name BondsData
extends RefCounted
## I compagni di battaglia (Roadmap 32, dal 1 ott 2026; richiesta dell'utente: «ogni creatura, Guardiani esclusi, una
## in campo che combatte con il suo stile»). Solo dati; le regole vive stanno in `BondFight` (il combattimento),
## `BhMandria` (seguire e scegliere il nemico) e `Herd` (le schede).
##
## Lo **stile** di un compagno sono i comportamenti della sua specie (`CreaturesData`, campo "behaviors"), usati contro
## le creature nemiche: un lupo carica, uno sputaspore spara, un talpone sbuca da sotto. Qui si dice quali
## comportamenti un compagno non usa (danneggerebbero il Germogliato o lo farebbero restare indietro) e come si
## sostituiscono quelli che non hanno senso fuori dal loro posto (chi nuota, nell'aria nuota dentro una bolla).

## I comportamenti che un compagno non usa: rubano o bevono dal Germogliato, rosicchiano le porte, scappano, si
## travestono e restano fermi, chiamano altre creature selvatiche, curano le creature selvatiche.
const SKIP := ["fugge", "ladro", "rosicchia", "succhia", "lucciola_vena", "parassita", "pastore", "mimo", "mimetico",
	"fotofobo", "richiamo", "evoca", "guaritore", "tessitore", "divide", "deriva", "nuota", "fermo"]
## I comportamenti che muovono la creatura: se lo stile non ne ha nessuno, prende «vola» o «cammina».
const MOVERS := ["cammina", "vola", "salta_verso", "scava", "sbuca", "picchiata", "teletrasporto", "agguato", "carica",
	"scatto"]

## Seguire il Germogliato e combattere (tessere e secondi).
const SIGHT := 12.0                    # il compagno difende entro questa distanza dal Germogliato
const LEASH := 18.0                    # oltre questa distanza dal Germogliato lascia il nemico e torna
const FAR := 22.0                      # più lontano di così (fuori dalla visuale) ricompare accanto al Germogliato
const STUCK_TIME := 1.4                # secondi senza avvicinarsi (lontano più di `STUCK_FROM` tessere): ricompare
const STUCK_FROM := 5.0
const STUCK_FIGHT := 2.5               # in lotta: secondi senza avvicinarsi al nemico prima di ricomparire
const SIGHT_MULT := 1.3                # il compagno vede un poco più lontano del suo stile selvatico (non ha paura del buio)
const HIT_EVERY := 0.7                 # secondi tra due colpi al contatto sullo stesso nemico
const AGGRO_TIME := 4.0                # secondi in cui una creatura colpita dal compagno lo prende di mira
const AGGRO_NEAR := 0.7                # o se il compagno le è più vicino di così (rispetto al Germogliato)
const SHOT_MIN := 0.6                  # i colpi a distanza valgono tra queste frazioni del danno del compagno
const SHOT_MAX := 1.4
const BLAST_MULT := 2.5                # lo scoppio di un compagno (non muore: lo rifà dopo `PAUSE`)
const PAUSE := 6.0


## Lo stile di una specie: i suoi comportamenti senza quelli di `SKIP`, più un modo di muoversi se manca.
static func style_of(cid: String) -> Array[String]:
	var d := CreaturesData.get_data(cid)
	var out: Array[String] = []
	var moves := false
	for b in d.get("behaviors", []):
		var s := String(b)
		if s in SKIP or s in out:
			continue
		out.append(s)
		if s in MOVERS:
			moves = true
	if not moves:
		out.push_front("vola" if flies(cid) else "cammina")
	return out


## Vola in campo? Chi vola, e chi nuota (fuori dall'acqua nuota nell'aria, dentro una bolla).
static func flies(cid: String) -> bool:
	var d := CreaturesData.get_data(cid)
	return bool(d.get("fly", false)) or bool(d.get("water", false)) or "nuota" in d.get("behaviors", [])


## Si può legare? Tutte le creature tranne Guardiani, Custodi e Signori (le `boss`).
static func bindable(cid: String) -> bool:
	var d := CreaturesData.get_data(cid)
	return not d.is_empty() and not bool(d.get("boss", false))


# ---- voce 312: legare ogni creatura -------------------------------------------------------------------------------

## La natura di una creatura decide quando e come si lega (il Laccio vale per tutte le altre):
##   avvizzita   malata d'Avvizzimento: prima si cura con la Rugiada di Linfa, poi si lega
##   vuoto       del Vuoto (anche le varianti «cave»): si lega solo al buio
##   spirito     si lega solo di notte, o nel buio profondo sotto terra
##   mimo        si lega solo scoperta (sveglia, non travestita)
##   costrutto   di pietra o d'ingranaggio: un laccio non la tiene, serve il Sigillo del legame
const NATURES := {
	"avvizzita": ["avvizziti"],
	"vuoto": ["vagavuoti", "mietivuoti", "tessivuoti", "talpe_vuoto", "pascolanti", "ombre", "ombre_parola",
		"cerbiatti_ombra", "eclissimi", "sciami"],
	"spirito": ["spiriti", "anime", "fatui", "spiriti_catacombe", "spiriti_bufera", "veli_nebbia", "spiritelli",
		"sussurratori"],
	"mimo": ["geomimi", "stellamimi"],
	"costrutto": ["golem", "gargolle", "sentinelle", "sentinelle_cielo", "sentinelle_radice", "ragni_ingranaggio",
		"custodi_orbita", "guardiani_linfa", "guardastele"],
}
const NATURE_TEXT := {
	"avvizzita": "malata d'Avvizzimento: curala con la Rugiada di Linfa, poi legala",
	"vuoto": "creatura del Vuoto: si lega solo al buio",
	"spirito": "spirito: si lega solo di notte, o nel buio profondo",
	"mimo": "si traveste: legala quando è scoperta",
	"costrutto": "di pietra: serve il Sigillo del legame",
}
const DARK := 0.25                     # sotto questa luce (0-1) una cella è «buia» per le creature del Vuoto

## I lacci: quanto aiutano (`mult`), fino a quanta Vita della creatura prendono (`hp`), che cosa legano soltanto.
const LACCI := {
	"laccio": {"mult": 1.0, "hp": 0.4},
	"laccio_intrecciato": {"mult": 1.45, "hp": 0.5},
	"laccio_seminatori": {"mult": 2.0, "hp": 0.6, "ancestral": true},
	"sigillo_legame": {"mult": 1.3, "hp": 0.5, "only": "costrutto"},
}
## Le rare: più difficili (moltiplicano la probabilità), e le ancestrali vogliono il Laccio dei Seminatori.
const RARE_CHANCE := {"antica": 0.5, "ancestrale": 0.35, "capobranco": 0.7, "iridata": 0.6}

## Le famiglie senza una riga in `HerdData.TAME` (prima non si addomesticavano): cibo, dono e prodotto dal loro ruolo.
const DIETS := {
	"predatore": ["boccone"], "erbivoro": ["tubero_linfa", "foglia_rugiada"], "volante": ["petali_lume", "boccone"],
	"colonia": ["resina_dolce", "gelatina"], "scavatore": ["fungo_brace", "tubero_linfa"], "neutro": ["gelatina", "fungo_luminoso"],
}
const AIDS := {
	"predatore": [{"damage": 1.04}, "colpi più forti del 4%"],
	"erbivoro": [{"regen": 1.08}, "la Vita ricresce l'8% più in fretta"],
	"volante": [{"run": 1.04}, "corri il 4% più in fretta"],
	"colonia": [{"luck": 0.03}, "un po' di fortuna nel bottino"],
	"scavatore": [{"dig": 1.1}, "scavi il 10% più in fretta"],
	"neutro": [{"defense": 1}, "+1 Scorza"],
}

const ITEMS := {
	"laccio_intrecciato": {"name": "Laccio intrecciato", "kind": "laccio", "icon": ["frusta", "legnoferro"], "stack": 20,
		"desc": "Seta e fili di legnoferro: prende una creatura fino a metà della sua Vita, e tiene meglio del Laccio di seta."},
	"laccio_seminatori": {"name": "Laccio dei Seminatori", "kind": "laccio", "icon": ["frusta", "sem"], "stack": 20,
		"desc": "Intrecciato con la Linfa antica: prende fino a tre quinti della Vita, tiene il doppio, e lega anche le creature ancestrali."},
	"sigillo_legame": {"name": "Sigillo del legame", "kind": "laccio", "icon": ["gemma", "sem"], "stack": 20,
		"desc": "Una pietra dei Seminatori con la runa del legame: lega le creature di pietra e d'ingranaggio (golem, sentinelle, gargolle), che nessun laccio tiene."},
}
const RECIPES := [
	{"out": "laccio_intrecciato", "qty": 3, "in": {"lingotto_legnoferro": 1, "seta_radice": 4}, "station": "telaio"},
	{"out": "laccio_seminatori", "qty": 2, "in": {"cristallo_linfa": 2, "seta_radice": 6, "linfa_antica": 1}, "station": "maglio"},
	{"out": "sigillo_legame", "qty": 2, "in": {"pietra_seminatori": 4, "cristallo_linfa": 1, "lingotto_ambra": 1}, "station": "maglio"},
]

static var _tame := {}
static var _nature := {}


## La natura di una creatura (una chiave di `NATURES`, o "" per le comuni).
static func nature_of(cid: String) -> String:
	if _nature.has(cid):
		return _nature[cid]
	var base := CreaturesData.base_of(cid)
	var fam := FamiliesData.family_of(base)
	var out := ""
	for k in NATURES:
		if fam in NATURES[k]:
			out = k
	if out == "" and base.contains("avvizz"):
		out = "avvizzita"
	if out == "":
		var bh: Array = CreaturesData.get_data(cid).get("behaviors", [])
		if "mimo" in bh or "mimetico" in bh:
			out = "mimo"
	if out == "" and String(FamiliesData.parts(cid)[2]) == "vuoto":
		out = "vuoto"                                    # una variante cava è del Vuoto
	_nature[cid] = out
	return out


## Il cibo, la difficoltà, il dono e il prodotto di una famiglia che `HerdData.TAME` non scrive (dal suo ruolo e dalla
## sua prima specie). {} se la famiglia non esiste.
static func default_tame(fam: String) -> Dictionary:
	if _tame.has(fam):
		return _tame[fam]
	var fd: Dictionary = FamiliesData.FAMILIES.get(fam, {})
	if fd.is_empty() or (fd.get("members", []) as Array).is_empty():
		return {}
	var role := String(fd.get("role", "neutro"))
	var first := String(fd["members"][0])
	var d := CreaturesData.get_data(first)
	var hp := int(d.get("hp", 20))
	var diff := 1 + int(hp >= 30) + int(hp >= 60) + int(hp >= 120) + int(hp >= 250)
	var out := {"diet": DIETS.get(role, DIETS["neutro"]), "diff": diff}
	out["produce"] = ["lumino", 300, 2, 4]               # (se il suo bottino non ha nulla di suo: qualche Lumino)
	for e in LootData.TABLES.get(String(d.get("loot", "")), []):
		var it := String(e["item"])
		if it != "lumino" and ItemsData.has(it):
			out["produce"] = [it, 240 + 60 * diff, 1, 1]
			break
	var aid: Array = AIDS.get(role, AIDS["neutro"])
	out["aid"] = aid[0]
	out["aid_text"] = aid[1]
	_tame[fam] = out
	return out


## Il dono di chi è in campo: quello scritto in `HerdData.TAME`, o quello del ruolo della famiglia (ogni compagno ne ha
## uno). [effetti, testo].
static func aid_of(fam: String) -> Array:
	var t := HerdData.tame_of(fam)
	if t.has("aid"):
		return [t["aid"], String(t.get("aid_text", ""))]
	var role := String(FamiliesData.FAMILIES.get(fam, {}).get("role", "neutro"))
	return AIDS.get(role, AIDS["neutro"])
