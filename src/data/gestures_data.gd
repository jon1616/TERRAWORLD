class_name GesturesData
## Il motore dei gesti (voce 356, Roadmap 38 «Le fondamenta della vastità»; piano in `VASTITA.md`). In Terraria l'80%
## delle armi ha un proiettile tutto suo; da noi la forma decideva il gesto e il materiale solo i numeri (59 gesti per 647
## armi, 29% di armi gemelle). Qui i **moduli** componibili dei proiettili e il **gesto di ogni materiale** (voce 369,
## anticipata): ogni metallo e materiale dei geni aggiunge a tutte le sue armi un effetto al colpo (`fx`, righe di
## `EffectsData`, letti da `Effects`) e un modo di volare per i colpi a distanza (`mods`, letti da `Projectiles`).
## Una lega porta i gesti dei suoi due metalli insieme: 36 leghe = 36 combinazioni diverse.
##
## I moduli dei proiettili (`mods`, si sommano; li applica `Projectiles`):
##   bounce   rimbalza sulla roccia tante volte invece di fermarsi
##   split    [n, frazione]: colpendo una creatura si divide in n schegge (non si dividono ancora)
##   boom     [raggio in tessere, frazione]: colpendo, ferisce anche chi sta attorno
##   ret      dopo tanti secondi torna indietro verso il Germogliato (come un boomerang) e colpisce di nuovo
##   wave     ondeggia: ampiezza in px
##   pierce   creature in più che attraversa
##   homing   quanto insegue (radianti al secondo)
##   speed    moltiplicatore della velocità
## Un materiale nuovo = una riga qui (la verifica dei dati segnala i materiali senza gesto).

const MATERIAL := {
	# i metalli
	"radicite": {"name": "Radice che trattiene", "fx": ["mat_radicite"], "mods": {"bounce": 1},
		"desc": "a volte trattiene la creatura un attimo; i colpi a distanza rimbalzano una volta"},
	"legnoferro": {"name": "Fibra che trapassa", "fx": ["mat_legnoferro"], "mods": {"pierce": 1},
		"desc": "a volte il colpo passa anche a chi sta dietro; i colpi a distanza attraversano una creatura in più"},
	"ambra": {"name": "Ambra che imprigiona", "fx": ["mat_ambra"], "mods": {"boom": [1.5, 0.35]},
		"desc": "a volte rallenta la creatura; i colpi a distanza scoppiano piano attorno"},
	"linfa": {"name": "Linfa che cerca", "fx": ["mat_linfa"], "mods": {"homing": 3.0},
		"desc": "ogni colpo rende un poco di Vita; i colpi a distanza inseguono"},
	"vuoto": {"name": "Vuoto che si spezza", "fx": ["mat_vuoto"], "mods": {"split": [2, 0.4]},
		"desc": "a volte dal colpo partono schegge; i colpi a distanza si dividono in due"},
	"pallidite": {"name": "Gelo pallido", "fx": ["mat_pallidite"], "mods": {"wave": 10.0, "speed": 1.15},
		"desc": "spesso rallenta la creatura; i colpi a distanza volano svelti, ondeggiando"},
	"tizzonite": {"name": "Tizzone", "fx": ["mat_tizzonite"], "mods": {"boom": [2.0, 0.45]},
		"desc": "spesso incendia; i colpi a distanza scoppiano di brace"},
	"stellare": {"name": "Stelle cadenti", "fx": ["mat_stellare"], "mods": {"homing": 2.0, "pierce": 1},
		"desc": "ogni quinto colpo cadono stelle sulla creatura; i colpi a distanza inseguono e attraversano"},
	"nimbite": {"name": "Folgore", "fx": ["mat_nimbite"], "mods": {"bounce": 2, "speed": 1.2},
		"desc": "ogni sesto colpo un fulmine salta su altre due creature; i colpi a distanza rimbalzano due volte"},
	# i materiali dei geni
	"ferro_brina": {"name": "Morso di brina", "fx": ["mat_ferro_brina"], "mods": {"pierce": 1},
		"desc": "a volte gela: la creatura quasi si ferma"},
	"ossidiana_brace": {"name": "Cuore di brace", "fx": ["mat_ossidiana"], "mods": {"boom": [2.5, 0.5]},
		"desc": "spesso incendia forte; i colpi a distanza scoppiano largo"},
	"micelio_duro": {"name": "Spore che restano", "fx": ["mat_micelio"], "mods": {"split": [3, 0.25]},
		"desc": "avvelena; i colpi a distanza si aprono in tre spore"},
	"linfite": {"name": "Linfa che risponde", "fx": ["mat_linfite"], "mods": {"homing": 4.0},
		"desc": "ogni colpo rende Vita e a volte Linfa; i colpi a distanza inseguono stretti"},
	"radicite_pura": {"name": "Radice che stringe", "fx": ["mat_radicite_pura"], "mods": {"bounce": 2},
		"desc": "spesso trattiene la creatura; i colpi a distanza rimbalzano due volte"},
	"ambra_dorata": {"name": "Ambra che paga", "fx": ["mat_ambra_dorata"], "mods": {"boom": [1.5, 0.3]},
		"desc": "a volte il colpo fa cadere Lumini; le creature sconfitte ne lasciano di più"},
	"ferro_stellato": {"name": "Pioggia di stelle", "fx": ["mat_ferro_stellato"], "mods": {"homing": 2.5, "pierce": 2},
		"desc": "ogni quarto colpo cadono stelle; i colpi a distanza inseguono e attraversano due creature"},
	"vuoto_cavo": {"name": "Eco del vuoto", "fx": ["mat_vuoto_cavo"], "mods": {"ret": 0.45},
		"desc": "i colpi tornano indietro e colpiscono due volte; a volte il colpo rimbalza su un'altra creatura"},
	"sospesite": {"name": "Leggerezza", "fx": ["mat_sospesite"], "mods": {"wave": 14.0, "speed": 1.3},
		"desc": "dopo ogni creatura sconfitta corri più svelto; i colpi volano veloci e ondeggiano"},
	"nerume": {"name": "Ombra che morde", "fx": ["mat_nerume"], "mods": {"split": [2, 0.5]},
		"desc": "rende la creatura vulnerabile (gli altri colpi fanno di più); i colpi a distanza si dividono"},
	"chitina": {"name": "Guscio che respinge", "fx": ["mat_chitina"], "mods": {"bounce": 1, "pierce": 1},
		"desc": "chi ti colpisce si ferisce sulle spine; i colpi a distanza rimbalzano e attraversano"},
	"osso_antico": {"name": "Memoria antica", "fx": ["mat_osso"], "mods": {"ret": 0.55},
		"desc": "ogni ottavo colpo stordisce tutto attorno; i colpi tornano indietro"},
}


## Il gesto di un materiale (anche delle leghe: i due metalli insieme). {} se non ne ha.
static func of_mat(mat: String) -> Dictionary:
	if MATERIAL.has(mat):
		return MATERIAL[mat]
	if SpineData.GESTURES.has(mat):                      # Roadmap 39: i metalli del Risveglio
		return SpineData.GESTURES[mat]
	if mat.begins_with("lega_"):
		var parts := _alloy_parts(mat)
		if parts.size() == 2 and MATERIAL.has(parts[0]) and MATERIAL.has(parts[1]):
			var a: Dictionary = MATERIAL[parts[0]]
			var b: Dictionary = MATERIAL[parts[1]]
			return {"name": "%s e %s" % [a["name"], String(b["name"]).to_lower()], "fx": (a["fx"] as Array) + (b["fx"] as Array),
				"mods": merge_mods(a["mods"], b["mods"]), "desc": "%s; e %s" % [a["desc"], b["desc"]]}
	return {}


## I due metalli di una lega («lega_radicite_legnoferro» → ["radicite", "legnoferro"]).
static func _alloy_parts(mat: String) -> Array:
	var rest := mat.trim_prefix("lega_")
	for a in MATERIAL:
		if rest.begins_with(String(a) + "_") and MATERIAL.has(rest.substr(String(a).length() + 1)):
			return [String(a), rest.substr(String(a).length() + 1)]
	return []


## Due gruppi di moduli insieme: i numeri si sommano (le velocità si moltiplicano), le coppie si tengono la più forte.
static func merge_mods(a: Dictionary, b: Dictionary) -> Dictionary:
	var out := a.duplicate(true)
	for k in b:
		if not out.has(k):
			out[k] = b[k]
		elif k == "speed":
			out[k] = float(out[k]) * float(b[k])
		elif b[k] is Array:
			if float(b[k][1]) > float(out[k][1]):
				out[k] = b[k]
		else:
			out[k] = float(out[k]) + float(b[k])
	return out


## Il danno in più contro **una** creatura, in media, dato dal gesto (per `FightModel` e gli strumenti del bilancio):
## le fiamme, il veleno, le stelle che cadono, la vulnerabilità. Ciò che colpisce altre creature (schegge, catene,
## trapassare, scoppi) o difende (rallentare, trattenere) qui non conta: rende di più nei gruppi e nelle ferite evitate.
static func single_bonus(mat: String) -> float:
	var k := 0.0
	for id in of_mat(mat).get("fx", []):
		var e: Dictionary = EffectsData.info(String(id))
		var ch := float(e.get("chance", 1.0))
		match String(e.get("do", "")):
			"brucia":
				k += ch * 0.6                  # un quarto del colpo al secondo, ma le fiamme non si sommano
			"avvelena":
				k += ch * 0.4
			"vulnera":
				k += ch * 0.15
			"pioggia":
				k += float(e.get("shards", 3)) * float(e.get("dmg", 0.5)) / float(e.get("n", 5)) * 0.8
	return k

