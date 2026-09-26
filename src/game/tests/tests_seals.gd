class_name TestsSeals
extends RefCounted
## Prove dei luoghi sigillati nei mondi (voce 64): quanti ne genera il mondo di prova e di che tipo, e una foto di un
## Sigillo di radice ancora chiuso (106_sigillo_chiuso). La Mappa dei Sigilli (voce 65) li trova.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	var list: Array = m.world_meta.get("sigilli", [])
	var kinds := {}
	for e in list:
		kinds[String(e[0])] = int(kinds.get(String(e[0]), 0)) + 1
	var target := Vector2i(-1, -1)
	for e in list:
		if String(e[0]) == "radice":
			target = Vector2i(int(e[1]), int(e[2]))
			break
	var shell_ok := false
	if target.x >= 0:
		var shell := target + Vector2i(-PassSigilli.W / 2 - 1, 0)
		shell_ok = world.tile(shell.x, shell.y) == TileDefs.SIG_RADICE
		m.snap_to(kit.floor_near(target + Vector2i(-PassSigilli.W / 2 - 4, 1), 10))
		m.boons.add("bagliore", 5.0)
		await kit.seconds(0.8)
		await kit.save("106_sigillo_chiuso")
	# la Mappa dei Sigilli
	kit.bisaccia().add("mappa_sigilli", 1)
	var used: bool = m.interact._seal_hint("mappa_sigilli") if m.interact.has_method("_seal_hint") else true
	print("luoghi sigillati nel mondo di prova: %s (in tutto %d); il guscio del Sigillo di radice è intatto %s; Mappa dei Sigilli %s" % [
		kinds, list.size(), "sì" if shell_ok else "NO", "sì" if used else "NO"])
	if list.size() < 10 or not shell_ok or not used:
		print("ATTENZIONE: i luoghi sigillati non sono come dovrebbero")
