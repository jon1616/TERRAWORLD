class_name ArtsPanel
extends UiPage
## Le arti (Roadmap 25, voce 251; tasto «arti», I). Rifatto nella Roadmap 55 «Il volto chiaro»: a sinistra le dieci
## forme d'arma con il rango della maestria (e la barra verso il rango dopo), poi le taglie e le prove del Cerchio; a
## destra la voce scelta: la maestria con la sua tecnica e i tre gradi della tecnica come tappe, le taglie aperte e il
## registro, il record delle prove.

const ART := Color("#ff9a6a")
const GOLD := Color("#ffd08a")

var sel := "spada"


func _keys() -> Array:
	return ArtsData.FORMS.keys() + ["taglie", "prove"]


func setup(main: Node2D) -> void:
	m = main
	key_action = "arti"
	visible = false
	build_page("Le arti del combattimento", "Ogni forma d'arma ha la sua maestria: cresce sconfiggendo creature con quell'arma in mano, e apre una tecnica.",
		ArtLib.tex("interfaccia", "pannello_arti") if ArtLib.has("interfaccia", "pannello_arti") else null, ART)
	set_hints([[Keys.label("arti"), "apri e chiudi"], [Keys.label("tecnica"), "la tecnica dell'arma in mano"], ["Clic", "scegli"]])
	split()
	list.chosen.connect(func(id: String) -> void:
		sel = id
		detail_top()
		mark_dirty())


func on_open() -> void:
	var f: String = m.arts.held_form()
	if f != "":
		sel = f
	m.bounties.fill()


func _icon(k: String) -> Variant:
	if k == "taglie":
		return "laccio_intrecciato" if ItemsData.has("laccio_intrecciato") else null
	if k == "prove":
		return ArtLib.tex("interfaccia", "pannello_arti") if ArtLib.has("interfaccia", "pannello_arti") else null
	return ItemIcons.make_ui(String(FormsData.FORMS[k].get("icon", k)), "legnoferro")


func _row(k: String) -> Dictionary:
	match k:
		"taglie":
			return {"id": k, "title": "Le taglie", "sub": "Prede ancestrali del Cacciatore", "badge": "%d riscosse" % int(m.character.taglie.get("fatte", 0)),
				"color": ART, "icon": _icon(k)}
		"prove":
			var r := int(m.character.stats.get("prova_record", 0))
			return {"id": k, "title": "Le prove del Cerchio", "sub": "%d ondate sempre più forti" % Trials.WAVES, "badge": "record %d" % r,
				"color": ART, "frac": float(r) / Trials.WAVES, "icon": _icon(k)}
	var rk: int = m.arts.rank(k)
	var p: int = m.arts.points(k)
	var a := ArtsData.points_for(rk)
	var b := ArtsData.points_for(mini(rk + 1, ArtsData.RANKS))
	var f := 1.0 if rk >= ArtsData.RANKS else clampf(float(p - a) / maxf(float(b - a), 1.0), 0.0, 1.0)
	return {"id": k, "title": String(FormsData.FORMS[k]["name"]), "sub": "Tecnica: %s" % ArtsData.TECHS[k]["name"],
		"badge": "rango %d" % rk, "color": GOLD, "frac": f, "icon": _icon(k), "dim": p <= 0}


func refresh() -> void:
	var items := []
	var ranks := 0
	for k in _keys():
		items.append(_row(String(k)))
		if String(k) in ArtsData.FORMS:
			ranks += int(m.arts.rank(String(k)))
	list.set_items(items, sel)
	set_chips([["%d ranghi" % ranks, GOLD], ["%d taglie" % int(m.character.taglie.get("fatte", 0)), ART],
		["record %d" % int(m.character.stats.get("prova_record", 0))]])
	match sel:
		"taglie":
			_fill_bounties()
		"prove":
			_fill_trials()
		_:
			_fill_form(sel)


func _fill_form(k: String) -> void:
	var t: Dictionary = ArtsData.TECHS[k]
	var rk: int = m.arts.rank(k)
	var g := ArtsData.tech_grade(rk)
	detail.reset(GOLD, detail_w())
	detail.head("La maestria %s" % ArtsData.FORMS[k], "Si cresce sconfiggendo creature con quest'arma in mano.", _icon(k), str(rk), "rango")
	var r := _row(k)
	var pts := "%d punti" % m.arts.points(k)
	if rk < ArtsData.RANKS:
		pts += " su %d per il rango %d" % [ArtsData.points_for(rk + 1), rk + 1]
	else:
		pts += " · il massimo"
	detail.progress(float(r.get("frac", 0.0)), pts)
	detail.chips([["danno con questa forma +%d%%" % roundi(ArtsData.DMG_PER_RANK * 100.0 * rk), UiPalette.BUONO]])
	var tb := detail.section("La tecnica: %s" % t["name"])
	tb.add_child(UiKit.rich("[color=#%s]%s[/color]" % [UiPalette.TESTO.to_html(false), t["desc"]], detail.w))
	tb.add_child(UiKit.stats([["Costo", "%d Linfa" % int(t["linfa"])], ["Attesa", "%d secondi" % roundi(float(t["cd"]))],
		["Tasto", Keys.label("tecnica")]]))
	var steps := []
	for i in 3:
		steps.append({"num": i + 1, "title": "Grado %d · al rango %d" % [i + 1, int(ArtsData.TECH_RANKS[i])],
			"text": "danno ×%.1f" % float(t["mult"][i]), "state": "fatto" if g > i else ("ora" if g == i else "poi")})
	detail.steps("I gradi della tecnica", steps)


func _fill_bounties() -> void:
	var bt: Bounties = m.bounties
	detail.reset(ART, detail_w())
	detail.head("Le taglie", "Il Cacciatore di taglie ti indica una preda ancestrale: più forte, con un tratto antico.", _icon("taglie"),
		str(int(m.character.taglie.get("fatte", 0))), "riscosse")
	if int(m.character.stats.get("guardiani", 0)) < 1:
		detail.empty(_icon("taglie"), "Non ancora", "Il Cacciatore di taglie arriva dopo il tuo primo Guardiano.")
		return
	detail.callout("Come si fa", "Vai nel posto indicato: la preda nasce poco lontano.")
	var open := []
	for b in bt.open_list():
		open.append(["ora", "[b]%s[/b] — %s" % [bt.title(b), bt.where_text(b)], "tratto: " + String(AncientData.TRAITS[String(b["tratto"])]["name"])])
	detail.checklist("Aperte", open)
	var reg: Array = m.character.taglie.get("registro", [])
	var done := []
	for e in reg.slice(maxi(reg.size() - 10, 0)):
		done.append(["fatto", "%s" % e[0], "%s, vigore %d" % [String(CreaturesData.get_data(String(e[1]))["name"]).to_lower(), int(e[2])]])
	detail.checklist("Il registro (%d)" % reg.size(), done)


func _fill_trials() -> void:
	detail.reset(ART, detail_w())
	var rec := int(m.character.stats.get("prova_record", 0))
	detail.head("Le prove del Cerchio", "Al Cerchio dei Seminatori, clic destro due volte: %d ondate delle creature dello strato, sempre più forti, un capo ogni %d." % [
		Trials.WAVES, Trials.BOSS_EVERY], _icon("prove"), str(rec), "record")
	detail.progress(float(rec) / Trials.WAVES, "%d ondate su %d · prove vinte: %d" % [rec, Trials.WAVES, int(m.character.stats.get("prove_vinte", 0))])
	detail.callout("Il premio", "Cresce con le ondate vinte: schegge di vigore, polvere iridata; vincendole tutte anche Linfa antica.")


## La scheda di una voce in testo (per le prove).
func text_of(k: String) -> String:
	match k:
		"taglie":
			return "Le taglie: %d riscosse" % int(m.character.taglie.get("fatte", 0))
		"prove":
			return "Le prove del Cerchio · il tuo record: %d ondate" % int(m.character.stats.get("prova_record", 0))
	var t: Dictionary = ArtsData.TECHS[k]
	return "La maestria %s · rango %d · la tecnica: %s — %s" % [ArtsData.FORMS[k], m.arts.rank(k), t["name"], t["desc"]]
