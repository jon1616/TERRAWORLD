class_name ItemUses
extends RefCounted
## «A cosa serve» (voce 351, Roadmap 37, 4 ott 2026). L'utente, giocando: «spesso trovo oggetti senza avere idea del
## loro utilizzo». Esamina mostrava solo le ricette; qui si raccolgono **tutti** i modi in cui un oggetto si usa, si
## offre, si spende o si mostra, leggendo i dati di ogni sistema:
##   il clic (per tipo d'oggetto), posarlo, indossarlo, l'Albero-Madre, gli abitanti (richieste, storie, regali,
##   botteghe), i Giardini perduti, richiami ed esche, il Maglio (innesti, incisioni, fasce, tempra, costi), la mandria
##   e i compagni, la pesca, il Museo, le macchine, i progetti, la vendita.
## Le righe si preparano una volta per sessione (`_index`, da `_build`); la vendita si calcola al momento.
## **Un sistema nuovo che consuma oggetti aggiunge qui la sua funzione `_from_…`** (e la chiama in `_build`).

## Che cosa fa il clic, per tipo d'oggetto (`kind`): solo i tipi il cui uso non si capisce da una ricetta.
const KIND_USE := {
	"cimelio": "Trovato una volta, il suo piccolo bonus vale per sempre (anche se lo lasci in una cassa).",
	"piccone": "In mano: scava i blocchi (clic sinistro tenuto). La forza decide quali rocce e minerali cede.",
	"ascia": "In mano: abbatte gli alberi a colpi.",
	"concime": "Clic su una coltura dell'orto: cresce di colpo di un terzo del tempo che le manca.",
	"martello": "In mano: toglie le pareti di fondo e, con lo scalpello, cambia la forma dei costrutti.",
	"spada": "In mano: colpisce le creature (clic sinistro).",
	"arco": "In mano: tira dardi verso il mouse; i dardi stanno nello scomparto delle munizioni.",
	"bastone": "In mano: lancia incantesimi spendendo Linfa.",
	"seme": "In mano: si pianta nella terra e diventa un albero.",
	"seme_mondo": "Si pianta in un'Aiuola del Giardino: nasce un portale verso il mondo di quel Seme.",
	"consumabile": "Si beve o si mangia con il clic: cura o dà un effetto a tempo.",
	"cura": "La Rugiada: cura le creature avvizzite, guarisce i nodi del Guardiano, purifica le terre malate.",
	"purifica": "Purifica le terre avvizzite attorno a dove lo usi.",
	"provetta": "Su una cosa speciale di un mondo impari un gene; su una creatura viva la studi (vale quattro sconfitte).",
	"fiala": "Tenuta nella Bisaccia ti insegna il suo gene; al Banco dell'Innestatrice aggiunge quel gene a un Seme.",
	"essenza": "Al Maglio dei Seminatori si innesta in un'arma o un'armatura e le dà il suo tratto; a un compagno dà un istinto.",
	"dono": "Si assorbe con il clic: Vita o Linfa massima in più, per sempre (fino a un limite).",
	"richiamo": "Al Cerchio o all'Altare richiama un Guardiano o un Custode già battuto, per batterlo di nuovo.",
	"richiamo_grande": "Chiama uno dei grandi Guardiani nel suo luogo.",
	"esca_signore": "L'esca rituale: usata nel luogo del suo Signore, lo fa venire.",
	"tavoletta": "Si legge con il clic: insegna parole della lingua dei Seminatori.",
	"stilo": "Rende certa una parola del Quaderno.",
	"mappa": "Si usa con il clic: segna sulla mappa (M) qualcosa di nascosto del mondo.",
	"bisaccia": "Si usa con il clic: la tua Bisaccia diventa più grande, per sempre.",
	"basto": "Si mette a una creatura della mandria: porta oggetti per te.",
	"pagina": "Si legge con il clic: un pezzo di diario trovato nelle grotte.",
	"fagiolo": "Si pianta: cresce una pianta che sale fino alle nuvole.",
	"sfida": "Si mette su un portale: il mondo diventa più difficile, con un premio se vinci.",
	"secchio": "Raccoglie un liquido (clic sull'acqua) e lo versa altrove.",
	"secchio_pieno": "Versa il liquido che contiene.",
	"contenitore": "Raccoglie e versa liquidi, più di un secchio.",
	"canna": "In mano: si pesca cliccando su uno specchio d'acqua (o Linfa, o brace).",
	# Roadmap 40, voce 368: gli stili nuovi
	"lancio": "In mano: si lancia verso il mouse (clic sinistro tenuto). Stando fermi un attimo il lancio dopo è perfetto.",
	"strumento": "In mano: suona verso il mouse; ogni nota che colpisce dà Ispirazione, e piena parte il canto dello strumento.",
	"ramo": "In mano: tira semi di Rugiada; ferire ti cura, e ogni sei colpi un'onda cura te e i compagni.",
	"semeguerra": "In mano: si pianta sul campo (seme-torre) o si lancia ad arco (seme-bomba).",
	"segnale": "Si usa con il clic: chiama il suo evento, di giorno o di notte.",
	"stendardo": "Si issa con il clic: per sempre, in ogni mondo, più danno e meno ferite contro quella famiglia di creature.",
	"sacchetto": "Si apre con il clic: armi firma, il Richiamo del Guardiano, lingotti e, a volte, il suo gioiello e il suo trofeo.",
	"esca": "Esca per la pesca: la canna usa da sola la migliore che hai.",
	"cassetta": "Si apre con il clic: dentro c'è un po' di tutto.",
	"compagno": "Chiama o rimanda il compagno che ti segue (luce, oggetti attirati).",
	"evocatore": "In mano: evoca alleati che combattono per te.",
	"laccio": "Su una creatura stremata (poca Vita): prova a legarla a te.",
	"vasetto": "Su una creatura piccola: la chiude nel vasetto, poi la liberi nel Giardino.",
	"creatura": "Una creatura nel vasetto: liberala con il clic dove vuoi.",
	"uovo": "Mettilo in un'Incubatrice: si schiude e la creatura nasce già tua.",
	"rampino": "In mano: si aggancia alla roccia e ti tira su.",
	"esplosivo": "Si lancia: fa saltare roccia e creature attorno.",
	"giavellotto": "Si lancia contro le creature.",
	"ricurvo": "Si lancia e torna in mano.",
	"coltura": "Si semina nell'orto, su terra arata.",
	"annaffiatoio": "Annaffia le colture: crescono più in fretta.",
	"parete": "Posa pareti di fondo (servono per le stanze).",
	"cannocchiale": "Guarda lontano: rivela un pezzo di mappa.",
	"bussola": "Indica la direzione della cosa che cerca.",
	"radice_ritorno": "Ti riporta a casa, al letto o al portale del mondo.",
	"specchio": "Ti riporta al punto di partenza del mondo.",
	"torcia": "Si posa sui muri e sul terreno: fa luce, e dove c'è luce le creature non nascono.",
	"isolante": "Sulla rete di Linfa: isola un tratto di vena.",
	"dispensa": "Apre la Dispensa: un magazzino personale che viaggia con te.",
	"pennello": "Sui giacimenti delle grotte: dissotterra fossili e ossa.",
	"lanterna": "In mano fa luce attorno a te mentre ti muovi, senza posare torce.",
	"piattaforma": "Si posa: una passerella su cui si sta in piedi e che si attraversa da sotto (e tenendo S).",
	"munizione": "Munizione per l'arco: l'arco tira sempre la migliore che hai (va da sola nello scomparto delle munizioni).",
	"pinza": "In mano: posa e toglie vene e fili della rete di Linfa, e mostra i fili.",
	"vena": "Con la Pinza: una vena della rete di Linfa, porta il Flusso dalle sorgenti alle macchine.",
	"filo": "Con la Pinza: un filo dell'Impulso, porta i comandi (leve, piastre, sensori) alle macchine.",
	"occhio": "In mano: mostra i fili e le vene della rete, senza la Pinza.",
	"tasca": "Si allaccia alla cintura (posto «tasca» della Bisaccia): caselle in più solo per certi oggetti.",
	"tintura": "Con il clic su un costrutto: ne cambia il colore.",
	"progetto": "La Tavola del progetto: copia una tua costruzione e, con il clic, la ricostruisce altrove con i materiali che porti (clic destro la svuota).",
	"progetto_sem": "Un progetto dei Seminatori: in mano, clic dove vuoi e la costruzione si alza con i materiali che porti.",
	"ricordo": "Un ricordo: si tiene, o si espone nel Museo del Giardino.",
	"lumino": "La moneta: con i Lumini compri dagli abitanti e paghi i loro servizi (ogni abitante sa fare qualcosa che nessun altro fa: parlaci).",
}

static var _index := {}            # id → Array[String] (righe già pronte)
static var _built := false


## Le righe «a cosa serve» di un oggetto (BBCode), senza le ricette (quelle le scrive `ItemInfo.uses_of`).
static func lines(id: String) -> Array:
	if not _built:
		_build()
	var out: Array = (_index.get(id, []) as Array).duplicate()
	var it := ItemsData.get_item(id)
	var k := String(it.get("kind", ""))
	if KIND_USE.has(k) and not out.has(KIND_USE[k]):
		out.push_front(KIND_USE[k])
	if it.has("place") or it.has("wall"):
		out.push_front("Si posa nel mondo: mettilo nella barra rapida e clicca dove vuoi.")
	if Bisaccia.is_gear(id) and _slot_of(k) != "":
		out.push_front("Si indossa (%s): trascinalo nel suo posto della Bisaccia." % _slot_of(k))
	var price := ValueData.sell_price(id, 1)
	if price > 0 and id != "lumino":
		out.append("Si vende agli abitanti: %d %s l'uno." % [price, "Lumino" if price == 1 else "Lumini"])
	return out


static func _slot_of(kind: String) -> String:
	for s in Bisaccia.EQUIP_SLOTS:
		if Bisaccia.kind_of_slot(String(s)) == kind:
			return String(s).trim_suffix("_1").trim_suffix("_2").replace("_", " ")
	return ""


static func _add(id: String, line: String) -> void:
	if id == "" or line == "":
		return
	if not _index.has(id):
		_index[id] = []
	if not (_index[id] as Array).has(line):
		(_index[id] as Array).append(line)


static func _build() -> void:
	_built = true
	_index = {}
	_from_tree()
	_from_npcs()
	_from_lost()
	_from_calls()
	_from_maglio()
	_from_herd()
	_from_museum()
	_from_machines()
	_from_projects()
	_from_misc()
	_from_finds()
	_from_purpose()


## «a» / «di» con l'articolo del nome: «alla Viandante», «dell'Erborista», «al Pescatore».
static func _prep(p: String, who: String) -> String:
	var forms := {"a": ["alla ", "al ", "all'", "allo ", "ai ", "alle "], "di": ["della ", "del ", "dell'", "dello ", "dei ", "delle "]}
	var arts := ["La ", "Il ", "L'", "Lo ", "I ", "Le "]
	for i in arts.size():
		if who.begins_with(arts[i]):
			return String(forms[p][i]) + who.substr(String(arts[i]).length())
	return "%s %s" % [p, who]


static func _name(id: String) -> String:
	return String(ItemsData.get_item(id).get("name", id))


## L'Albero-Madre: ogni offerta di oggetti, anche nelle strade alternative.
static func _from_tree() -> void:
	for i in MotherTreeData.STAGES.size():
		var st: Dictionary = MotherTreeData.STAGES[i]
		for o in st["offers"]:
			var alts: Array = o["any"] if (o as Dictionary).has("any") else [o]
			for a in alts:
				if (a as Dictionary).has("item"):
					_add(String(a["item"]), "[color=#ffd24a]L'Albero-Madre lo chiede[/color]: %d per lo stadio %d «%s»." % [int(a["n"]), i + 1, st["name"]])


## Gli abitanti: le richieste, i capitoli delle storie, i regali graditi, le botteghe.
static func _from_npcs() -> void:
	for npc in NpcData.NPCS:
		var nd: Dictionary = NpcData.NPCS[npc]
		var who := String(nd["name"])
		for q in nd.get("quests", []):
			for id in (q as Dictionary).get("need", {}):
				_add(String(id), "%s lo chiede in una sua richiesta (%d)." % [who, int(q["need"][id])])
		for id in nd.get("likes", []):
			_add(String(id), "Piace %s: come regalo vale cinque volte tanto." % _prep("a", who))
		for ch in NpcStoriesData.STORIES.get(npc, []):
			for id in (ch as Dictionary).get("need", {}):
				_add(String(id), "%s lo chiede nella sua storia, «%s» (%d)." % [who, ch["title"], int(ch["need"][id])])
		for job in NpcWork.JOBS.get(npc, []):
			for id in job[0]:
				_add(String(id), "Nella bottega %s: con %d fa %s." % [_prep("di", who), int(job[0][id]), _name(String(job[1]))])


## I Giardini perduti: le cure con un oggetto.
static func _from_lost() -> void:
	for g in LostGardensData.GARDENS:
		var gd: Dictionary = LostGardensData.GARDENS[g]
		for c in gd["cures"]:
			var need: Dictionary = c[3]
			if need.has("item"):
				_add(String(need["item"][0]), "Cura l'Albero %s: portagliene %d." % [_prep("di", String(gd["name"])), int(need["item"][1])])


## Richiami, esche dei Signori e dei grandi Guardiani.
static func _from_calls() -> void:
	for item in SummonData.CALLS:
		_add(String(item), "Al Cerchio dei richiami fa tornare %s." % CreaturesData.CREATURES.get(String(SummonData.CALLS[item]["creature"]), {}).get("name", "un Guardiano"))
	for k in KeepersData.KEEPERS:
		var kd: Dictionary = KeepersData.KEEPERS[k]
		_add(String(kd["summon"]), "All'Altare dei Seminatori fa tornare il Custode %s." % CreaturesData.CREATURES.get(String(kd["creature"]), {}).get("name", k))
	for id in ItemsData.all():
		var it: Dictionary = ItemsData.all()[id]
		if it.has("lord"):
			_add(String(id), "Chiama %s: usala nel suo luogo." % CreaturesData.CREATURES.get(String(it["lord"]), {}).get("name", "il suo Signore"))
		if it.has("bait"):
			_add(String(id), "Esca per la pesca: più fortuna e meno attesa (la canna usa la migliore che hai).")
		if it.has("gift"):
			_add(String(id), "Si assorbe: +%d di %s massima, per sempre." % [int(it["gift"][1]), "Vita" if String(it["gift"][0]) == "vita" else "Linfa"])
		if it.has("graft"):
			_add(String(id), "Al Maglio dei Seminatori si innesta in un oggetto: gli dà il tratto «%s»." % TraitsData.TRAITS.get(String(it["graft"]), {}).get("name", it["graft"]))


## Il Maglio e il Telaio: incisioni, fasce, togliere e rifare i tratti, la tempra, la rifusione.
static func _from_maglio() -> void:
	for e in IncisionsData.LIST:
		for id in e[4]:
			_add(String(id), "Al Maglio: incide la parola «%s» su un oggetto (%s)." % [e[0], e[3]])
	for f in FormsData.FASCE:
		var fd: Dictionary = FormsData.FASCE[f]
		_add(String(fd["item"]), "Al Telaio: fascia un attrezzo o un'arma di %s (%d)." % [fd["name"], int(fd["n"])])
	for id in TraitsData.UNGRAFT_COST:
		_add(String(id), "Al Maglio: toglie un innesto da un oggetto (%d)." % int(TraitsData.UNGRAFT_COST[id]))
	for id in TraitsData.REFORGE_COST:
		_add(String(id), "Al Maglio: rifà il tratto di nascita di un oggetto (%d)." % int(TraitsData.REFORGE_COST[id]))
	for id in Refusion.COST:
		_add(String(id), "Al Maglio: fonde due oggetti uguali in uno migliore (%d)." % int(Refusion.COST[id]))
	_add("scheggia_vigore", "Al Maglio: tempra l'oggetto in mano (+danno, più posti d'innesto); ogni livello ne chiede %d in più." % VigorData.TEMPER_COST)
	_add("linfa_antica", "Al Banco dell'Innestatrice: serve per incrociare due Semi di mondo.")
	_add("seme_mondo", "Al Banco dell'Innestatrice: due Semi ne fanno uno nuovo con i geni di entrambi.")


## La mandria e i compagni: il cibo di ogni famiglia, i lacci, gli oggetti dei compagni.
static func _from_herd() -> void:
	for fam in HerdData.TAME:
		var fname := String(FamiliesData.FAMILIES.get(fam, {}).get("name", fam)).to_lower()
		for id in HerdData.TAME[fam].get("diet", []):
			_add(String(id), "Cibo per i %s: con il clic destro li addomestichi o li nutri; nel Recinto-mangiatoia li sfama." % fname)
	for id in BondsData.LACCI:
		_add(String(id), "Su una creatura stremata prova a legarla come compagno di battaglia.")
	for id in BondsData.items():
		if BondsData.is_bond_item(String(id)):
			_add(String(id), "Si dà a un compagno di battaglia: clic sul compagno in campo con l'oggetto in mano.")


## Il Museo: i pezzi che una vetrina espone.
static func _from_museum() -> void:
	for h in MuseumData.HALLS:
		for id in MuseumData.pieces(String(h)):
			_add(String(id), "Si espone nel Museo del Giardino, %s (in una vetrina: resta tuo)." % MuseumData.HALLS[h]["name"])


## Le macchine della rete: ciò che bruciano.
static func _from_machines() -> void:
	for mid in MachinesData.MACHINES:
		var md: Dictionary = MachinesData.MACHINES[mid]
		for id in md.get("fuel", {}):
			_add(String(id), "Combustibile per %s: %d secondi di lavoro l'uno." % [md["name"], int(md["fuel"][id])])


## I progetti dei Seminatori e le grandi opere: i materiali in più.
static func _from_projects() -> void:
	for pid in ProjectsData.PROJECTS:
		var pd: Dictionary = ProjectsData.PROJECTS[pid]
		for id in pd.get("extra", {}):
			_add(String(id), "Serve per costruire «%s» (%d)." % [pd["name"], int(pd["extra"][id])])


## Il resto: munizioni, meccanismi, stanze.
static func _from_misc() -> void:
	for id in Combat.AMMO:
		_add(String(id), "Munizione per l'arco: va da sola nello scomparto delle munizioni.")
	_add("torcia", "Accende i bracieri degli enigmi dei Seminatori.")
	_add("chiave_seminatori", "Apre le porte chiuse degli enigmi dei Seminatori.")
	_add("cristallo_linfa", "Risveglia una Centrale dei Seminatori (clic destro sulla sua porta).")
	_add("seme_eco", "Al Cerchio dei richiami: serve per richiamare un Guardiano generato.")


## Roadmap 45: le chiavi dei biomi aprono le casse sigillate; la Pozza di Linfa antica trasforma.
static func _from_finds() -> void:
	for e in ChestsData.FOUND:
		if e.has("key"):
			_add(String(e["key"]), "Apre (e si consuma) la %s: si trova %s." % [String(e["name"]).to_lower(),
				"negli osservatori del cielo" if String(e["where"]) == "cielo" else "nelle rovine sotto il suo bioma"])
	for id in ItemsData.all():
		if TransmuteData.of(String(id)) != "":
			_add(String(id), "Nella Pozza di Linfa antica si trasforma in un altro oggetto della sua famiglia (dopo il primo Guardiano).")


## Roadmap 47 e 50: i trofei dei boss nella sala dei trofei; gli oggetti che valgono come ingrediente a gruppi.
static func _from_purpose() -> void:
	for id in ItemsData.all():
		var bo := RoomsData.boss_of_trophy(String(id))
		if bo != "":
			_add(String(id), "Esposto in una cassa della sala dei trofei: +%d%% di danno contro %s." % [
				roundi(RoomsData.BOSS_TROPHY * 100.0), CreaturesData.get_data(bo).get("name", bo)])
	var uses := {}
	for r in RecipesData.all():
		for k in r["in"]:
			if GroupsData.is_group(String(k)):
				uses[String(k)] = int(uses.get(String(k), 0)) + 1
	for g in uses:
		for mid in GroupsData.members(String(g)):
			_add(String(mid), "Vale come «%s» in %d ricette." % [String(GroupsData.GROUPS[g]["name"]).to_lower(), int(uses[g])])

