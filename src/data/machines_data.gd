class_name MachinesData
extends RefCounted
## Roadmap 19 «La Linfa che scorre»: le macchine della rete (sorgenti, riserve, macchine, sensori, nodi). Solo dati;
## da ogni riga nascono la stazione (`StationsData.STATIONS`), l'oggetto e la ricetta; il disegno è `MachineArt`, le
## regole `Energy` e i comportamenti in `src/game/energy/machines/` (`MachineBehavior.make(bh)`).
##
## Campi:
##   name, size [w, h], desc
##   role    "sorgente" (dà pulsi), "riserva" (tiene gocce), "macchina" (chiede pulsi), "comando" (manda l'Impulso),
##           "nodo" (logica dell'Impulso)
##   bh      il comportamento; p = i suoi parametri
##   pulsi   sorgente: quanti ne dà al massimo; macchina: quanti ne chiede mentre lavora
##   colpo   gocce che costa un'azione (una porta che si apre)
##   cap, io riserva: gocce che tiene e pulsi al più in entrata e in uscita
##   light   la luce che fa quando lavora (colore)
##   look    la forma del disegno in `MachineArt`; icon = [forma, materiale] dell'icona
##   in, station, qty  la ricetta (al banco `station`)
##   tier    in che momento della partita arriva (per l'Enciclopedia e il bilancio): 1 inizio … 5 fine

const MACHINES := {
	# ---------------------------------------------------------------- sorgenti (voce 192)
	"tamburo_radice": {"name": "Tamburo di radice", "role": "sorgente", "size": [2, 1], "bh": "tamburo", "pulsi": 10,
		"look": "tamburo", "icon": ["banco", "legno"], "in": {"legno": 14, "lingotto_radicite": 2}, "station": "ceppo", "tier": 1,
		"desc": "Una sorgente: chi ci cammina sopra (tu, o una creatura della tua mandria) lo fa girare e dà 10 pulsi."},
	"foglia_lanterna": {"name": "Foglia-lanterna", "role": "sorgente", "size": [2, 2], "bh": "sole", "pulsi": 12,
		"look": "foglia", "icon": ["foglia", "linfa"], "in": {"legno": 8, "gelatina": 4, "fungo_luminoso": 2}, "station": "ceppo",
		"tier": 1, "desc": "Una sorgente: beve la luce del giorno, fino a 12 pulsi a mezzogiorno (di più nel cielo). Di notte e sotto un tetto niente."},
	# ---------------------------------------------------------------- le sorgenti del mondo (voce 195)
	"mulino_semi": {"name": "Mulino di semi", "role": "sorgente", "size": [2, 3], "bh": "mulino", "pulsi": 35,
		"look": "mulino", "icon": ["pappo", "legno"], "in": {"legno": 20, "lingotto_radicite": 4, "seta_radice": 4}, "station": "ceppo",
		"tier": 2, "desc": "Una sorgente: le pale di pappo girano con il vento. Più vento e più in alto, più pulsi (fino a 35; nel cielo di più). Sotto terra non c'è vento."},
	"ruota_acqua": {"name": "Ruota d'acqua", "role": "sorgente", "size": [2, 2], "bh": "ruota", "pulsi": 40,
		"look": "ruota", "icon": ["mola", "legnoferro"], "in": {"legno": 16, "lingotto_legnoferro": 3}, "station": "baccello_ardente",
		"tier": 2, "desc": "Una sorgente: l'acqua che la bagna la fa girare, 5 pulsi per ogni cella d'acqua che la tocca (ai lati o sopra), fino a 40; l'acqua che scorre il 50% in più."},
	"baccello_brace": {"name": "Baccello di brace", "role": "sorgente", "size": [2, 2], "bh": "fuoco", "pulsi": 40, "slots": 4,
		"fuel": {"legno": 20.0, "polvere_brace": 90.0, "pietra_brace": 60.0, "fungo_brace": 45.0, "tizzone_quieto": 240.0},
		"hot": 2, "look": "brace", "icon": ["fornace", "brace"], "in": {"ardesia": 20, "lingotto_legnoferro": 4, "polvere_brace": 4},
		"station": "baccello_ardente", "tier": 2,
		"desc": "Una sorgente: brucia ciò che le metti nella cassetta (legno, polvere e pietra di brace…) e dà 40 pulsi, il doppio accanto a un lago di brace. Brucia solo quando la rete ne ha bisogno."},
	"pozzo_linfa": {"name": "Pozzo di Linfa", "role": "sorgente", "size": [2, 2], "bh": "pozzo", "pulsi": 80,
		"look": "pozzo", "icon": ["goccia", "cristallo"], "sul_liquido": true, "in": {"lingotto_ambra": 4, "cristallo_linfa": 3, "seta_radice": 4},
		"station": "maglio", "tier": 3,
		"desc": "Una sorgente: posato sopra un lago di Linfa beve la Linfa del mondo, 80 pulsi senza combustibile (meno se il lago è piccolo)."},
	"nucleo_cristallo": {"name": "Nucleo di cristallo", "role": "sorgente", "size": [2, 2], "bh": "fuoco", "pulsi": 120, "slots": 4,
		"fuel": {"cristallo_linfa": 120.0}, "look": "cuore_cristallo", "icon": ["cristallo", "linfa"],
		"in": {"cristallo_linfa": 8, "lingotto_ambra": 4, "gelatina": 6}, "station": "maglio", "tier": 3,
		"desc": "Una sorgente: consuma un cristallo di Linfa ogni 2 minuti di lavoro e dà 120 pulsi. Brucia solo quando la rete ne ha bisogno."},
	# ---------------------------------------------------------------- le sorgenti speciali (voce 196)
	"ruota_mandria": {"name": "Ruota della mandria", "role": "sorgente", "size": [3, 2], "bh": "mandria", "pulsi": 45,
		"look": "ruota_mandria", "icon": ["mola", "legno"], "in": {"legno": 24, "lingotto_legnoferro": 3, "lana_muschio": 4},
		"station": "ceppo", "tier": 2,
		"desc": "Una sorgente: le creature della tua mandria che ci corrono dentro la fanno girare, 15 pulsi e 5 in più per ogni livello (fino a 45). Mettila nel recinto. Una creatura affamata non corre."},
	"parafulmine": {"name": "Parafulmine di radice", "role": "sorgente", "size": [1, 4], "bh": "parafulmine", "pulsi": 0,
		"bolt": 3000.0, "look": "parafulmine", "icon": ["bastone", "folgorite"], "in": {"folgorite": 3, "lingotto_legnoferro": 4, "legno": 6},
		"station": "maglio", "tier": 3,
		"desc": "Durante i temporali attira i fulmini vicini (a 40 tessere): ogni fulmine versa 3000 gocce nelle riserve della sua rete. Serve una riserva."},
	"radice_madre": {"name": "Radice-madre", "role": "sorgente", "size": [2, 2], "bh": "radice_madre", "pulsi": 250,
		"look": "radice_madre", "icon": ["radice_viaggio", "linfa"], "in": {"linfa_antica": 1, "lingotto_linfa": 3, "cristallo_linfa": 4},
		"station": "maglio", "tier": 4,
		"desc": "Una sorgente: posata accanto al Cuore del mondo (a 4 tessere) beve la sua Linfa. Se il Guardiano è stato curato dà 250 pulsi senza fine; se è stato sconfitto, il Cuore ferito ne dà 120."},
	"radice_giardino": {"name": "Radice del Giardino", "role": "sorgente", "size": [2, 2], "bh": "radice_giardino", "pulsi": 300,
		"look": "radice_madre", "icon": ["radice_viaggio", "muschio"], "in": {"legno": 20, "linfa_antica": 1, "gelatina": 6},
		"station": "ceppo", "tier": 2,
		"desc": "Una sorgente del Giardino: posata vicino all'Albero-Madre (a 14 tessere) beve dalle sue radici, 50 pulsi per ogni stadio dell'Albero (fino a 300). Solo nel Giardino."},
	# ---------------------------------------------------------------- riserve
	"otre_linfa": {"name": "Otre di Linfa", "role": "riserva", "size": [1, 1], "bh": "riserva", "cap": 3000, "io": 30,
		"look": "otre", "icon": ["goccia", "linfa"], "in": {"legno": 4, "gelatina": 6, "lingotto_radicite": 1}, "station": "ceppo",
		"tier": 1, "desc": "Una riserva: tiene 3000 gocce di Linfa (un pulso per un secondo è una goccia), ne prende e ne dà al più 30 al secondo."},
	"baccello_serbatoio": {"name": "Baccello-serbatoio", "role": "riserva", "size": [2, 2], "bh": "riserva", "cap": 20000, "io": 120,
		"look": "otre", "icon": ["goccia", "legnoferro"], "in": {"lingotto_legnoferro": 4, "gelatina": 12, "seta_radice": 2},
		"station": "baccello_ardente", "tier": 2,
		"desc": "Una riserva: tiene 20000 gocce, ne prende e ne dà al più 120 al secondo. Il giorno della Foglia-lanterna per le lampade della notte."},
	"cisterna_viva": {"name": "Cisterna viva", "role": "riserva", "size": [3, 3], "bh": "riserva", "cap": 150000, "io": 500,
		"look": "cisterna", "icon": ["goccia", "ambra"], "in": {"lingotto_ambra": 6, "cristallo_linfa": 6, "gelatina": 20},
		"station": "maglio", "tier": 3,
		"desc": "Una riserva: tiene 150000 gocce e ne dà fino a 500 al secondo. Per i parafulmini, le porte-seme e le macchine grandi."},
	# ---------------------------------------------------------------- macchine
	"lampada_baccello": {"name": "Lampada a baccello", "role": "macchina", "size": [1, 1], "bh": "lampada", "pulsi": 1,
		"light": Color(0.7, 1.5, 1.4), "look": "lampada", "icon": ["lanterna", "linfa"], "in": {"legno": 2, "gelatina": 1},
		"station": "ceppo", "qty": 2, "tier": 1,
		"desc": "Una luce che si accende e si spegne con l'Impulso (o sempre accesa, se nessun filo la tocca). Chiede 1 pulso."},
	# ---------------------------------------------------------------- luce e buio (voce 199)
	"faro_linfa": {"name": "Faro di Linfa", "role": "macchina", "size": [1, 2], "bh": "lampada", "pulsi": 25,
		"light": Color(2.6, 3.0, 2.8), "zona": ["quiete", 14, 1.0], "look": "faro", "icon": ["lanterna", "cristallo"],
		"in": {"cristallo_linfa": 3, "lingotto_legnoferro": 3, "gelatina": 4}, "station": "baccello_ardente", "tier": 2,
		"desc": "Una luce grande: attorno a lui (14 tessere) non nasce nessuna creatura, come con dieci torce. Chiede 25 pulsi."},
	"cupola_quiete": {"name": "Cupola di quiete", "role": "macchina", "size": [2, 2], "bh": "zona", "pulsi": 60,
		"zona": ["quiete", 30, 1.0], "look": "cupola", "icon": ["gemma", "cielo"],
		"in": {"lingotto_ambra": 5, "cristallo_linfa": 4, "seta_radice": 6}, "station": "maglio", "tier": 3,
		"desc": "Nel raggio di 30 tessere non nasce nessuna creatura (il Totem della quiete, a energia e più grande). Chiede 60 pulsi."},
	"insegna_linfa": {"name": "Insegna di Linfa", "role": "macchina", "size": [1, 1], "bh": "lampada", "pulsi": 1,
		"light": Color(0.7, 1.5, 1.4), "colori": true, "look": "insegna", "icon": ["gemma", "linfa"],
		"in": {"gelatina": 1, "legno": 1}, "station": "ceppo", "qty": 4, "tier": 1,
		"desc": "Una piccola luce da parete del colore che scegli nel pannello: per segnare le strade, le stanze, i circuiti. Chiede 1 pulso."},
	# ---------------------------------------------------------------- liquidi (voce 199)
	"pompa_radice": {"name": "Pompa di radice", "role": "macchina", "size": [1, 1], "bh": "pompa", "pulsi": 10,
		"look": "pompa", "icon": ["goccia", "legnoferro"], "in": {"lingotto_legnoferro": 3, "gelatina": 4, "legno": 4},
		"station": "baccello_ardente", "tier": 2,
		"desc": "Beve il liquido sotto di sé (fino a 3 tessere) e lo manda allo Sbocco di radice della stessa rete, ovunque sia: svuotare grotte, riempire vasche, portare la brace. Chiede 10 pulsi."},
	"sbocco_radice": {"name": "Sbocco di radice", "role": "macchina", "size": [1, 1], "bh": "sbocco", "pulsi": 0,
		"look": "sbocco", "icon": ["goccia", "legno"], "in": {"legno": 3, "gelatina": 2}, "station": "ceppo", "tier": 2,
		"desc": "Dove esce il liquido della Pompa di radice della stessa rete: lo versa nella tessera sotto di sé."},
	"chiusa_radice": {"name": "Chiusa di radice", "role": "macchina", "size": [1, 1], "bh": "chiusa", "pulsi": 0, "colpo": 5,
		"porta": true, "frame": true, "look": "chiusa", "icon": ["mattoni", "legnoferro"], "in": {"lingotto_legnoferro": 1, "ardesia": 4},
		"station": "baccello_ardente", "tier": 2,
		"desc": "Un blocco che ferma i liquidi (e chi passa): con un filo si apre finché è acceso, senza fili il clic destro la apre o la chiude. Ogni volta 5 gocce."},
	"irrigatore": {"name": "Irrigatore", "role": "macchina", "size": [1, 1], "bh": "irrigatore", "pulsi": 5,
		"look": "irrigatore", "icon": ["annaffiatoio", "legnoferro"], "in": {"lingotto_legnoferro": 2, "seta_radice": 2},
		"station": "baccello_ardente", "tier": 2,
		"desc": "Annaffia da solo le colture nel raggio di 8 tessere (crescono il doppio più in fretta), se ha acqua vicino (3 tessere). Chiede 5 pulsi."},
	"distillatore": {"name": "Distillatore", "role": "macchina", "size": [2, 2], "bh": "distillatore", "pulsi": 30, "slots": 4,
		"sul_liquido": true, "look": "distillatore", "icon": ["alambicco", "linfa"],
		"in": {"lingotto_ambra": 3, "cristallo_linfa": 2, "legno": 6}, "station": "maglio", "tier": 3,
		"desc": "Posato sopra un lago di Linfa ne distilla una Pozione di Linfa al minuto nella sua cassetta. Chiede 30 pulsi."},
	# ---------------------------------------------------------------- giardino e mandria (voce 199)
	"serra_linfa": {"name": "Serra di Linfa", "role": "macchina", "size": [2, 2], "bh": "zona", "pulsi": 20,
		"zona": ["germoglio", 10, 1.34], "look": "serra", "icon": ["foglia", "cristallo"],
		"in": {"lingotto_legnoferro": 3, "cristallo_linfa": 2, "legno": 10}, "station": "baccello_ardente", "tier": 2,
		"desc": "Le colture nel raggio di 10 tessere crescono il 60% più in fretta, anche sotto terra. Chiede 20 pulsi."},
	"falciatrice_radice": {"name": "Falciatrice di radice", "role": "macchina", "size": [2, 1], "bh": "mietitrice", "pulsi": 8, "slots": 12,
		"look": "mietitrice", "icon": ["falce", "legnoferro"], "in": {"lingotto_legnoferro": 3, "legno": 6}, "station": "baccello_ardente",
		"tier": 2, "desc": "Raccoglie le colture mature nel raggio di 8 tessere nella sua cassetta e ripianta un seme. Chiede 8 pulsi."},
	"mungitrice": {"name": "Mungitrice del recinto", "role": "macchina", "size": [1, 1], "bh": "mungitrice", "pulsi": 5, "slots": 12,
		"look": "mungitrice", "icon": ["vasetto", "legno"], "in": {"lingotto_legnoferro": 2, "legno": 4, "lana_muschio": 2},
		"station": "baccello_ardente", "tier": 2,
		"desc": "Porta nella sua cassetta ciò che la mandria produce nei recinti vicini (6 tessere): il recinto non si ferma più quando è pieno. Chiede 5 pulsi."},
	"culla_calda": {"name": "Culla calda", "role": "macchina", "size": [1, 1], "bh": "culla", "pulsi": 10, "light": Color(1.2, 0.8, 0.5),
		"look": "culla", "icon": ["cuore", "ambra"], "in": {"lingotto_ambra": 1, "lana_muschio": 3, "legno": 3}, "station": "maglio",
		"tier": 3, "desc": "Scalda le Incubatrici vicine (4 tessere): le uova si schiudono il 40% prima. Chiede 10 pulsi."},
	# ---------------------------------------------------------------- fabbricare e smistare (voce 200)
	"forno_linfa": {"name": "Forno a Linfa", "role": "macchina", "size": [2, 2], "bh": "fabbrica", "pulsi": 30, "slots": 12,
		"p": {"station": "baccello_ardente", "prefix": "lingotto_", "every": 4.0}, "light": Color(1.4, 0.8, 0.4),
		"look": "forno", "icon": ["fornace", "linfa"], "in": {"lingotto_legnoferro": 6, "ardesia": 20, "cristallo_linfa": 1},
		"station": "baccello_ardente", "tier": 2,
		"desc": "Fonde da solo: i minerali (o le polveri) che metti nella sua cassetta diventano lingotti, uno ogni 4 secondi. Chiede 30 pulsi."},
	"frantoio": {"name": "Frantoio", "role": "macchina", "size": [2, 2], "bh": "fabbrica", "pulsi": 40, "slots": 12,
		"p": {"station": "frantoio", "every": 3.0}, "look": "frantoio", "icon": ["mola", "ardesia"],
		"in": {"lingotto_legnoferro": 5, "ardesia": 30}, "station": "baccello_ardente", "tier": 2,
		"desc": "Frantuma i minerali della sua cassetta: 3 minerali danno 4 polveri, e le polveri fondono come i minerali (un terzo di metallo in più). Anche a mano, qui accanto. Chiede 40 pulsi."},
	"telaio_linfa": {"name": "Telaio a Linfa", "role": "macchina", "size": [2, 1], "bh": "fabbrica", "pulsi": 20, "slots": 12,
		"p": {"station": "telaio", "choose": true, "every": 6.0}, "look": "telaio_linfa", "icon": ["telaio", "linfa"],
		"in": {"lingotto_legnoferro": 3, "seta_radice": 6, "legno": 8}, "station": "telaio", "tier": 2,
		"desc": "Tesse da solo la ricetta del Telaio scelta nel pannello, con ciò che metti nella sua cassetta: una ogni 6 secondi. Chiede 20 pulsi."},
	"braccio_radice": {"name": "Braccio di radice", "role": "macchina", "size": [1, 1], "bh": "braccio", "pulsi": 5,
		"look": "braccio", "icon": ["uncino", "legno"], "in": {"legno": 4, "lingotto_radicite": 2, "seta_radice": 1},
		"station": "ceppo", "tier": 2,
		"desc": "Sposta un oggetto al secondo dal contenitore alla sua sinistra a quello alla sua destra (o il contrario: il pannello). Con un filtro solo quell'oggetto. Chiede 5 pulsi."},
	"smistatore": {"name": "Smistatore", "role": "macchina", "size": [1, 1], "bh": "smistatore", "pulsi": 3, "slots": 4,
		"look": "smistatore", "icon": ["cesta", "linfa"], "in": {"legno": 6, "lingotto_legnoferro": 1, "gelatina": 2},
		"station": "ceppo", "tier": 2,
		"desc": "Raccoglie gli oggetti a terra vicino a lui (2 tessere, anche dai nastri) e li manda nelle casse della sua rete: prima in quella che li ha già, poi in quella che raccoglie il loro tipo. Chiede 3 pulsi."},
	"nodo_casse": {"name": "Nodo delle casse", "role": "macchina", "size": [1, 1], "bh": "zona", "pulsi": 10,
		"look": "nodo_casse", "icon": ["chiave", "linfa"], "in": {"cristallo_linfa": 2, "lingotto_legnoferro": 2}, "station": "baccello_ardente",
		"tier": 2,
		"desc": "Quando sei vicino a lui, tutte le casse attaccate alla sua rete (una vena che le tocca) danno gli ingredienti per creare, anche lontane. Chiede 10 pulsi."},
	"magazzino_vivo": {"name": "Magazzino vivo", "role": "macchina", "size": [3, 3], "bh": "magazzino", "pulsi": 10, "slots": 105,
		"look": "magazzino", "icon": ["cesta", "ambra"], "in": {"lingotto_ambra": 4, "legno": 30, "seta_radice": 6}, "station": "maglio",
		"tier": 3, "desc": "Una cassa di 105 caselle che si riordina da sola quando ha i suoi pulsi. Chiede 10 pulsi."},
	# ---------------------------------------------------------------- difendersi (voce 202)
	"torretta_spine": {"name": "Torretta di spine", "role": "macchina", "size": [1, 2], "bh": "torretta", "pulsi": 10, "colpo": 5,
		"slots": 4, "frame": true, "look": "torretta", "icon": ["arco", "legnoferro"], "in": {"lingotto_legnoferro": 5, "legno": 8, "seta_radice": 4},
		"station": "baccello_ardente", "tier": 2,
		"desc": "Tira i dardi della sua cassetta alla creatura ostile più vicina che vede (18 tessere), uno ogni 0,8 secondi: danno del dardo + 8. Un filo la arma e la disarma. Chiede 10 pulsi e 5 gocce a dardo."},
	"siepe_spine": {"name": "Siepe di spine viva", "role": "macchina", "size": [1, 1], "bh": "rovo", "pulsi": 3, "look": "rovo", "frame": true,
		"icon": ["aculeo", "legno"], "in": {"legno": 3, "aculeo": 2}, "station": "ceppo", "qty": 4, "tier": 2,
		"desc": "Acceso punge le creature che lo attraversano (12 ogni mezzo secondo); spento (un filo, o il pannello) si ritira e lascia passare. Te non ti punge mai. Chiede 3 pulsi."},
	"campana_allarme": {"name": "Campana d'allarme", "role": "macchina", "size": [1, 2], "bh": "campana", "pulsi": 0, "colpo": 2,
		"look": "campana", "icon": ["lanterna", "ambra"], "in": {"lingotto_ambra": 1, "legno": 4}, "station": "baccello_ardente", "tier": 2,
		"desc": "A ogni impulso (o clic destro) suona: tutti gli abitanti del mondo corrono a casa per mezzo minuto. Con un Orecchio di muschio, suona da sola quando arrivano le creature."},
	"scudo_corteccia": {"name": "Scudo di corteccia", "role": "macchina", "size": [1, 1], "bh": "zona", "pulsi": 40,
		"look": "scudo", "icon": ["scudo", "legnoferro"], "in": {"lingotto_legnoferro": 4, "legno": 10, "gelatina": 2}, "station": "baccello_ardente",
		"tier": 2, "desc": "Durante un assedio le porte attaccate alla sua rete (una vena che le tocca) reggono il doppio dei morsi. Chiede 40 pulsi."},
	# ---------------------------------------------------------------- la Valvola di sfogo (voce 207)
	"valvola_sfogo": {"name": "Valvola di sfogo", "role": "macchina", "size": [1, 1], "bh": "valvola", "pulsi": 0, "look": "valvola",
		"icon": ["gel", "linfa"], "in": {"lingotto_legnoferro": 2, "linfa_rappresa": 3}, "station": "baccello_ardente", "tier": 2,
		"desc": "Su una rete, la protegge dalla Tempesta di Linfa: le vene tese non si spezzano. Non chiede pulsi."},
	# ---------------------------------------------------------------- le Centrali dei Seminatori (voce 206)
	# `gen`: solo del generatore (nessun oggetto, nessuna ricetta); `fixed`: non si riprendono.
	"cuore_centrale": {"name": "Cuore della centrale", "role": "sorgente", "size": [2, 2], "bh": "centrale", "pulsi": 80,
		"look": "cuore_cristallo", "gen": true, "fixed": true,
		"desc": "La sorgente di una Centrale dei Seminatori. Dorme: un cristallo di Linfa la risveglia, e poi dà 80 pulsi per sempre."},
	"cuore_centrale_vivo": {"name": "Cuore della centrale intatta", "role": "sorgente", "size": [2, 2], "bh": "centrale", "pulsi": 120,
		"p": {"desto": true}, "look": "cuore_cristallo", "gen": true, "fixed": true,
		"desc": "La sorgente della Centrale intatta: non si è mai spenta, e dà 120 pulsi."},
	"porta_centrale": {"name": "Porta della centrale", "role": "macchina", "size": [1, 2], "bh": "porta_centrale", "pulsi": 0, "colpo": 20,
		"porta": true, "frame": true, "look": "porta", "gen": true, "fixed": true,
		"desc": "La porta della sala interna di una Centrale: la apre il filo viola del nodo, se la rete ha Linfa."},
	"leva_centrale": {"name": "Leva della centrale", "role": "comando", "size": [1, 1], "bh": "leva", "look": "leva", "gen": true, "fixed": true,
		"desc": "Una delle tre leve di una Centrale dei Seminatori: il nodo E vuole tutte e tre alzate."},
	"nodo_centrale": {"name": "Nodo E della centrale", "role": "nodo", "size": [1, 1], "bh": "nodo", "p": {"kind": "e"}, "look": "nodo_e",
		"gen": true, "fixed": true,
		"desc": "Il nodo di una Centrale: accende il filo viola della porta quando i fili delle tre leve sono accesi."},
	# ---------------------------------------------------------------- i nodi della logica (voce 205)
	"nodo_e": {"name": "Nodo E (intreccio)", "role": "nodo", "size": [1, 1], "bh": "nodo", "p": {"kind": "e"}, "look": "nodo_e",
		"icon": ["tavoletta", "ambra"], "in": {"legno": 1, "lingotto_legnoferro": 1, "cristallo_linfa": 1}, "station": "maglio", "qty": 2, "tier": 2,
		"desc": "Un nodo della logica: la sua uscita è accesa solo se tutti i fili d'ingresso sono accesi. Ingressi e uscita sono fili di colori diversi (l'uscita si sceglie nel pannello)."},
	"nodo_o": {"name": "Nodo O (biforco)", "role": "nodo", "size": [1, 1], "bh": "nodo", "p": {"kind": "o"}, "look": "nodo_o",
		"icon": ["tavoletta", "linfa"], "in": {"legno": 1, "lingotto_legnoferro": 1, "cristallo_linfa": 1}, "station": "maglio", "qty": 2, "tier": 2,
		"desc": "Un nodo della logica: la sua uscita è accesa se almeno un ingresso è acceso, e ripete i colpi."},
	"nodo_non": {"name": "Nodo NON (rovescio)", "role": "nodo", "size": [1, 1], "bh": "nodo", "p": {"kind": "non"}, "look": "nodo_non",
		"icon": ["tavoletta", "brace"], "in": {"legno": 1, "lingotto_legnoferro": 1, "cristallo_linfa": 1}, "station": "maglio", "qty": 2, "tier": 2,
		"desc": "Un nodo della logica: la sua uscita è accesa quando nessun ingresso lo è. Con un Occhio di luce: le lampade di notte."},
	"nodo_ritardo": {"name": "Nodo del ritardo", "role": "nodo", "size": [1, 1], "bh": "nodo", "p": {"kind": "ritardo"}, "look": "nodo_ritardo",
		"icon": ["stella", "ambra"], "in": {"legno": 1, "lingotto_legnoferro": 1, "cristallo_linfa": 1}, "station": "maglio", "qty": 2, "tier": 2,
		"desc": "Un nodo della logica: ripete ciò che arriva dopo un'attesa (da un quarto di secondo a cinque secondi). Con i carillon, una melodia."},
	"nodo_contatore": {"name": "Nodo contatore", "role": "nodo", "size": [1, 1], "bh": "nodo", "p": {"kind": "contatore"}, "look": "nodo_contatore",
		"icon": ["seme", "ambra"], "in": {"legno": 1, "lingotto_legnoferro": 1, "cristallo_linfa": 1}, "station": "maglio", "qty": 2, "tier": 2,
		"desc": "Un nodo della logica: conta le accensioni e i colpi; al numero scelto (2-20) dà un colpo e riparte."},
	"nodo_memoria": {"name": "Nodo della memoria", "role": "nodo", "size": [1, 1], "bh": "nodo", "p": {"kind": "memoria"}, "look": "nodo_memoria",
		"icon": ["gemma", "iride"], "in": {"legno": 1, "lingotto_legnoferro": 1, "cristallo_linfa": 1}, "station": "maglio", "qty": 2, "tier": 2,
		"desc": "Un nodo della logica che ricorda: con un ingresso ogni accensione alterna l'uscita; con due, il colore più basso accende e l'altro spegne."},
	# ---------------------------------------------------------------- i sensori (voce 204)
	"occhio_luce": {"name": "Occhio di luce", "role": "comando", "size": [1, 1], "bh": "sensore", "p": {"kind": "luce"}, "look": "sensore_luce",
		"icon": ["occhio", "ambra"], "in": {"legno": 2, "cristallo_linfa": 1}, "station": "ceppo", "tier": 2,
		"desc": "Un sensore: accende i suoi fili di giorno (o di notte: il pannello). Con un NON le lampade si accendono al tramonto."},
	"orecchio_muschio": {"name": "Orecchio di muschio", "role": "comando", "size": [1, 1], "bh": "sensore", "p": {"kind": "orecchio"}, "look": "sensore_orecchio",
		"icon": ["fungo", "muschio"], "in": {"legno": 2, "fungo_luminoso": 2}, "station": "ceppo", "tier": 2,
		"desc": "Un sensore: accende i suoi fili quando una creatura ostile è vicina (6, 10 o 16 tessere). Con una Campana, l'allarme suona da solo."},
	"sensore_acqua": {"name": "Sensore d'acqua", "role": "comando", "size": [1, 1], "bh": "sensore", "p": {"kind": "acqua"}, "look": "sensore_acqua",
		"icon": ["goccia", "legno"], "in": {"legno": 2, "gelatina": 2}, "station": "ceppo", "tier": 2,
		"desc": "Un sensore: accende i suoi fili quando la sua tessera è piena almeno a metà di un liquido (qualunque, o solo acqua, Linfa, brace)."},
	"sensore_cassa": {"name": "Sensore di cassa", "role": "comando", "size": [1, 1], "bh": "sensore", "p": {"kind": "cassa"}, "look": "sensore_cassa",
		"icon": ["cesta", "legno"], "in": {"legno": 3, "lingotto_radicite": 1}, "station": "ceppo", "tier": 2,
		"desc": "Un sensore: guarda la cassa alla sua sinistra (o destra): acceso se ha qualcosa, se è piena o se è vuota. Per accendere il Baccello di brace solo quando c'è minerale."},
	"sensore_riserva": {"name": "Sensore di riserva", "role": "comando", "size": [1, 1], "bh": "sensore", "p": {"kind": "riserva"}, "look": "sensore_riserva",
		"icon": ["goccia", "ambra"], "in": {"lingotto_legnoferro": 1, "gelatina": 2}, "station": "baccello_ardente", "tier": 2,
		"desc": "Un sensore: acceso quando le riserve della sua rete sono sotto un quarto (o oltre tre quarti). Per accendere una sorgente di scorta."},
	"orologio_linfa": {"name": "Orologio di Linfa", "role": "comando", "size": [1, 1], "bh": "sensore", "p": {"kind": "orologio"}, "look": "sensore_orologio",
		"icon": ["stella", "linfa"], "in": {"lingotto_legnoferro": 1, "cristallo_linfa": 1}, "station": "baccello_ardente", "tier": 2,
		"desc": "Un comando che batte il tempo: un colpo sui suoi fili ogni 1, 5, 30 secondi, 2 o 10 minuti."},
	"barometro": {"name": "Barometro di radice", "role": "comando", "size": [1, 1], "bh": "sensore", "p": {"kind": "meteo"}, "look": "sensore_meteo",
		"icon": ["specchio", "cielo"], "in": {"legno": 3, "piuma_nubi": 1, "gelatina": 1}, "station": "ceppo", "tier": 2,
		"desc": "Un sensore: acceso con la pioggia, con il temporale o con qualunque maltempo. Chiude le porte del cortile, arma i parafulmini."},
	# ---------------------------------------------------------------- giocare e decorare (voce 203)
	"carillon_radice": {"name": "Carillon di radice", "role": "macchina", "size": [1, 1], "bh": "carillon", "pulsi": 0, "colpo": 1,
		"look": "carillon", "icon": ["stella", "ambra"], "in": {"lingotto_ambra": 1, "legno": 2}, "station": "maglio", "qty": 4, "tier": 2,
		"desc": "A ogni impulso suona la sua nota (nel pannello, otto note): tanti carillon, un Orologio e qualche Ritardo fanno una melodia."},
	"fontana_linfa": {"name": "Fontana di Linfa", "role": "macchina", "size": [2, 2], "bh": "lampada", "pulsi": 4, "bello": 6,
		"light": Color(0.6, 1.2, 1.2), "look": "fontana", "icon": ["goccia", "linfa"], "in": {"ardesia": 12, "cristallo_linfa": 1, "gelatina": 2},
		"station": "ceppo", "tier": 2,
		"desc": "Un getto di Linfa che brilla: nelle stanze conta come un mobile bello (+6). Chiede 4 pulsi."},
	"esposizione": {"name": "Teca d'esposizione", "role": "macchina", "size": [1, 2], "bh": "esposizione", "pulsi": 2, "slots": 1,
		"bello": 3, "light": Color(1.2, 1.1, 0.9), "look": "teca", "icon": ["gemma", "cielo"], "in": {"cristallo_linfa": 1, "legno": 4, "gelatina": 2},
		"station": "ceppo", "tier": 2,
		"desc": "Una teca illuminata per un trofeo o un oggetto unico: nelle stanze è un mobile bello, e i trofei contano per la sala dei trofei. Chiede 2 pulsi."},
	# ---------------------------------------------------------------- la Trivella (voce 201)
	"trivella_radice": {"name": "Trivella di radice", "role": "macchina", "size": [3, 2], "bh": "trivella", "pulsi": 80, "slots": 16,
		"light": Color(1.2, 1.0, 0.6), "look": "trivella", "icon": ["piccone", "legnoferro"],
		"in": {"lingotto_legnoferro": 8, "lingotto_ambra": 2, "cristallo_linfa": 2, "legno": 10}, "station": "maglio", "tier": 3,
		"desc": "Scava da sola un pozzo largo 3 verso il basso con il piccone che metti nella sua cassetta (la sua forza decide che cosa scava) e ci mette ciò che trova. Si ferma ai liquidi, ai Sigilli, a ciò che hai costruito, a cassetta piena; al più 600 blocchi al giorno. Chiede 80 pulsi."},
	# ---------------------------------------------------------------- muoversi (voce 198)
	"ascensore_bolla": {"name": "Ascensore a bolla", "role": "macchina", "size": [2, 1], "bh": "ascensore", "pulsi": 15,
		"frame": true, "look": "ascensore", "icon": ["goccia", "muschio"],
		"in": {"lingotto_legnoferro": 4, "gelatina": 8, "seta_radice": 4}, "station": "baccello_ardente", "tier": 2,
		"desc": "Sopra di lui sale una colonna di bolle fino al primo soffitto (al più 60 tessere): tenendo il salto ti porta su, tenendo giù scendi piano. Chiede 15 pulsi."},
	"nastro_vivo": {"name": "Nastro vivo", "role": "macchina", "size": [1, 1], "bh": "nastro", "pulsi": 2, "frame": true,
		"look": "nastro", "icon": ["foglia", "muschio"], "in": {"legno": 2, "seta_radice": 1, "gelatina": 1}, "station": "ceppo",
		"qty": 4, "tier": 1,
		"desc": "Un nastro di foglie che porta gli oggetti a terra, il doppio più svelto di quelli delle farm. Un impulso ne cambia il verso (anche il pannello). Chiede 2 pulsi."},
	"catapulta_spore": {"name": "Catapulta di spore", "role": "macchina", "size": [1, 1], "bh": "catapulta", "pulsi": 0, "colpo": 60,
		"frame": true, "look": "catapulta", "icon": ["fungo", "muschio"], "in": {"fungo_luminoso": 4, "gelatina": 6, "legno": 4},
		"station": "ceppo", "tier": 2,
		"desc": "A ogni impulso (o clic destro) lancia chi ci sta sopra: in su, a sinistra o a destra (nel pannello). Ogni lancio costa 60 gocce."},
	"porta_seme": {"name": "Porta-seme", "role": "macchina", "size": [2, 3], "bh": "porta_seme", "pulsi": 0, "colpo": 2000,
		"look": "porta_seme", "icon": ["radice_viaggio", "ambra"], "in": {"lingotto_ambra": 6, "cristallo_linfa": 6, "linfa_antica": 1},
		"station": "maglio", "tier": 3,
		"desc": "Clic destro: ti porta alla Porta-seme dello stesso canale (nel pannello), ovunque nel mondo. Ogni viaggio costa 2000 gocce della sua rete."},
	# ---------------------------------------------------------------- l'Impulso: comandi e porta (voce 193)
	"leva_radice": {"name": "Leva di radice", "role": "comando", "size": [1, 1], "bh": "leva", "look": "leva",
		"icon": ["chiave", "legno"], "in": {"legno": 3, "lingotto_radicite": 1}, "station": "ceppo", "tier": 1,
		"desc": "Un comando: clic destro la alza o la abbassa. Alzata accende i fili dell'Impulso che la toccano."},
	"pulsante_radice": {"name": "Pulsante di radice", "role": "comando", "size": [1, 1], "bh": "pulsante", "look": "pulsante",
		"icon": ["gemma", "linfa"], "in": {"legno": 2, "gelatina": 1}, "station": "ceppo", "tier": 1,
		"desc": "Un comando: clic destro manda un colpo sui fili che lo toccano (una porta si apre o si chiude, una lampada si alterna)."},
	"piastra_radice": {"name": "Piastra di radice", "role": "comando", "size": [1, 1], "bh": "piastra", "look": "piastra",
		"frame": true, "icon": ["mattoni", "legno"], "in": {"legno": 3, "ardesia": 2}, "station": "ceppo", "tier": 1,
		"desc": "Un comando: accesa finché qualcuno ci sta sopra (nel pannello: tu, le creature, o tutti)."},
	"porta_viva": {"name": "Porta di radice viva", "role": "macchina", "size": [1, 2], "bh": "porta", "pulsi": 0, "colpo": 20,
		"porta": true, "frame": true, "look": "porta", "icon": ["porta", "linfa"],
		"in": {"legno": 10, "lingotto_radicite": 2, "gelatina": 2}, "station": "ceppo", "tier": 1,
		"desc": "Una porta che le creature non aprono. Senza fili si apre da sola quando arrivi; con un filo la comanda l'Impulso. Ogni volta che si muove costa 20 gocce della sua rete."},
}


## I dati di una macchina ({} se l'id non è una macchina).

## La forma d'icona di una macchina: quella dipinta «macchina_<id>» (8 ott 2026, con il materiale dei dati) se c'è;
## altrimenti quella dei dati (spesso un segnaposto: l'icona dell'interfaccia allora resta il disegno del mondo, vedi
## `IconVariety.of_ui`). Si guarda il file: questo file di dati non nomina altre classi.
static func icon_of(id: String, icon: Array) -> Array:
	if ResourceLoader.exists("res://arte/icone48/macchina_%s.png" % id):
		return ["macchina_" + id, icon[1] if icon.size() > 1 else "linfa"]
	return icon

static func get_machine(id: String) -> Dictionary:
	return MACHINES.get(id, {})


static func is_machine(id: String) -> bool:
	return MACHINES.has(id)


static var _stations := {}


## Le stazioni delle macchine (le unisce `StationsData.STATIONS`).
static func stations() -> Dictionary:
	if _stations.is_empty():
		for id in MACHINES:
			var d: Dictionary = MACHINES[id]
			var e := {"name": d["name"], "size": d["size"], "item": id, "macchina": true}
			if d.has("slots"):
				e["slots"] = int(d["slots"])             # la cassetta del combustibile (la apre il pannello)
			if d.get("fixed", false):
				e["fixed"] = true                        # voce 206: le macchine delle Centrali non si riprendono
			if d.has("bello"):
				e["bello"] = int(d["bello"])             # la bellezza nelle stanze (`Rooms`)
			if d.get("porta", false):
				e["porta_rete"] = true                   # le tessere si chiudono e si aprono (vedi `MbPorta`)
			if d.get("sul_liquido", false):
				e["sul_liquido"] = true                  # si posa sopra un lago (il Pozzo di Linfa)
			if d.has("light"):
				e["light_rete"] = d["light"]           # la luce la accende la rete (`Energy`), non la stazione da sola
			_stations[id] = e
	return _stations


## Gli oggetti delle macchine (li unisce `ItemsData.all()`).
static func items() -> Dictionary:
	var out := {}
	for id in MACHINES:
		var d: Dictionary = MACHINES[id]
		if d.get("gen", false):
			continue                                     # solo del generatore
		out[id] = {"name": d["name"], "kind": "stazione", "cat": "rete", "place": id, "icon": icon_of(id, d.get("icon", ["banco", "linfa"])),
			"stack": 99, "desc": d["desc"]}
	return out


## Le ricette delle macchine (le unisce `RecipesData.all()`).
static func recipes() -> Array:
	var out := []
	for id in MACHINES:
		var d: Dictionary = MACHINES[id]
		if d.has("in"):
			out.append({"out": id, "qty": int(d.get("qty", 1)), "in": d["in"], "station": d.get("station", "ceppo")})
	return out
