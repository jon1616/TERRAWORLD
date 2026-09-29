class_name KeysData
## I comandi del gioco e i loro tasti di partenza (27 set 2026). I tasti scelti dal giocatore nelle Opzioni stanno in
## `Settings` ("tasti"); si leggono sempre con `Keys` (`Keys.pressed(evento, azione)`, `Keys.held(azione)`), mai con
## `KEY_…` scritto nel codice. Esc resta fisso (chiude i pannelli, apre la pausa); i clic del mouse pure.
## [azione, nome, tasti di partenza (codici di Godot), gruppo]

const ACTIONS := [
	["sinistra", "Vai a sinistra", [KEY_A, KEY_LEFT], "Muoversi"],
	["destra", "Vai a destra", [KEY_D, KEY_RIGHT], "Muoversi"],
	["salto", "Salta (tieni premuto: più in alto, plana)", [KEY_SPACE, KEY_W, KEY_UP], "Muoversi"],
	["giu", "Scendi dalle passerelle, sgancia il rampino", [KEY_S, KEY_DOWN], "Muoversi"],
	["schiva", "Schivata (serve un oggetto che la sblocca)", [KEY_C], "Muoversi"],
	["cavalca", "Sali o scendi dalla cavalcatura", [KEY_R], "Muoversi"],
	["bisaccia", "Apri la Bisaccia (e Creare)", [KEY_E, KEY_TAB], "Pannelli"],
	["mappa", "Mappa", [KEY_M], "Pannelli"],
	["minimappa", "Mostra o nascondi la minimappa", [KEY_N], "Pannelli"],
	["erbario", "Erbario", [KEY_L], "Pannelli"],
	["semenzaio", "Semenzaio (mondi e Genario)", [KEY_K], "Pannelli"],
	["mandria", "Mandria", [KEY_G], "Pannelli"],
	["enciclopedia", "Enciclopedia", [KEY_H], "Pannelli"],
	["aiuto", "Mostra o nascondi l'aiuto dei tasti", [KEY_F1], "Pannelli"],
	["filo", "Il filo da seguire: passa a un altro", [KEY_J], "Pannelli"],
	["quaderno", "Il Quaderno delle parole (la lingua dei Seminatori)", [KEY_U], "Pannelli"],
	["pilastri", "Il Libro dei pilastri (i gradi della maestria)", [KEY_P], "Pannelli"],
	["atlante", "L'Atlante (i mondi, le loro stelle e ciò che manca)", [KEY_O], "Pannelli"],
	["vista", "Potere: Vista della Linfa", [KEY_V], "Poteri"],
	["ponte", "Potere: Radici-ponte", [KEY_F], "Poteri"],
	["confronta", "Confronta nei suggerimenti", [KEY_SHIFT], "Altro"],
	["area", "Posa ad area (trascinando un blocco)", [KEY_CTRL], "Altro"],
	["riponi", "Riponi nelle casse vicine (quelle che hanno già l'oggetto o lo raccolgono)", [KEY_Q], "Altro"],
	["vena", "Scavo intelligente: solo lo stesso blocco (tienilo premuto all'inizio)", [KEY_SHIFT], "Altro"],
]


static func action(id: String) -> Array:
	for a in ACTIONS:
		if String(a[0]) == id:
			return a
	return []
