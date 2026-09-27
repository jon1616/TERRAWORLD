class_name TestsLegends
extends RefCounted
## Prove dei Semi leggendari e del Seme Primo (voce 81): ogni leggenda ha tre geni esistenti di categorie diverse (uno
## stellare); un genoma che li porta è leggendario e si chiama così; compiere una leggenda la segna; con le tre
## condizioni l'Albero-Madre dona il Seme Primo (Mosaico, geni stellari, vigore più alto). Foto 148_leggende.

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	var lg: Legends = m.legends
	var ch: Character = m.character
	var bad := []
	for k in LegendsData.LEGENDS:
		var ld: Dictionary = LegendsData.LEGENDS[k]
		var cats := {}
		var star := false
		for g in ld["needs"]:
			var d := GenesData.info(String(g))
			if d.is_empty():
				bad.append("%s: gene %s" % [k, g])
				continue
			if cats.has(d["cat"]):
				bad.append("%s: due geni di %s" % [k, d["cat"]])
			cats[d["cat"]] = true
			star = star or int(d["rar"]) == 3
		if not star:
			bad.append("%s senza geni stellari" % k)
		if not ItemsData.get_item(String(ld["gift"])).has("name"):
			bad.append("%s: dono %s" % [k, ld["gift"]])
	# un genoma leggendario
	var gs := ["foresta"] + (LegendsData.LEGENDS["abisso"]["needs"] as Array)
	var known0: Dictionary = Genome.known.duplicate()
	var desc := Genome.describe({"geni": gs, "vigore": 6})
	var found := Legends.of_genes(gs)
	var plain := Legends.of_genes(["foresta", "sommerso"])
	# compiere una leggenda
	var lg0: Dictionary = ch.leggende.duplicate()
	var l0 := lg.legend
	lg.legend = "abisso"
	lg._on_resolved("curato")
	var completed := ch.leggende.has("abisso")
	lg.legend = l0
	# il Seme Primo
	var p0 := lg.progress()
	var ready0 := lg.ready_for_primo()
	var st0 := int(ch.albero.get("stadio", 0))
	ch.albero["stadio"] = MotherTreeData.STAGES.size()
	for g in GenesData.GENES:
		Genome.known[String(g)] = 2
	ch.leggende["notte_stellata"] = 1
	var ready1 := lg.ready_for_primo()
	var bag: Bisaccia = kit.bisaccia()
	var genome := lg.give_primo()
	var in_bag := false
	for i in bag.slots.size():
		if bool(bag.data_at(i).get("primo", false)):
			in_bag = true
			bag.slots[i] = {}
	bag.changed.emit()
	var pdesc := Genome.describe(genome)
	var pcats := {}
	for g in genome["geni"]:
		pcats[GenesData.cat_of(String(g))] = true
	# la pagina dell'Enciclopedia
	var ep: EncyPanel = m.encyclopedia.panel
	m.guardian.lore.visible = false
	m.encyclopedia.open("cap:leggende")
	await kit.frames(4)
	await kit.save("148_leggende")
	ep.close_panel()
	await kit.frames(2)
	# si rimette tutto com'era
	ch.albero["stadio"] = st0
	Genome.known.clear()
	Genome.known.merge(known0)
	ch.leggende = lg0
	print("leggende: %d, problemi %s; genoma dell'abisso «%s» (%s), senza i tre geni «%s»; compiuta %s; Seme Primo: pronto prima %s, con tutto %s, nella Bisaccia %s, «%s», vigore %d, categorie %d; avanzamento %s" % [
		LegendsData.LEGENDS.size(), bad, desc, found, plain, "sì" if completed else "NO", "sì" if ready0 else "no",
		"sì" if ready1 else "NO", "sì" if in_bag else "NO", pdesc, int(genome["vigore"]), pcats.size(), p0])
	if not bad.is_empty() or found != "abisso" or plain != "" or not desc.begins_with(Legends.name_of("abisso")) \
			or not completed or ready0 or not ready1 or not in_bag or not pdesc.begins_with("Seme Primo") \
			or not "mosaico" in genome["geni"] or pcats.size() != genome["geni"].size() or int(genome["vigore"]) < Genome.local_vigor + 5:
		print("ATTENZIONE: i Semi leggendari o il Seme Primo non funzionano come dovrebbero")
