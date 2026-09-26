class_name BiomeItemsData
extends RefCounted
## Gli oggetti dei biomi della voce 40 (Boschi di brina e Cenerarie): i materiali delle loro creature e ciò che se ne
## fa, più i Semi di mondo delle due specie nuove. Solo dati; stessi campi di `ItemsData` e `RecipesData`, uniti a
## tutti gli altri in `ItemsData.all()` e `RecipesData.all()`. I set in `SetsData` («brina» e «cenere»).

const ITEMS := {
	# materiali
	"vello_brina": {"name": "Vello di brina", "kind": "materiale", "icon": ["seta", "brina"], "desc": "Dal Cervo di brina: caldo dentro, gelato fuori."},
	"palco_brina": {"name": "Palco di brina", "kind": "materiale", "icon": ["artiglio", "brina"], "desc": "Un ramo dei palchi di un Cervo di brina. Non si scioglie mai."},
	"piuma_gelo": {"name": "Piuma del gelo", "kind": "materiale", "icon": ["penna", "brina"], "desc": "Dal Gufo del gelo: leggera come la neve che non cade."},
	"squama_brace": {"name": "Squama di salamandra", "kind": "materiale", "icon": ["scaglia", "cenere"], "desc": "Dalla schiena di una Salamandra di brace: ancora tiepida."},
	"cenere_viva": {"name": "Cenere viva", "kind": "materiale", "icon": ["polvere", "brace"], "desc": "Quello che resta di un Fatuo di cenere: una polvere che non si spegne."},
	# Boschi di brina: le vesti di brina (set «Passo di brina»), un arco e i suoi dardi, un amuleto
	"cappuccio_brina": {"name": "Cappuccio di brina", "kind": "elmo", "icon": ["elmo", "brina"], "tier": 3, "defense": 3, "acc": {"run": 1.05}, "desc": "Corsa +5%."},
	"manto_brina": {"name": "Manto di brina", "kind": "corazza", "icon": ["corazza", "brina"], "tier": 3, "defense": 5, "desc": "Vello di cervo cucito con piume del gelo."},
	"gambali_brina": {"name": "Gambali di brina", "kind": "gambali", "icon": ["gambali", "brina"], "tier": 3, "defense": 3, "acc": {"jump": 1.05}, "desc": "Salto +5%."},
	"arco_gelo": {"name": "Arco del gelo", "kind": "arco", "icon": ["arco", "brina"], "tier": 3, "damage": 16, "speed": 2.6, "knockback": 1.0, "multishot": 2, "desc": "Palchi di brina tesi con piume del gelo: due dardi a ogni tiro."},
	"dardo_gelo": {"name": "Dardo del gelo", "kind": "munizione", "icon": ["freccia", "brina"], "damage": 9, "stack": 999, "desc": "Una piuma del gelo in coda: vola dritto e punge freddo."},
	"amuleto_palco": {"name": "Amuleto del palco", "kind": "accessorio", "icon": ["amuleto", "brina"], "acc": {"run": 1.15, "jump": 1.1}, "desc": "Corsa +15%, salto +10%."},
	# Cenerarie: la corazza di squame (set «Cuore di brace»), una lama, un amuleto
	"elmo_squame": {"name": "Elmo di squame", "kind": "elmo", "icon": ["elmo", "cenere"], "tier": 3, "defense": 4, "acc": {"damage": 1.04}, "desc": "Danno +4%."},
	"corazza_squame": {"name": "Corazza di squame", "kind": "corazza", "icon": ["corazza", "cenere"], "tier": 3, "defense": 6, "desc": "Squame di salamandra su legnoferro."},
	"gambali_squame": {"name": "Gambali di squame", "kind": "gambali", "icon": ["gambali", "cenere"], "tier": 3, "defense": 4, "desc": "Pesanti, ma tengono il calore."},
	"lama_salamandra": {"name": "Lama della salamandra", "kind": "spada", "icon": ["spada", "cenere"], "tier": 3, "damage": 19, "speed": 2.5, "knockback": 2.2, "desc": "Una lama di squame ancora tiepide."},
	"cuore_brace": {"name": "Cuore di brace", "kind": "accessorio", "icon": ["amuleto", "brace"], "acc": {"damage": 1.08, "thorns": 6}, "desc": "Danno +8%; chi ti tocca si scotta (6)."},
	# i trofei (solo dalle creature rare di queste specie, vedi `TrophyItemsData.TROPHY_OF`) e ciò che se ne fa
	"cuore_brina": {"name": "Cuore di brina", "kind": "trofeo", "icon": ["essenza", "brina"], "desc": "Lo lasciano solo le creature rare di questa specie."},
	"occhio_gelo": {"name": "Occhio del gelo", "kind": "trofeo", "icon": ["occhio", "brina"], "desc": "Lo lasciano solo le creature rare di questa specie."},
	"coda_brace": {"name": "Coda di brace", "kind": "trofeo", "icon": ["artiglio", "brace"], "desc": "La lasciano solo le creature rare di questa specie."},
	"fiamma_fatua": {"name": "Fiamma fatua", "kind": "trofeo", "icon": ["essenza", "brace"], "desc": "La lasciano solo le creature rare di questa specie."},
	"corona_palchi": {"name": "Corona di palchi", "kind": "accessorio", "icon": ["corona", "brina"], "acc": {"run": 1.2, "fall_safe": true}, "desc": "Corsa +20%, nessuna ferita da caduta."},
	"occhio_notte_gelo": {"name": "Sguardo del gelo", "kind": "accessorio", "icon": ["occhio", "brina"], "acc": {"halo": 1.5, "stealth": 0.85}, "desc": "Alone più ampio; le creature ti notano più tardi."},
	"frusta_brace": {"name": "Frusta di coda", "kind": "spada", "icon": ["lama", "brace"], "tier": 4, "damage": 23, "speed": 3.2, "knockback": 1.5, "poison": true, "desc": "Una coda di salamandra che schiocca: ogni colpo brucia (avvelena)."},
	"lanterna_fatua": {"name": "Lanterna fatua", "kind": "accessorio", "icon": ["lanterna", "brace"], "acc": {"halo": 1.6, "magic": 1.1}, "desc": "Alone molto più ampio, incantesimi +10%."},
	# le due specie nuove dei Semi di mondo
	"seme_mondo_brina": {"name": "Seme di brina", "kind": "seme_mondo", "icon": ["seme", "brina"], "species": "brina", "stack": 9, "desc": "Un Seme di mondo nutrito di brina: dietro il suo portale, boschi gelati e cieli chiari."},
	"seme_mondo_cenere": {"name": "Seme di cenere", "kind": "seme_mondo", "icon": ["seme", "cenere"], "species": "cenere", "stack": 9, "desc": "Un Seme di mondo nutrito di cenere viva: dietro il suo portale, pianure di cenere e braci."},
}

const RECIPES := [
	{"out": "cappuccio_brina", "qty": 1, "in": {"vello_brina": 6, "piuma_gelo": 3}, "station": "telaio"},
	{"out": "manto_brina", "qty": 1, "in": {"vello_brina": 10, "piuma_gelo": 4}, "station": "telaio"},
	{"out": "gambali_brina", "qty": 1, "in": {"vello_brina": 8, "piuma_gelo": 3}, "station": "telaio"},
	{"out": "arco_gelo", "qty": 1, "in": {"palco_brina": 2, "piuma_gelo": 6, "legno": 10}, "station": "ceppo"},
	{"out": "dardo_gelo", "qty": 30, "in": {"piuma_gelo": 1, "legno": 2}, "station": "ceppo"},
	{"out": "amuleto_palco", "qty": 1, "in": {"palco_brina": 3, "vello_brina": 4, "lingotto_legnoferro": 3}, "station": "maglio"},
	{"out": "elmo_squame", "qty": 1, "in": {"squama_brace": 8, "lingotto_legnoferro": 4}, "station": "maglio"},
	{"out": "corazza_squame", "qty": 1, "in": {"squama_brace": 12, "lingotto_legnoferro": 6}, "station": "maglio"},
	{"out": "gambali_squame", "qty": 1, "in": {"squama_brace": 10, "lingotto_legnoferro": 5}, "station": "maglio"},
	{"out": "lama_salamandra", "qty": 1, "in": {"squama_brace": 8, "cenere_viva": 4, "lingotto_legnoferro": 5}, "station": "maglio"},
	{"out": "cuore_brace", "qty": 1, "in": {"cenere_viva": 10, "squama_brace": 3}, "station": "alambicco"},
	{"out": "corona_palchi", "qty": 1, "in": {"cuore_brina": 2, "palco_brina": 4}, "station": "maglio"},
	{"out": "occhio_notte_gelo", "qty": 1, "in": {"occhio_gelo": 2, "piuma_gelo": 6}, "station": "maglio"},
	{"out": "frusta_brace", "qty": 1, "in": {"coda_brace": 2, "squama_brace": 8}, "station": "maglio"},
	{"out": "lanterna_fatua", "qty": 1, "in": {"fiamma_fatua": 2, "cenere_viva": 8}, "station": "maglio"},
	{"out": "seme_mondo_brina", "qty": 1, "in": {"seme_mondo": 1, "vello_brina": 10, "piuma_gelo": 6}, "station": "altare"},
	{"out": "seme_mondo_cenere", "qty": 1, "in": {"seme_mondo": 1, "cenere_viva": 12, "squama_brace": 6}, "station": "altare"},
]
