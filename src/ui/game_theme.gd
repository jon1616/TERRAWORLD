class_name GameTheme
extends RefCounted
## Il tema del gioco (`Session._ready`): per ora i suggerimenti (tooltip), che con il tema di Godot avevano il fondo
## trasparente e sopra certi sfondi non si leggevano (appunto dell'utente, 25 set 2026). Riquadro scuro con il bordo
## turchese come la Bisaccia, testo chiaro con il contorno.
## Si scrive nel tema predefinito del motore: i suggerimenti compaiono in una finestrella a sé, che non eredita il
## tema della finestra principale (assegnarlo a `root.theme` non bastava).


static func apply() -> void:
	var t := ThemeDB.get_default_theme()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.02, 0.06, 0.07, 0.97)
	sb.border_color = Color("#2f7a70")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	t.set_stylebox("panel", "TooltipPanel", sb)
	t.set_color("font_color", "TooltipLabel", Color("#eafff6"))
	t.set_color("font_outline_color", "TooltipLabel", Color(0.01, 0.03, 0.04))
	t.set_constant("outline_size", "TooltipLabel", 2)
	t.set_font_size("font_size", "TooltipLabel", 15)
