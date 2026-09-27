class_name HiddenCreatures
extends RefCounted
## Le creature nascoste (voce 97, creature e bottino in `src/data/hidden_creatures.gd`): ogni `EVERY` secondi, se la
## condizione di una c'è e non ce n'è già una in giro, a volte (`CHANCE`) ne esce una a qualche tessera dal
## Germogliato. Condizioni: notte in superficie, un tempo, una stagione, un oggetto in mano sotto terra. La prima volta
## che se ne incontra una si conta (`nascoste`: obiettivo, diario). Lo chiama `Secrets`.

const EVERY := 5.0
const CHANCE := 0.06
const CONDITIONS := {
	"lucciola_mezzanotte": {"when": "notte", "surface": true, "hint": "nelle notti, in superficie"},
	"spirito_temporale": {"when": "meteo", "value": "temporale", "surface": true, "hint": "durante un temporale, allo scoperto"},
	"cervo_gelo_bianco": {"when": "stagione", "value": "gelo", "surface": true, "hint": "nella stagione del Gelo, in superficie"},
	"gatto_lanterna": {"when": "mano", "value": "lanterna_linfa", "surface": false, "hint": "a chi porta in mano una Lanterna di Linfa sotto terra"},
}


## Le condizioni di ognuna, adesso: {id: vero/falso}.
static func active(m: Node2D) -> Dictionary:
	var out := {}
	var surface: bool = m.depth_watch.stratum == 0 and not m.giardino.active
	for cid in CONDITIONS:
		var cd: Dictionary = CONDITIONS[cid]
		var ok: bool = surface == bool(cd["surface"])
		match String(cd["when"]):
			"notte":
				ok = ok and m.day.is_night()
			"meteo":
				ok = ok and m.weather != null and String(m.weather.id) == String(cd["value"])
			"stagione":
				ok = ok and m.seasons != null and m.seasons.current >= 0 \
					and String(SeasonsData.SEASONS[m.seasons.current]["id"]) == String(cd["value"])
			"mano":
				ok = ok and String(m.hud.current().get("id", "")) == String(cd["value"])
		out[cid] = ok
	return out


static func try_spawn(m: Node2D, rng: RandomNumberGenerator, force := false) -> Creature:
	for c in m.fauna.list:
		if c.has_meta("nascosta"):
			return null
	var act := active(m)
	for cid in act:
		if not act[cid] or (not force and rng.randf() > CHANCE):
			continue
		var cell := _spot(m, rng, bool(CONDITIONS[cid]["surface"]))
		if cell.x < 0:
			continue
		var cr: Creature = m.fauna.add(String(cid), Vector2(cell.x * 16 + 8, (cell.y + 1) * 16 - float(CreaturesData.get_data(cid)["half"][1]) - 0.1))
		cr.set_meta("nascosta", true)
		cr.extra = true
		var st: Dictionary = m.character.stats
		if not st.has("nascosta_" + String(cid)):
			st["nascosta_" + String(cid)] = 1
			m.objectives.bump("nascoste")            # la prima volta che se ne incontra una di questa specie
		m.hud.toast("Qualcosa di raro si aggira qui vicino…")
		return cr
	return null


## Un posto a 16-26 tessere dal Germogliato: in superficie sul terreno, sotto terra su un pavimento di grotta.
static func _spot(m: Node2D, rng: RandomNumberGenerator, surface: bool) -> Vector2i:
	var w: World = m.world
	var pc: Vector2i = m.player_cell()
	for k in 20:
		var x := pc.x + (1 if rng.randf() < 0.5 else -1) * rng.randi_range(16, 26)
		if not w.inside(x, 2):
			continue
		if surface:
			return Vector2i(x, w.surface[x] - 1)
		for dy in range(-8, 9):
			var y := pc.y + dy
			if w.inside(x, y + 1) and not w.solid(x, y) and not w.solid(x, y - 1) and w.solid(x, y + 1):
				return Vector2i(x, y)
	return Vector2i(-1, -1)
