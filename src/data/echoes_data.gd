class_name EchoesData
extends RefCounted
## Gli echi (Roadmap 36, voce 344): aprendo per la prima volta uno scrigno delle rovine, a volte, due sagome di luce
## rivivono per un attimo una scena del passato (le disegna `EchoFx`). Battute brevissime; chi parla si riconosce dal
## colore (quelli di `SowersData`). Il primo eco pronto (in quest'ordine) e non ancora visto; condizioni di `LoreConds`.
##   [id, [[chi, battuta], …], condizione]   chi = id di `SowersData.SOWERS` o «albero» (la voce del legno)

const CHANCE := 0.4                      # probabilità a ogni scrigno delle rovine aperto la prima volta
const COOLDOWN := 120.0                  # secondi tra un eco e l'altro
const LINE_TIME := 2.8                   # secondi per battuta
const ALBERO := {"name": "la voce del legno", "color": "#ffcf88"}

const ECHOES := [
	["conta", [["ilvenna", "Uno, due… ne manca uno."], ["odran", "Lascialo cadere. Ce ne sono tanti."],
		["ilvenna", "No. Questo lo tengo."]], {}],
	["vuoto", [["odran", "Si è mosso."], ["varek", "Il Vuoto non si muove."], ["odran", "Allora perché mi guarda?"]], {}],
	["canto", [["sareth", "Senti? Canta anche il buio."], ["ilvenna", "Non è un canto, Saréth. È fame."]],
		{"any": [{"stat": "stele", "n": 3}, {"stat": "guardiani", "n": 1}]}],
	["proposta", [["sareth", "Un mondo più grande di tutti."], ["varek", "Nato dal Vuoto?"],
		["sareth", "Nato da noi. Il Vuoto lo presta soltanto."]], {"any": [{"stat": "cronache", "n": 2}, {"sower": "ilvenna", "n": 1}]}],
	["nome", [["sareth", "Mi chiama per nome."], ["sareth", "Nessuno lo fa più."]],
		{"any": [{"stat": "cronache", "n": 3}, {"stat": "catene", "n": 2}]}],
	["bugia", [["varek", "Diremo che è caduto."], ["odran", "Diremo una bugia."], ["varek", "Diremo quello che serve."]],
		{"any": [{"stat": "catene", "n": 3}, {"nero": "si"}]}],
	["alberi", [["varek", "Se cantano insieme, la chiamata non si sente."], ["ilvenna", "E se si spezzano?"],
		["varek", "Non si spezzeranno."]], {"stat": "perduti", "n": 1}],
	["pezzi", [["odran", "Quanti pezzi?"], ["varek", "Uno per Cuore."], ["odran", "E che cosa resta di noi?"],
		["varek", "Abbastanza. Forse."]], {"sower": "varek", "n": 1}],
	["dimenticare", [["ilvenna", "Ti dimenticherò."], ["odran", "Lo so. Io no: io guardo."]], {"stat": "guardiani", "n": 3}],
	["radice", [["maesh", "Vado dove finisce la radice."], ["ilvenna", "Torna."], ["maesh", "Qualcuno tornerà. Non io."]],
		{"albero": 13}],
	["frutto", [["ilvenna", "Con che cosa l'hai fatto?"], ["albero", "Con quello che restava."], ["ilvenna", "Anche con lei?"]],
		{"nero": "si"}],
	["risposta", [["sareth", "Non ho mai voluto tutti i mondi."], ["sareth", "Volevo soltanto che qualcuno rispondesse."]],
		{"nero": "curato"}],
]


static func speaker(who: String) -> Dictionary:
	return ALBERO if who == "albero" else SowersData.SOWERS.get(who, ALBERO)
