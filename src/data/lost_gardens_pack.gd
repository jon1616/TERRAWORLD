extends RefCounted
## Roadmap 21 «Le radici del cosmo»: ciò che vive nei quattro Giardini perduti (`LostGardensData`). Un pacchetto come
## quelli dei biomi (`BiomesData.PACK_FILES`): questo file non nomina altre classi.

const DATA := {
	"items": {
		# i materiali delle cure
		"goccia_acqua_viva": {"name": "Goccia d'acqua viva", "kind": "materiale", "icon": ["goccia", "lagunite"], "stack": 99,
			"desc": "L'acqua del lago del Giardino sommerso: non si ferma mai, nemmeno nella mano. L'Albero sommerso ne ha sete."},
		"ingranaggio_radice": {"name": "Ingranaggio di radice", "kind": "materiale", "icon": ["mola", "legnoferro"], "stack": 99,
			"desc": "Un dente di legnoferro cresciuto intorno a un nodo: le macchine selvatiche del Giardino di ferro ne sono fatte."},
		"bacca_rovo": {"name": "Bacca di rovo", "kind": "materiale", "icon": ["seme", "sanguinella"], "stack": 99,
			"desc": "Una bacca scura e dolce dei rovi del Giardino selvatico. I Cervi di rovo ne vanno pazzi; si può seminare."},
		"eco_parola": {"name": "Eco di parola", "kind": "materiale", "icon": ["essenza", "iride"], "stack": 99,
			"desc": "Una parola dei Seminatori rimasta sola nell'aria del Giardino muto, senza più chi la dica."},
		# i doni degli Alberi perduti guariti
		"amo_radice_cosmo": {"name": "Amo della radice del cosmo", "kind": "accessorio", "icon": ["aculeo", "lagunite"], "unique": true,
			"stack": 1, "acc": {"fish_luck": 0.4, "fish_size": 0.1, "respiro": 1.5},
			"story": "L'Albero sommerso lo fece crescere da una sua radice per ringraziarti.", "source": "dono dell'Albero sommerso guarito",
			"desc": "Fortuna di pesca +40%, pesci più grandi, respiro sott'acqua +50%."},
		"cuore_ingranaggio": {"name": "Cuore d'ingranaggio", "kind": "amuleto", "icon": ["amuleto", "legnoferro"], "unique": true,
			"stack": 1, "acc": {"dig": 1.2, "atk_speed": 1.06},
			"story": "Batteva dentro l'Albero di ferro. Adesso batte al tuo collo.", "source": "dono dell'Albero di ferro guarito",
			"desc": "Scavo +20%, colpi +6%."},
		"corno_selvatico": {"name": "Corno selvatico", "kind": "accessorio", "icon": ["artiglio", "muschio"], "unique": true,
			"stack": 1, "acc": {"run": 1.08, "regen": 1.1},
			"story": "Suonandolo, ogni bestia del Giardino selvatico alzava la testa.", "source": "dono dell'Albero selvatico guarito",
			"desc": "Corsa +8%, la Vita ricresce +10%."},
		"voce_ritrovata": {"name": "Voce ritrovata", "kind": "anello", "icon": ["anello", "iride"], "unique": true,
			"stack": 1, "acc": {"magic": 1.15, "luck": 0.08},
			"story": "Le prime parole che l'Albero muto disse di nuovo. Le chiuse in un anello per te.",
			"source": "dono dell'Albero muto guarito", "desc": "Incantesimi +15%, fortuna +8%."},
	},
}
