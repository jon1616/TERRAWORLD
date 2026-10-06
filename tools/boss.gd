extends SceneTree
## Voce 186 (Roadmap 18): i boss e gli scontri speciali con `FightModel`. Per ogni boss: l'equipaggiamento atteso quando
## lo si incontra, i secondi per batterlo, la Vita persa (in «Vite»: 1,0 = una Vita piena) e le pozioni che servono,
## per «attento» (arma e armatura del grado) e «medio» (armatura di un grado sotto). Senza finestra:
##   Godot_console.exe --headless --path . --script res://tools/boss.gd
## Scrive prove/boss.txt. La fascia voluta: 45-120 s con l'arma attesa; «attento» finisce con una o due pozioni, «medio»
## ne vuole di più; nessuno cade in meno di 4 colpi. Non si contano i servitori evocati e le fasi (sono in più).

const MATS := ["", "radicite", "legnoferro", "ambra", "linfa", "vuoto", "stellare", "corallite", "sanguinite", "cuorelegno",
	"eterite", "astrite", "primambra"]
## Il momento della partita: vigore → [grado del metallo, Vita massima, tempra] (come `tools/percorso.gd`).
const AT := {1: [3, 130, 0], 2: [4, 160, 0], 3: [5, 190, 0], 4: [5, 220, 0], 5: [6, 250, 2], 6: [7, 300, 2], 8: [9, 360, 2],
	10: [11, 420, 4], 12: [12, 480, 4]}
## Roadmap 39: i Guardiani hanno la Vita delle creature per `SpineData.boss_time` (scontri più lunghi più si sale), il
## danno di `VigorData.creature_dmg`; la fascia voluta dei secondi cresce con lo stesso fattore.
## Il grado atteso nello strato (vigore 1).
const STRATUM_TIER := [1, 1, 2, 3, 3]
const POTION := 50

var out := ""


func _init() -> void:
	_p("BOSS (voce 186): secondi per batterlo | Vita persa in Vite | pozioni | colpi per cadere — attento / medio")
	_p("")
	_p("I Guardiani del Cuore (vigore 1-3 scritti, poi generati)")
	var gl: Array = GuardiansData.LIST
	for v in [1, 2, 3]:
		var cid := String(gl[posmod(v - 1, gl.size())]["creature"])
		_row(cid, v, _bhp(v), VigorData.creature_dmg(v), AT[v])
	# i Guardiani generati cambiano con il seme del mondo: dodici semi per vigore, il più facile e il più difficile
	for v in [4, 6, 8, 10, 12]:
		var rows := []
		for k in 12:
			var gid := "gg~%d" % (1000 + v * 97 + k * 7919)
			var lo := _loadout(int(AT[v][0]), int(AT[v][0]), int(AT[v][2]))
			var fx := FightModel.effects(lo["equip"])
			var f := FightModel.stats_of(CreaturesData.get_data(gid), _bhp(v), VigorData.creature_dmg(v))
			var du := FightModel.duel(FightModel.weapon(lo["weapon"], fx), int(fx["scorza"]), float(AT[v][1]), f,
				FightModel.SKILL["attento"])
			rows.append([float(du["lost"]) / float(AT[v][1]), gid])
		rows.sort_custom(func(a: Array, b: Array) -> bool: return float(a[0]) < float(b[0]))
		_row(String(rows[0][1]), v, _bhp(v), VigorData.creature_dmg(v), AT[v])
		_row(String(rows[rows.size() / 2][1]), v, _bhp(v), VigorData.creature_dmg(v), AT[v])
		_row(String(rows[-1][1]), v, _bhp(v), VigorData.creature_dmg(v), AT[v])
	_p("")
	_p("I Custodi degli strati (vigore 1, l'equipaggiamento dello strato)")
	for k in KeepersData.KEEPERS:
		var kd: Dictionary = KeepersData.KEEPERS[k]
		var s := int(kd["stratum"])
		_row(String(kd["creature"]), 1, 1.0, 1.0, [STRATUM_TIER[s], 100 + 10 * s, 0])
	_p("")
	_p("I Signori (vigore 1: pericolo del loro strato, metà di quello del cielo)")
	var lords: Dictionary = BiomesData.pack("lords")
	for k in lords:
		var ld: Dictionary = lords[k]
		var wh: Dictionary = ld.get("where", {})
		var s := int(wh.get("stratum", 2 if wh.has("under") else 0))
		# come `Lords.strength`: la radice del pericolo dello strato, metà di quello del cielo
		var mult := sqrt(float(StrataData.STRATA[s]["danger"]))
		var tier := maxi(STRATUM_TIER[s], 2)
		if wh.has("sky"):
			var sb := SkyData.get_biome(String(wh["sky"]))
			mult *= 1.0 + (float(sb.get("danger", 1.0)) - 1.0) * 0.5
			tier = 4 if String(sb.get("band", "")) == "alto" else 2   # il cielo alto si raggiunge più avanti
		_row(String(ld["creature"]), 1, mult, mult, [tier, 110 + 10 * s, 0])
	_p("")
	_p("I Grandi Guardiani (vigore 2, la marea, i pilastri, la tempesta)")
	for id in CreaturesData.CREATURES:
		var d: Dictionary = CreaturesData.CREATURES[id]
		if String(d.get("great", "")) != "":
			_row(String(id), 2, _bhp(2), VigorData.creature_dmg(2), AT[2])
	var f := FileAccess.open("res://prove/boss.txt", FileAccess.WRITE)
	if f:
		f.store_string(out)
	quit()


func _p(s: String) -> void:
	print(s)
	out += s + "\n"


func _loadout(tier: int, armor_tier: int, tp: int) -> Dictionary:
	var weapon := {"id": "spada_" + MATS[tier]}
	if tp > 0:
		weapon["dati"] = {"tempra": tp}
	var eq := {}
	if armor_tier >= 1:
		for piece in ["elmo", "corazza", "gambali", "guanti", "stivali"]:
			var id := "%s_%s" % [piece, MATS[armor_tier]]
			if not ItemsData.get_item(id).is_empty():
				eq[piece] = {"id": id, "dati": {"tempra": tp}} if tp > 0 else {"id": id}
	return {"weapon": weapon, "equip": eq}


func _one(cid: String, mult: float, dmg: float, at: Array, armor_lag: int, skill: Dictionary, band := 1.0) -> String:
	var lo := _loadout(int(at[0]), int(at[0]) - armor_lag, int(at[2]))
	var fx := FightModel.effects(lo["equip"])
	var w := FightModel.weapon(lo["weapon"], fx)
	var d := CreaturesData.get_data(cid)
	var f := FightModel.stats_of(d, mult, dmg)           # i boss: Vita e danno × vigore, senza il pericolo delle nascite
	var hp := float(at[1])
	var du := FightModel.duel(w, int(fx["scorza"]), hp, f, skill)
	var lives := float(du["lost"]) / hp
	var pots := ceili(maxf(float(du["lost"]) - hp * 0.7, 0.0) / POTION)
	var flag := ""
	if float(du["ttk"]) < 45.0 * band or float(du["ttk"]) > 120.0 * band:
		flag += "t"
	if int(du["to_die"]) < 4:
		flag += "c"
	return "%5.0fs %4.1f %2d %2d%s" % [float(du["ttk"]), lives, pots, int(du["to_die"]), (" !" + flag) if flag != "" else "   "]


func _row(cid: String, v: int, mult: float, dmg: float, at: Array) -> void:
	var d := CreaturesData.get_data(cid)
	var name := String(d.get("name", cid))
	_p("   v%-2d %-30s Vita %5.0f  | %s | %s" % [v, name.left(30), float(d["hp"]) * mult, _one(cid, mult, dmg, at, 0, FightModel.SKILL["attento"], SpineData.boss_time(v)),
		_one(cid, mult, dmg, at, 1, FightModel.SKILL["medio"], SpineData.boss_time(v))])


func _bhp(v: int) -> float:
	return VigorData.creature_mult(v) * SpineData.boss_time(v)
