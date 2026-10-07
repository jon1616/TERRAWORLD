class_name WorldTip
extends RefCounted
## Le schede delle cose del mondo (26 set 2026, scelta dell'utente: suggerimenti «su tutto»): creature, abitanti,
## oggetti a terra, alberi, colture, rocce e minerali, decorazioni che si raccolgono, nidi, Sigilli. Le stazioni sono
## in `StationTip`. Le compone `TipsHook` per la cosa sotto il mouse; qui solo il testo, nessuna regola di gioco.

const ROLE_NAMES := {"erbivoro": "erbivoro", "predatore": "predatore", "colonia": "vive in colonia", "volante": "volante",
	"scavatore": "scava nella terra", "neutro": "tranquillo"}


static func creature(m: Node2D, cr: Creature) -> TipCard:
	var c := TipCard.new()
	var d: Dictionary = cr.data
	var col := Color("#e4f6ee")
	if cr.boss:
		col = Color("#ff7a6a")
	elif cr.tame != null:
		col = Color("#b8e070")
	elif cr.ancient != null:
		col = Color("#ffd24a")
	elif cr.docile:
		col = Color("#a8e0c8")
	c.title(String(d.get("name", cr.id)), col, cr.icon())
	var sub := []
	if cr.ancient != null:
		sub.append(String(AncientData.RARITIES[cr.ancient.rarity]["label"]))
	if cr.family != "" and FamiliesData.FAMILIES.has(cr.family):
		var fd: Dictionary = FamiliesData.FAMILIES[cr.family]
		sub.append("famiglia dei %s" % String(fd["name"]).to_lower())
		sub.append(String(ROLE_NAMES.get(String(fd.get("role", "")), "")))
	if cr.boss:
		sub.append("Signore del luogo" if cr.data.has("lord") else "Guardiano")   # voce 135
	c.sub(" · ".join(sub.filter(func(s: String) -> bool: return s != "")))
	c.bar("Vita %d / %d" % [cr.hp, cr.hp_max], float(cr.hp) / maxf(cr.hp_max, 1), Color("#e05a4a") if not cr.calm else TipCard.GOOD)
	if cr.tame == null and not cr.calm and cr.mind.state != Mind.CALM:
		c.line("Ora: %s" % cr.mind.label(), Color("#e8d8a0"))       # voce 129: lo stato del cervello
	# voce 138: che cosa si sa della specie dipende da quanto l'hai studiata
	var grade: int = m.study.grade(cr.base) if m.get("study") != null and cr.tame == null else 3
	for wd in WilesData.of(cr.data.get("behaviors", [])):          # voce 130: le astuzie e la contromossa
		if grade >= 3:
			c.line("%s: %s" % [wd["name"], wd["counter"]], Color("#a8e0c8"))
		else:
			c.line("%s: studiala per sapere come batterla" % wd["name"], Color("#80a8a0"))
	var rows := [["Danno", str(cr.damage)]]
	if cr.defense > 0:
		rows.append(["Scorza", str(cr.defense)])
	c.stats(rows)
	# debolezze e resistenze
	var weak := []
	var strong := []
	for e in ElementsData.ELEMENTS:
		var a := ElementsData.affinity(cr.base if cr.base != "" else cr.id, String(e))
		if a > 1.01:
			weak.append(ElementsData.tag(String(e)))
		elif a < 0.99:
			strong.append(ElementsData.tag(String(e)))
	if grade < 2:
		if not weak.is_empty() or not strong.is_empty():
			c.line("Debolezze: sconfiggila per scoprirle", Color("#80a8a0"))
	else:
		if not weak.is_empty():
			c.pair("Debole a", ", ".join(weak), TipCard.GOOD)
		if not strong.is_empty():
			c.pair("Resiste a", ", ".join(strong), TipCard.BAD)
	if m.get("study") != null and cr.tame == null and not cr.boss:
		c.line(m.study.line(cr.base), Color("#d8c890"))
	# le creature antiche e i loro tratti
	if cr.ancient != null and not cr.ancient.traits.is_empty():
		for t in cr.ancient.traits:
			var td: Dictionary = AncientData.TRAITS.get(String(t), {})
			c.pair(String(td.get("name", t)), String(td.get("desc", "")), Color("#ffd24a"))
	# stati
	var st := []
	if cr.burn_t > 0.0:
		st.append(ArtLib.bb("interfaccia", "brace") + "brucia")
	if cr.poison_t > 0.0:
		st.append(ArtLib.bb("interfaccia", "spora") + "avvelenata")
	if cr.chill_t > 0.0:
		st.append(ArtLib.bb("interfaccia", "rallentato") + "rallentata")
	if cr.weak_t > 0.0:
		st.append(ArtLib.bb("interfaccia", "vulnerabile") + "vulnerabile")
	if cr.stun > 0.0:
		st.append(ArtLib.bb("interfaccia", "stordito") + "stordita")
	if cr.shell > 0.0:
		st.append("chiusa nel guscio")
	if cr.calm:
		st.append("guarita: non attacca più")
	elif cr.docile and not cr.provoked:
		st.append("docile: non attacca se non la colpisci")
	if not st.is_empty():
		c.pair("Ora", ", ".join(st), Color("#8ef0d8"))
	# la mandria
	if cr.tame != null:
		c.sep()
		c.line(HerdInfo.short(cr.tame.rec), Color("#b8e070"))
	elif cr.family != "" and not cr.boss and not HerdData.tame_of(cr.family).is_empty():
		c.sep()
		# Roadmap 32: ogni creatura si lega; la natura dice quando e come
		var nat := BondsData.nature_of(cr.id)
		c.pair("Si lega", String(BondsData.NATURE_TEXT[nat]) if nat != "" else "con il Laccio quando è stremata, o con %s" % HerdInfo.diet_text(cr.family), Color("#b8e070"))
		if int(m.character.stats.get("legata_" + (cr.base if cr.base != "" else cr.id), 0)) < 1:
			c.line("Non l'hai mai legata: una specie nuova per il Libro dei legami", Color("#ffd08a"))
		if cr.affection > 0.0:
			c.bar("Affetto %d%%" % roundi(cr.affection), cr.affection / 100.0, Color("#b8e070"))
	# che cosa ne sai (l'Erbario)
	var kills := int((m.character.erbario.get("creature", {}) as Dictionary).get(cr.base if cr.base != "" else cr.id, 0))
	c.sep()
	if kills > 0:
		c.line("Ne hai sconfitte %d" % kills, TipCard.SOFT)
		var loot := _loot_names(String(d.get("loot", "")))
		if loot != "":
			c.pair("Lascia", loot, Color("#ffd24a"))
	else:
		c.line("Mai sconfitta: l'Erbario non la conosce ancora", Color("#ffd08a"))
	return c


static func _loot_names(table: String) -> String:
	var out := []
	for e in LootData.TABLES.get(table, []):
		var n := String(ItemsData.get_item(String(e["item"])).get("name", ""))
		if n != "" and not n in out:
			out.append(n)
	return ", ".join(out.slice(0, 5))


static func npc(m: Node2D, n: Npc) -> TipCard:
	var c := TipCard.new()
	c.title(NpcData.name_of(n.id), Color("#ffd08a"))
	var lvl := NpcBonds.level(m.character, n.id)
	var hearts := "♥".repeat(lvl) + "♡".repeat(maxi(4 - lvl, 0))
	c.sub("abitante · affetto %s" % hearts, Color("#ff9ab8"))
	var aff := NpcBonds.affetto(m.character, n.id)
	c.bar("Affetto %d (livello %d)" % [aff, lvl], float(aff % NpcBonds.PER_LEVEL) / NpcBonds.PER_LEVEL, Color("#ff9ab8"))
	if lvl > 0:
		c.line("Sconto del %d%% sulle sue merci" % roundi(lvl * NpcBonds.DISCOUNT * 100.0), TipCard.GOOD)
	var likes := []
	for it in NpcData.NPCS.get(n.id, {}).get("likes", []):
		likes.append(String(ItemsData.get_item(String(it)).get("name", it)))
	if not likes.is_empty():
		c.pair("Gli piace", ", ".join(likes), Color("#ff9ab8"))
	var q := NpcBonds.quest_text(m.character, n.id)
	if q != "":
		c.sep()
		c.pair("Richiesta", q, TipCard.GOLD if not NpcBonds.quest_ready(m.character, n.id) else TipCard.GOOD)
	c.hint("Clic destro: commercia, dona, consegna")
	return c


static func drop(slot: Dictionary) -> TipCard:
	var c := ItemTip.card(slot, {"no_compare": true})
	if c != null:
		c.hint("A terra: avvicinati per raccoglierlo")
	return c


static func tree(t: Vector3i) -> TipCard:
	var v := TreesData.decode(t.z)
	var sp: Dictionary = TreesData.SPECIES[int(v[0])]
	var sz: Dictionary = TreesData.SIZES[int(v[1])]
	var c := TipCard.new()
	c.title(String(sp["name"]), Color("#8ef0a0"))
	c.sub("albero %s" % sz["name"])
	c.stats([["Robustezza", str(int(sz["hp"]))], ["Legno", "%d-%d" % [int(sz["wood"][0]), int(sz["wood"][1])]]])
	c.hint("Con l'ascia: legno e semi")
	return c


static func crop(e: Array) -> TipCard:
	var cd: Dictionary = CropsData.CROPS.get(String(e[0]), {})
	var c := TipCard.new()
	c.title(String(cd.get("name", e[0])), Color("#b8f080"), String(cd.get("seed", "")))
	var total := float(cd.get("grow", 1.0))
	var left := float(e[1])
	if left <= 0.0:
		c.bar("Pronta da raccogliere", 1.0, TipCard.GOOD)
		c.hint("Clic destro: raccogli")
	else:
		c.bar("Cresce: mancano %s" % _mins(left), 1.0 - left / maxf(total, 1.0), Color("#b8f080"))
		c.line("Annaffiata: cresce il doppio più in fretta" if bool(e[2]) else "Non annaffiata (l'annaffiatoio dimezza l'attesa)",
			TipCard.GOOD if bool(e[2]) else TipCard.SOFT)
	var h := []
	for it in cd.get("harvest", {}):
		h.append(String(ItemsData.get_item(String(it)).get("name", it)))
	if not h.is_empty():
		c.pair("Dà", ", ".join(h), Color("#ffd24a"))
	return c


## Una tessera: che cos'è, se il piccone che hai in mano la rompe, che cosa lascia.
static func tile(m: Node2D, t: int) -> TipCard:
	var c := TipCard.new()
	if t == TileDefs.SIG_VELATO and m.powers._vista_t <= 0.0:
		t = TileDefs.STONE                     # il Sigillo velato sembra ardesia: lo svela solo la Vista della Linfa
	if TileDefs.SEAL_KIND.has(t):
		return seal(m, String(TileDefs.SEAL_KIND[t]))
	if t == TileDefs.PORTA_SEM:
		c.title("Porta dei Seminatori", Color("#ffd24a"))
		c.sub("il piccone non la scalfisce")
		return c
	var drop_id := String(TileDefs.DROP.get(t, ""))
	var tname := String(TileDefs.NAMES.get(t, "Roccia"))
	var need := int(TileDefs.POWER.get(t, 0))
	if t == TileDefs.COSTRUTTO or t == TileDefs.COSTRUTTO_T:
		var mc: Vector2i = m.actions.mouse_cell()      # voce 128: il costrutto sotto il mouse
		var bk: int = m.world.build_at(mc.x, mc.y)
		if bk > 0:
			drop_id = BuildData.item_of(bk)
			tname = String(BuildData.kind_info(bk)["name"])
			need = BuildData.power(bk)
	c.title(tname, Color("#c8d0d8"), drop_id)
	var hand: Dictionary = m.hud.current()
	var have := 0
	if String(hand.get("use", "")) == "scava":
		have = int(Gear.stats({"id": hand["id"], "tratto": hand.get("tratto", ""), "dati": hand.get("dati", {})})["power"])
	if need >= 999:
		c.line("Non si scava", TipCard.BAD)
	elif need > 0:
		c.stats([["Forza richiesta", str(need)], ["Il tuo piccone", str(have) if have > 0 else "—"]])
		c.line("Il tuo piccone la rompe" if have >= need else "Ti serve un piccone più forte", TipCard.GOOD if have >= need else TipCard.BAD)
	if drop_id != "" and ItemsData.get_item(drop_id).has("name"):
		c.pair("Lascia", String(ItemsData.get_item(drop_id)["name"]), Color("#ffd24a"))
	var tt: int = m.world.tile(m.actions.mouse_cell().x, m.actions.mouse_cell().y)
	if TileDefs.DORMANT[tt] == 1 and not TileDefs.awake_on:
		c.line("Dorme: dà il metallo solo dopo il Risveglio del Cuore", TipCard.BAD)      # voce 413
	_ground(c, tt)
	return c


## Roadmap 52: che cosa fa una terra sotto i piedi (le stesse tabelle che leggono il movimento e le cadute).
static func _ground(c: TipCard, t: int) -> void:
	var notes := []
	if TileDefs.FALLS[t] == 1:
		notes.append("frana senza appoggio")
	if TileDefs.SLIP[t] < 1.0:
		notes.append("ci si scivola")
	if TileDefs.STICK[t] < 1.0:
		notes.append("rallenta chi ci cammina")
	if TileDefs.SOFT[t] < 1.0:
		notes.append("attutisce le cadute")
	if TileDefs.FERTILE[t] > 1.0:
		notes.append("l'orto ci cresce ×%.1f" % TileDefs.FERTILE[t])
	if TileDefs.WARM[t] == 1:
		notes.append("scalda chi le sta vicino")
	if TileDefs.QUIET[t] == 1:
		notes.append("i passi non fanno rumore")
	if TileDefs.BLAST[t] == 1:
		notes.append("regge le esplosioni")
	if TileDefs.FOSSIL[t] > 0.0:
		notes.append("nasconde fossili")
	if not notes.is_empty():
		var txt := ", ".join(notes)
		c.line(txt.left(1).to_upper() + txt.substr(1), TipCard.GOOD)


static func seal(m: Node2D, kind: String) -> TipCard:
	var c := TipCard.new()
	var pw := ""
	for p in PowersData.POWERS:
		if String(PowersData.POWERS[p].get("seal", "")) == kind:
			pw = String(p)
	c.title("Sigillo", Color("#6ff0b8"))
	c.sub("un luogo chiuso dai Seminatori")
	var pname := String(PowersData.POWERS.get(pw, {}).get("name", "un potere dell'Albero-Madre"))
	var owned: bool = pw != "" and m.powers.has(pw)
	c.pair("Si apre con", pname, TipCard.GOOD if owned else TipCard.GOLD)
	c.line("Hai questo potere: clic destro per aprirlo" if owned else "L'Albero-Madre te lo donerà crescendo",
		TipCard.GOOD if owned else TipCard.SOFT)
	c.line("Dentro: uno scrigno e un Frammento dell'Albero", TipCard.SOFT)
	return c


static func decor(d: int) -> TipCard:
	if PodsData.KINDS.has(d):                          # voce 301: un baccello dormiente
		var pc := TipCard.new()
		pc.title(String(PodsData.KINDS[d]["name"]), Color("#f0d8a0"))
		pc.sub("si apre: dentro c'è sempre qualcosa")
		pc.hint("Clic per aprirlo")
		return pc
	var it := String(TileDefs.DECOR_DROP.get(d, ""))
	if it == "" and HarvestData.DECOR.has(d):
		it = String(HarvestData.DECOR[d][0])        # voce 300: il raccolto della pianta
	if it == "":
		return null
	var c := TipCard.new()
	c.title(String(ItemsData.get_item(it).get("name", it)), Color("#b8f080"), it)
	c.sub("pianta selvatica")
	c.hint("Clic per raccoglierla")
	return c


static func nest(m: Node2D, e: Dictionary) -> TipCard:
	var fam := String(e.get("fam", ""))
	var c := TipCard.new()
	var fname := String(FamiliesData.FAMILIES.get(fam, {}).get("name", fam))
	c.title("Nido dei %s" % fname.to_lower(), Color("#f0e0a0"))
	c.stats([["Uova", str(int(e.get("eggs", 0)))]])
	if bool(e.get("fed", false)):
		c.line("Nutrito: le uova si schiudono prima", TipCard.GOOD)
	c.hint("Clic destro: prendi un uovo, nutri o distruggi")
	return c


## Voce 73: un liquido.
static func liquid(t: int) -> TipCard:
	var td: Dictionary = LiquidsData.TYPES[t]
	var c := TipCard.new()
	c.title(String(td["name"]), td["color"])
	if bool(td["swim"]):
		c.line("Ci si nuota: tieni premuto il salto per salire", TipCard.TEXT)
	if float(td["heal"]) > 0.0:
		c.line("Cura chi ci sta dentro (%s Vita al secondo)" % ItemTip.num(float(td["heal"]), 0), TipCard.GOOD)
	if float(td["dps"]) > 0.0:
		c.line("Brucia chi ci cade dentro (%d Vita al secondo)" % roundi(float(td["dps"])), TipCard.BAD)
	c.hint("Il secchio di radice lo raccoglie")
	return c


static func _mins(s: float) -> String:
	if s >= 60.0:
		return "%d min" % ceili(s / 60.0)
	return "%d s" % ceili(s)
