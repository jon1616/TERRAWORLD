class_name GearEffects
extends Node
## Gli effetti degli accessori indossati (campo `acc` in `ItemsData`), ricalcolati ogni volta che cambia la Bisaccia:
##   run        corsa più veloce (moltiplica `Player.run_mult`)
##   jump       salto più alto (`Player.jump_mult`)
##   glide      tenendo Spazio in caduta si plana (`Player.glide`)
##   fall_safe  niente ferite da caduta (`Life.fall_safe`)
##   halo       alone del Germogliato più ampio (`Boons.halo_mult`)
##   regen      la Vita ricresce più in fretta (`Vitals.regen_mult`)
##   thorns     danno a chi tocca il Germogliato (`Combat.thorns`); luck: fortuna nel bottino (`Fauna.luck`)
##   dig        scavo e taglio più rapidi (`PlayerActions.dig_mult`); stealth: le creature vedono meno lontano
## La Scorza degli accessori (campo `defense`) la somma già `Bisaccia.scorza`.

var m: Node2D


func setup(main: Node2D) -> void:
	m = main
	m.character.bisaccia.changed.connect(refresh)
	refresh()


func refresh() -> void:
	var run := 1.0
	var jump := 1.0
	var glide := false
	var safe := false
	var halo := 1.0
	var regen := 1.0
	var luck := 0.0
	var thorns := 0
	var stealth := 1.0
	var dig := 1.0
	var b: Bisaccia = m.character.bisaccia
	for slot in b.equip:
		var acc: Dictionary = ItemsData.get_item(String(b.equip[slot])).get("acc", {})
		run *= float(acc.get("run", 1.0))
		jump *= float(acc.get("jump", 1.0))
		glide = glide or bool(acc.get("glide", false))
		safe = safe or bool(acc.get("fall_safe", false))
		halo *= float(acc.get("halo", 1.0))
		regen *= float(acc.get("regen", 1.0))
		thorns += int(acc.get("thorns", 0))
		luck += float(acc.get("luck", 0.0))
		dig *= float(acc.get("dig", 1.0))
		stealth *= float(acc.get("stealth", 1.0))
		var tr := String(b.equip_traits.get(slot, ""))
		run *= TraitsData.effect(tr, "run")
		halo *= TraitsData.effect(tr, "halo")
		regen *= TraitsData.effect(tr, "regen")
		luck += TraitsData.effect(tr, "luck")
		thorns += int(TraitsData.effect(tr, "thorns"))
		stealth *= TraitsData.effect(tr, "stealth")
	m.player.run_mult = run
	m.player.jump_mult = jump
	m.player.glide = glide
	m.life.fall_safe = safe
	m.boons.halo_mult = halo
	m.vitals.regen_mult = regen
	m.fauna.luck = luck
	m.combat.thorns = thorns
	Behavior.stealth = stealth
	m.actions.dig_mult = dig
