class_name Behavior
extends RefCounted
## Un comportamento di creatura. Le creature ne combinano più d'uno (es. «cammina» + «carica»): a ogni passo ognuno
## guarda la creatura e il bersaglio e decide cosa vuole fare, scrivendo nelle intenzioni della creatura
## (`want_x`, `want_fly`, `vel` per i salti, `fire` per gli spari, `summons` per chiamare aiuto). La fisica la
## applica poi la creatura.
## Un comportamento nuovo = un file in `behaviors/` + una riga in `make`.


func tick(_c: Creature, _dt: float) -> void:
	pass


static func make(id: String) -> Behavior:
	match id:
		"salta_verso":
			return BhSaltaVerso.new()
		"cammina":
			return BhCammina.new()
		"vola":
			return BhVola.new()
		"carica":
			return BhCarica.new()
		"spara":
			return BhSpara.new()
		"ventaglio":
			return BhVentaglio.new()
		"scatto":
			return BhScatto.new()
		"evoca":
			return BhEvoca.new()
		"agguato":
			return BhAgguato.new()
		"scava":
			return BhScava.new()
		"teletrasporto":
			return BhTeletrasporto.new()
		"guscio":
			return BhGuscio.new()
		"bombarda":
			return BhBombarda.new()
		"mimo":
			return BhMimo.new()
		"fugge":
			return BhFugge.new()                  # le varianti timide (voce 55)
		"nuota":
			return BhNuota.new()                  # voce 73: le creature d'acqua
		"fermo":
			return Behavior.new()
	push_error("comportamento sconosciuto: %s" % id)
	return Behavior.new()


## Il bersaglio è entro `tiles` tessere?
static func sees(c: Creature, tiles: float) -> bool:
	return c.target != null and c.target.position.distance_to(c.position) < tiles * 16.0 * stealth


## Tratto Ombra dell'equipaggiamento: le creature notano il Germogliato più tardi (lo imposta `GearEffects`).
static var stealth := 1.0
