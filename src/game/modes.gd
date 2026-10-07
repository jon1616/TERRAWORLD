class_name Modes
extends Node
## Le modalità in partita (Roadmap 49, voce 405; dati in `ModesData`). Legge `world_meta["modalita"]` (0 Normale,
## 1 Radice dura, 2 Vuoto) e regola le creature selvatiche (`Creature.mode_hp/mode_dmg/mode_phase`, applicati da
## `Creature.strengthen` a chi nasce da `Fauna.add`), i Sacchetti e i capi (`bag_extra`, letto da `FirmaDrops`) e, nel
## Vuoto, la **Furia del Giardiniere**: le ferite la caricano (`charge`), piena si scatena per `FURY_TIME` secondi
## (un effetto a tempo dei dati, `BoonsData`: danno e colpi più forti, ogni colpo cura un poco).

var m: Node2D
var mode := 0
var charge := 0.0                        # 0-100
var unleashed := 0                       # per le prove


func setup(main: Node2D) -> void:
	m = main
	mode = clampi(int(m.world_meta.get("modalita", 0)), 0, ModesData.MODES.size() - 1)
	var md := ModesData.of(mode)
	Creature.mode_hp = float(md["hp"])
	Creature.mode_dmg = float(md["dmg"])
	Creature.mode_phase = float(md["phase"])
	m.vitals.wounded.connect(_on_wounded)


func _exit_tree() -> void:
	Creature.mode_hp = 1.0                   # (le prove e il menu tornano alla Normale)
	Creature.mode_dmg = 1.0
	Creature.mode_phase = 1.0


## Quanti oggetti in più dà un Sacchetto o un capo in questa modalità.
func bag_extra() -> int:
	return int(ModesData.of(mode)["bag"])


func _on_wounded(amount: int) -> void:
	if not ModesData.of(mode).get("fury", false) or m.boons.active.has(ModesData.FURY_BOON):
		return
	charge = minf(charge + float(amount) / maxf(float(m.vitals.hp_max), 1.0) * ModesData.FURY_GAIN, 100.0)
	if charge >= 100.0:
		unleash()


func unleash() -> void:
	charge = 0.0
	unleashed += 1
	m.boons.add(ModesData.FURY_BOON, ModesData.FURY_TIME)
	Fx.puff(m.fx, m.player.position, Color(2.0, 0.6, 1.6))
	if m.get("juice") != null:
		m.juice.shake(4.0, 0.3)
	m.hud.toast("La Furia del Giardiniere si scatena!")


## La riga della Furia (per la scheda del personaggio): "" se la modalità non ce l'ha.
func line() -> String:
	if not ModesData.of(mode).get("fury", false):
		return ""
	return "Furia del Giardiniere %d%%" % roundi(charge)
