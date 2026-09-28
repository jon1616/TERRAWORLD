class_name WordChests
extends Node
## Gli scrigni a parola (Roadmap 17, voce 174): clic destro su uno scrigno sigillato da una parola apre la **ruota dei
## glifi** (`GlyphPanel`): la frase con la parola mancante e, da scegliere, le parole di quella classe che il Germogliato
## ha già visto. Giusta: lo scrigno si apre (e dentro c'è di più), la parola diventa certa. Sbagliata: il sigillo si
## chiude per `LOCK` secondi. I sigilli in `world_meta["scrigni_parola"]` (dagli appunti di `PassParole`).

const LOCK := 45.0
const BONUS := "rovina_3"                # il bottino in più di uno scrigno aperto con la parola

var m: Node2D
var panel: GlyphPanel
var opened := 0                          # (prove)


func setup(main: Node2D) -> void:
	m = main
	if not m.world_meta.has("scrigni_parola"):
		m.world_meta["scrigni_parola"] = (m.world.gen_notes.get("scrigni_parola", {}) as Dictionary).duplicate(true)
	panel = GlyphPanel.new()
	m.hud.add_child(panel)
	panel.setup(self)
	m.hud.overlays.append(panel)


func all() -> Dictionary:
	return m.world_meta["scrigni_parola"]


func seal_of(o: Vector2i) -> Dictionary:
	return all().get("%d,%d" % [o.x, o.y], {})


## Clic destro sullo scrigno.
func touch(o: Vector2i) -> bool:
	var e := seal_of(o)
	if e.is_empty():
		return false
	var left := float(e.get("lock", 0.0)) - Time.get_unix_time_from_system()
	if left > 0.0:
		m.hud.toast("Il sigillo è ancora chiuso: riprova tra %d secondi" % ceili(left))
		return true
	m.language.see(e["words"], "scrigno:%d:%d,%d" % [m.world.world_seed, o.x, o.y])
	panel.open(o, e)
	return true


## Le parole che si possono scegliere: quelle almeno viste, della stessa classe e dello stesso strato della mancante.
func choices(e: Dictionary) -> Array:
	var gap := String(e["words"][int(e["gap"])])
	var out := []
	for w in LanguageData.WORDS:
		if m.language.state(String(w)) >= Language.VISTA and LanguageData.class_of(String(w)) == LanguageData.class_of(gap) \
				and LanguageData.layer_of(String(w)) == LanguageData.layer_of(gap):
			out.append(String(w))
	out.sort_custom(func(a: String, b: String) -> bool: return LanguageData.sem(a) < LanguageData.sem(b))
	return out


## La risposta: vero se era giusta (lo scrigno si apre).
func answer(o: Vector2i, w: String) -> bool:
	var e := seal_of(o)
	if e.is_empty():
		return false
	var gap := String(e["words"][int(e["gap"])])
	if w != gap:
		e["lock"] = Time.get_unix_time_from_system() + LOCK
		m.hud.toast("Il sigillo non riconosce «%s» e si richiude: riprova tra %d secondi" % [LanguageData.sem(w), int(LOCK)])
		m.sfx.play("rompi", Vector2(o) * 16.0)
		return false
	all().erase("%d,%d" % [o.x, o.y])
	m.view.remove_station(o)
	m.world.stations[o] = "scrigno"
	m.view.add_station(o)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var loot := LootData.roll_chest(BONUS, rng, 2)
	loot["tavoletta_seminatori"] = int(loot.get("tavoletta_seminatori", 0)) + 1
	for id in loot:
		m.world.chest_at(o).add(String(id), int(loot[id]))
	m.language.confirm([gap], "scrigno")
	opened += 1
	m.objectives.bump("scrigni_parola")
	m.hud.toast("Il sigillo riconosce «%s» (%s) e si apre" % [LanguageData.sem(gap), LanguageData.it(gap)])
	m.sfx.play("dono", Vector2(o) * 16.0)
	return true
