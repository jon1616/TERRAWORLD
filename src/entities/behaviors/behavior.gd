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
		"succhia":
			return BhSucchia.new()
		"lucciola_vena":
			return BhLucciolaVena.new()
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
		# voce 130: le astuzie (`WilesData`)
		"sbuca":
			return BhSbuca.new()
		"divide":
			return BhDivide.new()
		"ladro":
			return BhLadro.new()
		"mimetico":
			return BhMimetico.new()
		"scudo":
			return BhScudo.new()
		"guaritore":
			return BhGuaritore.new()
		"richiamo":
			return BhRichiamo.new()
		"parassita":
			return BhParassita.new()
		"tuffatore":
			return BhTuffatore.new()
		"tessitore":
			return BhTessitore.new()
		"rosicchia":
			return BhRosicchia.new()
		"fotofobo":
			return BhFotofobo.new()
		"pastore":
			return BhPastore.new()
		"scoppia":
			return BhScoppia.new()
		# voce 136: le mosse dei tre Guardiani scritti a mano
		"marea":
			return BhMarea.new()
		"rimodella":
			return BhRimodella.new()
		"correnti":
			return BhCorrenti.new()
		# Roadmap 16: il cielo
		"picchiata":
			return BhPicchiata.new()
		"folgore":
			return BhFolgore.new()
		"deriva":
			return BhDeriva.new()
		"cura_legame":
			return BhCuraLegame.new()             # Roadmap 32: un istinto dei compagni
		"fermo":
			return Behavior.new()
	push_error("comportamento sconosciuto: %s" % id)
	return Behavior.new()


## Il bersaglio è entro `tiles` tessere? Voce 129: lo decide il cervello (`Mind.sees`: luce, olfatto, memoria).
static func sees(c: Creature, tiles: float) -> bool:
	return c.target != null and c.mind.sees(c, tiles)


## Tratto Ombra dell'equipaggiamento: le creature notano il Germogliato più tardi (lo imposta `GearEffects`).
static var stealth := 1.0
## Voce 75: la nebbia accorcia la vista delle creature (lo imposta `Weather`).
static var fog := 1.0
## Voce 85: gli effetti (Muschio che nasconde) per qualche secondo.
static var effect_stealth := 1.0
