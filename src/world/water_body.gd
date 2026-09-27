class_name WaterBody
extends RefCounted
## Uno specchio di liquido (voce 118, Roadmap 14 «Le acque vive»): il liquido collegato attorno a una cella, riconosciuto
## **al momento** (non scritto dal generatore), così un laghetto fatto dal giocatore vale come uno naturale. La carta
## d'identità dice che liquido è, quanto è grande (volume in celle piene), quanto è profondo, in che strato e in che
## bioma si trova; `ok` = abbastanza grande per pescare (`MIN_VOLUME`). Lo useranno la canna (voce 121) e i pesci (120).

const CAP := 4000                      # celle al più da guardare: oltre, è un mare (e basta sapere che è grande)
const MIN_VOLUME := 24.0               # celle piene: sotto non si pesca (niente pesca nelle pozzanghere)


## Lo specchio che contiene la cella c ({} se lì non c'è liquido).
static func at(w: World, c: Vector2i, want_cells := false) -> Dictionary:
	if not w.inside(c.x, c.y):
		return {}
	var i0 := c.y * w.w + c.x
	var lq := w.liquid
	if lq[i0] & 15 == 0:
		return {}
	var type := (lq[i0] >> 4) & 3
	var seen := {i0: true}
	var todo := PackedInt32Array([i0])
	var cells := PackedInt32Array()
	var vol := 0
	var top := c.y
	var bottom := c.y
	var x0 := c.x
	var x1 := c.x
	var cols := {}                      # colonna -> celle di liquido (la profondità)
	while not todo.is_empty() and cells.size() < CAP:
		var k := todo[todo.size() - 1]
		todo.resize(todo.size() - 1)
		cells.append(k)
		vol += lq[k] & 15
		var x := k % w.w
		var y := k / w.w
		top = mini(top, y)
		bottom = maxi(bottom, y)
		x0 = mini(x0, x)
		x1 = maxi(x1, x)
		cols[x] = int(cols.get(x, 0)) + 1
		for d in [k - 1, k + 1, k - w.w, k + w.w]:
			if d < 0 or d >= lq.size() or seen.has(d):
				continue
			if (d == k - 1 and x == 0) or (d == k + 1 and x == w.w - 1):
				continue
			if lq[d] & 15 != 0 and ((lq[d] >> 4) & 3) == type:
				seen[d] = true
				todo.append(d)
	var depth := 0
	for x in cols:
		depth = maxi(depth, int(cols[x]))
	var cx := (x0 + x1) / 2
	var volume := vol / 8.0
	var out := {"type": type, "liquid": String(LiquidsData.TYPES[type]["id"]), "volume": volume, "cells": cells.size(),
		"top": top, "bottom": bottom, "x0": x0, "x1": x1, "depth": depth, "center": Vector2i(cx, top),
		"stratum": StrataData.at(w, cx, top), "biome": int(w.biomes[clampi(cx, 0, w.w - 1)]),
		"big": cells.size() >= CAP, "ok": volume >= MIN_VOLUME}
	if want_cells:
		out["list"] = cells
	return out


## In breve, per le schede e le prove: «Acqua · 86 celle · profonda 5 · Superficie, Foresta-lanterna».
static func describe(b: Dictionary) -> String:
	if b.is_empty():
		return ""
	return "%s · %s celle · profonda %d · %s, %s%s" % [String(LiquidsData.TYPES[int(b["type"])]["name"]),
		"più di %d" % CAP if b["big"] else str(roundi(float(b["volume"]))), int(b["depth"]),
		StrataData.STRATA[int(b["stratum"])]["name"], BiomesData.BIOMES[int(b["biome"])]["name"],
		"" if b["ok"] else " (troppo piccolo per pescare)"]
