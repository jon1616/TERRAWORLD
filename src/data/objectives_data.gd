class_name ObjectivesData
extends RefCounted
## Gli obiettivi del Germogliato (voce 16): una strada di traguardi, dal primo albero al portale, sempre visibile
## (i prossimi tre, in alto a sinistra). Solo dati; li controlla `Objectives`.
##
## Campi: text (cosa fare), check (condizione), reward ({oggetto: quantità}).
## Condizioni:
##   {"item": id, "n": N}          avere almeno N di quell'oggetto nella Bisaccia (o indossato)
##   {"station": id}               una stazione di quel tipo piazzata nel mondo
##   {"stratum": k}                aver raggiunto lo strato k (`StrataData`)
##   {"stat": nome, "n": N}        un conteggio del personaggio (`Character.stats`: notti, scrigni, viaggi, cuore)
##   {"kill": id, "n": N}          creature di quel tipo sconfitte (dall'Erbario)
##   {"equip": tipo}               qualcosa indossato di quel tipo (accessorio, corazza…)
##   {"guardian": true}            il Guardiano del mondo sconfitto o curato
##   {"erbario": P}                Erbario completo almeno al P%

const LIST := [
	{"id": "legno", "text": "Abbatti un albero-lanterna e raccogli 10 legni", "check": {"item": "legno", "n": 10},
		"reward": {"seme_lanterna": 2}},
	{"id": "ceppo", "text": "Costruisci e piazza il Ceppo del Giardiniere", "check": {"station": "ceppo"},
		"reward": {"torcia": 5}},
	{"id": "torce", "text": "Tieni 15 torce nella Bisaccia", "check": {"item": "torcia", "n": 15},
		"reward": {"pozione_rugiada": 1}},
	{"id": "sottobosco", "text": "Scendi nel Sottobosco di radici", "check": {"stratum": 1},
		"reward": {"pozione_rugiada": 2}},
	{"id": "radicite", "text": "Scava 6 pezzi di radicite", "check": {"item": "minerale_radicite", "n": 6},
		"reward": {"torcia": 10}},
	{"id": "notte", "text": "Supera la tua prima notte", "check": {"stat": "notti", "n": 1},
		"reward": {"pozione_bagliore": 1}},
	{"id": "purifica", "text": "Purifica una zona avvizzita con un Seme di muschio", "check": {"stat": "purificate", "n": 1},
		"reward": {"seme_muschio": 5}},
	{"id": "baccello", "text": "Costruisci il Baccello ardente", "check": {"station": "baccello_ardente"},
		"reward": {"minerale_radicite": 6}},
	{"id": "lingotto", "text": "Fondi un lingotto di radicite", "check": {"item": "lingotto_radicite", "n": 1},
		"reward": {"dardo": 30}},
	{"id": "scrigno", "text": "Trova e apri uno Scrigno dei Seminatori", "check": {"stat": "scrigni", "n": 1},
		"reward": {"pozione_scorza": 1}},
	{"id": "accessorio", "text": "Indossa un accessorio", "check": {"equip": "accessorio"},
		"reward": {"polvere_brace": 3}},
	{"id": "maglio", "text": "Costruisci il Maglio dei Seminatori", "check": {"station": "maglio"},
		"reward": {"lingotto_legnoferro": 3}},
	{"id": "piccone_legnoferro", "text": "Forgia un piccone di legnoferro", "check": {"item": "piccone_legnoferro", "n": 1},
		"reward": {"pozione_rugiada": 2}},
	{"id": "caverne", "text": "Raggiungi le Caverne d'ardesia", "check": {"stratum": 2},
		"reward": {"torcia": 15}},
	{"id": "scarabeo", "text": "Sconfiggi uno scarabeo d'ardesia", "check": {"kill": "scarabeo_ardesia", "n": 1},
		"reward": {"pozione_scorza": 1}},
	{"id": "linfa", "text": "Raggiungi le Profondità della Linfa", "check": {"stratum": 3},
		"reward": {"pozione_bagliore": 2}},
	{"id": "cristalli", "text": "Raccogli 10 cristalli di Linfa", "check": {"item": "cristallo_linfa", "n": 10},
		"reward": {"lingotto_ambra": 3}},
	{"id": "fondo", "text": "Raggiungi il Fondo", "check": {"stratum": 4},
		"reward": {"rugiada_linfa": 1}},
	{"id": "cuore", "text": "Trova il Cuore del mondo (ascolta il battito)", "check": {"stat": "cuore", "n": 1},
		"reward": {"rugiada_linfa": 1}},
	{"id": "guardiano", "text": "Sconfiggi o cura il Guardiano del Cuore", "check": {"guardian": true},
		"reward": {"pozione_rugiada": 3}},
	{"id": "portale", "text": "Pianta il Seme di mondo e attraversa il portale", "check": {"stat": "viaggi", "n": 1},
		"reward": {"torcia": 20}},
	{"id": "erbario", "text": "Completa metà dell'Erbario", "check": {"erbario": 50},
		"reward": {"pozione_bagliore": 3}},
]

## Quanti obiettivi si vedono insieme.
const SHOWN := 3
