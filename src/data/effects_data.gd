class_name EffectsData
## Gli effetti speciali componibili (voce 85, Roadmap 12): ciò che rende un oggetto **diverso**, non solo più forte. Solo
## dati: li applica `Effects`. Un oggetto li porta nel campo "effects" (ItemsData): [id, …]; valgono indossati (armature,
## accessori) o in mano (armi e attrezzi). Un effetto nuovo = una riga qui, se usa un **quando** e un **cosa** che ci sono.
##
## Quando ("when"):
##   colpo       a ogni colpo andato a segno (con "chance")
##   ogni        ogni "n" colpi andati a segno
##   uccisione   a ogni creatura sconfitta
##   ferita      quando il Germogliato è ferito (con "chance"; "sotto" = solo sotto questa frazione di Vita)
##   morte       quando la Vita finirebbe ("cool" secondi tra una volta e l'altra)
##   se          finché vale una condizione ("cond": vita_bassa, notte, acqua, fermo, sottoterra, superficie)
##   aura        di continuo, attorno al Germogliato ("r" tessere)
## Cosa ("do"), con i suoi parametri:
##   brucia (t)  ·  gela (t: rallenta)  ·  stordisce (t)  ·  schegge (n, dmg: frazione del colpo)  ·  catena (n, dmg, r)
##   cura (frac: del colpo, o min)  ·  lumini (n)  ·  corsa (mult, t: per qualche secondo)  ·  ombra (mult, t: le
##   creature ti vedono meno)  ·  riflesso (frac: del colpo ricevuto, alla creatura più vicina)  ·  salva (frac: della
##   Vita piena che resta)  ·  danno (mult)  ·  rigenera (mult)  ·  respiro (mult)

const EFFECTS := {
	"brace_colpo": {"name": "Tizzone", "when": "colpo", "chance": 0.35, "do": "brucia", "t": 3.0,
		"desc": "un colpo su tre incendia: la creatura brucia per 3 secondi"},
	"gelo_colpo": {"name": "Brina", "when": "colpo", "chance": 0.3, "do": "gela", "t": 2.5,
		"desc": "un colpo su tre gela: la creatura rallenta per qualche secondo"},
	"stordisce_colpo": {"name": "Rintocco", "when": "colpo", "chance": 0.15, "do": "stordisce", "t": 0.9,
		"desc": "a volte il colpo stordisce per un attimo"},
	"schegge": {"name": "Schegge", "when": "colpo", "chance": 0.2, "do": "schegge", "n": 4, "dmg": 0.4,
		"desc": "a volte dal colpo partono quattro schegge che feriscono attorno"},
	"fulmine_eco": {"name": "Eco del fulmine", "when": "ogni", "n": 6, "do": "catena", "targets": 3, "dmg": 0.6, "r": 7,
		"desc": "ogni sesto colpo un fulmine salta su altre tre creature vicine"},
	"linfa_colpo": {"name": "Sete di Linfa", "when": "colpo", "chance": 1.0, "do": "cura", "frac": 0.06,
		"desc": "ogni colpo ti rende un po' di Vita (6% del danno)"},
	"furia_bassa": {"name": "Ultima radice", "when": "se", "cond": "vita_bassa", "do": "danno", "mult": 1.35,
		"desc": "sotto un terzo della Vita, colpi più forti del 35%"},
	"notturno": {"name": "Occhi di notte", "when": "se", "cond": "notte", "do": "danno", "mult": 1.2,
		"desc": "di notte, colpi più forti del 20%"},
	"anfibio": {"name": "Pinne", "when": "se", "cond": "acqua", "do": "corsa", "mult": 1.5,
		"desc": "nei liquidi ti muovi la metà più svelto"},
	"respiro_lungo": {"name": "Branchia", "when": "se", "cond": "acqua", "do": "respiro", "mult": 2.5,
		"desc": "sott'acqua il respiro dura molto di più"},
	"ombra_ferito": {"name": "Muschio che nasconde", "when": "ferita", "chance": 1.0, "sotto": 0.3, "do": "ombra",
		"mult": 0.3, "t": 4.0, "cool": 20.0, "desc": "ferito sotto un terzo della Vita, per 4 secondi quasi non ti vedono"},
	"seconda_vita": {"name": "Seconda radice", "when": "morte", "do": "salva", "frac": 0.3, "cool": 300.0,
		"desc": "una volta ogni cinque minuti, invece di appassire, resti in piedi con un terzo della Vita"},
	"slancio": {"name": "Slancio", "when": "uccisione", "do": "corsa", "mult": 1.35, "t": 3.0,
		"desc": "dopo ogni creatura sconfitta corri più svelto per 3 secondi"},
	"caccia_lumini": {"name": "Cacciatore", "when": "uccisione", "do": "lumini", "n": 2,
		"desc": "ogni creatura sconfitta lascia 2 Lumini in più"},
	"aura_gelo": {"name": "Inverno addosso", "when": "aura", "r": 4, "do": "gela", "t": 0.8,
		"desc": "le creature entro 4 tessere rallentano"},
	"rigenera_fermo": {"name": "Radicato", "when": "se", "cond": "fermo", "do": "rigenera", "mult": 3.0,
		"desc": "stando fermo la Vita ricresce tre volte più in fretta"},
	"spine_vive": {"name": "Rovo vivo", "when": "ferita", "chance": 1.0, "do": "riflesso", "frac": 0.6,
		"desc": "chi ti ferisce riceve il 60% del colpo"},
	"profondo": {"name": "Talpa", "when": "se", "cond": "sottoterra", "do": "danno", "mult": 1.15,
		"desc": "sotto terra, colpi più forti del 15%"},
	"cielo_aperto": {"name": "Vento alle spalle", "when": "se", "cond": "superficie", "do": "corsa", "mult": 1.12,
		"desc": "in superficie corri più svelto"},
}


static func info(id: String) -> Dictionary:
	return EFFECTS.get(id, {})


## «Tizzone: un colpo su tre incendia…» per le schede.
static func line(id: String) -> String:
	var e := info(id)
	return "%s: %s" % [e.get("name", id), e.get("desc", "")] if not e.is_empty() else id
