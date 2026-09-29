class_name HerdInfo
extends RefCounted
## I testi della mandria (voce 59): la riga breve di una creatura, la sua scheda (pannello della mandria e casella
## Esamina per il vasetto pieno), fame e umore a parole.

const STATES := {"guardia": "di guardia alla cuccia", "segue": "ti segue", "recinto": "nel recinto", "riposo": "riposa nel Giardino", "vasetto": "in un vasetto"}
const BORN := {"nutrita": "Addomesticata con il cibo", "laccio": "Presa con il laccio", "uovo": "Nata da un uovo",
	"allevata": "Nata nel tuo allevamento"}


static func short(rec: Dictionary) -> String:
	return "%s, %s, livello %d · %s · %s" % [rec["nome"], String(CreaturesData.get_data(String(rec["specie"]))["name"]).to_lower(),
		int(rec["lvl"]), hunger_text(rec), mood_text(rec)]


static func hunger_text(rec: Dictionary) -> String:
	var f := float(rec["fame"])
	return "sazia" if f < 0.4 else ("ha un po' di fame" if f < 0.8 else "affamata")


static func mood_text(rec: Dictionary) -> String:
	var f := float(rec["felice"])
	return "felice" if f > 0.75 else ("tranquilla" if f > 0.4 else "scontenta")


static func diet_text(fam: String) -> String:
	var names := []
	for d in HerdData.tame_of(fam).get("diet", []):
		names.append(String(ItemsData.get_item(String(d))["name"]).to_lower())
	return " o ".join(names)


## La scheda in BBCode.
static func sheet(rec: Dictionary) -> String:
	var d := CreaturesData.get_data(String(rec["specie"]))
	var t := Herd.tame_data(rec)
	var fam := Herd.family_of(rec)
	var out := "[font_size=18][color=#ffd08a]%s[/color][/font_size] [color=#9fc8c0]— %s, famiglia dei %s[/color]\n" % [rec["nome"],
		d["name"], String(FamiliesData.FAMILIES[fam]["name"]).to_lower()]
	out += "[color=#cfeee4]Livello %d (%d/%d) · %s · %s · %s[/color]\n" % [int(rec["lvl"]), int(rec["xp"]),
		HerdData.xp_for(int(rec["lvl"])), STATES.get(String(rec["stato"]), rec["stato"]), hunger_text(rec), mood_text(rec)]
	var st := Herd.stats_of(rec)
	out += "[color=#9fc8c0]Vita %d%% di %d · %s · mangia %s[/color]\n" % [roundi(float(rec["vita"]) * 100.0), int(st["hp"]),
		("danno %d" % int(st["damage"])) if Herd.fights(rec) else "non combatte", diet_text(fam)]
	var p: Array = t["produce"]
	out += "[color=#9fc8c0]Nel recinto: %s, ogni %d minuti circa[/color]\n" % [String(ItemsData.get_item(String(p[0]))["name"]).to_lower(),
		maxi(1, roundi(float(p[1]) / 60.0))]
	if t.has("aid_text"):
		out += "[color=#8ef0d8]Quando ti segue: %s[/color]\n" % t["aid_text"]
	if t.has("mount_text"):
		out += "[color=#8ef0d8]Si cavalca (R): %s[/color]\n" % t["mount_text"]
	var job := HerdJobs.job_of(rec)
	if job != "":
		out += "[color=#ffd08a]Lavoro: %s — %s[/color]\n" % [HerdJobs.JOBS[job]["name"], HerdJobs.JOBS[job]["desc"]]
	var g: Dictionary = rec.get("doti", {})
	if not g.is_empty():
		out += Breeding.sheet(g)                   # voce 60
	out += "[color=#6a8a84]%s[/color]\n" % BORN.get(String(rec["nato"]), "")
	return out
