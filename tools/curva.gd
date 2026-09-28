extends SceneTree
## Voce 179 (Roadmap 18): la curva della difficoltà secondo `ZoneModel`. Per ogni grado di equipaggiamento (arma e
## armatura intera dello stesso metallo) e ogni zona (strato × vigore): la **pressione** (Vita persa per creatura
## sconfitta, in % della Vita), i secondi per abbatterne una e la ferita di un contatto. Senza finestra:
##   Godot_console.exe --headless --path . --script res://tools/curva.gd -- [--abilita medio] [--nuda]
## `--nuda` = senza armatura (solo l'arma). Scrive prove/curva.txt e lo stampa.

const TIERS := [["iniziale", "spada_radice", ""], ["radicite", "spada_radicite", "radicite"],
	["legnoferro", "spada_legnoferro", "legnoferro"], ["ambra", "spada_ambra", "ambra"], ["linfa", "spada_linfa", "linfa"],
	["vuoto", "spada_vuoto", "vuoto"], ["stellare", "spada_stellare", "stellare"]]
const ZONES := [[0, 1, false], [0, 1, true], [1, 1, false], [2, 1, false], [3, 1, false], [4, 1, false], [2, 2, false],
	[4, 2, false], [4, 3, false], [4, 5, false], [4, 8, false], [4, 12, false]]

var out := ""


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var sk := "medio"
	var i := args.find("--abilita")
	if i >= 0 and i + 1 < args.size():
		sk = args[i + 1]
	var bare := "--nuda" in args
	var skill: Dictionary = FightModel.SKILL[sk]
	_p("CURVA (abilità «%s»%s): pressione %% | secondi per abbattere | ferita di un contatto" % [sk, ", senza armatura" if bare else ""])
	var head := "%-11s" % ""
	for z in ZONES:
		head += " | %-15s" % ("%s%s v%d" % [["Sup", "Sott", "Cav", "Prof", "Fondo"][int(z[0])], " notte" if bool(z[2]) else "", int(z[1])])
	_p(head)
	for t in TIERS:
		var eq := {}
		if String(t[2]) != "" and not bare:
			for piece in ["elmo", "corazza", "gambali", "guanti", "stivali"]:
				if not ItemsData.get_item("%s_%s" % [piece, t[2]]).is_empty():
					eq[piece] = {"id": "%s_%s" % [piece, t[2]]}
		var lo := {"weapon": {"id": String(t[1])}, "equip": eq, "hp": 100.0}
		var row := "%-11s" % t[0]
		var sc := 0
		for z in ZONES:
			var r := ZoneModel.fight(lo, int(z[0]), int(z[1]), skill, bool(z[2]))
			sc = int(r["scorza"])
			row += " | %4.0f%% %4.1fs %3.0f" % [float(r["pressure"]) * 100.0, float(r["ttk"]), float(r["hit"])]
		_p(row + "   (Scorza %d)" % sc)
	var f := FileAccess.open("res://prove/curva.txt", FileAccess.WRITE)
	if f:
		f.store_string(out)
	quit()


func _p(s: String) -> void:
	print(s)
	out += s + "\n"
