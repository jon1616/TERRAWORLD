class_name FloraData
extends RefCounted
## Alberi-lanterna e germogli: quanto sono robusti, cosa lasciano, quanto ci mettono a crescere.

## Robustezza di un albero: ogni colpo d'ascia toglie la forza dell'ascia (radicite 35 → 3 colpi).
const TREE_HP := 100
## Legno che cade da un albero abbattuto (minimo, massimo).
const WOOD := [6, 10]
## Probabilità che cada un seme d'albero-lanterna, e quanti.
const SEED_CHANCE := 0.6
const SEEDS := [1, 2]
## Secondi di gioco perché un germoglio diventi albero (minimo, massimo).
const GROW := [150.0, 300.0]
## Spazio libero sopra un germoglio perché possa crescere (tessere).
const ROOM := 7
## Area occupata da un albero rispetto alla sua base: colonne x-1..x+1, righe da y-HEIGHT a y.
const HEIGHT := 7
