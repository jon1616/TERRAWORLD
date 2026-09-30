class_name PanelButtons
extends Node
## Voce 101: i pulsanti dei pannelli in basso a sinistra, accanto al «?» dell'Enciclopedia, con le icone di Nano
## Banana: Bisaccia, Mappa, Erbario, Semenzaio, Mandria e il menu di pausa. Ognuno ha una scheda con il nome e il
## tasto; come il «?» si nascondono quando un pannello è aperto. Senza le icone non compaiono (restano i tasti).
## Due file: sotto, accanto al «?», i pannelli di tutti i giorni; sopra quelli delle Roadmap 17-25 (Quaderno,
## Pilastri, Arti, Atlante) e la pausa. In una fila sola arriverebbero a toccare la barra rapida.

const SIZE := 40.0
const GAP := 8.0
const ROWS := [Vector2(64, 840), Vector2(16, 792)]   # inizio di ogni fila: la prima a destra del «?» (16, 840)
const PER_ROW := 5

## [icona, nome, tasto (id di KeysData o testo), azione]
const BUTTONS := [
	["pannello_bisaccia", "Bisaccia", "bisaccia", "bisaccia"],
	["pannello_mappa", "Mappa", "mappa", "mappa"],
	["pannello_erbario", "Erbario", "erbario", "erbario"],
	["pannello_semenzaio", "Semenzaio: i mondi e il Genario", "semenzaio", "semenzaio"],
	["pannello_mandria", "Mandria", "mandria", "mandria"],
	["pannello_quaderno", "Quaderno delle parole", "quaderno", "quaderno"],
	["pannello_pilastri", "Libro dei pilastri", "pilastri", "pilastri"],
	["pannello_arti", "Le arti del combattimento", "arti", "arti"],
	["pannello_atlante", "Atlante dei mondi", "atlante", "atlante"],
	["pannello_opzioni", "Pausa e Opzioni", "", "pausa"],
]

var m: Node2D
var buttons: Array[Button] = []


func setup(main: Node2D) -> void:
	m = main
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not ArtLib.has("interfaccia", "pannello_bisaccia"):
		return
	for i in BUTTONS.size():
		var b: Array = BUTTONS[i]
		if not ArtLib.has("interfaccia", String(b[0])):
			continue
		var btn := Button.new()
		btn.icon = ArtLib.tex("interfaccia", String(b[0]))
		btn.expand_icon = true
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var row: Vector2 = ROWS[floori(i / float(PER_ROW))]
		btn.position = row + Vector2((i % PER_ROW) * (SIZE + GAP), 0)
		btn.size = Vector2(SIZE, SIZE)
		btn.focus_mode = Control.FOCUS_NONE
		btn.add_theme_constant_override("icon_max_width", 32)
		RecipeRow.style(btn, true, Color("#2f7a70"))
		var key := Keys.label(String(b[2])) if String(b[2]) != "" else "Esc"
		var tip := "%s (%s)" % [b[1], key]
		Tips.attach(btn, func() -> Variant: return TipCard.simple(tip))
		var what := String(b[3])
		btn.pressed.connect(func() -> void: press(what))
		m.hud.add_child(btn)
		buttons.append(btn)


## Apre (o chiude) il pannello del pulsante: come il suo tasto.
func press(what: String) -> void:
	match what:
		"bisaccia":
			m.hud.panel.toggle()
		"mappa":
			m.hud.map.toggle()
		"erbario":
			_overlay(ErbarioPanel)
		"semenzaio":
			_overlay(SemenzaioPanel)
		"mandria":
			_overlay(HerdPanel)
		"quaderno":
			_overlay(LexiconPanel)
		"pilastri":
			_overlay(PillarsPanel)
		"arti":
			_overlay(ArtsPanel)
		"atlante":
			_overlay(AtlasPanel)
		"pausa":
			m.game_options.open_menu()


func _overlay(kind: Variant) -> void:
	for o in m.hud.overlays:
		if is_instance_of(o, kind):
			if o.has_method("toggle"):
				o.toggle()
			elif o.visible:
				o.close()
			else:
				o.open()
			return


func _process(_dt: float) -> void:
	var show: bool = not m.hud.is_open()
	for b in buttons:
		b.visible = show
