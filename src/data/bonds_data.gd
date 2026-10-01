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


# ---- voce 313: crescere ------------------------------------------------------------------------------------------

## La forza viene dal livello, la specie dà la forma. Ogni specie ha una «forza di specie» (Vita/5 + danno + difesa×2):
## un compagno la porta verso `TOTAL` (con `SHAPE` = 0,75: le specie forti restano un poco più forti), poi cresce di
## `GROWTH` a livello. Misurato con `tools/compagni.gd`: la creatura tipica della Superficie vale un compagno di livello
## 1, quella del Fondo del primo mondo il 21, quella del Fondo al vigore 12 il 44; al 50 un compagno vale ~1,3 volte
## quest'ultima. `HP_K` e `DMG_K` lo pareggiano con le creature selvatiche, che feriscono `DangerData.DAMAGE` volte di
## più: alla pari un compagno da solo vince, ma ne esce ferito. Così un grumo allevato bene vale quanto una lince del
## profondo.
const LVL_MAX := 50
const GROWTH := 1.047
const HP_K := 1.3
const DMG_K := 1.35
const TOTAL := 20.0
const SHAPE := 0.75
const DEF_PER_LVL := 0.12              # difesa che si aggiunge a ogni livello
const SPEED_PER_LVL := 0.004           # velocità in più a ogni livello
const GROW_LVLS := [[20, 1.15], [40, 1.3]]   # al livello 20 e 40 si vede più grande
const FRUIT_STEP := 0.03               # voce 314: ogni Frutto del legame (+3%, o +1 di difesa per la scorza)
const FRUIT_MAX := 10                  # al più dieci frutti di ogni tipo per compagno
## Le rare legate: quanto valgono in più (i loro tratti si aggiungono, da `AncientData.TRAITS`).
const RARE_STATS := {"antica": 1.25, "ancestrale": 1.5, "capobranco": 1.15, "iridata": 1.2}
## L'esperienza: una creatura sconfitta vale secondo il suo «livello» (la sua forza vera rispetto a `TOTAL`), di più se
## è più forte del compagno, di meno se è più debole. Quella sconfitta dal Germogliato mentre il compagno è in campo
## ne dà `SHARE_PLAYER`.
const XP_BASE := 6.0
const XP_PER_LVL := 2.0
const XP_GAP := 0.1
const SHARE_PLAYER := 0.5


## Quanto la specie viene portata verso la forza di riferimento.
static func species_k(sp: String) -> float:
	var d := CreaturesData.get_data(sp)
	var t := float(d.get("hp", 20)) / 5.0 + maxf(float(d.get("damage", 3)), 3.0) + float(d.get("defense", 0)) * 2.0
	return pow(TOTAL / maxf(t, 1.0), SHAPE)


## Vita, danno, difesa e velocità di un compagno. `m_hp`/`m_dmg`: doti dell'allevamento; `rare`: {"r", "t"} della rara
## legata; `fruits`: i Frutti del legame mangiati (voce 314).
static func stats(sp: String, lvl: int, forza: float, m_hp: float, m_dmg: float, rare: Dictionary, fruits: Dictionary) -> Dictionary:
	var d := CreaturesData.get_data(sp)
	var k := species_k(sp)
	var g := pow(GROWTH, float(clampi(lvl, 1, LVL_MAX) - 1))
	var f := sqrt(clampf(forza, 1.0, 4.0))
	var hp_m := 1.0
	var dmg_m := 1.0
	var spd_m := 1.0
	var def_add := 0
	if not rare.is_empty():
		var rm := float(RARE_STATS.get(String(rare.get("r", "")), 1.0))
		hp_m *= rm
		dmg_m *= rm
		for t in rare.get("t", []):
			var td: Dictionary = AncientData.TRAITS.get(String(t), {})
			hp_m *= sqrt(float(td.get("hp", 1.0)))
			dmg_m *= sqrt(float(td.get("damage", 1.0)))
			spd_m *= float(td.get("speed", 1.0))
			def_add += int(td.get("defense", 0))
	hp_m *= 1.0 + FRUIT_STEP * int(fruits.get("vita", 0))
	dmg_m *= 1.0 + FRUIT_STEP * int(fruits.get("forza", 0))
	spd_m *= 1.0 + FRUIT_STEP * 0.5 * int(fruits.get("slancio", 0))
	def_add += int(fruits.get("scorza", 0))
	return {
		"hp": maxi(roundi(float(d.get("hp", 20)) * k * g * f * m_hp * hp_m * HP_K), 1),
		"damage": maxi(roundi(maxf(float(d.get("damage", 3)), 3.0) * k * g * f * m_dmg * dmg_m * DMG_K), 1),
		"defense": roundi(float(d.get("defense", 0)) * sqrt(k) + DEF_PER_LVL * (lvl - 1)) + def_add,
		"speed": float(d.get("speed", 60)) * (1.0 + SPEED_PER_LVL * (lvl - 1)) * spd_m,
	}


## Il «livello» di una creatura qualunque, dalla sua forza vera (Vita e danno di adesso, già cresciuti con lo strato).
static func level_of(hp_max: int, damage: int, defense: int) -> float:
	var t := float(hp_max) / 5.0 + maxf(float(damage), 3.0) + float(defense) * 2.0
	return clampf(1.0 + log(maxf(t, 1.0) / TOTAL) / log(GROWTH), 1.0, 80.0)


## L'esperienza che un compagno di livello `lvl` prende da una creatura di livello `foe_lvl`.
static func xp_from(foe_lvl: float, lvl: int) -> int:
	var gap := clampf(1.0 + XP_GAP * (foe_lvl - float(lvl)), 0.25, 2.0)
	return maxi(roundi((XP_BASE + XP_PER_LVL * foe_lvl) * gap), 1)


## I punti per salire dal livello `lvl` al successivo.
static func xp_for(lvl: int) -> int:
	return 30 + 12 * lvl


## Quanto si vede grande al suo livello.
static func scale_at(lvl: int) -> float:
	var s := 1.0
	for e in GROW_LVLS:
		if lvl >= int(e[0]):
			s = float(e[1])
	return s
