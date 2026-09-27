class_name EncyCatalogs
extends RefCounted
## I cataloghi dell'Enciclopedia (27 set 2026), tutti nati dai dati: le liste in linea dei capitoli (`inline`), i
## cataloghi completi (`catalog`) e le schede di un oggetto, di una creatura, di un gene. Vedi `EncyPages`.

const G := "#ffd08a"                    # oro: i nomi
const T := "#cfeee4"                    # testo
const D := "#8aa8a2"                    # spento


static func _b(name: String, desc: String, col := G) -> String:
	return "• [color=%s]%s[/color] — [color=%s]%s[/color]" % [col, name, T, desc]


## Una lista in linea per un segnaposto dei capitoli ({cat_strati} → "cat_strati").
static func inline(key: String) -> String:
	var rows := []
	match key:
		"tabella_tasti":
			var group := ""
			for a in KeysData.ACTIONS:
				if String(a[3]) != group:
					group = String(a[3])
					rows.append("[b]%s[/b]" % group)
				rows.append("• [color=%s]%s[/color]  %s" % [G, Keys.labels(String(a[0])), a[1]])
		"cat_strati":
			for s in StrataData.STRATA:
				rows.append(_b(String(s["name"]), String(s.get("desc", ""))))
		"cat_biomi":
			for b in BiomesData.BIOMES:
				var rare := " [color=#ffb0f0](raro: nasce solo da un innesto con mutazione)[/color]" if int(b["weight"]) == 0 else ""
				rows.append(_b(String(b["name"]), String(b.get("desc", "")) + rare))
		"cat_stagioni":
			for s in SeasonsData.SEASONS:
				rows.append(_b(String(s["name"]), String(s["desc"]), String(s.get("color", G)) if s.get("color") is String else G))
		"cat_eventi":
			for id in EventsData.EVENTS:
				var e: Dictionary = EventsData.EVENTS[id]
				rows.append(_b(String(e["name"]), "%s (%s)" % [e["desc"], "di notte" if String(e.get("when", "")) == "notte" else "di giorno"]))
		"cat_collezioni":
			var names := []
			for c in RelicsData.COLLECTIONS:
				names.append("%s: %s" % [RelicsData.COLLECTIONS[c]["name"], RelicsData.COLLECTIONS[c]["desc"]])
			return "; ".join(names)
		"cat_minerali":
			var ores := TileDefs.POWER.keys().filter(func(t: int) -> bool: return int(TileDefs.POWER[t]) < 999 and TileDefs.NAMES.has(t) \
				and String(TileDefs.DROP.get(t, "")).begins_with("minerale") or t == TileDefs.CRYSTAL)
			ores.sort_custom(func(a: int, b: int) -> bool: return int(TileDefs.POWER[a]) < int(TileDefs.POWER[b]))
			for t in ores:
				var p := int(TileDefs.POWER[t])
				rows.append(_b(String(TileDefs.NAMES[t]), "forza del piccone %s" % (str(p) if p > 0 else "qualunque")))
		"cat_alberi":
			for s in TreesData.SPECIES:
				rows.append(_b(String(s["name"]), "nel bioma %s" % _biome_name(String(s["biome"]))))
		"cat_colture":
			for id in CropsData.CROPS:
				var c: Dictionary = CropsData.CROPS[id]
				rows.append(_b(String(c["name"]), "matura in %d minuti, dal seme %s" % [ceili(float(c["grow"]) / 60.0),
					EncyPages.item_link(String(c["seed"]))]))
		"cat_banchi":
			for sid in StationsData.STATIONS:
				var n := StationTip.recipes_at(String(sid))
				if n > 0:
					rows.append(_b(String(StationsData.STATIONS[sid]["name"]), "%d ricette · %s" % [n,
						TipWordsData.STATION_USE.get(sid, "")]))
			rows.append(_b("A mano", "%d ricette, ovunque" % StationTip.recipes_at("")))
		"cat_materiali_breve":
			var ms := MaterialsData.MATERIALS.keys()
			ms.sort_custom(func(a: String, b: String) -> bool: return int(MaterialsData.MATERIALS[a]["tier"]) < int(MaterialsData.MATERIALS[b]["tier"]))
			for k in ms:
				var md: Dictionary = MaterialsData.MATERIALS[k]
				rows.append(_b(String(md["label"]).trim_prefix("di ").trim_prefix("d'").capitalize(), "grado %d%s" % [int(md["tier"]),
					(", elemento %s" % ElementsData.tag(String(md["elemento"]))) if String(md.get("elemento", "")) != "" else ""]))
		"cat_forme":
			for f in FormsData.FORMS:
				var fd: Dictionary = FormsData.FORMS[f]
				rows.append(_b(String(fd["name"]), String(fd.get("desc", TipWordsData.kind_name(String(fd["kind"]))))))
		"cat_qualita":
			var qs := []
			for q in TraitsData.QUALITY:
				qs.append("[color=%s]%s[/color] (×%s)" % [q["color"], q["name"], ItemTip.num(float(q["mult"]))])
			return ", ".join(qs)
		"cat_fasce":
			for f in FormsData.FASCE:
				var fd: Dictionary = FormsData.FASCE[f]
				rows.append(_b("Fascia di %s" % fd["name"], "%s · %d %s" % [fd["desc"], int(fd["n"]), EncyPages.item_link(String(fd["item"]))]))
		"cat_set":
			var all := SetsData.all()
			for s in all:
				rows.append(_b(String(all[s]["name"]), String(all[s]["desc"])))
		"cat_elementi":
			for e in ElementsData.ELEMENTS:
				var ed: Dictionary = ElementsData.ELEMENTS[e]
				rows.append(_b(String(ed["name"]), String(ed["desc"]), String(ed["color"])))
		"cat_reazioni":
			for r in ElementsData.REACTIONS:
				rows.append(_b("%s (%s + %s)" % [r["name"], ElementsData.ELEMENTS[r["pair"][0]]["name"], ElementsData.ELEMENTS[r["pair"][1]]["name"]],
					String(r["desc"]), String(r["color"])))
		"cat_guardiani":
			for g in GuardiansData.LIST:
				rows.append(_b(EncyPages.creature_link(String(g["creature"])), String(g.get("wake", "")), String(g["color"])))
			rows.append("[color=%s]Dopo il terzo vigore i Guardiani tornano, sempre più forti.[/color]" % D)
		"cat_custodi":
			for k in KeepersData.KEEPERS:
				var kd: Dictionary = KeepersData.KEEPERS[k]
				rows.append(_b(EncyPages.creature_link(String(kd["creature"])), "nello strato «%s»" % StrataData.STRATA[int(kd["stratum"])]["name"],
					String(kd["color"])))
		"cat_abitanti":
			for n in NpcData.NPCS:
				var nd: Dictionary = NpcData.NPCS[n]
				rows.append(_b(String(nd["name"]), "«%s»" % nd.get("greet", "")))
		"cat_rarita":
			var rs := []
			for r in GenesData.RARITY:
				rs.append("[color=%s]%s[/color]" % [r["color"], r["name"]])
			return ", ".join(rs)
		"cat_categorie_geni":
			for c in GenesData.CATEGORIES:
				var ci: Dictionary = GenesData.CAT_INFO[c]
				rows.append(_b(String(ci["name"]), "si preleva in %s" % ci["where"], String(ci["color"])))
		"cat_firme":
			for s in SignaturesData.SIGNATURES:
				var sd: Dictionary = SignaturesData.SIGNATURES[s]
				rows.append(_b(String(sd["name"]).capitalize(), String(sd["desc"])) if EncyPages.show_all else
					"• [color=%s]una firma: %s[/color]" % [D, "si scopre trovandola"])
			if not EncyPages.show_all:
				return "Ci sono %d firme diverse: le scopri trovandole (o con le anticipazioni)." % SignaturesData.SIGNATURES.size()
		"cat_stadi":
			for i in MotherTreeData.STAGES.size():
				var st: Dictionary = MotherTreeData.STAGES[i]
				rows.append(_b("%d. %s" % [i + 1, st["name"]], "«%s»" % st["say"]))
		"cat_luoghi":
			for id in PlacesData.PLACES:
				var pd: Dictionary = PlacesData.PLACES[id]
				var seen: bool = EncyPages.show_all or (EncyPages.ch != null and EncyPages.ch.stats.has("luogo_" + String(id)))
				if not seen:
					rows.append("• [color=%s]un luogo che non hai ancora trovato[/color]" % D)
					continue
				var gn := (pd["genes"] as Array).map(func(g: String) -> String: return String(GenesData.GENES[g]["name"]))
				rows.append(_b(String(pd["name"]), "%s · nei mondi con %s · %s" % [pd["banner"], " o ".join(gn),
					"in superficie" if pd.get("surface", false) else "nello strato «%s»" % StrataData.STRATA[int(pd["strata"][0])]["name"]],
					String(pd["color"])))
		"cat_nascoste":
			for cid in HiddenCreatures.CONDITIONS:
				var cd: Dictionary = HiddenCreatures.CONDITIONS[cid]
				rows.append(_b(String(CreaturesData.CREATURES[cid]["name"]), "creatura nascosta: esce solo %s" % cd["hint"], "#c890ff"))
		"cat_segreti":
			for g in SecretsData.GRADES.size():
				var gd: Dictionary = SecretsData.GRADES[g]
				var kinds := []
				for k in SecretsData.KINDS:
					if int(SecretsData.KINDS[k]["grade"]) == g:
						kinds.append(String(SecretsData.KINDS[k]["name"]))
				rows.append(_b(String(gd["name"]).capitalize(), "%s · premio: %d Lumini e il bottino %s%s" % [", ".join(kinds),
					int(gd["lumini"]), ["delle rovine vicine", "delle rovine", "delle rovine profonde", "più ricco del profondo"][g],
					(", a volte un oggetto unico" if float(gd["unique"]) > 0.0 else "")], String(gd["color"])))
		"cat_rigori":
			for b in BiomesData.BIOMES:
				if not b.has("harsh"):
					continue
				var kd: Dictionary = HarshData.KINDS[String(b["harsh"]["kind"])]
				var gear := []
				var items: Dictionary = b.get("items", {})
				for iid in items:
					if (items[iid].get("acc", {}) as Dictionary).has(String(kd["acc"])) and not items[iid].get("unique", false) \
							and not items[iid]["kind"] in ["elmo", "corazza", "gambali"]:
						gear.append(String(items[iid]["name"]))
					elif items[iid].has("boon"):
						gear.append(String(items[iid]["name"]) + " (rimedio)")
				rows.append(_b(String(b["name"]), "%s — %s. Ripara: %s%s" % [kd["name"], kd["desc"], ", ".join(gear),
					" · il terreno ferisce" if b.has("hurt_tile") else ""], String(kd["color"])))
		"cat_sottosuolo":
			for u in UnderBiomesData.UNDER:
				var ud: Dictionary = UnderBiomesData.UNDER[u]
				rows.append(_b(String(ud["name"]), "%s · %s" % [ud["desc"], StrataData.STRATA[int(ud["stratum"])]["name"]], "#b890ff"))
		"cat_ali":
			for id in FlightData.WINGS:
				rows.append(_b(String(FlightData.WINGS[id]["name"]), FlightData.line(id), String(FlightData.WINGS[id]["color"])))
		"cat_regole_nascita":
			rows.append(_b("Lontano da te", "fuori dalla visuale: tra %d e %d tessere (le esche: almeno %d)" % [
				int(DangerData.SPAWN_MIN), int(DangerData.SPAWN_MAX), FarmData.AWAY], "#8ef0d8"))
			rows.append(_b("Lontano dalle torce", "nessuna nasce entro %d tessere da una torcia" % int(FarmData.TORCH), "#ffd24a"))
			rows.append(_b("Al buio sotto terra", "sotto la Superficie si nasce solo dove la luce è sotto il %d%%" % roundi(DangerData.DARK * 100.0), "#b070f0"))
			rows.append(_b("Con i piedi per terra", "chi non vola ha bisogno di due tessere d'aria e del pavimento", "#c8c0b0"))
			rows.append(_b("Strato e bioma", "ogni creatura ha i suoi strati; in superficie anche i suoi biomi, e alcune solo di notte", "#7ed67a"))
			rows.append(_b("Un tetto per zona", "più il posto è pericoloso, più creature insieme e più in fretta; il Totem della quiete le ferma", "#ff8a6a"))
		"cat_farm":
			for id in FarmData.BAITS:
				var b: Dictionary = FarmData.BAITS[id]
				rows.append(_b(String(b["name"]), "chiama chi lascia l'oggetto posato: entro %d tessere, una ogni %d s, al più %d insieme, un'esca ogni %d chiamate" % [
					int(b["r"]), int(b["every"]), int(b["cap"]), int(b["per"])], "#ffb070"))
			for id in FarmData.HOPPERS:
				var h: Dictionary = FarmData.HOPPERS[id]
				rows.append(_b(String(h["name"]), "una cassa da %d caselle che aspira gli oggetti entro %d tessere" % [int(h["slots"]), int(h["r"])], "#e0c080"))
			rows.append(_b("Nastro di radici", "spinge gli oggetti caduti; clic destro cambia verso", "#c8a070"))
			rows.append(_b("Radice-ancora", "entro %d tessere la farm lavora anche quando sei lontano" % FarmData.ANCHOR_R, "#8ef0d8"))
		"cat_trappole":
			for t in TrapsData.TYPES:
				var td: Dictionary = TrapsData.TYPES[t]
				rows.append(_b(String(td["name"]), Traps.describe(TrapsData.id_of(t, 0)), String(td["color"])))
		"cat_totem":
			for t in ZonesData.TYPES:
				var td: Dictionary = ZonesData.TYPES[t]
				rows.append(_b(String(td["name"]), "%s%s" % [td["desc"], " [color=#ff9a7a](scambio)[/color]" if td.get("cost", false) else ""],
					String(td["color"])))
		"cat_gemme":
			for g in JewelsData.GEMS:
				var gd: Dictionary = JewelsData.GEMS[g]
				var parts := []
				for k in gd["amulet"]:
					var v := float(gd["amulet"][k]) * 3              # il valore di un amuleto di grado 3
					parts.append(TipWordsData.acc_line(String(k), v if k in JewelsData.ADD else 1.0 + v)[0])
				rows.append(_b(String(ItemsData.get_item(g).get("name", g)), "amuleto: %s · anello: %s" % [", ".join(parts),
					EffectsData.line(String(gd["effect"]))]))
		"cat_effetti":
			for k in EffectsData.EFFECTS:
				rows.append(_b(String(EffectsData.EFFECTS[k]["name"]), String(EffectsData.EFFECTS[k]["desc"]), "#ffd24a"))
		"cat_richiami":
			for k in SummonData.CALLS:
				var cid := String(SummonData.CALLS[k]["creature"])
				rows.append(_b("[url=item:%s]%s[/url]" % [k, ItemsData.get_item(k)["name"]], String(CreaturesData.get_data(cid)["name"])))
		"cat_casse":
			for e in ChestsData.all():
				var how := "si trova nelle rovine" if ChestsData.is_found(String(e["id"])) else (
					"al %s" % StationsData.STATIONS.get(String(e.get("station", "ceppo")), {}).get("name", "Ceppo") if e.has("in") else "al Ceppo del Giardiniere, con il legno")
				rows.append(_b("[url=item:%s]%s[/url]" % [e["id"], e["name"]], "%d caselle · %s" % [int(e["slots"]), how]))
		"cat_sfide":
			for k in ChallengesData.LIST:
				rows.append(_b(String(ChallengesData.LIST[k]["name"]), String(ChallengesData.LIST[k]["desc"])))
		"cat_record":
			for r in Challenges.records(EncyPages.ch):
				rows.append(_b(String(r[0]), String(r[1])))
		"cat_leggende":
			var ch: Character = EncyPages.ch
			for k in LegendsData.LEGENDS:
				var ld: Dictionary = LegendsData.LEGENDS[k]
				var parts := []
				for g in ld["needs"]:
					parts.append(String(GenesData.info(String(g))["name"]) if Genome.state(String(g)) >= 1 or EncyPages.show_all else "?")
				var done := ch != null and ch.leggende.has(k)
				rows.append(_b(String(ld["name"]) + ("  ✓" if done else ""), "%s — geni: %s" % [ld["desc"], ", ".join(parts)]))
		"cat_primo":
			var ch2: Character = EncyPages.ch
			var ld2 := 0
			if ch2 != null:
				for k in LegendsData.LEGENDS:
					if ch2.leggende.has(k):
						ld2 += 1
			var learned := 0
			var total := 0
			for g in GenesData.GENES:
				if String(GenesData.info(String(g)).get("cat", "")) != "superficie":
					total += 1
					if Genome.state(String(g)) >= 2:
						learned += 1
			var tree_done := ch2 != null and int(ch2.albero.get("stadio", 0)) >= MotherTreeData.STAGES.size()
			rows.append(_b("L'Albero-Madre sveglio del tutto", "tutti gli stadi" + ("  ✓" if tree_done else "")))
			rows.append(_b("Il Genario", "%d geni imparati su %d (ne servono %d)" % [learned, total, ceili(total * LegendsData.PRIMO_GENARIO)]))
			rows.append(_b("Le leggende", "%d compiute (ne servono %d)" % [ld2, LegendsData.PRIMO_LEGENDS]))
		"cat_gradi":
			for t in VigorData.TEMPERS:
				var td: Dictionary = VigorData.TEMPERS[t]
				rows.append(_b("Grado %d · indole %s" % [int(td["grade"]), String(td["adj"][1])], String(td["desc"])))
		"cat_meteo":
			for k in WeatherData.STATES:
				rows.append(_b(String(WeatherData.STATES[k]["name"]), String(WeatherData.STATES[k]["desc"])))
		"cat_reazioni_liquidi":
			for k in LiquidsData.REACTIONS:
				rows.append("• [color=%s]%s[/color]" % [G, LiquidsData.REACTIONS[k]["name"]])
		"cat_poteri":
			for p in PowersData.POWERS:
				var pd: Dictionary = PowersData.POWERS[p]
				rows.append(_b(String(pd["name"]), String(pd["desc"])))
	return "\n".join(rows)


static func _biome_name(id: String) -> String:
	for b in BiomesData.BIOMES:
		if String(b["id"]) == id:
			return String(b["name"])
	return id


## Un catalogo completo: [titolo, testo, icona].
static func catalog(id: String) -> Array:
	var filt := id.get_slice(":", 1) if id.contains(":") else ""
	id = id.get_slice(":", 0)
	var t := ""
	match id:
		"oggetti":
			var groups := {}
			var items := ItemsData.all()
			for iid in items:
				if (items[iid] as Dictionary).get("gen", false):
					continue
				var c: Array = CraftCatsData.CATS[CraftCatsData.of(String(iid))]
				if filt != "" and String(c[0]) != filt:
					continue
				if not groups.has(c[0]):
					groups[c[0]] = []
				groups[c[0]].append(String(iid))
			for c in CraftCatsData.CATS:
				if not groups.has(c[0]):
					continue
				var ids: Array = groups[c[0]]
				ids.sort_custom(func(a: String, b: String) -> bool: return String(items[a]["name"]) < String(items[b]["name"]))
				var known := ids.filter(func(x: String) -> bool: return EncyPages.known_item(x))
				t += "\n[font_size=19][color=#%s]%s[/color][/font_size]  [color=%s](%d su %d scoperti)[/color]\n" % [
					(c[2] as Color).to_html(false), c[1], D, known.size(), ids.size()]
				t += "   ".join(known.map(func(x: String) -> String: return EncyPages.item_link(x))) + "\n"
			t += "\n[color=%s]Armi, attrezzi e armature di ogni forma in ogni materiale: vedi [url=cap:forme]Forme[/url] e [url=cat:materiali]Materiali[/url].[/color]" % D
			return ["Oggetti" + ((" · " + filt) if filt != "" else ""), t, ""]
		"creature":
			var fams := FamiliesData.FAMILIES
			for f in fams:
				var names: Array = (fams[f]["members"] as Array).map(func(x: String) -> String: return EncyPages.creature_link(x))
				t += "[color=%s]%s[/color]: %s\n" % [G, fams[f]["name"], ", ".join(names)]
			return ["Creature", t, ""]
		"famiglie":
			for f in FamiliesData.FAMILIES:
				var fd: Dictionary = FamiliesData.FAMILIES[f]
				var tame := not HerdData.tame_of(String(f)).is_empty()
				t += _b(String(fd["name"]), "%s%s · %d specie" % [WorldTip.ROLE_NAMES.get(String(fd.get("role", "")), ""),
					", si addomestica" if tame else "", (fd["members"] as Array).size()]) + "\n"
			return ["Famiglie", t, ""]
		"geni":
			for c in GenesData.CATEGORIES:
				var ci: Dictionary = GenesData.CAT_INFO[c]
				var gs: Array = GenesData.of_cat(String(c))
				t += "\n[color=%s][b]%s[/b][/color]\n" % [ci["color"], ci["name"]]
				t += "   ".join(gs.map(func(g: String) -> String:
					return EncyPages.link("gene:" + g, String(GenesData.GENES[g]["name"])) if EncyPages.known_gene(g) else "[color=#5a706c]?[/color]")) + "\n"
			return ["Geni", t, ""]
		"materiali":
			# 28 set 2026 (appunto dell'utente): ogni riga comincia con il nome del materiale; per gruppi
			var groups := [["Metalli", []], ["Leghe", []], ["Materiali dei geni", []]]
			for k in MaterialsData.all():
				var md: Dictionary = MaterialsData.get_mat(String(k))
				var gi := 0 if MaterialsData.MATERIALS.has(k) else (1 if md.has("alloy") else 2)
				(groups[gi][1] as Array).append(String(k))
			for gr in groups:
				t += "[color=%s]%s[/color]\n" % [G, gr[0]]
				for k in gr[1]:
					var md: Dictionary = MaterialsData.get_mat(String(k))
					var nm := String(md.get("short", String(md.get("label", k)).trim_prefix("di ").trim_prefix("d'")))
					nm = nm.substr(0, 1).to_upper() + nm.substr(1)
					var bar := String(md.get("bar", ""))
					var link := "[url=item:%s]%s[/url]" % [bar, nm] if ItemsData.get_item(bar).has("name") else nm
					var el := String(md.get("elemento", ""))
					t += "• [color=#ffe8b0]%s[/color]  [color=%s](grado %d%s)[/color] — [color=%s]%s[/color]\n" % [link, D,
						int(md.get("tier", 0)), (", " + el) if el != "" else "", T, MaterialsData.describe(String(k))]
				t += "\n"
			return ["Materiali", t, ""]
		"forme":
			return ["Forme", inline("cat_forme"), ""]
		"tratti":
			for tr in TraitsData.TRAITS:
				var td: Dictionary = TraitsData.TRAITS[tr]
				t += _b(String(td["name"]), "%s  [color=%s](%s)[/color]" % [td["desc"], D, ", ".join(td["for"])]) + "\n"
			t += "\n[b]Tratti delle creature antiche[/b] (le loro Essenze si innestano):\n"
			for tr in AncientData.TRAITS:
				var ad: Dictionary = AncientData.TRAITS[tr]
				t += _b(String(ad["name"]), String(ad["desc"]), "#ffd24a") + "\n"
			return ["Tratti", t, ""]
		"stazioni":
			for sid in StationsData.STATIONS:
				var sd: Dictionary = StationsData.STATIONS[sid]
				if String(sd["name"]) in t:
					continue
				t += _b(String(sd["name"]), String(TipWordsData.STATION_USE.get(sid, ItemsData.get_item(String(sd.get("item", ""))).get("desc", "")))) + "\n"
			return ["Banchi e stazioni", t, ""]
		"glossario":
			var ws := LanguageData.WORDS.keys()
			ws.sort_custom(func(a: String, b: String) -> bool: return LanguageData.sem(a) < LanguageData.sem(b))
			var n := 0
			for w in ws:
				var k: bool = EncyPages.show_all or (EncyPages.ch != null and EncyPages.ch.lingua.has(w))
				if k:
					n += 1
					t += "• [color=#6ff0b8]%s[/color] — %s\n" % [LanguageData.sem(String(w)), LanguageData.it(String(w))]
			t = "[color=%s]%d parole su %d.[/color]\n\n" % [D, n, ws.size()] + t
			return ["Glossario dei Seminatori", t, ""]
		"obiettivi_elenco":
			for o in ObjectivesData.LIST:
				var done: bool = EncyPages.ch != null and String(o["id"]) in EncyPages.ch.obiettivi
				t += "%s [color=%s]%s[/color]\n" % ["✔" if done else "•", "#8ff0a0" if done else T, o["text"]]
			return ["Obiettivi", t, ""]
	return ["?", "", ""]


## La scheda completa di un oggetto (come Esamina: con ricette e provenienza).
static func item_page(id: String) -> String:
	if not EncyPages.known_item(id):
		return "[color=%s]Non l'hai ancora trovato.[/color]" % D
	return ItemInfo.bbcode(id)


## La scheda di una specie: famiglia, dove vive, valori, elementi, bottino.
static func creature_page(id: String) -> String:
	if not EncyPages.known_creature(id):
		return "[color=%s]Non l'hai ancora sconfitta.[/color]" % D
	var d := CreaturesData.get_data(id)
	var t := ""
	var fam := FamiliesData.family_of(id)
	if fam != "":
		t += "[color=%s]Famiglia dei %s[/color] · %s\n" % [D, String(FamiliesData.FAMILIES[fam]["name"]).to_lower(),
			WorldTip.ROLE_NAMES.get(String(FamiliesData.FAMILIES[fam].get("role", "")), "")]
	t += "Vita [b]%d[/b] · danno [b]%d[/b]%s\n" % [int(d.get("hp", 0)), int(d.get("damage", 0)),
		(" · Scorza [b]%d[/b]" % int(d["defense"])) if int(d.get("defense", 0)) > 0 else ""]
	var where := []
	for s in d.get("strata", []):
		where.append(String(StrataData.STRATA[int(s)]["name"]))
	for b in d.get("biomes", []):
		where.append(_biome_name(String(b)))
	if not where.is_empty():
		t += "Vive: %s\n" % ", ".join(where)
	var weak := []
	var strong := []
	for e in ElementsData.ELEMENTS:
		var a := ElementsData.affinity(id, String(e))
		if a > 1.01:
			weak.append(ElementsData.tag(String(e)))
		elif a < 0.99:
			strong.append(ElementsData.tag(String(e)))
	if not weak.is_empty():
		t += "Debole a: %s\n" % ", ".join(weak)
	if not strong.is_empty():
		t += "Resiste a: %s\n" % ", ".join(strong)
	var loot := []
	for e in LootData.TABLES.get(String(d.get("loot", "")), []):
		var l := EncyPages.item_link(String(e["item"]))
		if not l in loot:
			loot.append(l)
	if not loot.is_empty():
		t += "Lascia: %s\n" % ", ".join(loot)
	if fam != "" and not HerdData.tame_of(fam).is_empty():
		t += "[color=#b8e070]Si addomestica[/color] con %s.\n" % HerdInfo.diet_text(fam)
	if EncyPages.ch != null:
		t += "[color=%s]Sconfitte: %d[/color]\n" % [D, int((EncyPages.ch.erbario.get("creature", {}) as Dictionary).get(id, 0))]
	return t


static func gene_page(g: String) -> String:
	if not EncyPages.known_gene(g):
		return "[color=%s]Un gene che non hai ancora visto.[/color]" % D
	return Genario.detail(g)
