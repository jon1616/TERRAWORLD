class_name GenBands
extends RefCounted
## Il lavoro di una passata diviso in fasce di righe, fatte su più processori insieme (pulizia del generatore, 28 set
## 2026: il mondo nasceva su un processore solo e le passate che guardano ogni tessera prendevano 9 secondi su 10).
## Le fasce sono sempre le stesse (ROWS righe), qualunque sia il numero di processori: chi usa il caso lo prende da
## `GenContext.band_rng(fascia)`, così il mondo esce identico fatto in parallelo o una fascia alla volta.
##
## Regole per chi scrive un lavoro a fasce:
## - legge solo copie locali (tiles, walls, surface…: `var tiles := w.tiles` prima), mai le proprietà di `World`;
## - scrive solo nelle righe della sua fascia, nella copia che restituisce (`slice` della fascia);
## - dentro un gruppo di thread (le prove generano più mondi insieme) le fasce si fanno una alla volta: aspettare un
##   gruppo di thread da dentro un altro può bloccare tutto.

const ROWS := 25


## Chiama job(fascia, y0, y1) per ogni fascia di righe [y0, y1) e restituisce i risultati in ordine di fascia.
static func run(h: int, job: Callable) -> Array:
	var n := ceili(h / float(ROWS))
	var out := []
	out.resize(n)
	var one := func(i: int) -> void:
		out[i] = job.call(i, i * ROWS, mini((i + 1) * ROWS, h))
	Par.each(n, one, "generatore a fasce")
	return out


## Rimette insieme le fasce: la parte k del risultato di ogni fascia, una dopo l'altra.
static func join(parts: Array, k: int) -> PackedByteArray:
	var all := PackedByteArray()
	for p in parts:
		all.append_array(p[k])
	return all


## Rimette insieme gli elenchi (per esempio i punti trovati) nell'ordine delle fasce.
static func join_list(parts: Array, k: int) -> Array:
	var all := []
	for p in parts:
		all.append_array(p[k])
	return all
